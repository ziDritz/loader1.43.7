class ank.battlefield.SpriteHandler
{
   /** @type MovieClip - Reference to the main battlefield display container */
   var _mcBattlefield;
   /** @type Object - Collection of all sprite data objects indexed by sprite ID */
   var _oSprites;
   /** @type MovieClip - Container holding all sprite MovieClip instances */
   var _mcContainer;
   /** @type Object - Global API reference for accessing application services and data */
   var api;
   /** @type Boolean - Flag indicating if all sprites are currently masked/hidden */
   var _bAllSpritesMasked;
   /** @type Function - Callback function to update position of carried sprites on each frame */
   var updateCarriedPosition;
   /** @type Function - Callback function invoked on each frame update */
   var onEnterFrame;
   /** @type Number - Default cell count threshold above which sprite movement uses run animation (static: 6) */
   static var DEFAULT_RUNLINIT = 6;
   /** @type Boolean - Global flag tracking whether player sprites are currently hidden (static) */
   static var _bPlayerSpritesHidden = false;
   /** @type Boolean - Global flag tracking whether monster tooltips are currently displayed (static) */
   static var _bShowMonstersTooltip = false;
   /**
    * Constructor - Initializes SpriteHandler with battlefield display references
    * @param b:MovieClip - Battlefield display container (mcBattlefield)
    * @param c:MovieClip - Container for sprite instances (mcContainer)
    * @param d:Object - Sprite data collection (oSprites)
    */
   function SpriteHandler(b, c, d)
   {
      // 1. Delegate to initialize() to set up field references
      this.initialize(b,c,d);
   }
   function get isShowingMonstersTooltip()
   {
      return ank.battlefield.SpriteHandler._bShowMonstersTooltip;
   }
   function get isPlayerSpritesHidden()
   {
      return ank.battlefield.SpriteHandler._bPlayerSpritesHidden;
   }
   /**
    * Initialize SpriteHandler internal references
    * Purpose: Set up battlefield container references and global API access
    * @param b:MovieClip - Battlefield display container
    * @param c:MovieClip - Sprite instances container
    * @param d:Object - Sprite data collection object
    * Data flow: Stores references for all sprite rendering and management operations
    */
   function initialize(b, c, d)
   {
      // 1. Store battlefield display reference
      this._mcBattlefield = b;
      // 2. Store sprite data collection
      this._oSprites = d;
      // 3. Store sprite MovieClip container
      this._mcContainer = c;
      // 4. Obtain global API reference for datacenter and gfx access
      this.api = _global.API;
   }
   /**
    * Remove all sprites from the battlefield
    * Purpose: Clear battlefield display by removing all active sprites
    * @param bKeepData:Boolean - If true, preserve sprite data in collection; if false, delete completely
    * Data flow: Iterates through all sprites and individually removes each one
    */
   function clear(bKeepData)
   {
      // 1. Retrieve all sprite data items from collection
      var oItems = this._oSprites.getItems();
      // 2. Iterate through each sprite in collection
      for(var k in oItems)
      {
         // 3. Remove sprite display and optionally clear data
         this.removeSprite(k,bKeepData);
      }
   }
   /**
    * Get all sprite data collection
    * Purpose: Access complete sprite data collection for iteration or inspection
    * Data flow: Returns entire sprites object collection
    */
   function getSprites()
   {
      return this._oSprites;
   }
   /**
    * Get sprite data object by ID
    * Purpose: Retrieve specific sprite data for manipulation
    * @param sID:String - Unique sprite identifier
    * Data flow: Returns single sprite data object from collection
    */
   function getSprite(sID)
   {
      return this._oSprites.getItemAt(sID);
   }
   /**
    * Get sprite MovieClip instance by ID
    * Purpose: Access sprite display object for rendering operations
    * @param sID:String - Unique sprite identifier
    * Data flow: Returns sprite MovieClip instance from container
    */
   function getSpriteMc(sID)
   {
      return this._mcContainer["sprite" + sID];
   }
   /**
    * Add sprite to battlefield display
    * Purpose: Create and attach sprite MovieClip with proper depth and initialization
    * @param sID:String - Unique sprite identifier
    * @param oSprite:Object - Optional sprite data (uses collection if undefined)
    * Data flow: Creates MovieClip from sprite template, applies ghost/invader filters, stores reference
    */
   function addSprite(sID, oSprite)
   {
      // 1. Determine if sprite data was provided or must be retrieved
      var bSpriteProvided = true;
      if(oSprite == undefined)
      {
         bSpriteProvided = false;
         // 2. Retrieve sprite data from collection by ID
         oSprite = this._oSprites.getItemAt(sID);
      }
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[addSprite] pas de spriteData");
         return undefined;
      }
      // 3. Add sprite data to collection if not already provided
      if(bSpriteProvided)
      {
         this._oSprites.addItemAt(sID,oSprite);
      }
      // 4. Remove any existing sprite MovieClip with same ID
      this._mcContainer["sprite" + sID].removeMovieClip();
      // 5. Calculate appropriate depth layer for sprite based on cell position
      var nDepth = ank.battlefield.utils.SpriteDepthFinder.getFreeDepthOnCell(this._mcBattlefield.mapHandler,this._oSprites,oSprite.cellNum,oSprite.allowGhostMode && this._mcBattlefield.bGhostView);
      var mcInstance = this._mcContainer.getInstanceAtDepth(nDepth);
      // 6. Attach sprite MovieClip to container with battlefield context
      oSprite.mc = this._mcContainer.attachClassMovie(oSprite.clipClass,"sprite" + sID,nDepth,[this._mcBattlefield,this._oSprites,oSprite]);
      // 7. Apply sprite visibility state based on current mask status
      oSprite.isHidden = this._bAllSpritesMasked;
      // 8. Apply ghost mode transparency if enabled
      if(oSprite.allowGhostMode && this._mcBattlefield.bGhostView)
      {
         oSprite.mc.setAlpha(ank.battlefield.Constants.GHOSTVIEW_SPRITE_ALPHA);
      }
      // 9. Apply invader area red glow filter if applicable
      if(dofus.Constants.INVADER_AREA)
      {
         if(!(oSprite instanceof dofus.datacenter.MonsterGroup || oSprite instanceof dofus.datacenter.Monster))
         {
            return undefined;
         }
         if(oSprite.gfxFileName == "1219" || oSprite.gfxFileName == "1635")
         {
            return undefined;
         }
         oSprite.mc.filters = [new flash.filters.GlowFilter(16711680,1,6,6,1,1,true,false)];
      }
   }
   /**
    * Add child sprite linked to parent sprite position
    * Purpose: Create dependent sprite that follows parent's movement and direction
    * @param sID:String - Child sprite identifier
    * @param sParentID:String - Parent sprite identifier to link to
    * @param nChildIndex:Number - Position index around parent (0-7, 8 directions)
    * @param oSprite:Object - Optional child sprite data object
    * Data flow: Establishes parent-child relationship, calculates cell position relative to parent
    */
   function addLinkedSprite(sID, sParentID, nChildIndex, oSprite)
   {
      // 1. Determine if sprite data provided or retrieve from collection
      var bSpriteProvided = true;
      // 2. Retrieve parent sprite data
      var oParentSprite = this._oSprites.getItemAt(sParentID);
      if(oParentSprite == undefined)
      {
         ank.utils.Logger.err("[addLinkedSprite] pas de spriteData parent");
         return undefined;
      }
      if(oSprite == undefined)
      {
         bSpriteProvided = false;
         oSprite = this._oSprites.getItemAt(sID);
      }
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[addLinkedSprite] pas de spriteData");
         return undefined;
      }
      // 3. Add child sprite data to collection if provided externally
      if(bSpriteProvided)
      {
         this._oSprites.addItemAt(sID,oSprite);
      }
      // 4. Calculate child cell position based on parent location and direction index
      var nCellNum = ank.battlefield.utils.Pathfinding.getArroundCellNum(this._mcBattlefield.mapHandler,oParentSprite.cellNum,oParentSprite.direction,nChildIndex);
      // 5. Check if calculated cell is walkable and active
      var oCellData = this._mcBattlefield.mapHandler.getCellData(nCellNum);
      if(oCellData.movement > 0 && oCellData.active)
      {
         oSprite.cellNum = nCellNum;
      }
      else
      {
         // 6. Use parent cell if target cell is blocked
         oSprite.cellNum = oParentSprite.cellNum;
      }
      // 7. Establish bidirectional parent-child relationship
      oSprite.linkedParent = oParentSprite;
      oSprite.childIndex = nChildIndex;
      oParentSprite.linkedChilds.addItemAt(sID,oSprite);
      // 8. Add sprite to battlefield display
      this.addSprite(sID);
   }
   /**
    * Make sprite carried by parent sprite
    * Purpose: Establish carrying relationship where child sprite moves with parent
    * @param sID:String - Child sprite identifier to be carried
    * @param sParentID:String - Parent sprite identifier that carries child
    * Data flow: Links sprites, updates animation to carrying pose, synchronizes position on each frame
    */
   function carriedSprite(sID, sParentID)
   {
      // 1. Retrieve child sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[carriedSprite] pas de spriteData");
         return undefined;
      }
      // 2. Retrieve parent sprite data
      var oParentSprite = this._oSprites.getItemAt(sParentID);
      if(oParentSprite == undefined)
      {
         ank.utils.Logger.err("[carriedSprite] pas de spriteData parent");
         return undefined;
      }
      // 3. Check if parent already carries another sprite
      if(!oParentSprite.hasCarriedChild())
      {
         // 4. Auto-calculate parent direction facing the carried sprite
         this.autoCalculateSpriteDirection(sParentID,oSprite.cellNum);
         // 5. Sync child sprite direction with parent
         oSprite.direction = oParentSprite.direction;
         // 6. Establish bidirectional carrying relationship
         oSprite.carriedParent = oParentSprite;
         oParentSprite.carriedChild = oSprite;
         // 7. Set parent animation to carrying pose
         var mcParent = oParentSprite.mc;
         mcParent.setAnim("carring",false,false);
         // 8. Setup frame-based position update callback for carried sprite
         mcParent.onEnterFrame = function()
         {
            this.updateCarriedPosition();
            delete this.onEnterFrame;
         };
         // 9. Move child sprite to parent cell location
         oSprite.mc.updateMap(oParentSprite.cellNum,oSprite.isVisible);
         oSprite.mc.setNewCellNum(oParentSprite.cellNum);
      }
   }
   /**
    * Remove visual effects applied by specific caster
    * Purpose: Clear temporary effect displays from fight when caster is removed
    * @param sCasterID:String - ID of sprite that applied effects to remove
    * Data flow: Iterates all sprites, delegates effect removal to each sprite's effect manager
    */
   function removeEffectsByCasterID(sCasterID)
   {
      // 1. Verify fight is active and caster ID is valid
      if(!this.api.datacenter.Game.isFight || sCasterID == undefined)
      {
         return undefined;
      }
      // 2. Retrieve all sprite items from collection
      var oItems = this.getSprites().getItems();
      // 3. Iterate through all sprites
      for(var sID in oItems)
      {
         var oSprite = oItems[sID];
         // 4. Get effects manager from sprite
         var oEffectsManager = oSprite.EffectsManager;
         // 5. Delegate effect removal to sprite's effects manager
         if(oEffectsManager != undefined)
         {
            oEffectsManager.removeEffectsByCasterID(sCasterID);
         }
      }
   }
   /**
    * Release carried sprite and place on ground
    * Purpose: Stop carrying relationship and animate sprite drop to new location
    * @param sID:String - Child sprite identifier to uncarry
    * @param nCellNum:Number - Destination cell for dropped sprite
    * @param bWithAnimation:Boolean - If true, animate carrying pose transition; if false, instant placement
    * @param oSeq:Object - Optional sequencer for action orchestration
    * Data flow: Breaks carrying relationship, sequences animation frames, updates sprite position
    */
   function uncarriedSprite(sID, nCellNum, bWithAnimation, oSeq)
   {
      // 1. Retrieve child sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[SpriteHandler] (addLinkedSprite) pas de spriteData parent");
         return undefined;
      }
      // 2. Verify sprite is actually being carried
      if(oSprite.hasCarriedParent())
      {
         // 3. Set carry-drop-in-progress flag
         oSprite.uncarryingSprite = true;
         var mcSprite = oSprite.mc;
         // 4. Retrieve parent sprite references
         var oParentSprite = oSprite.carriedParent;
         var mcParent = oParentSprite.mc;
         var oSequencer = oParentSprite.sequencer;
         // 5. Use provided sequencer or parent's sequencer
         if(oSeq == undefined)
         {
            oSeq = oSequencer;
         }
         else if(bWithAnimation)
         {
            oSeq.addAction(1,false,this,function(oParent, oSequencer)
            {
               oParent.sequencer = oSequencer;
            }
            ,[oParentSprite,oSeq]);
         }
         // 6. If animating, add carrying exit animation
         if(bWithAnimation)
         {
            oSeq.addAction(2,false,this,this.autoCalculateSpriteDirection,[oParentSprite.id,nCellNum]);
            oSeq.addAction(3,true,mcParent,mcParent.setAnim,["carringEnd",false,false]);
            mcParent.onEnterFrame = function()
            {
               this.updateCarriedPosition();
               delete this.onEnterFrame;
            };
         }
         // 7. Break carrying relationship
         oSeq.addAction(4,false,this,function(oChild, oParent)
         {
            oSprite.uncarryingSprite = false;
            oSprite.carriedParent = undefined;
            oParent.carriedChild = undefined;
         }
         ,[oSprite,oParentSprite]);
         // 8. Position child sprite on ground
         if(!oSeq.containsAction(mcSprite,mcSprite.setPosition))
         {
            oSeq.addAction(5,false,this,this.setSpritePosition,[oSprite.id,nCellNum]);
         }
         // 9. If parent not queued for removal, return to idle pose
         if(!oParentSprite.isPendingClearing)
         {
            oSeq.addAction(6,false,mcParent,mcParent.setAnim,["static",false,false]);
         }
         // 10. Restore parent sequencer if was temporarily swapped
         if(bWithAnimation)
         {
            oSeq.addAction(7,false,this,function(oParent, oSequencer)
            {
               oParent.sequencer = oSequencer;
            }
            ,[oParentSprite,oSequencer]);
         }
      }
   }
   /**
    * Equip mount on sprite
    * Purpose: Attach mount equipment and update sprite appearance
    * @param sID:String - Sprite identifier
    * @param oMount:Object - Mount object to equip
    * Data flow: Updates sprite data and triggers redraw to display mounted appearance
    */
   function mountSprite(sID, oMount)
   {
      // 1. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[mountSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      // 2. Update mount if different from current
      if(oMount != oSprite.mount)
      {
         // 3. Store new mount on sprite
         oSprite.mount = oMount;
         // 4. Redraw sprite to reflect mount graphics
         oSprite.mc.draw();
      }
   }
   /**
    * Remove mount from sprite
    * Purpose: Unequip mount and update sprite appearance
    * @param sID:String - Sprite identifier
    * Data flow: Clears mount reference and triggers redraw to display unmounted appearance
    */
   function unmountSprite(sID)
   {
      // 1. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[unmountSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      // 2. Clear mount if currently equipped
      if(oSprite.mount != undefined)
      {
         // 3. Remove mount reference
         oSprite.mount = undefined;
         // 4. Redraw sprite to reflect unmounted appearance
         oSprite.mc.draw();
      }
   }
   /**
    * Remove sprite from battlefield display
    * Purpose: Destroy sprite MovieClip and optionally clean up data structures
    * @param sID:String - Sprite identifier to remove
    * @param bKeepData:Boolean - If true preserve data in collection; if false, delete completely
    * Data flow: Cleans up display, relationships, and data; recursively removes child sprites
    */
   function removeSprite(sID, bKeepData)
   {
      // 1. Remove sprite speech bubble if present
      this._mcBattlefield.removeSpriteBubble(sID);
      // 2. Remove sprite overhead display (name, hp bar)
      this._mcBattlefield.hideSpriteOverHead(sID);
      // 3. Default to not keeping data if undefined
      if(bKeepData == undefined)
      {
         bKeepData = false;
      }
      // 4. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      // 5. Clear hover state if sprite was under mouse
      if(oSprite.mc != undefined && oSprite.mc == this.api.gfx.rollOverMcSprite)
      {
         this.api.gfx.onSpriteRollOut(oSprite.mc);
      }
      // 6. Recursively remove all child sprites linked to this sprite
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            this.removeSprite(oChildsItems[k].id,bKeepData);
         }
      }
      // 7. Remove reference from parent's child collection
      if(oSprite.hasParent && !bKeepData)
      {
         oSprite.linkedParent.linkedChilds.removeItemAt(sID);
      }
      // 8. Clear carried child if present
      if(oSprite.hasCarriedChild())
      {
         oSprite.carriedChild.carriedParent = undefined;
         oSprite.carriedChild.mc.setPosition();
      }
      // 9. Clear carried parent relationship if present
      if(oSprite.hasCarriedParent())
      {
         var oCarriedParent = oSprite.carriedParent;
         // 10. Clear parent's carried child reference
         oSprite.carriedParent.carriedChild = undefined;
         // 11. Return parent to idle animation
         oCarriedParent.mc.setAnim("static",false,false);
      }
      // 12. Reset MovieClip prototype and remove from container
      this._mcContainer["sprite" + sID].__proto__ = MovieClip.prototype;
      this._mcContainer["sprite" + sID].removeMovieClip();
      // 13. Remove sprite location registration from map
      this._mcBattlefield.mapHandler.getCellData(oSprite.cellNum).removeSpriteOnID(oSprite.id);
      // 14. Delete sprite data from collection if not keeping
      if(!bKeepData)
      {
         this._oSprites.removeItemAt(sID);
      }
   }
   /**
    * Hide or show individual sprite
    * Purpose: Control visibility of sprite and all its linked children
    * @param sID:String - Sprite identifier
    * @param bHide:Boolean - If true hide sprite, if false show sprite
    * Data flow: Recursively applies visibility state to sprite and all linked children
    */
   function hideSprite(sID, bHide)
   {
      // 1. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      // 2. Recursively hide all child sprites
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            this.hideSprite(oChildsItems[k].id,bHide);
         }
      }
      // 3. Apply visibility state to sprite MovieClip
      oSprite.mc.setVisible(!bHide);
   }
   /**
    * Show all sprites on battlefield
    * Purpose: Unmask all sprites that were previously masked
    * Data flow: Clears global mask flag and resets isHidden on all sprites
    */
   function unmaskAllSprites()
   {
      // 1. Clear global masking flag
      this._bAllSpritesMasked = false;
      // 2. Retrieve all sprite items
      var oItems = this._oSprites.getItems();
      // 3. Mark all sprites as visible
      for(var k in oItems)
      {
         oItems[k].isHidden = false;
      }
   }
   /**
    * Hide all sprites on battlefield
    * Purpose: Mask all sprites without removing them
    * Data flow: Sets global mask flag and hides all sprites
    */
   function maskAllSprites()
   {
      // 1. Set global masking flag
      this._bAllSpritesMasked = true;
      // 2. Retrieve all sprite items
      var oItems = this._oSprites.getItems();
      // 3. Mark all sprites as hidden
      for(var k in oItems)
      {
         oItems[k].isHidden = true;
      }
   }
   /**
    * Hide or show sprites by type during non-fight situations
    * Purpose: Selectively control visibility based on sprite type classification
    * @param bHide:Boolean - If true hide matching sprites, if false show them
    * @param nType:Number - Sprite type filter (1=characters, 2=NPCs, 3=monsters, 4=players, undefined=all)
    * Data flow: Filters sprites by type and applies visibility state with child sprite propagation
    */
   function hideSprites(bHide, nType)
   {
      // 1. Prevent hiding during active fight
      if(this.api.datacenter.Game.isFight)
      {
         return undefined;
      }
      // 2. Set global player sprite hidden state
      ank.battlefield.SpriteHandler._bPlayerSpritesHidden = bHide != undefined ? bHide : true;
      // 3. Retrieve all sprite items
      var oItems = this.getSprites().getItems();
      // 4. Iterate through all sprites
      for(var sID in oItems)
      {
         // 5. Skip player character
         if(sID != this.api.datacenter.Player.ID)
         {
            var oSprite = oItems[sID];
            var mcSprite = oSprite.mc;
            var oData = mcSprite.data;
            // 6. Determine if sprite matches type filter
            switch(nType)
            {
               case 1:
                  var bIsValidType = oData instanceof dofus.datacenter.Character || (oData instanceof dofus.datacenter.MonsterGroup || (oData instanceof dofus.datacenter.OfflineCharacter || oData instanceof dofus.datacenter.PrismSprite));
                  break;
               case 2:
                  bIsValidType = oData instanceof dofus.datacenter.NonPlayableCharacter;
                  break;
               case 3:
                  bIsValidType = oData instanceof dofus.datacenter.MonsterGroup;
                  break;
               case 4:
                  bIsValidType = oData instanceof dofus.datacenter.Character;
               default:
                  bIsValidType = true;
            }
            // 7. Apply visibility to matching sprites
            if(bIsValidType)
            {
               // 8. Hide or show main sprite
               oSprite.mc.setVisible(!bHide);
               // 9. Apply visibility to all linked child sprites
               var oChildsItems = oSprite.linkedChilds.getItems();
               for(var sChildID in oChildsItems)
               {
                  var oChildSprite = oChildsItems[sChildID];
                  oChildSprite.mc.setVisible(!bHide);
               }
            }
         }
      }
   }
   /**
    * Set sprite and children facing direction
    * Purpose: Update sprite direction for proper animation facing
    * @param sID:String - Sprite identifier
    * @param nDir:Number - Direction value (0-7 representing 8 directions)
    * Data flow: Sets direction on sprite and recursively on all linked children and carried child
    */
   function setSpriteDirection(sID, nDir)
   {
      // 1. Validate direction parameter
      if(nDir == undefined)
      {
         return undefined;
      }
      // 2. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteDirection] Sprite " + sID + " inexistant");
         return undefined;
      }
      // 3. Recursively set direction on linked child sprites
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            this.setSpriteDirection(oChildsItems[k].id,nDir);
         }
      }
      // 4. Set direction on carried child if present
      if(oSprite.hasCarriedChild())
      {
         oSprite.carriedChild.mc.setDirection(nDir);
      }
      // 5. Apply direction to sprite MovieClip
      var mcSprite = oSprite.mc;
      mcSprite.setDirection(nDir);
   }
   /**
    * Move sprite to new cell and set direction
    * Purpose: Update sprite position on map and handle linked children repositioning
    * @param sID:String - Sprite identifier
    * @param nCellNum:Number - Destination cell number
    * @param nDir:Number - Optional direction to face after movement
    * Data flow: Updates sprite location, recursively repositions children based on parent direction
    */
   function setSpritePosition(sID, nCellNum, nDir)
   {
      // 1. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         // 2. Log error if sprite not found
         ank.utils.Logger.err("[setSpritePosition] Sprite " + sID + " inexistant");
         return undefined;
      }
      // 3. Validate cell number is numeric
      if(_global.isNaN(Number(nCellNum)))
      {
         ank.utils.Logger.err("[setSpritePosition] cellNum n\'est pas un nombre");
         return undefined;
      }
      // 4. Validate cell number is within map bounds
      if(Number(nCellNum) < 0 || Number(nCellNum) > this._mcBattlefield.mapHandler.getCellCount())
      {
         ank.utils.Logger.err("[setSpritePosition] cellNum invalide");
         return undefined;
      }
      // 5. Reposition linked child sprites if present
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            // 6. Calculate child cell position relative to parent
            var nChildCellNum = ank.battlefield.utils.Pathfinding.getArroundCellNum(this._mcBattlefield.mapHandler,nCellNum,nDir,oChildsItems[k].childIndex);
            // 7. Set child sprite direction
            this.setSpriteDirection(oChildsItems[k].id,nChildCellNum,nDir);
         }
      }
      // 8. Remove any existing speech bubble
      this._mcBattlefield.removeSpriteBubble(sID);
      // 9. Update sprite direction if provided
      if(nDir != undefined)
      {
         oSprite.direction = nDir;
      }
      // 10. Move sprite MovieClip to new cell
      var mcSprite = oSprite.mc;
      mcSprite.setPosition(nCellNum);
   }
   /**
    * Stop sprite movement and return to idle pose
    * Purpose: Interrupt ongoing movement sequence and freeze sprite at cell
    * @param sID:String - Sprite identifier
    * @param oSeq:Object - Sequencer handling movement actions
    * @param nCellNum:Number - Cell to place sprite when stopping
    * Data flow: Clears sequence queue, marks sprite as not moving, returns to static pose
    */
   function stopSpriteMove(sID, oSeq, nCellNum)
   {
      // 1. Clear all pending movement actions from sequencer
      oSeq.clearAllNextActions();
      // 2. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      var mcSprite = oSprite.mc;
      // 3. Mark sprite as no longer moving
      oSprite.isInMove = false;
      // 4. Add action to position sprite at stop location
      oSeq.addAction(8,false,mcSprite,mcSprite.setPosition,[nCellNum]);
      // 5. Add action to set sprite to idle animation
      oSeq.addAction(9,false,mcSprite,mcSprite.setAnim,["static"]);
   }
   /**
    * Slide sprite to adjacent cell with optional animation
    * Purpose: Move sprite to nearby cell using pathfinding and optional custom animation
    * @param sID:String - Sprite identifier
    * @param cellNum:Number - Destination cell (-1 for invalid)
    * @param seq:Object - Sequencer for movement orchestration
    * @param sAnimation:String - Optional custom animation name (defaults to "static")
    * Data flow: Calculates path from current to destination cell, initiates movement sequence
    */
   function slideSprite(sID, cellNum, seq, sAnimation)
   {
      // 1. Check for invalid cell
      if(cellNum == -1)
      {
         return undefined;
      }
      // 2. Default animation to static if not provided
      if(sAnimation == undefined)
      {
         sAnimation = "static";
      }
      // 3. Retrieve sprite data
      var oSprite = this._oSprites.getItemAt(sID);
      // 4. Get current cell (use future cell if sprite is moving)
      var nCurrentCell = oSprite.futureCellNum == -1 ? oSprite.cellNum : oSprite.futureCellNum;
      // 5. Calculate direction from current to destination cell
      var nDirection = ank.battlefield.utils.Pathfinding.getDirectionFromCoordinates(this._mcBattlefield.mapHandler.getCellData(nCurrentCell).x,this._mcBattlefield.mapHandler.getCellData(nCurrentCell).rootY,this._mcBattlefield.mapHandler.getCellData(cellNum).x,this._mcBattlefield.mapHandler.getCellData(cellNum).rootY,false);
      // 6. Create path from current cell to destination
      var aPath = ank.battlefield.utils.Compressor.makeFullPath(this._mcBattlefield.mapHandler,[{num:nCurrentCell},{num:cellNum,dir:nDirection}]);
      // 7. Move sprite along calculated path
      if(aPath != undefined)
      {
         this.moveSprite(sID,aPath,seq,false,sAnimation);
      }
   }
   /**
    * Move sprite along path with walk/run/jump animations
    * Purpose: Animate sprite movement along cell path, handle child sprite movement, manage animation type selection\n    * @param sID:String - Sprite identifier\n    * @param path:Array - Array of cell numbers representing movement path\n    * @param seq:Object - Sequencer for action orchestration\n    * @param bClearSequencer:Boolean - If true, clear existing queued actions\n    * @param sAnimation:String - Optional custom animation for entire path\n    * @param bForcedRun:Boolean - Force run animation regardless of path length\n    * @param bForcedWalk:Boolean - Force walk animation instead of run\n    * @param runLimit:Number - Cell count threshold above which auto-switch to run (default 6)\n    * Data flow: Sequences movement to each cell, selects animation type based on path length and parameters, handles height-based jump detection\n    */\n   function moveSprite(sID, path, seq, bClearSequencer, sAnimation, bForcedRun, bForcedWalk, runLimit)\n   {\n      // 1. Remove any existing sprite dialog bubble\n      this._mcBattlefield.removeSpriteBubble(sID);\n      // 2. Remove overhead display (name/HP bar)\n      this._mcBattlefield.hideSpriteOverHead(sID);\n      // 3. Determine if custom animation provided\n      var bHasAnimation = sAnimation != undefined;\n      // 4. Set run limit threshold (default 6 cells)\n      if(runLimit == undefined)\n      {\n         runLimit = ank.battlefield.SpriteHandler.DEFAULT_RUNLINIT;\n      }\n      // 5. Default forced flags to false if undefined\n      if(bForcedRun == undefined)\n      {\n         bForcedRun = false;\n      }\n      if(bForcedWalk == undefined)\n      {\n         bForcedWalk = false;\n      }\n      // 6. Determine animation type based on parameters\n      var sAnimType = !bHasAnimation ? \"walk\" : \"slide\";\n      if(bForcedWalk)\n      {\n         sAnimType = \"walk\";\n      }\n      else if(bForcedRun)\n      {\n         sAnimType = \"run\";\n      }\n      else if(!bForcedRun && (!bForcedWalk && !bHasAnimation))\n      {\n         // 7. Auto-switch to run if path exceeds run limit\n         if(path.length > runLimit)\n         {\n            sAnimType = \"run\";\n         }\n      }\n      // 8. Retrieve sprite data\n      var oSprite = this._oSprites.getItemAt(sID);\n      if(oSprite == undefined)\n      {\n         ank.utils.Logger.err(\"[moveSprite] Sprite \" + sID + \" inexistant\");\n         return undefined;\n      }\n      // 9. Use sprite's sequencer if not provided\n      if(seq == undefined)\n      {\n         seq = oSprite.sequencer;\n      }\n      // 10. Set future cell to final path destination\n      var nFinalCell = Number(path[path.length - 1]);\n      oSprite.futureCellNum = nFinalCell;\n      // 11. Handle movement of linked child sprites\n      if(oSprite.hasChilds)\n      {\n         // 12. Calculate parent direction at path end\n         if(path.length > 1)\n         {\n            var nDirection = ank.battlefield.utils.Pathfinding.getDirection(this._mcBattlefield.mapHandler,Number(path[path.length - 2]),nFinalCell);\n         }\n         else\n         {\n            nDirection = oSprite.direction;\n         }\n         var oChildsItems = oSprite.linkedChilds.getItems();\n         for(var k in oChildsItems)\n         {\n            var oChildSprite = oChildsItems[k];\n            // 13. Calculate child destination relative to parent\n            var nChildCell = ank.battlefield.utils.Pathfinding.getArroundCellNum(this._mcBattlefield.mapHandler,nFinalCell,nDirection,oChildSprite.childIndex);\n            // 14. Find pathfinding route for child\n            var aChildPath = ank.battlefield.utils.Pathfinding.pathFind(this.api,this._mcBattlefield.mapHandler,oChildSprite.cellNum,nChildCell,{bAllDirections:oChildSprite.allDirections,bIgnoreSprites:true,bCellNumOnly:true,bWithBeginCellNum:true});\n            if(aChildPath != null)\n            {\n               // 15. Schedule child movement with delay (200ms more if not on same cell)\n               ank.utils.Timer.setTimer(oChildSprite,\"battlefield\",this,this.moveSprite,200 + (oSprite.cellNum != oChildSprite.cellNum ? 0 : 200),[oChildSprite.id,aChildPath,oChildSprite.sequencer,bClearSequencer,sAnimation,oChildSprite.forceRun || bForcedRun,oChildSprite.forceWalk || bForcedWalk,runLimit]);\n            }\n         }\n      }\n      var mcSprite = oSprite.mc;\n      // 16. Clear existing sequencer actions if requested\n      if(bClearSequencer)\n      {\n         if(!bHasAnimation)\n         {\n            seq.clearAllNextActions();\n         }\n      }\n      // 17. Initial action: move sprite to first path cell\n      seq.addAction(10,false,mcSprite,mcSprite.setPosition,[path[0]]);\n      var nPathLength = path.length;\n      var nLastIndex = nPathLength - 1;\n      // 18. Iterate through each cell in path\n      var i = 0;\n      while(i < nPathLength)\n      {\n         var sAnim = sAnimation;\n         var sAnimTypeMove = sAnimType;\n         var bJump = false;\n         // 19. Check for height difference requiring jump animation\n         if(i != 0)\n         {\n            var nPrevHeight = this._mcBattlefield.mapHandler.getCellHeight(path[i - 1]);\n            var nCurrHeight = this._mcBattlefield.mapHandler.getCellHeight(path[i]);\n            // 20. Enable jump if height difference significant\n            if(Math.abs(nPrevHeight - nCurrHeight) > 0.5 && this._mcBattlefield.isJumpActivate)\n            {\n               sAnim = \"jump\";\n               sAnimTypeMove = \"run\";\n               bJump = true;\n            }\n         }\n         // 21. Add action to move sprite to next cell with animation\n         seq.addAction(11,true,mcSprite,mcSprite.moveToCell,[seq,path[i],i == nLastIndex,sAnimTypeMove,sAnim,bJump]);\n         i = i + 1;\n      }\n      // 22. Execute all queued movement actions\n      seq.execute();\n   }
   /**
    * Toggle creature costume transformation for all characters
    * Purpose: Switch character graphics between normal and creature form
    * @param bEnabled:Boolean - If true enable creature mode, if false disable and restore
    * Data flow: Iterates characters, swaps graphics files and stores/restores mount data
    */
   function setCreatureMode(bEnabled)
   {
      // 1. Retrieve all sprite items from datacenter
      var oItems = this.api.datacenter.Sprites.getItems();
      // 2. Iterate through all sprites
      for(var k in oItems)
      {
         var oSprite = oItems[k];
         // 3. Filter to character type sprites only
         if(oSprite instanceof dofus.datacenter.Character)
         {
            // 4. Check if sprite can switch to creature mode
            if(oSprite.canSwitchInCreaturesMode)
            {
               // 5. Skip mutant characters
               if(!(oSprite instanceof dofus.datacenter.Mutant))
               {
                  // 6. Enable creature mode path
                  if(bEnabled)
                  {
                     // 7. Only transform if not already in creature mode
                     if(!oSprite.bInCreaturesMode)
                     {
                        // 8. Store original graphics file path
                        oSprite.tmpGfxFile = oSprite.gfxFile;
                        // 9. Store mounted animal reference
                        oSprite.tmpMount = oSprite.mount;
                        // 10. Remove mount while in creature form
                        oSprite.mount = undefined;
                        // 11. Build creature graphics path from guild ID
                        var sPath = dofus.Constants.CLIPS_PERSOS_PATH + oSprite.Guild + "2.swf";
                        // 12. Set sprite to creature graphics
                        this.api.gfx.setSpriteGfx(oSprite.id,sPath);
                        // 13. Mark as in creature mode
                        oSprite.bInCreaturesMode = true;
                     }
                  }
                  // 14. Disable creature mode path
                  else if(oSprite.bInCreaturesMode)
                  {
                     // 15. Restore mount reference
                     oSprite.mount = oSprite.tmpMount;
                     delete oSprite.tmpMount;
                     // 16. Restore original graphics filepath
                     var sRestorePath = oSprite.tmpGfxFile != undefined ? oSprite.tmpGfxFile : oSprite.gfxFile;
                     delete oSprite.tmpGfxFile;
                     // 17. Apply restored graphics
                     this.api.gfx.setSpriteGfx(oSprite.id,sRestorePath);
                     // 18. Mark as exited creature mode
                     oSprite.bInCreaturesMode = false;
                  }
               }
            }
         }
      }
   }
   /**
    * Reset all static visibility flags to defaults
    * Purpose: Clear global state flags when switching maps or scenes
    * Data flow: Resets player sprite hidden flag and monster tooltip flag to false
    */
   static function resetStaticVars()
   {
      // 1. Reset global player sprite visibility flag
      ank.battlefield.SpriteHandler._bPlayerSpritesHidden = false;
      // 2. Reset global monster tooltip display flag
      ank.battlefield.SpriteHandler._bShowMonstersTooltip = false;
   }
   /**
    * Toggle tooltip display for all monster groups
    * Purpose: Show or hide identification tooltips on monster sprites
    * @param bShow:Boolean - If true show tooltips, if false hide them
    * Data flow: Triggers rollOver/rollOut animations on monster sprites
    */
   function showMonstersTooltip(bShow)
   {
      // 1. Set global monster tooltip visibility flag
      ank.battlefield.SpriteHandler._bShowMonstersTooltip = bShow;
      // 2. Retrieve all sprite items from gfx handler
      var oItems = this.api.gfx.spriteHandler.getSprites().getItems();
      // 3. Iterate through all sprites
      for(var sID in oItems)
      {
         var mcSprite = oItems[sID].mc;
         var oData = mcSprite.data;
         // 4. Filter to monster group sprites only
         if(oData instanceof dofus.datacenter.MonsterGroup)
         {
            // 5. Show or hide tooltip based on flag
            if(bShow)
            {
               // 6. Trigger tooltip display via rollover
               mcSprite._rollOver(true);
            }
            else
            {
               // 7. Hide tooltip via rollout
               mcSprite._rollOut(true);
            }
         }
      }
   }
   function launchVisualEffect(sID, oEffectData, nCellNum, nDisplayType, mSpriteAnimation, sTargetID, oSpriteToHideDuringAnimation, bForceVisible, bBlocking)
   {
      if(bBlocking == undefined)
      {
         bBlocking = true;
      }
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[launchVisualEffect] Sprite " + sID + " inexistant");
         return undefined;
      }
      var oTargetSprite = this._oSprites.getItemAt(sTargetID);
      if(!this.api.electron.isWindowFocused)
      {
         oEffectData.file = undefined;
      }
      if(!bBlocking)
      {
         this._mcBattlefield.visualEffectHandler.addEffect(oSprite,oEffectData,nCellNum,nDisplayType,oTargetSprite,!bForceVisible ? oSprite.isVisible : true);
         return undefined;
      }
      var mcSprite = oSprite.mc;
      var oSequencer = oSprite.sequencer;
      var bShowEffect = true;
      switch(nDisplayType)
      {
         case 0:
            var bBlocking = false;
            bShowEffect = false;
            break;
         case 10:
         case 11:
            bBlocking = false;
            break;
         case 12:
            bBlocking = true;
            break;
         case 20:
         case 21:
            bBlocking = false;
            break;
         case 30:
         case 31:
            bBlocking = true;
            break;
         case 40:
         case 41:
            bBlocking = true;
            break;
         case 50:
            bBlocking = false;
            break;
         case 51:
            bBlocking = true;
            break;
         default:
            bBlocking = false;
            bShowEffect = false;
      }
      mcSprite._ACTION = oSprite;
      mcSprite._OBJECT = mcSprite;
      oSequencer.addAction(12,false,this,this.autoCalculateSpriteDirection,[sID,nCellNum]);
      if(mSpriteAnimation != undefined)
      {
         var sAnimType = typeof mSpriteAnimation;
         if(sAnimType == "object")
         {
            if(mSpriteAnimation.length < 3)
            {
               ank.utils.Logger.err("[launchVisualEffect] l\'anim " + mSpriteAnimation + " est invalide");
               return undefined;
            }
            var nSpriteCell = oSprite.cellNum;
            var oCellData = this._mcBattlefield.mapHandler.getCellData(nSpriteCell);
            var oTargetCellData = this._mcBattlefield.mapHandler.getCellData(nCellNum);
            var nDirection = ank.battlefield.utils.Pathfinding.getDirectionFromCoordinates(oCellData.x,oCellData.y,oTargetCellData.x,oTargetCellData.y,false);
            var aPath = ank.battlefield.utils.Compressor.makeFullPath(this._mcBattlefield.mapHandler,ank.battlefield.utils.Pathfinding.pathFind(this.api,this._mcBattlefield.mapHandler,nSpriteCell,nCellNum,{bIgnoreSprites:true,bWithBeginCellNum:true}));
            aPath.pop();
            var nLastCell = aPath[aPath.length - 1];
            this.moveSprite(sID,aPath,oSequencer,false,mSpriteAnimation[0],false,true);
            oSequencer.addAction(13,false,mcSprite,mcSprite.setDirection,[ank.battlefield.utils.Pathfinding.convertHeightToFourDirection(nDirection)]);
            oSequencer.addAction(14,true,mcSprite,mcSprite.setAnim,[mSpriteAnimation[1]]);
            if(bShowEffect)
            {
               oSequencer.addAction(15,bBlocking,this._mcBattlefield.visualEffectHandler,this._mcBattlefield.visualEffectHandler.addEffect,[oSprite,oEffectData,nCellNum,nDisplayType,oTargetSprite,!bForceVisible ? oSprite.isVisible : true]);
            }
            var aReturnPath = ank.battlefield.utils.Compressor.makeFullPath(this._mcBattlefield.mapHandler,ank.battlefield.utils.Pathfinding.pathFind(this.api,this._mcBattlefield.mapHandler,nLastCell,nSpriteCell,{bIgnoreSprites:true,bWithBeginCellNum:true}));
            this.moveSprite(sID,aReturnPath,oSequencer,false,mSpriteAnimation[2],false,true);
            oSequencer.addAction(16,false,mcSprite,mcSprite.setDirection,[nDirection]);
            if(mSpriteAnimation[3] != undefined)
            {
               oSequencer.addAction(17,false,mcSprite,mcSprite.setAnim,[mSpriteAnimation[3]]);
            }
            oSequencer.execute();
            return undefined;
         }
         if(sAnimType == "string")
         {
            oSequencer.addAction(18,true,mcSprite,mcSprite.setAnim,[mSpriteAnimation,false,true]);
         }
      }
      if(oSpriteToHideDuringAnimation != undefined)
      {
         oSequencer.addAction(19,false,this,this.hideSprite,[oSpriteToHideDuringAnimation.id,true]);
      }
      if(bShowEffect)
      {
         oSequencer.addAction(20,bBlocking,this._mcBattlefield.visualEffectHandler,this._mcBattlefield.visualEffectHandler.addEffect,[oSprite,oEffectData,nCellNum,nDisplayType,oTargetSprite,!bForceVisible ? oSprite.isVisible : true]);
      }
      if(oSpriteToHideDuringAnimation != undefined)
      {
         oSequencer.addAction(21,false,this,this.hideSprite,[oSpriteToHideDuringAnimation.id,false]);
      }
      oSequencer.execute();
   }
   function launchCarriedSprite(sID, oEffectData, nCellNum, nDisplayType)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      var oSequencer = oSprite.sequencer;
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[launchCarriedSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      var oCarriedChild = oSprite.carriedChild;
      this.launchVisualEffect(sID,oEffectData,nCellNum,nDisplayType,"carringThrow",undefined,oCarriedChild);
      oSequencer.addAction(22,false,this,this.setSpritePosition,[oCarriedChild.id,nCellNum]);
      this.uncarriedSprite(oCarriedChild.id,nCellNum,false,oSequencer);
      oSequencer.addAction(23,false,this,this.setSpriteAnim,[sID,"static"]);
      oSequencer.execute();
   }
   function autoCalculateSpriteDirection(sID, nCellNum)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[launchVisualEffect] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(oSprite.cellNum != nCellNum)
      {
         var mcSprite = oSprite.mc;
         var oCellData = this._mcBattlefield.mapHandler.getCellData(oSprite.cellNum);
         var oTargetCellData = this._mcBattlefield.mapHandler.getCellData(nCellNum);
         var nDirection = ank.battlefield.utils.Pathfinding.getDirectionFromCoordinates(oCellData.x,oCellData.rootY,oTargetCellData.x,oTargetCellData.rootY,false);
         mcSprite.setDirection(nDirection);
      }
   }
   function convertHeightToFourSpriteDirection(sID)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[convertHeightToFourSpriteDirection] Sprite " + sID + " inexistant");
         return undefined;
      }
      this.setSpriteDirection(sID,ank.battlefield.utils.Pathfinding.convertHeightToFourDirection(oSprite.direction));
   }
   function setSpriteAnim(sID, anim, bForced)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteAnim(" + anim + ")] Sprite " + sID + " inexistant");
         return undefined;
      }
      ank.utils.Timer.removeTimer(oSprite.mc,"battlefield");
      oSprite.mc.setAnim(anim,false,bForced);
   }
   function setSpriteLoopAnim(sID, anim, nTimer)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteLoopAnim] Sprite " + sID + " inexistant");
         return undefined;
      }
      ank.utils.Timer.removeTimer(oSprite.mc,"battlefield");
      oSprite.mc.setAnim(anim,true);
      ank.utils.Timer.setTimer(oSprite.mc,"battlefield",oSprite.mc,oSprite.mc.setAnim,nTimer,["static"]);
   }
   function setSpriteTimerAnim(sID, anim, bForced, nTimer)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteTimerAnim] Sprite " + sID + " inexistant");
         return undefined;
      }
      ank.utils.Timer.removeTimer(oSprite.mc,"battlefield");
      oSprite.mc.setAnimTimer(anim,false,bForced,nTimer);
   }
   function setSpriteGfx(sID, sFile)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteGfx] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(sFile != oSprite.gfxFile)
      {
         oSprite.gfxFile = sFile;
         oSprite.mc.draw();
         if(oSprite.allowGhostMode && this._mcBattlefield.bGhostView)
         {
            oSprite.mc.setAlpha(ank.battlefield.Constants.GHOSTVIEW_SPRITE_ALPHA);
         }
      }
   }
   function setSpriteColorTransform(sID, t)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteColorTransform] Sprite " + sID + " inexistant");
         return undefined;
      }
      oSprite.mc.setColorTransform(t);
   }
   function setSpriteAlpha(sID, nAlpha)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteAlpha] Sprite " + sID + " inexistant");
         return undefined;
      }
      oSprite.mc.setAlpha(nAlpha);
   }
   function addSpriteExtraClip(sID, clipFile, col, bTop)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[addSpriteExtraClip] Sprite " + sID + " inexistant");
         return undefined;
      }
      oSprite.mc.addExtraClip(clipFile,col,bTop);
   }
   function removeSpriteExtraClip(sID, bTop)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[removeSpriteExtraClip] Sprite " + sID + " inexistant");
         return undefined;
      }
      oSprite.mc.removeExtraClip(bTop);
   }
   function showSpritePoints(sID, value, col)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[showSpritePoints] Sprite " + sID + " inexistant");
         return undefined;
      }
      oSprite.mc.showPoints(value,col);
   }
   function setSpriteGhostView(bool)
   {
      var oItems = this._oSprites.getItems();
      for(var k in oItems)
      {
         var oSprite = this._oSprites.getItemAt(k);
         oSprite.mc.setGhostView(oSprite.allowGhostMode && bool);
      }
   }
   function selectSprite(sID, bSelect)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[selectSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            this.selectSprite(oChildsItems[k].id,bSelect);
         }
      }
      oSprite.mc.select(bSelect);
   }
   function setSpriteScale(sID, nScaleX, nScaleY)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[selectSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      oSprite.mc.setScale(nScaleX,nScaleY);
   }
}
