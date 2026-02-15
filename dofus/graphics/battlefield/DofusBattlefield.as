class dofus.graphics.battlefield.DofusBattlefield extends ank.battlefield.Battlefield
{
   var _oAPI;
   var _rollOverMcSprite;
   var _rollOverMcObject;
   var dispatchEvent;
   var mapHandler;
   function DofusBattlefield()
   {
      super();
   }
   function get api()
   {
      return this._oAPI;
   }
   function get rollOverMcSprite()
   {
      return this._rollOverMcSprite;
   }
   function get rollOverMcObject()
   {
      return this._rollOverMcObject;
   }
   function set rollOverMcObject(rollOverMcObject)
   {
      this._rollOverMcObject = rollOverMcObject;
   }
   function initialize(oDatacenter, sGroundFile, sObjectFile, sAccessoriesPath, oAPI)
   {
      super.initialize(oDatacenter,sGroundFile,sObjectFile,sAccessoriesPath,oAPI);
      mx.events.EventDispatcher.initialize(this);
      this._oAPI = oAPI;
   }
   function addSpritePoints(sID, sValue, nTypePoint)
   {
      if(this.api.kernel.OptionsManager.getOption("PointsOverHead") && this.api.electron.isWindowFocused)
      {
         super.addSpritePoints(sID,sValue,nTypePoint);
      }
   }
   function onInitError()
   {
      _root.onCriticalError(this.api.lang.getText("CRITICAL_ERROR_LOADING_BATTLEFIELD"));
   }
   function onMapLoaded()
   {
      this._rollOverMcObject = undefined;
      this._rollOverMcSprite = undefined;
      var map_o = this.api.datacenter.Map;
      this.api.ui.unloadUIComponent("CenterText");
      this.api.ui.unloadUIComponent("CenterTextMap");
      this.api.ui.unloadUIComponent("FightsInfos");
      this.setInteraction(ank.battlefield.Constants.INTERACTION_NONE);
      this.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_RELEASE);
      this.setInteraction(ank.battlefield.Constants.INTERACTION_SPRITE_RELEASE_OVER_OUT);
      if(this.api.datacenter.Game.isFight)
      {
         this.setInteraction(ank.battlefield.Constants.INTERACTION_OBJECT_NONE);
      }
      else
      {
         this.setInteraction(ank.battlefield.Constants.INTERACTION_OBJECT_RELEASE_OVER_OUT);
      }
      this.api.datacenter.Game.setInteractionType("move");
      this.api.network.Game.getExtraInformations();
      this.api.ui.unloadLastUIAutoHideComponent();
      this.api.ui.removePopupMenu();
      this.api.ui.getUIComponent("MapInfos").update();
      var subareaId_n = map_o.subarea;
      if(subareaId_n != this.api.datacenter.Basics.gfx_lastSubarea)
      {
         var subareaObj_o = this.api.datacenter.Subareas.getItemAt(subareaId_n);
         var centerText_s = new String();
         var subareaName_s = new String();
         var areaName_s = this.api.lang.getMapAreaText(map_o.area).n;
         if(subareaObj_o == undefined)
         {
            subareaName_s = this.api.lang.getMapSubAreaName(subareaId_n);
            if(areaName_s != subareaName_s)
            {
               centerText_s = areaName_s + "\n(" + subareaName_s + ")";
            }
            else
            {
               centerText_s = areaName_s;
            }
         }
         else
         {
            subareaName_s = subareaObj_o.name;
            centerText_s = subareaObj_o.name + " (" + subareaObj_o.alignment.name + ")";
            if(areaName_s != subareaName_s)
            {
               centerText_s = areaName_s + "\n(" + subareaName_s + ")\n" + subareaObj_o.alignment.name;
            }
            else
            {
               centerText_s = areaName_s + "\n" + subareaObj_o.alignment.name;
            }
         }
         if(dofus.Constants.INVADER_AREA && (!map_o.isDungeon && !_global.isNaN(this.api.datacenter.Temporis.currentAreaInvadeLevel)))
         {
            centerText_s += " - " + this.api.lang.getText("TR3_ACTUAL_INVADE_TIME",[this.api.datacenter.Temporis.currentAreaInvadeTimer]) + " (" + this.api.lang.getText("LEVEL") + " " + this.api.datacenter.Temporis.currentAreaInvadeLevel + ")";
         }
         if(!this.api.kernel.TutorialManager.isTutorialMode)
         {
            this.api.ui.loadUIComponent("CenterText","CenterText",{text:centerText_s,background:false,timer:2000},{bForceLoad:true});
         }
         this.api.datacenter.Basics.gfx_lastSubarea = subareaId_n;
      }
      if(this.api.kernel.OptionsManager.getOption("Grid") == true || this.api.datacenter.Game.isRunning)
      {
         this.api.gfx.drawGrid();
      }
      else
      {
         this.api.gfx.removeGrid();
      }
      if(this.showingCellIds)
      {
         this.updateCellIds();
      }
      this.api.ui.getUIComponent("Banner").circleXtra.setCircleXtraParams({currentCoords:[map_o.x,map_o.y]});
      if(!this.api.datacenter.Game.isRunning)
      {
         if(Number(map_o.ambianceID) > 0)
         {
            this.api.sounds.playEnvironment(map_o.ambianceID);
         }
         if(Number(map_o.musicID) > 0)
         {
            this.api.sounds.playMusic(map_o.musicID,true);
         }
      }
      var mapTextParts_a = Array(this.api.lang.getMapText(map_o.id).p);
      var mapTextIndex_n = 0;
      while(mapTextParts_a.length > mapTextIndex_n)
      {
         var layerNumbers_a = mapTextParts_a[mapTextIndex_n][0];
         var cellNum_n = mapTextParts_a[mapTextIndex_n][1];
         var criterions_o = mapTextParts_a[mapTextIndex_n][2];
         if(!dofus.utils.criterions.CriterionManager.fillingCriterions(criterions_o))
         {
            var cellData_o = this.api.gfx.mapHandler.getCellData(cellNum_n);
            var innerIdx_n = 0;
            while(innerIdx_n < layerNumbers_a.length)
            {
               if(cellData_o.layerObject1Num == layerNumbers_a[innerIdx_n])
               {
                  cellData_o.mcObject1._visible = false;
               }
               if(cellData_o.layerObject2Num == layerNumbers_a[innerIdx_n])
               {
                  cellData_o.mcObject2._visible = false;
               }
               innerIdx_n = innerIdx_n + 1;
            }
         }
         mapTextIndex_n = mapTextIndex_n + 1;
      }
      this.dispatchEvent({type:"mapLoaded",currentMap:map_o});
   }
   function onCellRelease(mcCell)
   {
      if(this.api.kernel.TutorialManager.isTutorialMode)
      {
         this.api.kernel.TutorialManager.onWaitingCase({code:"CELL_RELEASE",params:[mcCell.num]});
         return false;
      }
      switch(this.api.datacenter.Game.interactionType)
      {
         case 1:
            var playerData_o = this.api.datacenter.Player.data;
            var pathFound_b = false;
            var canMoveAllDirs_b = this.api.datacenter.Player.canMoveInAllDirections;
            if(this.api.datacenter.Player.InteractionsManager.calculatePath(this.mapHandler,mcCell.num,true,this.api.datacenter.Game.isFight,false,canMoveAllDirs_b))
            {
               if(this.api.datacenter.Game.isFight)
               {
                  pathFound_b = true;
               }
               else
               {
                  pathFound_b = this.api.datacenter.Basics.interactionsManager_path[this.api.datacenter.Basics.interactionsManager_path.length - 1].num == mcCell.num;
               }
            }
            if(!this.api.datacenter.Game.isFight && !pathFound_b)
            {
               if(this.api.datacenter.Player.InteractionsManager.calculatePath(this.mapHandler,mcCell.num,true,this.api.datacenter.Game.isFight,true,canMoveAllDirs_b))
               {
                  pathFound_b = true;
               }
            }
            if(pathFound_b)
            {
               if(getTimer() - this.api.datacenter.Basics.gfx_lastActionTime < dofus.Constants.CLICK_MIN_DELAY && (playerData_o == undefined || !playerData_o.isAdminSonicSpeed))
               {
                  ank.utils.Logger.err("T trop rapide du clic");
                  return null;
               }
               this.api.datacenter.Basics.gfx_lastActionTime = getTimer();
               if(this.api.datacenter.Basics.interactionsManager_path.length != 0)
               {
                  var compressedPath_s = ank.battlefield.utils.Compressor.compressPath(this.api.datacenter.Basics.interactionsManager_path);
                  if(compressedPath_s != undefined)
                  {
                     if(this.api.datacenter.Game.isFight && this.api.datacenter.Game.isRunning)
                     {
                        var playerSeq_o = playerData_o.sequencer;
                        playerSeq_o.addAction(122,false,playerData_o.GameActionsManager,playerData_o.GameActionsManager.transmittingMove,[1,[compressedPath_s]]);
                        playerSeq_o.execute();
                     }
                     else
                     {
                        playerData_o.GameActionsManager.transmittingMove(1,[compressedPath_s]);
                     }
                     delete this.api.datacenter.Basics.interactionsManager_path;
                  }
               }
               return true;
            }
            return false;
            break;
         case 2:
            if(this.api.datacenter.Player.currentUseObject != null && this.api.datacenter.Basics.gfx_canLaunch)
            {
               var playerData_o = this.api.datacenter.Player.data;
               var playerSeq_o = playerData_o.sequencer;
               playerSeq_o.addAction(123,false,playerData_o.GameActionsManager,playerData_o.GameActionsManager.transmittingOther,[300,[this.api.datacenter.Player.currentUseObject.ID,mcCell.num]]);
               playerSeq_o.execute();
               this.api.datacenter.Player.currentUseObject = null;
            }
            else if(this.api.datacenter.Basics.spellManager_errorMsg != undefined)
            {
               this.api.kernel.showMessage(undefined,this.api.datacenter.Basics.spellManager_errorMsg,"ERROR_CHAT");
               delete this.api.datacenter.Basics.spellManager_errorMsg;
            }
            this.api.gfx.clearSpellPreview();
            this.api.kernel.GameManager.lastSpellLaunch = getTimer();
            this.api.datacenter.Game.setInteractionType("move");
            break;
         case 3:
            if(this.api.datacenter.Player.currentUseObject != null && this.api.datacenter.Basics.gfx_canLaunch)
            {
               var playerData2_o = this.api.datacenter.Player.data;
               var playerSeq2_o = playerData2_o.sequencer;
               playerSeq2_o.addAction(124,false,playerData2_o.GameActionsManager,playerData2_o.GameActionsManager.transmittingOther,[303,[mcCell.num]]);
               playerSeq2_o.execute();
               this.api.datacenter.Player.currentUseObject = null;
            }
            this.api.gfx.clearSpellPreview();
            this.api.kernel.GameManager.lastSpellLaunch = getTimer();
            this.api.datacenter.Game.setInteractionType("move");
            break;
         case 4:
            var spriteOnId_n = this.mapHandler.getCellData(mcCell.num).spriteOnID;
               if(spriteOnId_n != undefined)
            {
               break;
            }
            this.api.network.Game.setPlayerPosition(mcCell.num);
            break;
         case 5:
            if(this.api.datacenter.Player.currentUseObject != null && this.api.datacenter.Basics.gfx_canLaunch)
            {
               this.api.network.Items.use(this.api.datacenter.Player.currentUseObject.ID,this.mapHandler.getCellData(mcCell.num).spriteOnID,mcCell.num);
            }
            this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_RELEASE);
            this.api.gfx.clearPointer();
            this.unSelect(true);
            this.api.datacenter.Player.reset();
            this.api.ui.removeCursor();
            this.api.datacenter.Game.setInteractionType("move");
            break;
         case 6:
            if(this.api.datacenter.Game.isFight)
            {
               if(mcCell.num != undefined)
               {
                  this.api.network.Game.setFlag(mcCell.num);
               }
               this.api.gfx.clearPointer();
               this.api.gfx.unSelectAllButOne("startPosition");
               this.api.ui.removeCursor();
               if(this.api.datacenter.Game.isRunning && this.api.datacenter.Game.currentPlayerID == this.api.datacenter.Player.ID)
               {
                  this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_RELEASE_OVER_OUT);
                  this.api.datacenter.Game.setInteractionType("move");
               }
               else
               {
                  this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_RELEASE);
                  this.api.datacenter.Game.setInteractionType("place");
               }
            }
      }
   }
   function onCellRollOver(mcCell)
   {
      if(this.api.kernel.TutorialManager.isTutorialMode)
      {
         this.api.kernel.TutorialManager.onWaitingCase({code:"CELL_OVER",params:[mcCell.num]});
         return undefined;
      }
      if(this.api.datacenter.Game.isRunning && (!this.api.datacenter.Player.isCurrentPlayer && this.api.datacenter.Game.interactionType != 6))
      {
         return undefined;
      }
      switch(this.api.datacenter.Game.interactionType)
      {
         case 1:
            var player_o = this.api.datacenter.Player;
            var playerData_o = player_o.data;
            var spriteId_n = this.mapHandler.getCellData(mcCell.num).spriteOnID;
            var spriteDC_o = this.api.datacenter.Sprites.getItemAt(spriteId_n);
            if(spriteDC_o != undefined)
            {
               this.showSpriteInfos(spriteDC_o);
            }
            if(ank.battlefield.utils.Pathfinding.checkRange(this.mapHandler,playerData_o.cellNum,mcCell.num,false,0,playerData_o.MP,0))
            {
               this.api.datacenter.Player.InteractionsManager.setState(this.api.datacenter.Game.isFight);
               this.api.datacenter.Player.InteractionsManager.calculatePath(this.mapHandler,mcCell.num,false,this.api.datacenter.Game.isFight);
            }
            else
            {
               delete this.api.datacenter.Basics.interactionsManager_path;
            }
            break;
         case 2:
         case 3:
            var player2_o = this.api.datacenter.Player;
            var playerData2_o = player2_o.data;
            var startCell_n = playerData2_o.cellNum;
            var currentUseObject_o = player2_o.currentUseObject;
            var spellsManager_o = player2_o.SpellsManager;
            var rangeModerator_n = currentUseObject_o.rangeModerator;
            this.api.gfx.mapHandler.resetEmptyCells();
            this.api.datacenter.Basics.gfx_canLaunch = spellsManager_o.checkCanLaunchSpellOnCell(this.mapHandler,currentUseObject_o,this.mapHandler.getCellData(mcCell.num),rangeModerator_n,false);
            if(this.api.datacenter.Basics.gfx_canLaunch)
            {
               this.api.ui.setCursorForbidden(false);
               this.drawPointer(mcCell.num);
            }
            else
            {
               this.api.ui.setCursorForbidden(true,dofus.Constants.FORBIDDEN_FILE);
            }
            break;
         case 5:
         case 6:
            this.api.datacenter.Basics.gfx_canLaunch = true;
            this.api.ui.setCursorForbidden(false);
            this.drawPointer(mcCell.num);
      }
   }
   function onCellRollOut(mcCell)
   {
      if(this.api.kernel.TutorialManager.isTutorialMode)
      {
         this.api.kernel.TutorialManager.onWaitingCase({code:"CELL_OUT",params:[mcCell.num]});
         return undefined;
      }
      if(this.api.datacenter.Game.isRunning && (!this.api.datacenter.Player.isCurrentPlayer && this.api.datacenter.Game.interactionType != 6))
      {
         return undefined;
      }
      switch(this.api.datacenter.Game.interactionType)
      {
         case 1:
            this.hideSpriteInfos();
            this.unSelect(true);
            break;
         case 2:
         case 3:
            this.api.ui.setCursorForbidden(true,dofus.Constants.FORBIDDEN_FILE);
            this.hidePointer();
            this.api.datacenter.Basics.gfx_canLaunch = false;
            this.hideSpriteInfos();
            break;
         case 5:
         case 6:
            this.api.ui.setCursorForbidden(true,dofus.Constants.FORBIDDEN_FILE);
            this.api.datacenter.Basics.gfx_canLaunch = false;
            this.hidePointer();
      }
   }
   function onSpriteRelease(mcSprite, bRightClick)
   {
      if(bRightClick == undefined)
      {
         bRightClick = false;
      }
      var spriteData_o = mcSprite.data;
      var spriteId_n = spriteData_o.id;
      if(this.api.kernel.TutorialManager.isTutorialMode)
      {
         this.api.kernel.TutorialManager.onWaitingCase({code:"SPRITE_RELEASE",params:[spriteData_o.id]});
         return undefined;
      }
      if(spriteData_o.hasParent)
      {
         this.onSpriteRelease(spriteData_o.linkedParent.mc);
         return undefined;
      }
      var interactionType_n = this.api.datacenter.Game.interactionType;
      if(interactionType_n !== 5)
      {
         if(spriteData_o instanceof dofus.datacenter.Mutant && !spriteData_o.showIsPlayer)
         {
            if(!this.api.datacenter.Game.isRunning)
            {
               if(this.api.datacenter.Player.isMutant)
               {
                  return undefined;
               }
            }
            var cellMc_o = this.mapHandler.getCellData(spriteData_o.cellNum).mc;
            this.onCellRelease(cellMc_o);
         }
         else if(spriteData_o instanceof dofus.datacenter.Character || spriteData_o instanceof dofus.datacenter.Mutant && spriteData_o.showIsPlayer)
         {
            if(this.api.datacenter.Game.isFight && (this.api.datacenter.Game.isRunning && !(this.api.datacenter.Player.isAuthorized && (this.api.datacenter.Game.interactionType == dofus.datacenter.Game.INTERACTION_TYPE_MOVE && this.api.datacenter.Player.currentUseObject == null))))
            {
               var charCellMc_o = this.mapHandler.getCellData(spriteData_o.cellNum).mc;
               this.onCellRelease(charCellMc_o);
               return undefined;
            }
            if(Key.isDown(Key.CONTROL))
            {
               var cellPlayers_a = this.mapHandler.getCellData(spriteData_o.cellNum).allSpritesOn;
               this.api.kernel.GameManager.showCellPlayersPopupMenu(cellPlayers_a);
            }
            else
            {
               this.api.kernel.GameManager.showPlayerPopupMenu(spriteData_o);
            }
         }
         else if(spriteData_o instanceof dofus.datacenter.NonPlayableCharacter)
         {
            if(this.api.datacenter.Player.cantSpeakNPC)
            {
               return undefined;
            }
            var npcActions_a = spriteData_o.actions;
            if(npcActions_a != undefined && npcActions_a.length != 0)
            {
               var npcMenu_o = this.api.ui.createPopupMenu();
               if(Key.isDown(Key.SHIFT) || bRightClick)
               {
                  var preferredOrder_a = [6,3,1,2,4,5,7,8];
                  var prefIdx_n = 0;
                  while(prefIdx_n < preferredOrder_a.length)
                  {
                     var foundItem_o = npcActions_a.findFirstItem("actionId",preferredOrder_a[prefIdx_n]).item;
                     if(foundItem_o != undefined)
                     {
                        var actionWrapper_o = foundItem_o.action;
                        var actionMethod = actionWrapper_o.method;
                        var actionObject_o = actionWrapper_o.object;
                        var actionParams_a = actionWrapper_o.params;
                        actionMethod.apply(actionObject_o,actionParams_a);
                        break;
                     }
                     prefIdx_n = prefIdx_n + 1;
                  }
               }
               else
               {
                  var actCount_n = npcActions_a.length;
                  while(actCount_n-- > 0)
                  {
                     var actEntry_o = npcActions_a[actCount_n];
                     var actId_n = actEntry_o.actionId;
                     var actWrapper2_o = actEntry_o.action;
                     var actMethod2 = actWrapper2_o.method;
                     var actObject2_o = actWrapper2_o.object;
                     var actParams2_a = actWrapper2_o.params;
                     npcMenu_o.addItem(actEntry_o.name,actObject2_o,actMethod2,actParams2_a);
                  }
                  npcMenu_o.show(_root._xmouse,_root._ymouse);
               }
            }
         }
         else if(spriteData_o instanceof dofus.datacenter.Team)
         {
            var playerAlign_n = this.api.datacenter.Player.data.alignment.index;
            var teamAlign_n = spriteData_o.alignment.index;
            var enemyAlign_n = spriteData_o.enemyTeam.alignment.index;
            var fightType_n = spriteData_o.challenge.fightType;
            var canJoin_b = false;
            switch(fightType_n)
            {
               case 0:
                  switch(spriteData_o.type)
                  {
                     case 0:
                     case 2:
                        canJoin_b = this.api.datacenter.Player.canChallenge && (!this.api.datacenter.Player.isMutant || this.api.datacenter.Player.canAttackDungeonMonstersWhenMutant);
                  }
                  break;
               case 1:
               case 2:
                  switch(spriteData_o.type)
                  {
                     case 0:
                     case 1:
                        if(playerAlign_n == teamAlign_n)
                        {
                           canJoin_b = !this.api.datacenter.Player.isMutant;
                        }
                        else
                        {
                           canJoin_b = this.api.lang.getAlignmentCanJoin(playerAlign_n,teamAlign_n) && (this.api.lang.getAlignmentCanAttack(playerAlign_n,enemyAlign_n) && !this.api.datacenter.Player.isMutant);
                        }
                  }
                  break;
               case 3:
                  switch(spriteData_o.type)
                  {
                     case 0:
                        canJoin_b = !this.api.datacenter.Player.isMutant || this.api.datacenter.Player.canAttackDungeonMonstersWhenMutant;
                        break;
                     case 1:
                        canJoin_b = false;
                  }
                  break;
               case 4:
                  switch(spriteData_o.type)
                  {
                     case 0:
                        canJoin_b = !this.api.datacenter.Player.isMutant || this.api.datacenter.Player.canAttackDungeonMonstersWhenMutant;
                        break;
                     case 1:
                        canJoin_b = false;
                  }
                  break;
               case 5:
                  switch(spriteData_o.type)
                  {
                     case 0:
                        canJoin_b = !this.api.datacenter.Player.isMutant && !this.api.datacenter.Player.cantInteractWithTaxCollector;
                        break;
                     case 3:
                        canJoin_b = false;
                  }
                  break;
               case 6:
                  switch(spriteData_o.type)
                  {
                     case 0:
                        canJoin_b = !this.api.datacenter.Player.isMutant || this.api.datacenter.Player.canAttackDungeonMonstersWhenMutant;
                        break;
                     case 2:
                        canJoin_b = this.api.datacenter.Player.isMutant && !this.api.datacenter.Player.canAttackDungeonMonstersWhenMutant == true;
                  }
            }
            if(canJoin_b)
            {
               var showMenu_b = true;
               var teamMenu_o = this.api.ui.createPopupMenu();
               var maxTeam_n = this.api.lang.getMapMaxTeam(this.api.datacenter.Map.id);
               var maxChallenge_n = this.api.lang.getMapMaxChallenge(this.api.datacenter.Map.id);
               if(spriteData_o.challenge.count >= maxChallenge_n)
               {
                  teamMenu_o.addItem(this.api.lang.getText("CHALENGE_FULL"));
               }
               else if(spriteData_o.count >= maxTeam_n)
               {
                  teamMenu_o.addItem(this.api.lang.getText("TEAM_FULL"));
               }
               else if(Key.isDown(Key.SHIFT) || bRightClick)
               {
                  showMenu_b = false;
                  this.api.network.GameActions.joinChallenge(spriteData_o.challenge.id,spriteData_o.id);
                  this.api.ui.hideTooltip();
               }
               else
               {
                  teamMenu_o.addItem(this.api.lang.getText("JOIN_SMALL"),this.api.network.GameActions,this.api.network.GameActions.joinChallenge,[spriteData_o.challenge.id,spriteData_o.id]);
               }
               if(showMenu_b)
               {
                  teamMenu_o.show(_root._xmouse,_root._ymouse);
               }
            }
         }
         else if(spriteData_o instanceof dofus.datacenter.ParkMount)
         {
            if(spriteData_o.ownerName == this.api.datacenter.Player.Name || this.api.datacenter.Map.firstMountPark.guildName == this.api.datacenter.Player.guildInfos.name && this.api.datacenter.Player.guildInfos.playerRights.canManageOtherMount)
            {
               if(Key.isDown(Key.SHIFT) || bRightClick)
               {
                  this.api.network.Mount.parkMountData(spriteData_o.id);
               }
               else
               {
                  var mountMenu_o = this.api.ui.createPopupMenu();
                  mountMenu_o.addStaticItem(this.api.lang.getText("MOUNT_OF",[spriteData_o.ownerName]));
                  mountMenu_o.addItem(this.api.lang.getText("VIEW_MOUNT_DETAILS"),this.api.network.Mount,this.api.network.Mount.parkMountData,[spriteData_o.id]);
                  mountMenu_o.show(_root._xmouse,_root._ymouse);
               }
            }
         }
         else if(spriteData_o instanceof dofus.datacenter.Creature)
         {
            var creatureCellMc_o = this.mapHandler.getCellData(spriteData_o.cellNum).mc;
            this.onCellRelease(creatureCellMc_o);
         }
         else if(spriteData_o instanceof dofus.datacenter.MonsterGroup || spriteData_o instanceof dofus.datacenter.Monster)
         {
            if(spriteData_o instanceof dofus.datacenter.Monster && this.api.kernel.GameManager.isInMyTeam(spriteData_o))
            {
               this.api.kernel.GameManager.showMonsterPopupMenu(spriteData_o);
            }
            if(!this.api.datacenter.Player.isMutant || (this.api.datacenter.Player.canAttackDungeonMonstersWhenMutant || this.api.datacenter.Player.canAttackMonstersAnywhereWhenMutant))
            {
               var monsterCellData_o = this.mapHandler.getCellData(spriteData_o.cellNum);
               var monsterCellMc_o = monsterCellData_o.mc;
               if(!Key.isDown(Key.SHIFT) && (!bRightClick && (!this.api.datacenter.Game.isFight && spriteData_o instanceof dofus.datacenter.MonsterGroup)))
               {
                  var isTrigger_b = monsterCellData_o.isTrigger;
                  if(!isTrigger_b && this.api.kernel.OptionsManager.getOption("ViewAllMonsterInGroup") == true)
                  {
                     var monsterMenu_o = this.api.ui.createPopupMenu();
                     monsterMenu_o.addItem(this.api.lang.getText("ATTACK"),this,this.onCellRelease,[monsterCellMc_o]);
                     monsterMenu_o.show();
                  }
                  else
                  {
                     this.onCellRelease(monsterCellMc_o);
                  }
               }
               else
               {
                  this.onCellRelease(monsterCellMc_o);
               }
            }
         }
         else if(spriteData_o instanceof dofus.datacenter.OfflineCharacter)
         {
            if(!this.api.datacenter.Player.isMutant || this.api.datacenter.Player.canAttackDungeonMonstersWhenMutant)
            {
               if(!this.api.datacenter.Player.canExchange)
               {
                  return undefined;
               }
               if(Key.isDown(Key.SHIFT) || bRightClick)
               {
                  this.api.kernel.GameManager.startExchange(4,spriteData_o.id,spriteData_o.cellNum);
               }
               else
               {
                  var offlineName_s = spriteData_o.name;
                  var adminMenu_o;
                  if(this.api.datacenter.Player.isAuthorized)
                  {
                     adminMenu_o = this.api.kernel.AdminManager.getAdminPopupMenu(offlineName_s,false);
                  }
                  else
                  {
                     adminMenu_o = this.api.ui.createPopupMenu();
                  }
                  adminMenu_o.addStaticItem(this.api.lang.getText("SHOP") + " " + this.api.lang.getText("OF") + " " + spriteData_o.name);
                  adminMenu_o.addItem(this.api.lang.getText("BUY"),this.api.kernel.GameManager,this.api.kernel.GameManager.startExchange,[4,spriteData_o.id,spriteData_o.cellNum]);
                  if(spriteData_o.characterID != undefined && spriteData_o.name != undefined)
                  {
                     adminMenu_o.addItem(this.api.lang.getText("REPORT_PLAYER"),this.api.kernel.GameManager,this.api.kernel.GameManager.reportPlayer,[spriteData_o.characterID,spriteData_o.name,true]);
                  }
                  var adminShift_n = 2;
                  if(this.api.datacenter.Map.isMyHome)
                  {
                     adminMenu_o.addItem(this.api.lang.getText("KICKOFF"),this.api.network.Basics,this.api.network.Basics.kick,[spriteData_o.cellNum]);
                     adminShift_n = adminShift_n + 1;
                  }
                  if(this.api.datacenter.Player.isAuthorized)
                  {
                     var revIdx_n = 0;
                     while(revIdx_n < adminShift_n)
                     {
                        adminMenu_o.items.unshift(adminMenu_o.items.pop());
                        revIdx_n = revIdx_n + 1;
                     }
                  }
                  adminMenu_o.show(_root._xmouse,_root._ymouse,true);
               }
            }
         }
         else if(spriteData_o instanceof dofus.datacenter.TaxCollector)
         {
            if(!this.api.datacenter.Player.isMutant)
            {
               if(this.api.datacenter.Player.cantInteractWithTaxCollector)
               {
                  return undefined;
               }
               if(this.api.datacenter.Game.isFight)
               {
                  var taxCellMc_o = this.mapHandler.getCellData(spriteData_o.cellNum).mc;
                  this.onCellRelease(taxCellMc_o);
               }
               else if(Key.isDown(Key.SHIFT) || bRightClick)
               {
                  this.api.network.Dialog.create(spriteId_n);
               }
               else
               {
                  var guildRights_o = this.api.datacenter.Player.guildInfos.playerRights;
                  var isGuildOwner_b = spriteData_o.guildName == this.api.datacenter.Player.guildInfos.name;
                  var canCollect_b = guildRights_o.canCollect || spriteData_o.isMine && guildRights_o.canCollectOwnTaxCollector;
                  var taxMenu_o = this.api.ui.createPopupMenu();
                  taxMenu_o.addItem(this.api.lang.getText("SPEAK"),this.api.network.Dialog,this.api.network.Dialog.create,[spriteId_n]);
                  taxMenu_o.addItem(this.api.lang.getText("COLLECT_TAX"),this.api.kernel.GameManager,this.api.kernel.GameManager.startExchange,[8,spriteId_n],isGuildOwner_b && canCollect_b);
                  taxMenu_o.addItem(this.api.lang.getText("ATTACK"),this.api.network.GameActions,this.api.network.GameActions.attackTaxCollector,[[spriteId_n]],!isGuildOwner_b);
                  taxMenu_o.show(_root._xmouse,_root._ymouse);
               }
            }
         }
         else if(spriteData_o instanceof dofus.datacenter.PrismSprite)
         {
            if(!this.api.datacenter.Player.isMutant)
            {
               if(this.api.datacenter.Game.isFight)
               {
                  var prismCellMc_o = this.mapHandler.getCellData(spriteData_o.cellNum).mc;
                  this.onCellRelease(prismCellMc_o);
               }
               else
               {
                  var isNeutral_b = this.api.datacenter.Player.alignment.index == 0;
                  var isSameAlign_b = this.api.datacenter.Player.alignment.compareTo(spriteData_o.alignment) == 0;
                  if((Key.isDown(Key.SHIFT) || bRightClick) && isSameAlign_b)
                  {
                     this.api.network.GameActions.usePrism([spriteId_n]);
                  }
                  else
                  {
                     var prismMenu_o = this.api.ui.createPopupMenu();
                     prismMenu_o.addItem(this.api.lang.getText("USE_WORD"),this.api.network.GameActions,this.api.network.GameActions.usePrism,[[spriteId_n]],isSameAlign_b);
                     prismMenu_o.addItem(this.api.lang.getText("ATTACK"),this.api.network.GameActions,this.api.network.GameActions.attackPrism,[[spriteId_n]],!isSameAlign_b && !isNeutral_b);
                     prismMenu_o.show(_root._xmouse,_root._ymouse);
                  }
               }
            }
         }
      }
      else
      {
         if(this.api.datacenter.Player.currentUseObject != null && this.api.datacenter.Basics.gfx_canLaunch)
         {
            this.api.network.Items.use(this.api.datacenter.Player.currentUseObject.ID,spriteData_o.id,spriteData_o.cellNum);
         }
         this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_RELEASE);
         this.api.gfx.clearPointer();
         this.unSelect(true);
         this.api.datacenter.Player.reset();
         this.api.ui.removeCursor();
         this.api.datacenter.Game.setInteractionType("move");
      }
   }
   function onSpriteRollOver(mcSprite, bFakeEvent)
   {
      if(!bFakeEvent)
      {
         this._rollOverMcSprite = mcSprite;
      }
      if(_root._xscale != 100)
      {
         return undefined;
      }
      var spriteData_o = mcSprite.data;
      var alignColor_s = dofus.Constants.OVERHEAD_TEXT_OTHER;
      if(!spriteData_o.isVisible)
      {
         this.showSpriteInfos(spriteData_o);
         return undefined;
      }
      if(spriteData_o.isClear)
      {
         return undefined;
      }
      if(spriteData_o.hasParent)
      {
         this.onSpriteRollOver(spriteData_o.linkedParent.mc,bFakeEvent);
         return undefined;
      }
      if(this.api.datacenter.Game.isRunning || this.api.datacenter.Game.interactionType == 5)
      {
         var cellMc_o = this.mapHandler.getCellData(spriteData_o.cellNum).mc;
         if(spriteData_o.isVisible)
         {
            this.onCellRollOver(cellMc_o);
         }
      }
      var displayText_s = spriteData_o.name;
      if(spriteData_o instanceof dofus.datacenter.Mutant && spriteData_o.showIsPlayer)
      {
         if(this.api.datacenter.Game.isRunning)
         {
            if(this.api.kernel.OptionsManager.getOption("ViewHPAsBar"))
            {
               displayText_s = "";
               this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.HealthBarOverHead,[spriteData_o,100]);
            }
            else
            {
               displayText_s = spriteData_o.playerName + " (" + spriteData_o.LP + ")";
            }
            this.showSpriteInfos(spriteData_o);
         }
         else
         {
            displayText_s = spriteData_o.playerName + " [" + spriteData_o.monsterName + " (" + spriteData_o.Level + ")]";
         }
      }
      else if(spriteData_o instanceof dofus.datacenter.Mutant || (spriteData_o instanceof dofus.datacenter.Creature || spriteData_o instanceof dofus.datacenter.Monster))
      {
         alignColor_s = dofus.Constants.NPC_ALIGNMENT_COLOR[spriteData_o.alignment.index];
         if(this.api.datacenter.Game.isRunning)
         {
            if(this.api.kernel.OptionsManager.getOption("ViewHPAsBar"))
            {
               displayText_s = "";
               this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.HealthBarOverHead,[spriteData_o,100]);
            }
            else
            {
               displayText_s += " (" + spriteData_o.LP + ")";
            }
            this.showSpriteInfos(spriteData_o);
         }
         else
         {
            displayText_s += " (" + spriteData_o.Level + ")";
         }
      }
      else if(spriteData_o instanceof dofus.datacenter.Character)
      {
         alignColor_s = dofus.Constants.OVERHEAD_TEXT_CHARACTER;
         var alignmentFile_s = dofus.Constants.DEMON_ANGEL_FILE;
         if(spriteData_o.alignment.fallenAngelDemon)
         {
            alignmentFile_s = dofus.Constants.FALLEN_DEMON_ANGEL_FILE;
         }
         var alignIndex_n = !spriteData_o.haveFakeAlignement ? spriteData_o.alignment.index : spriteData_o.fakeAlignment.index;
         if(spriteData_o.rank.value > 0)
         {
            if(alignIndex_n == 1)
            {
               var rankValue_n = spriteData_o.rank.value;
            }
            else if(alignIndex_n == 2)
            {
               rankValue_n = 10 + spriteData_o.rank.value;
            }
            else if(alignIndex_n == 3)
            {
               rankValue_n = 20 + spriteData_o.rank.value;
            }
         }
         if(this.api.datacenter.Game.isRunning)
         {
            this.addSpriteOverHeadItem(spriteData_o.id,"effects",dofus.graphics.battlefield.EffectsOverHead,[spriteData_o]);
            if(this.api.kernel.OptionsManager.getOption("ViewHPAsBar"))
            {
               displayText_s = "";
               this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.HealthBarOverHead,[spriteData_o,100,alignmentFile_s,rankValue_n]);
            }
            else
            {
               displayText_s += " (" + spriteData_o.LP + ")";
            }
            this.showSpriteInfos(spriteData_o);
         }
         else if(this.api.datacenter.Game.isFight)
         {
            displayText_s += " (" + spriteData_o.Level + ")";
         }
         var title_s = spriteData_o.title;
         if(spriteData_o.guildName != undefined && spriteData_o.guildName.length != 0)
         {
            displayText_s = "";
            this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.GuildOverHead,[spriteData_o.guildName,spriteData_o.name,spriteData_o.emblem,alignmentFile_s,rankValue_n,spriteData_o.pvpGain,title_s],undefined,true);
         }
      }
      else if(spriteData_o instanceof dofus.datacenter.TaxCollector)
      {
         if(this.api.datacenter.Game.isRunning)
         {
            if(this.api.kernel.OptionsManager.getOption("ViewHPAsBar"))
            {
               displayText_s = "";
               this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.HealthBarOverHead,[spriteData_o,100]);
            }
            else
            {
               displayText_s += " (" + spriteData_o.LP + ")";
            }
            this.showSpriteInfos(spriteData_o);
         }
         else if(this.api.datacenter.Game.isFight)
         {
            displayText_s += " (" + spriteData_o.Level + ")";
         }
         else
         {
            displayText_s = "";
            this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.GuildOverHead,[spriteData_o.guildName,spriteData_o.name,spriteData_o.emblem]);
         }
      }
      else if(spriteData_o instanceof dofus.datacenter.PrismSprite)
      {
         alignmentFile_s = dofus.Constants.DEMON_ANGEL_FILE;
         if(spriteData_o.alignment.value > 0)
         {
            if(spriteData_o.alignment.index == 1)
            {
               rankValue_n = spriteData_o.alignment.value;
            }
            else if(spriteData_o.alignment.index == 2)
            {
               rankValue_n = 10 + spriteData_o.alignment.value;
            }
            else if(spriteData_o.alignment.index == 3)
            {
               rankValue_n = 20 + spriteData_o.alignment.value;
            }
         }
         alignColor_s = dofus.Constants.NPC_ALIGNMENT_COLOR[spriteData_o.alignment.index];
         this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.TextOverHead,[displayText_s,alignmentFile_s,alignColor_s,rankValue_n]);
      }
      else if(spriteData_o instanceof dofus.datacenter.ParkMount)
      {
         alignColor_s = dofus.Constants.OVERHEAD_TEXT_CHARACTER;
         displayText_s = this.api.lang.getText("MOUNT_PARK_OVERHEAD",[spriteData_o.modelName,spriteData_o.level,spriteData_o.ownerName]);
         this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.TextOverHead,[displayText_s,alignmentFile_s,alignColor_s,rankValue_n]);
      }
      else if(spriteData_o instanceof dofus.datacenter.OfflineCharacter)
      {
         alignColor_s = dofus.Constants.OVERHEAD_TEXT_CHARACTER;
         displayText_s = "";
         this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.OfflineOverHead,[spriteData_o]);
      }
      else if(spriteData_o instanceof dofus.datacenter.NonPlayableCharacter)
      {
         var curMap_o = this.api.datacenter.Map;
         var subareaObj_o = this.api.datacenter.Subareas.getItemAt(curMap_o.subarea);
         if(subareaObj_o != undefined)
         {
            alignColor_s = dofus.Constants.NPC_ALIGNMENT_COLOR[subareaObj_o.alignment.index];
         }
      }
      else if(spriteData_o instanceof dofus.datacenter.MonsterGroup || spriteData_o instanceof dofus.datacenter.Team)
      {
         if(spriteData_o.alignment.index != -1)
         {
            alignColor_s = dofus.Constants.NPC_ALIGNMENT_COLOR[spriteData_o.alignment.index];
         }
         var fightType_n = spriteData_o.challenge.fightType;
         if(spriteData_o.isVisible && (spriteData_o instanceof dofus.datacenter.MonsterGroup || spriteData_o.type == 1 && (fightType_n == 2 || (fightType_n == 3 || fightType_n == 4))))
         {
            if(displayText_s != "")
            {
               var titleType_s = dofus.Constants.OVERHEAD_TEXT_TITLE;
               this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.TextWithTitleOverHead,[displayText_s,alignmentFile_s,alignColor_s,rankValue_n,this.api.lang.getText("LEVEL") + " " + spriteData_o.totalLevel,titleType_s,spriteData_o.bonusValue]);
            }
            this.selectSprite(spriteData_o.id,true);
            return undefined;
         }
      }
      if(displayText_s != "")
      {
         this.addSpriteOverHeadItem(spriteData_o.id,"text",dofus.graphics.battlefield.TextOverHead,[displayText_s,alignmentFile_s,alignColor_s,rankValue_n,spriteData_o,title_s]);
      }
      this.selectSprite(spriteData_o.id,true);
   }
   function onSpriteRollOut(mcSprite, bFakeEvent)
   {
      if(!bFakeEvent)
      {
         this._rollOverMcSprite = undefined;
      }
      var spriteData_o = mcSprite.data;
      if(this.api.gfx.spriteHandler.isShowingMonstersTooltip && spriteData_o instanceof dofus.datacenter.MonsterGroup)
      {
         return undefined;
      }
      if(spriteData_o.hasParent)
      {
         this.onSpriteRollOut(spriteData_o.linkedParent.mc);
         return undefined;
      }
      if(this.api.datacenter.Game.isRunning || this.api.datacenter.Game.interactionType == 5)
      {
         this.hideSpriteInfos();
         var cellMc_o = this.mapHandler.getCellData(spriteData_o.cellNum).mc;
         this.onCellRollOut(cellMc_o);
      }
      this.removeSpriteOverHeadLayer(spriteData_o.id,"text");
      this.removeSpriteOverHeadLayer(spriteData_o.id,"effects");
      this.selectSprite(spriteData_o.id,false);
   }
   function onObjectRelease(mcObject, bRightClick)
   {
      if(bRightClick == undefined)
      {
         bRightClick = false;
      }
      this.api.ui.hideTooltip();
      var cellData_o = mcObject.cellData;
      var cellMc_o = cellData_o.mc;
      var layerNum_n = cellData_o.layerObject2Num;
      if(this.api.kernel.TutorialManager.isTutorialMode)
      {
         this.api.kernel.TutorialManager.onWaitingCase({code:"OBJECT_RELEASE",params:[cellData_o.num,layerNum_n]});
         return undefined;
      }
      var externalData_o = cellData_o.layerObjectExternalData;
      if(externalData_o != undefined)
      {
         if(externalData_o.rideItemDurability != undefined)
         {
            if(this.api.datacenter.Map.firstMountPark.isMine(this.api))
            {
               var mountMenu_o = this.api.ui.createPopupMenu();
               mountMenu_o.addStaticItem(externalData_o.name);
               mountMenu_o.addItem(this.api.lang.getText("REMOVE"),this.api.network.Mount,this.api.network.Mount.removeObjectInPark,[cellMc_o.num]);
               mountMenu_o.show(_root._xmouse,_root._ymouse);
               return undefined;
            }
         }
      }
      if(!_global.isNaN(layerNum_n) && (this.api.datacenter.Player.canUseInteractiveObjects && this.api.datacenter.Game.interactionType != 5))
      {
         var interactiveData_o = this.api.lang.getInteractiveObjectDataByGfxText(layerNum_n);
         var objName_s = interactiveData_o.n;
         var skillsArr_a = interactiveData_o.sk;
         var objType_n = interactiveData_o.t;
         switch(objType_n)
         {
            case 1:
            case 2:
            case 3:
            case 4:
            case 7:
            case 10:
            case 12:
            case 14:
            case 15:
               var isGather_b = objType_n == 1;
               if(isGather_b)
               {
                  var clickRec_o = this.api.mouseClicksMemorizer.getMouseClickForGather(2);
                  if(clickRec_o != undefined)
                  {
                     var clickDelta_n = getTimer() - clickRec_o.time;
                     var isQuickClick_b = clickDelta_n < dofus.Constants.CLICK_MIN_DELAY;
                     if(isQuickClick_b)
                     {
                        var hit_b = mcObject.hitTest(clickRec_o.nX,clickRec_o.nY,true);
                        if(hit_b)
                        {
                           this.api.kernel.showMessage(undefined,this.api.lang.getText("SRV_MSG_0"),"ERROR_CHAT");
                           return undefined;
                        }
                     }
                  }
                  this.api.mouseClicksMemorizer.resetForGather();
               }
               var hasJob_b = this.api.datacenter.Player.currentJobID != undefined;
               if(hasJob_b)
               {
                  var jobSkills_a = this.api.datacenter.Player.Jobs.findFirstItem("id",this.api.datacenter.Player.currentJobID).item.skills;
               }
               else
               {
                  jobSkills_a = new ank.utils.ExtendedArray();
               }
               var menuEnabled_b = true;
               var gatherMenu_o = this.api.ui.createPopupMenu();
               gatherMenu_o.addStaticItem(objName_s);
               for(var k in skillsArr_a)
               {
                  var skillId = skillsArr_a[k];
                  var skillDC = new dofus.datacenter.Skill(skillId);
                  var hasSkill_b = jobSkills_a.findFirstItem("id",skillId).index != -1;
                  var isNovice_b = this.api.datacenter.Player.Level <= dofus.Constants.NOVICE_LEVEL;
                  var skillState_s = skillDC.getState(hasSkill_b,false,false,false,false,isNovice_b);
                  if(skillState_s != "X")
                  {
                     var canUse_b = skillState_s == "V";
                     if(canUse_b && ((Key.isDown(Key.SHIFT) || bRightClick) && (skillId != 44 && objType_n != 1)))
                     {
                        this.api.kernel.GameManager.useRessource(cellMc_o,cellMc_o.num,skillId);
                        menuEnabled_b = false;
                        break;
                     }
                     if(_root._xscale != 100 && objType_n == 1)
                     {
                        return undefined;
                     }
                     gatherMenu_o.addItem(skillDC.description,this.api.kernel.GameManager,this.api.kernel.GameManager.useRessource,[cellMc_o,cellMc_o.num,skillId],canUse_b);
                  }
               }
               if(menuEnabled_b)
               {
                  gatherMenu_o.isGatherPopupMenu = isGather_b;
                  if(gatherMenu_o.isGatherPopupMenu && objType_n == 1)
                  {
                     gatherMenu_o.gatherCellNum = cellMc_o.num;
                  }
                  gatherMenu_o.show(_root._xmouse,_root._ymouse);
               }
               break;
            case 5:
               var houseText_s = this.api.lang.getHousesDoorText(this.api.datacenter.Map.id,cellMc_o.num);
               this.api.kernel.HouseManager.openHouseMenu(objName_s,houseText_s,skillsArr_a,cellMc_o);
               break;
            case 6:
            case 6:
               var storageIndex_n = cellMc_o.num;
               var storageObj_o = this.api.datacenter.Storages.getItemAt(storageIndex_n);
               var isLocked_b = storageObj_o.isLocked;
               var isMyHome_b = this.api.datacenter.Map.isMyHome;
               var showStorage_b = true;
               var storageMenu_o = this.api.ui.createPopupMenu();
               storageMenu_o.addStaticItem(objName_s);
               for(var k in skillsArr_a)
               {
                  var skillId2 = skillsArr_a[k];
                  var skillDC2 = new dofus.datacenter.Skill(skillId2);
                  var skillState2 = skillDC2.getState(true,isMyHome_b,true,isLocked_b);
                  if(skillState2 != "X")
                  {
                     var canUse2_b = skillState2 == "V";
                     if(canUse2_b && ((Key.isDown(Key.SHIFT) || bRightClick) && (skillId2 == 104 || skillId2 == 153)))
                     {
                        this.api.kernel.GameManager.useRessource(cellMc_o,cellMc_o.num,skillId2);
                        showStorage_b = false;
                        break;
                     }
                     storageMenu_o.addItem(skillDC2.description,this.api.kernel.GameManager,this.api.kernel.GameManager.useRessource,[cellMc_o,cellMc_o.num,skillId2],canUse2_b);
                  }
               }
               if(showStorage_b)
               {
                  storageMenu_o.show(_root._xmouse,_root._ymouse);
               }
               break;
            case 13:
               var firstMountPark_o = this.api.datacenter.Map.firstMountPark;
               this.api.kernel.MountParkManager.openMountParkMenu(objName_s,skillsArr_a,cellMc_o,firstMountPark_o);
               break;
            default:
               this.onCellRelease(cellMc_o);
         }
      }
      else
      {
         this.onCellRelease(cellMc_o);
      }
   }
   function onObjectRollOver(mcObject)
   {
      this._rollOverMcObject = mcObject;
      if(_root._xscale != 100)
      {
         return undefined;
      }
      var cellData_o = mcObject.cellData;
      var cellMc_o = cellData_o.mc;
      var layerNum_n = cellData_o.layerObject2Num;
      if(this.api.datacenter.Game.interactionType == 5)
      {
         cellMc_o = mcObject.cellData.mc;
         this.onCellRollOver(cellMc_o);
      }
      mcObject.select(true);
      var externalData_o = cellData_o.layerObjectExternalData;
      if(externalData_o != undefined)
      {
         var name_s = externalData_o.name;
         if(externalData_o.rideItemDurability != undefined)
         {
            if(this.api.datacenter.Map.firstMountPark.isMine(this.api))
            {
               name_s += "\n" + this.api.lang.getText("DURABILITY") + " : " + externalData_o.rideItemDurability + "/" + externalData_o.rideItemDurabilityMax;
            }
         }
         var tmpChar_o = new dofus.datacenter.Character("itemOnCell",ank.battlefield.mc.Sprite,"",cellMc_o.num,0,0);
         this.api.datacenter.Sprites.addItemAt("itemOnCell",tmpChar_o);
         this.api.gfx.addSprite("itemOnCell");
         this.addSpriteOverHeadItem("itemOnCell","text",dofus.graphics.battlefield.TextOverHead,[name_s,"",dofus.Constants.OVERHEAD_TEXT_CHARACTER]);
      }
      var interactiveData_o = this.api.lang.getInteractiveObjectDataByGfxText(layerNum_n);
      var objName_s = interactiveData_o.n;
      var skillsArr_a = interactiveData_o.sk;
      var objType_n = interactiveData_o.t;
      switch(objType_n)
      {
         case 5:
            var houseText_s = this.api.lang.getHousesDoorText(this.api.datacenter.Map.id,cellMc_o.num);
            var houseInstances_o = this.api.kernel.HouseManager.getHouseInstances(houseText_s);
            var porteChar_o = new dofus.datacenter.Character("porte",ank.battlefield.mc.Sprite,"",cellMc_o.num,0,0);
            this.api.datacenter.Sprites.addItemAt("porte",porteChar_o);
            this.api.gfx.addSprite("porte");
            this.addSpriteOverHeadItem("porte","text",dofus.graphics.battlefield.PropertyOverHead,[houseInstances_o,"HouseIcon"]);
            break;
         case 13:
            var firstMountPark_o = this.api.datacenter.Map.firstMountPark;
            var enclosChar_o = new dofus.datacenter.Character("enclos",ank.battlefield.mc.Sprite,"",cellMc_o.num,0,0);
            this.api.datacenter.Sprites.addItemAt("enclos",enclosChar_o);
            this.api.gfx.addSprite("enclos");
            var mountParks_o = this.api.datacenter.Map.mountParks;
            this.addSpriteOverHeadItem("enclos","text",dofus.graphics.battlefield.MountParkOverHead,[mountParks_o,"FarmIcon"]);
      }
   }
   function onObjectRollOut(mcObject)
   {
      this._rollOverMcObject = undefined;
      this.api.ui.hideTooltip();
      if(this.api.datacenter.Game.interactionType == 5)
      {
         var cellMc_o = mcObject.cellData.mc;
         this.onCellRollOut(cellMc_o);
      }
      mcObject.select(false);
      this.removeSpriteOverHeadLayer("enclos","text");
      this.removeSprite("enclos",false);
      this.removeSpriteOverHeadLayer("porte","text");
      this.removeSprite("porte",false);
      this.removeSpriteOverHeadLayer("itemOnCell","text");
      this.removeSprite("itemOnCell",false);
   }
   function showSpriteInfos(oSprite)
   {
      if(!this.api.kernel.OptionsManager.getOption("SpriteInfos"))
      {
         return undefined;
      }
      if(this.api.kernel.OptionsManager.getOption("SpriteMove") && (oSprite.isVisible && this.api.ui.isCursorHidden()))
      {
         this.api.gfx.drawZone(oSprite.cellNum,0,oSprite.MP,"move",dofus.Constants.CELL_MOVE_RANGE_COLOR,"C".charCodeAt(0));
      }
      this.api.ui.getUIComponent("Banner").showRightPanel("BannerSpriteInfos",{data:oSprite},true,true);
   }
   function hideSpriteInfos()
   {
      this.api.ui.getUIComponent("Banner").hideRightPanel(false,true);
      this.api.gfx.clearZoneLayer("move");
   }
}
