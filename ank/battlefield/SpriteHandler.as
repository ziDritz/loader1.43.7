class ank.battlefield.SpriteHandler
{
   var _mcBattlefield;
   var _oSprites;
   var _mcContainer;
   var api;
   var _bAllSpritesMasked;
   var updateCarriedPosition;
   var onEnterFrame;
   static var DEFAULT_RUNLINIT = 6;
   static var _bPlayerSpritesHidden = false;
   static var _bShowMonstersTooltip = false;
   function SpriteHandler(b, c, d)
   {
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
   function initialize(b, c, d)
   {
      this._mcBattlefield = b;
      this._oSprites = d;
      this._mcContainer = c;
      this.api = _global.API;
   }
   function clear(bKeepData)
   {
      var oItems = this._oSprites.getItems();
      for(var k in oItems)
      {
         this.removeSprite(k,bKeepData);
      }
   }
   function getSprites()
   {
      return this._oSprites;
   }
   function getSprite(sID)
   {
      return this._oSprites.getItemAt(sID);
   }
   function getSpriteMc(sID)
   {
      return this._mcContainer["sprite" + sID];
   }
   function addSprite(sID, oSprite)
   {
      var bSpriteProvided = true;
      if(oSprite == undefined)
      {
         bSpriteProvided = false;
         oSprite = this._oSprites.getItemAt(sID);
      }
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[addSprite] pas de spriteData");
         return undefined;
      }
      if(bSpriteProvided)
      {
         this._oSprites.addItemAt(sID,oSprite);
      }
      this._mcContainer["sprite" + sID].removeMovieClip();
      var nDepth = ank.battlefield.utils.SpriteDepthFinder.getFreeDepthOnCell(this._mcBattlefield.mapHandler,this._oSprites,oSprite.cellNum,oSprite.allowGhostMode && this._mcBattlefield.bGhostView);
      var mcInstance = this._mcContainer.getInstanceAtDepth(nDepth);
      oSprite.mc = this._mcContainer.attachClassMovie(oSprite.clipClass,"sprite" + sID,nDepth,[this._mcBattlefield,this._oSprites,oSprite]);
      oSprite.isHidden = this._bAllSpritesMasked;
      if(oSprite.allowGhostMode && this._mcBattlefield.bGhostView)
      {
         oSprite.mc.setAlpha(ank.battlefield.Constants.GHOSTVIEW_SPRITE_ALPHA);
      }
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
   function addLinkedSprite(sID, sParentID, nChildIndex, oSprite)
   {
      var bSpriteProvided = true;
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
      if(bSpriteProvided)
      {
         this._oSprites.addItemAt(sID,oSprite);
      }
      var nCellNum = ank.battlefield.utils.Pathfinding.getArroundCellNum(this._mcBattlefield.mapHandler,oParentSprite.cellNum,oParentSprite.direction,nChildIndex);
      var oCellData = this._mcBattlefield.mapHandler.getCellData(nCellNum);
      if(oCellData.movement > 0 && oCellData.active)
      {
         oSprite.cellNum = nCellNum;
      }
      else
      {
         oSprite.cellNum = oParentSprite.cellNum;
      }
      oSprite.linkedParent = oParentSprite;
      oSprite.childIndex = nChildIndex;
      oParentSprite.linkedChilds.addItemAt(sID,oSprite);
      this.addSprite(sID);
   }
   function carriedSprite(sID, sParentID)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[carriedSprite] pas de spriteData");
         return undefined;
      }
      var oParentSprite = this._oSprites.getItemAt(sParentID);
      if(oParentSprite == undefined)
      {
         ank.utils.Logger.err("[carriedSprite] pas de spriteData parent");
         return undefined;
      }
      if(!oParentSprite.hasCarriedChild())
      {
         this.autoCalculateSpriteDirection(sParentID,oSprite.cellNum);
         oSprite.direction = oParentSprite.direction;
         oSprite.carriedParent = oParentSprite;
         oParentSprite.carriedChild = oSprite;
         var mcParent = oParentSprite.mc;
         mcParent.setAnim("carring",false,false);
         mcParent.onEnterFrame = function()
         {
            this.updateCarriedPosition();
            delete this.onEnterFrame;
         };
         oSprite.mc.updateMap(oParentSprite.cellNum,oSprite.isVisible);
         oSprite.mc.setNewCellNum(oParentSprite.cellNum);
      }
   }
   function removeEffectsByCasterID(sCasterID)
   {
      if(!this.api.datacenter.Game.isFight || sCasterID == undefined)
      {
         return undefined;
      }
      var oItems = this.getSprites().getItems();
      for(var sID in oItems)
      {
         var oSprite = oItems[sID];
         var oEffectsManager = oSprite.EffectsManager;
         if(oEffectsManager != undefined)
         {
            oEffectsManager.removeEffectsByCasterID(sCasterID);
         }
      }
   }
   function uncarriedSprite(sID, nCellNum, bWithAnimation, oSeq)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[SpriteHandler] (addLinkedSprite) pas de spriteData parent");
         return undefined;
      }
      if(oSprite.hasCarriedParent())
      {
         oSprite.uncarryingSprite = true;
         var mcSprite = oSprite.mc;
         var oParentSprite = oSprite.carriedParent;
         var mcParent = oParentSprite.mc;
         var oSequencer = oParentSprite.sequencer;
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
         oSeq.addAction(4,false,this,function(oChild, oParent)
         {
            oSprite.uncarryingSprite = false;
            oSprite.carriedParent = undefined;
            oParent.carriedChild = undefined;
         }
         ,[oSprite,oParentSprite]);
         if(!oSeq.containsAction(mcSprite,mcSprite.setPosition))
         {
            oSeq.addAction(5,false,this,this.setSpritePosition,[oSprite.id,nCellNum]);
         }
         if(!oParentSprite.isPendingClearing)
         {
            oSeq.addAction(6,false,mcParent,mcParent.setAnim,["static",false,false]);
         }
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
   function mountSprite(sID, oMount)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[mountSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(oMount != oSprite.mount)
      {
         oSprite.mount = oMount;
         oSprite.mc.draw();
      }
   }
   function unmountSprite(sID)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[unmountSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(oSprite.mount != undefined)
      {
         oSprite.mount = undefined;
         oSprite.mc.draw();
      }
   }
   function removeSprite(sID, bKeepData)
   {
      this._mcBattlefield.removeSpriteBubble(sID);
      this._mcBattlefield.hideSpriteOverHead(sID);
      if(bKeepData == undefined)
      {
         bKeepData = false;
      }
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite.mc != undefined && oSprite.mc == this.api.gfx.rollOverMcSprite)
      {
         this.api.gfx.onSpriteRollOut(oSprite.mc);
      }
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            this.removeSprite(oChildsItems[k].id,bKeepData);
         }
      }
      if(oSprite.hasParent && !bKeepData)
      {
         oSprite.linkedParent.linkedChilds.removeItemAt(sID);
      }
      if(oSprite.hasCarriedChild())
      {
         oSprite.carriedChild.carriedParent = undefined;
         oSprite.carriedChild.mc.setPosition();
      }
      if(oSprite.hasCarriedParent())
      {
         var oCarriedParent = oSprite.carriedParent;
         oSprite.carriedParent.carriedChild = undefined;
         oCarriedParent.mc.setAnim("static",false,false);
      }
      this._mcContainer["sprite" + sID].__proto__ = MovieClip.prototype;
      this._mcContainer["sprite" + sID].removeMovieClip();
      this._mcBattlefield.mapHandler.getCellData(oSprite.cellNum).removeSpriteOnID(oSprite.id);
      if(!bKeepData)
      {
         this._oSprites.removeItemAt(sID);
      }
   }
   function hideSprite(sID, bHide)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            this.hideSprite(oChildsItems[k].id,bHide);
         }
      }
      oSprite.mc.setVisible(!bHide);
   }
   function unmaskAllSprites()
   {
      this._bAllSpritesMasked = false;
      var oItems = this._oSprites.getItems();
      for(var k in oItems)
      {
         oItems[k].isHidden = false;
      }
   }
   function maskAllSprites()
   {
      this._bAllSpritesMasked = true;
      var oItems = this._oSprites.getItems();
      for(var k in oItems)
      {
         oItems[k].isHidden = true;
      }
   }
   function hideSprites(bHide, nType)
   {
      if(this.api.datacenter.Game.isFight)
      {
         return undefined;
      }
      ank.battlefield.SpriteHandler._bPlayerSpritesHidden = bHide != undefined ? bHide : true;
      var oItems = this.getSprites().getItems();
      for(var sID in oItems)
      {
         if(sID != this.api.datacenter.Player.ID)
         {
            var oSprite = oItems[sID];
            var mcSprite = oSprite.mc;
            var oData = mcSprite.data;
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
            if(bIsValidType)
            {
               oSprite.mc.setVisible(!bHide);
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
   function setSpriteDirection(sID, nDir)
   {
      if(nDir == undefined)
      {
         return undefined;
      }
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpriteDirection] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            this.setSpriteDirection(oChildsItems[k].id,nDir);
         }
      }
      if(oSprite.hasCarriedChild())
      {
         oSprite.carriedChild.mc.setDirection(nDir);
      }
      var mcSprite = oSprite.mc;
      mcSprite.setDirection(nDir);
   }
   function setSpritePosition(sID, nCellNum, nDir)
   {
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[setSpritePosition] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(_global.isNaN(Number(nCellNum)))
      {
         ank.utils.Logger.err("[setSpritePosition] cellNum n\'est pas un nombre");
         return undefined;
      }
      if(Number(nCellNum) < 0 || Number(nCellNum) > this._mcBattlefield.mapHandler.getCellCount())
      {
         ank.utils.Logger.err("[setSpritePosition] cellNum invalide");
         return undefined;
      }
      if(oSprite.hasChilds)
      {
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            var nChildCellNum = ank.battlefield.utils.Pathfinding.getArroundCellNum(this._mcBattlefield.mapHandler,nCellNum,nDir,oChildsItems[k].childIndex);
            this.setSpriteDirection(oChildsItems[k].id,nChildCellNum,nDir);
         }
      }
      this._mcBattlefield.removeSpriteBubble(sID);
      if(nDir != undefined)
      {
         oSprite.direction = nDir;
      }
      var mcSprite = oSprite.mc;
      mcSprite.setPosition(nCellNum);
   }
   function stopSpriteMove(sID, oSeq, nCellNum)
   {
      oSeq.clearAllNextActions();
      var oSprite = this._oSprites.getItemAt(sID);
      var mcSprite = oSprite.mc;
      oSprite.isInMove = false;
      oSeq.addAction(8,false,mcSprite,mcSprite.setPosition,[nCellNum]);
      oSeq.addAction(9,false,mcSprite,mcSprite.setAnim,["static"]);
   }
   function slideSprite(sID, cellNum, seq, sAnimation)
   {
      if(cellNum == -1)
      {
         return undefined;
      }
      if(sAnimation == undefined)
      {
         sAnimation = "static";
      }
      var oSprite = this._oSprites.getItemAt(sID);
      var nCurrentCell = oSprite.futureCellNum == -1 ? oSprite.cellNum : oSprite.futureCellNum;
      var nDirection = ank.battlefield.utils.Pathfinding.getDirectionFromCoordinates(this._mcBattlefield.mapHandler.getCellData(nCurrentCell).x,this._mcBattlefield.mapHandler.getCellData(nCurrentCell).rootY,this._mcBattlefield.mapHandler.getCellData(cellNum).x,this._mcBattlefield.mapHandler.getCellData(cellNum).rootY,false);
      var aPath = ank.battlefield.utils.Compressor.makeFullPath(this._mcBattlefield.mapHandler,[{num:nCurrentCell},{num:cellNum,dir:nDirection}]);
      if(aPath != undefined)
      {
         this.moveSprite(sID,aPath,seq,false,sAnimation);
      }
   }
   function moveSprite(sID, path, seq, bClearSequencer, sAnimation, bForcedRun, bForcedWalk, runLimit)
   {
      this._mcBattlefield.removeSpriteBubble(sID);
      this._mcBattlefield.hideSpriteOverHead(sID);
      var bHasAnimation = sAnimation != undefined;
      if(runLimit == undefined)
      {
         runLimit = ank.battlefield.SpriteHandler.DEFAULT_RUNLINIT;
      }
      if(bForcedRun == undefined)
      {
         bForcedRun = false;
      }
      if(bForcedWalk == undefined)
      {
         bForcedWalk = false;
      }
      var sAnimType = !bHasAnimation ? "walk" : "slide";
      if(bForcedWalk)
      {
         sAnimType = "walk";
      }
      else if(bForcedRun)
      {
         sAnimType = "run";
      }
      else if(!bForcedRun && (!bForcedWalk && !bHasAnimation))
      {
         if(path.length > runLimit)
         {
            sAnimType = "run";
         }
      }
      var oSprite = this._oSprites.getItemAt(sID);
      if(oSprite == undefined)
      {
         ank.utils.Logger.err("[moveSprite] Sprite " + sID + " inexistant");
         return undefined;
      }
      if(seq == undefined)
      {
         seq = oSprite.sequencer;
      }
      var nFinalCell = Number(path[path.length - 1]);
      oSprite.futureCellNum = nFinalCell;
      if(oSprite.hasChilds)
      {
         if(path.length > 1)
         {
            var nDirection = ank.battlefield.utils.Pathfinding.getDirection(this._mcBattlefield.mapHandler,Number(path[path.length - 2]),nFinalCell);
         }
         else
         {
            nDirection = oSprite.direction;
         }
         var oChildsItems = oSprite.linkedChilds.getItems();
         for(var k in oChildsItems)
         {
            var oChildSprite = oChildsItems[k];
            var nChildCell = ank.battlefield.utils.Pathfinding.getArroundCellNum(this._mcBattlefield.mapHandler,nFinalCell,nDirection,oChildSprite.childIndex);
            var aChildPath = ank.battlefield.utils.Pathfinding.pathFind(this.api,this._mcBattlefield.mapHandler,oChildSprite.cellNum,nChildCell,{bAllDirections:oChildSprite.allDirections,bIgnoreSprites:true,bCellNumOnly:true,bWithBeginCellNum:true});
            if(aChildPath != null)
            {
               ank.utils.Timer.setTimer(oChildSprite,"battlefield",this,this.moveSprite,200 + (oSprite.cellNum != oChildSprite.cellNum ? 0 : 200),[oChildSprite.id,aChildPath,oChildSprite.sequencer,bClearSequencer,sAnimation,oChildSprite.forceRun || bForcedRun,oChildSprite.forceWalk || bForcedWalk,runLimit]);
            }
         }
      }
      var mcSprite = oSprite.mc;
      if(bClearSequencer)
      {
         if(!bHasAnimation)
         {
            seq.clearAllNextActions();
         }
      }
      seq.addAction(10,false,mcSprite,mcSprite.setPosition,[path[0]]);
      var nPathLength = path.length;
      var nLastIndex = nPathLength - 1;
      var i = 0;
      while(i < nPathLength)
      {
         var sAnim = sAnimation;
         var sAnimTypeMove = sAnimType;
         var bJump = false;
         if(i != 0)
         {
            var nPrevHeight = this._mcBattlefield.mapHandler.getCellHeight(path[i - 1]);
            var nCurrHeight = this._mcBattlefield.mapHandler.getCellHeight(path[i]);
            if(Math.abs(nPrevHeight - nCurrHeight) > 0.5 && this._mcBattlefield.isJumpActivate)
            {
               sAnim = "jump";
               sAnimTypeMove = "run";
               bJump = true;
            }
         }
         seq.addAction(11,true,mcSprite,mcSprite.moveToCell,[seq,path[i],i == nLastIndex,sAnimTypeMove,sAnim,bJump]);
         i = i + 1;
      }
      seq.execute();
   }
   function setCreatureMode(bEnabled)
   {
      var oItems = this.api.datacenter.Sprites.getItems();
      for(var k in oItems)
      {
         var oSprite = oItems[k];
         if(oSprite instanceof dofus.datacenter.Character)
         {
            if(oSprite.canSwitchInCreaturesMode)
            {
               if(!(oSprite instanceof dofus.datacenter.Mutant))
               {
                  if(bEnabled)
                  {
                     if(!oSprite.bInCreaturesMode)
                     {
                        oSprite.tmpGfxFile = oSprite.gfxFile;
                        oSprite.tmpMount = oSprite.mount;
                        oSprite.mount = undefined;
                        var sPath = dofus.Constants.CLIPS_PERSOS_PATH + oSprite.Guild + "2.swf";
                        this.api.gfx.setSpriteGfx(oSprite.id,sPath);
                        oSprite.bInCreaturesMode = true;
                     }
                  }
                  else if(oSprite.bInCreaturesMode)
                  {
                     oSprite.mount = oSprite.tmpMount;
                     delete oSprite.tmpMount;
                     var sRestorePath = oSprite.tmpGfxFile != undefined ? oSprite.tmpGfxFile : oSprite.gfxFile;
                     delete oSprite.tmpGfxFile;
                     this.api.gfx.setSpriteGfx(oSprite.id,sRestorePath);
                     oSprite.bInCreaturesMode = false;
                  }
               }
            }
         }
      }
   }
   static function resetStaticVars()
   {
      ank.battlefield.SpriteHandler._bPlayerSpritesHidden = false;
      ank.battlefield.SpriteHandler._bShowMonstersTooltip = false;
   }
   function showMonstersTooltip(bShow)
   {
      ank.battlefield.SpriteHandler._bShowMonstersTooltip = bShow;
      var oItems = this.api.gfx.spriteHandler.getSprites().getItems();
      for(var sID in oItems)
      {
         var mcSprite = oItems[sID].mc;
         var oData = mcSprite.data;
         if(oData instanceof dofus.datacenter.MonsterGroup)
         {
            if(bShow)
            {
               mcSprite._rollOver(true);
            }
            else
            {
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
