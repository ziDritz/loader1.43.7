class dofus.aks.Game extends dofus.aks.Handler
{
   var extendIn;
   static var TYPE_SOLO = 1;
   static var TYPE_FIGHT = 2;
   var bSubareaHasWhiteFloor = false;
   var _bIsBusy = false;
   var nLastMapIdReceived = -1;
   function Game(oAKS, oAPI)
   {
      super.initialize(oAKS,oAPI);
      this.extendIn = new dofus.aks.extend.GameIn(oAKS,oAPI);
   }
   function get isBusy()
   {
      return this._bIsBusy;
   }
   function set isBusy(bIsBusy)
   {
      this._bIsBusy = bIsBusy;
   }
   function create()
   {
      this.aks.send("GC" + dofus.aks.Game.TYPE_SOLO);
   }
   function leave(sSpriteID)
   {
      this.aks.send("GQ" + (sSpriteID != undefined ? sSpriteID : ""));
   }
   function setPlayerPosition(nCellNum)
   {
      this.aks.send("Gp" + nCellNum,true);
   }
   function ready(bReady)
   {
      this.aks.send("GR" + (!bReady ? "0" : "1"));
   }
   function getMapData(nMapID)
   {
      if(this.api.lang.getConfigText("ENABLE_CLIENT_MAP_REQUEST"))
      {
         this.aks.send("GD" + (nMapID == undefined ? "" : String(nMapID)));
      }
   }
   function getExtraInformations()
   {
      var sCommand = "G";
      if(!this.aks.bMachineStateSent)
      {
         if(this.api.electron.getSystemInformation("virtual"))
         {
            sCommand += "i";
         }
         else
         {
            sCommand += "І";
         }
         this.aks.bMachineStateSent = true;
      }
      else
      {
         sCommand += "I";
      }
      this.aks.send(sCommand);
   }
   function turnEnd()
   {
      if(this.api.datacenter.Player.isCurrentPlayer)
      {
         this.aks.send("Gt",false);
      }
   }
   function turnOk(sSpriteID)
   {
      this.aks.send("GT" + (sSpriteID == undefined ? "" : sSpriteID),false);
   }
   function turnOk2(sSpriteID)
   {
      this.aks.send("GT" + (sSpriteID == undefined ? "" : sSpriteID),false);
   }
   function askDisablePVPMode()
   {
      this.aks.send("GP*",false);
   }
   function enabledPVPMode(bEnabled)
   {
      this.aks.send("GP" + (!bEnabled ? "-" : "+"),false);
   }
   function freeMySoul()
   {
      this.aks.send("GF",false);
   }
   function setFlag(nCellID)
   {
      this.aks.send("Gf" + nCellID,false);
   }
   function showFightChallengeTarget(challengeId)
   {
      this.aks.send("Gdi" + challengeId,false);
   }
   function onCreate(bSuccess, sExtraData)
   {
      if(!bSuccess)
      {
         ank.utils.Logger.err("[onCreate] Impossible de créer la partie");
         return undefined;
      }
      var aDataParts = sExtraData.split("|");
      var nGameState = Number(aDataParts[0]);
      if(nGameState != 1)
      {
         ank.utils.Logger.err("[onCreate] Type incorrect");
         return undefined;
      }
      this.api.datacenter.Game = new dofus.datacenter.Game();
      this.api.datacenter.Game.state = nGameState;
      var mcBanner = dofus.graphics.gapi.ui.Banner(this.api.ui.getUIComponent("Banner"));
      dofus.graphics.gapi.ui.banner.BannerGauge.showGaugeMode(mcBanner);
      mcBanner.chat.removeTemporaryReplacementPanel();
      var oChatPanel = mcBanner.chat.shortcutsReplacementPanel;
      if(oChatPanel != undefined)
      {
         oChatPanel.showMiniMap(true);
         oChatPanel.updateSprite(undefined);
      }
      this.api.datacenter.Player.data.initAP(false);
      this.api.datacenter.Player.data.initMP(false);
      this.api.datacenter.Player.SpellsManager.clear();
      this.api.datacenter.Player.data.CharacteristicsManager.initialize();
      this.api.datacenter.Player.data.EffectsManager.initialize();
      this.api.datacenter.Player.clearSummon();
      this.api.gfx.cleanMap(1);
      this.onCreateSolo();
   }
   function onJoin(sExtraData)
   {
      this.api.datacenter.Player.guildInfos.defendedTaxCollectorID = undefined;
      if(this.api.gfx.spriteHandler.isPlayerSpritesHidden)
      {
         this.api.gfx.spriteHandler.hideSprites(false);
      }
      var aDataParts = sExtraData.split("|");
      var nGameState = Number(aDataParts[0]);
      var bCancelButton = aDataParts[1] != "0" ? true : false;
      var bShowChallenge = aDataParts[2] != "0" ? true : false;
      var bIsSpectator = aDataParts[3] != "0" ? true : false;
      var nTimerDuration = Number(aDataParts[4]);
      var nFightType = Number(aDataParts[5]);
      this.api.datacenter.Game = new dofus.datacenter.Game();
      this.api.datacenter.Game.state = nGameState;
      this.api.datacenter.Game.fightType = nFightType;
      var mcBanner = dofus.graphics.gapi.ui.Banner(this.api.ui.getUIComponent("Banner"));
      mcBanner.redrawChrono();
      mcBanner.updateEye();
      this.api.datacenter.Game.isSpectator = bIsSpectator;
      if(!bIsSpectator)
      {
         this.api.datacenter.Player.data.initAP(false);
         this.api.datacenter.Player.data.initMP(false);
         this.api.datacenter.Player.SpellsManager.clear();
      }
      this.api.gfx.cleanMap(1);
      if(this.api.datacenter.Game.isTacticMode)
      {
         this.api.gfx.activateTacticMode(this.api,true);
      }
      if(bShowChallenge)
      {
         this.api.ui.loadUIComponent("ChallengeMenu","ChallengeMenu",{labelReady:this.api.lang.getText("READY"),labelCancel:this.api.lang.getText("CANCEL_SMALL"),cancelButton:bCancelButton,ready:false},{bStayIfPresent:true});
      }
      if(!_global.isNaN(nTimerDuration))
      {
         mcBanner.startTimer(nTimerDuration / 1000);
      }
      this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_OBJECT_NONE);
      this.api.ui.unloadLastUIAutoHideComponent();
      this.api.ui.unloadUIComponent("FightsInfos");
      switch(this.api.datacenter.Map.subarea)
      {
         case 320:
         case 321:
            this.bSubareaHasWhiteFloor = true;
            break;
         default:
            this.bSubareaHasWhiteFloor = false;
      }
      this.api.ui.unloadUIComponent("GameResult");
      this.api.ui.unloadUIComponent("GameResultLight");
   }
   function onPositionStart(sExtraData)
   {
      var aDataParts = sExtraData.split("|");
      var sTeam1Data = aDataParts[0];
      var sTeam2Data = aDataParts[1];
      var nTeamIndex = Number(aDataParts[2]);
      this.api.datacenter.Basics.aks_current_team = nTeamIndex;
      this.api.datacenter.Basics.aks_team1_starts = [];
      this.api.datacenter.Basics.aks_team2_starts = [];
      this.api.kernel.StreamingDisplayManager.onFightStart();
      this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_NONE);
      this.api.datacenter.Game.setInteractionType("place");
      if(nTeamIndex == undefined)
      {
         ank.utils.Logger.err("[onPositionStart] Impossible de trouver l\'équipe du joueur local !");
      }
      this.api.gfx.mapHandler.showFightCells(sTeam1Data,sTeam2Data);
      var i = 0;
      while(i < sTeam1Data.length)
      {
         var nCellId = ank.utils.Compressor.decode64(sTeam1Data.charAt(i)) << 6;
         nCellId += ank.utils.Compressor.decode64(sTeam1Data.charAt(i + 1));
         this.api.datacenter.Basics.aks_team1_starts.push(nCellId);
         if(nTeamIndex == 0)
         {
            this.api.gfx.setInteractionOnCell(nCellId,ank.battlefield.Constants.INTERACTION_CELL_RELEASE);
         }
         i += 2;
      }
      var j = 0;
      while(j < sTeam2Data.length)
      {
         var nCellId2 = ank.utils.Compressor.decode64(sTeam2Data.charAt(j)) << 6;
         nCellId2 += ank.utils.Compressor.decode64(sTeam2Data.charAt(j + 1));
         this.api.datacenter.Basics.aks_team2_starts.push(nCellId2);
         if(nTeamIndex == 1)
         {
            this.api.gfx.setInteractionOnCell(nCellId2,ank.battlefield.Constants.INTERACTION_CELL_RELEASE);
         }
         j += 2;
      }
      if(this.api.ui.getUIComponent("FightOptionButtons") == undefined)
      {
         this.api.ui.loadUIComponent("FightOptionButtons","FightOptionButtons");
      }
      this.api.kernel.TipsManager.showNewTip(dofus.managers.TipsManager.TIP_FIGHT_PLACEMENT);
   }
   function onPlayersCoordinates(sExtraData)
   {
      if(sExtraData != "e")
      {
         var aCoordinates = sExtraData.split("|");
         var i = 0;
         while(i < aCoordinates.length)
         {
            var aCoordParts = aCoordinates[i].split(";");
            var sSpriteID = aCoordParts[0];
            var nCellPosition = Number(aCoordParts[1]);
            this.api.gfx.setSpritePosition(sSpriteID,nCellPosition);
            i = i + 1;
         }
      }
      else
      {
         this.api.sounds.events.onError();
      }
   }
   function onReady(sExtraData)
   {
      var bIsReady = sExtraData.charAt(0) == "1";
      var sSpriteID = sExtraData.substr(1);
      if(bIsReady)
      {
         this.api.gfx.addSpriteExtraClip(sSpriteID,dofus.Constants.READY_FILE,undefined,true);
      }
      else
      {
         this.api.gfx.removeSpriteExtraClip(sSpriteID,true);
      }
   }
   function onStartToPlay()
   {
      this.api.ui.getUIComponent("Banner").stopTimer();
      this.aks.GameActions.onActionsFinish(this.api.datacenter.Player.ID);
      this.api.sounds.events.onGameStart(this.api.datacenter.Map.musics);
      this.api.kernel.StreamingDisplayManager.onFightStartEnd();
      var mcBanner = this.api.ui.getUIComponent("Banner");
      mcBanner.showGiveUpButton(true);
      if(this.api.ui.getUIComponent("FightOptionButtons") == undefined)
      {
         this.api.ui.loadUIComponent("FightOptionButtons","FightOptionButtons");
      }
      if(!this.api.datacenter.Game.isSpectator)
      {
         var oPlayerData = this.api.datacenter.Player.data;
         oPlayerData.initAP();
         oPlayerData.initMP();
         mcBanner.showPoints(true);
         mcBanner.showNextTurnButton(true);
         this.api.ui.loadUIComponent("CenterText","CenterText",{text:this.api.lang.getText("GAME_LAUNCH"),background:true,timer:2000},{bForceLoad:true});
         this.api.ui.getUIComponent("FightOptionButtons").onGameRunning();
         mcBanner.shortcuts.setCurrentTab("Spells");
      }
      this.api.ui.loadUIComponent("Timeline","Timeline");
      this.api.ui.unloadUIComponent("ChallengeMenu");
      this.api.gfx.unSelect(true);
      this.api.gfx.mapHandler.showingFightCells = false;
      if(!this.api.gfx.gridHandler.bGridVisible)
      {
         this.api.gfx.drawGrid();
      }
      this.api.datacenter.Game.setInteractionType("move");
      this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_NONE);
      this.api.kernel.GameManager.signalFightActivity();
      this.api.datacenter.Game.isRunning = true;
      var oSprites = this.api.datacenter.Sprites.getItems();
      for(var k in oSprites)
      {
         this.api.gfx.addSpriteExtraClip(k,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oSprites[k].Team]);
      }
      if(this.api.datacenter.Game.isTacticMode)
      {
         this.api.gfx.activateTacticMode(this.api,true);
      }
   }
   function onTurnStart(sExtraData)
   {
      if(this.api.datacenter.Game.isFirstTurn)
      {
         this.api.datacenter.Game.isFirstTurn = false;
         var oSprites = this.api.gfx.spriteHandler.getSprites().getItems();
         for(var sID in oSprites)
         {
            this.api.gfx.removeSpriteExtraClip(sID,true);
         }
      }
      var aDataParts = sExtraData.split("|");
      var sSpriteID = aDataParts[0];
      var nDuration = Number(aDataParts[1]) / 1000;
      var nTableTurn = Number(aDataParts[2]);
      var bPassiveTurn = aDataParts.length > 3 && aDataParts[3] == "1";
      this.api.datacenter.Game.currentTableTurn = nTableTurn;
      var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
      oSprite.GameActionsManager.clear();
      this.api.gfx.unSelect(true);
      this.api.datacenter.Game.currentPlayerID = sSpriteID;
      this.api.kernel.GameManager.cleanPlayer(this.api.datacenter.Game.lastPlayerID);
      this.api.ui.getUIComponent("Timeline").nextTurn(sSpriteID);
      if(this.api.datacenter.Player.isCurrentPlayer)
      {
         this.api.electron.makeNotification(this.api.lang.getText("PLAYER_TURN",[this.api.datacenter.Player.Name]));
         if(!this.api.datacenter.Game.passiveTurn && this.api.kernel.OptionsManager.getOption("StartTurnSound"))
         {
            this.api.sounds.events.onTurnStart();
         }
         if(this.api.kernel.GameManager.autoSkip && this.api.datacenter.Game.isFight)
         {
            this.api.network.Game.turnEnd();
         }
         this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_RELEASE_OVER_OUT);
         if(!bPassiveTurn)
         {
            this.api.datacenter.Player.SpellsManager.nextTurn();
         }
         this.api.ui.getUIComponent("Banner").startTimer(nDuration);
         this.api.kernel.GameManager.startInactivityDetector();
         if(this.api.gfx.rollOverMcSprite == undefined)
         {
            dofus.DofusCore.getInstance().forceMouseOver();
         }
         this.api.gfx.mapHandler.resetEmptyCells();
      }
      else
      {
         this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_NONE);
         this.api.ui.getUIComponent("Timeline").startChrono(nDuration);
         if(this.api.datacenter.Game.isSpectator && this.api.kernel.OptionsManager.getOption("SpriteInfos"))
         {
            this.api.ui.getUIComponent("Banner").showRightPanel("BannerSpriteInfos",{data:oSprite},true);
         }
      }
      if(!this.api.datacenter.Game.passiveTurn && this.api.kernel.OptionsManager.getOption("StringCourse"))
      {
         var aColors = [];
         aColors[1] = oSprite.color1;
         aColors[2] = oSprite.color2;
         aColors[3] = oSprite.color3;
         this.api.ui.loadUIComponent("StringCourse","StringCourse",{gfx:oSprite.artworkFile,name:oSprite.name,level:this.api.lang.getText("LEVEL_SMALL") + " " + oSprite.Level,colors:aColors,gfxID:oSprite.gfxID,bFilters:oSprite instanceof dofus.datacenter.Monster},{bForceLoad:true});
      }
      if(this.api.electron.isWindowFocused && (oSprite instanceof dofus.datacenter.Character && !this.api.datacenter.Game.passiveTurn))
      {
         var oVisualEffect = new ank.battlefield.datacenter.VisualEffect();
         oVisualEffect.file = dofus.Constants.HIGHLIGHT_FILE;
         oVisualEffect.bInFrontOfSprite = false;
         var nCellNum = oSprite.cellNum;
         this.api.gfx.spriteLaunchVisualEffect(sSpriteID,oVisualEffect,nCellNum,10);
      }
      this.api.kernel.GameManager.cleanUpGameArea(true);
      ank.utils.Timer.setTimer(this.api.network.Ping,"GameDecoDetect",this.api.network,this.api.network.quickPing,nDuration * 1000);
      this.api.kernel.TipsManager.showNewTip(dofus.managers.TipsManager.TIP_FIGHT_START);
   }
   function onTurnFinish(sExtraData)
   {
      var sSpriteID = sExtraData;
      var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
      if(this.api.datacenter.Player.isCurrentPlayer)
      {
         this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_CELL_NONE);
         this.api.kernel.GameManager.stopInactivityDetector();
         this.api.kernel.GameManager.onTurnEnd();
      }
      this.api.datacenter.Game.lastPlayerID = this.api.datacenter.Game.currentPlayerID;
      this.api.datacenter.Game.currentPlayerID = undefined;
      this.api.ui.getUIComponent("Banner").stopTimer();
      this.api.ui.getUIComponent("Timeline").stopChrono();
      this.api.kernel.GameManager.cleanUpGameArea(true);
   }
   function onTurnlist(sExtraData)
   {
      var aTurnSequence = sExtraData.split("|");
      this.api.datacenter.Game.turnSequence = aTurnSequence;
      this.api.ui.getUIComponent("Timeline").update();
   }
   function onTurnMiddle(sExtraData)
   {
      if(!this.api.datacenter.Game.isRunning)
      {
         ank.utils.Logger.err("[innerOnTurnMiddle] on est pas en combat");
         return undefined;
      }
      var aDataParts = sExtraData.split("|");
      var oSpriteUpdates = {};
      var i = 0;
      for(; i < aDataParts.length; i = i + 1)
      {
         var aSpriteParts = aDataParts[i].split(";");
         if(aSpriteParts.length != 0)
         {
            var sSpriteID = aSpriteParts[0];
            var bDying = aSpriteParts[1] != "1" ? false : true;
            var nLP = Number(aSpriteParts[2]);
            var nAP = Number(aSpriteParts[3]);
            var nMP = Number(aSpriteParts[4]);
            var nNewCell = Number(aSpriteParts[5]);
            var nLPMax = Number(aSpriteParts[6]);
            var nLPMax2 = Number(aSpriteParts[7]);
            oSpriteUpdates[sSpriteID] = true;
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
            if(oSprite != undefined)
            {
               var oSequencer = oSprite.sequencer;
               if(bDying)
               {
                  if(oSequencer.isPlaying())
                  {
                     continue;
                  }
                  oSprite.mc.clear();
                  this.api.gfx.removeSpriteOverHeadLayer(sSpriteID,"text");
               }
               else
               {
                  oSprite.LP = nLP;
                  oSprite.LPmax = nLPMax2;
                  oSprite.AP = nAP;
                  oSprite.MP = nMP;
                  if(oSequencer.isPlaying())
                  {
                     continue;
                  }
                  if(!_global.isNaN(nNewCell) && !oSprite.hasCarriedParent())
                  {
                     this.api.gfx.setSpritePosition(sSpriteID,nNewCell);
                  }
                  if(oSprite.hasCarriedChild())
                  {
                     oSprite.carriedChild.updateCarriedPosition();
                  }
               }
            }
            else
            {
               ank.utils.Logger.err("[onTurnMiddle] le sprite n\'existe pas");
            }
         }
      }
      var oAllSprites = this.api.datacenter.Sprites.getItems();
      for(var k in oAllSprites)
      {
         if(!oSpriteUpdates[k])
         {
            oAllSprites[k].mc.clear();
            this.api.datacenter.Sprites.removeItemAt(k);
         }
      }
      this.api.ui.getUIComponent("Timeline").timelineControl.updateCharacters();
   }
   function prepareTurnEnd()
   {
      if(!this.api.datacenter.Game.isRunning || (!this.api.datacenter.Game.isFight || !this.api.datacenter.Player.isCurrentPlayer))
      {
         return undefined;
      }
      var oSequencer = this.api.datacenter.Player.data.sequencer;
      if(oSequencer.containsAction(this,this.turnEnd))
      {
         return undefined;
      }
      oSequencer.addAction(24,false,this,this.turnEnd,[]);
      oSequencer.execute();
   }
   function onTurnReady(sExtraData)
   {
      var sSpriteID = sExtraData;
      var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
      if(oSprite != undefined)
      {
         var oSequencer = oSprite.sequencer;
         oSequencer.addAction(25,false,this,this.turnOk);
         oSequencer.execute();
      }
      else
      {
         ank.utils.Logger.err("[onTurnReday] le sprite " + sSpriteID + " n\'existe pas");
         this.turnOk2();
      }
   }
   function onMapData(sExtraData)
   {
      var aDataParts = sExtraData.split("|");
      var sMapId = aDataParts[0];
      var sDate = aDataParts[1];
      var sKey = aDataParts[2];
      if(Number(sMapId) == this.api.datacenter.Map.id)
      {
         this.api.gfx.onMapLoaded();
         return undefined;
      }
      this.api.gfx.showContainer(false);
      this.nLastMapIdReceived = _global.parseInt(sMapId,10);
      this.api.kernel.MapsServersManager.loadMap(sMapId,sDate,sKey);
   }
   function onMapLoaded()
   {
      this.api.gfx.showContainer(true);
      this.api.kernel.GameManager.applyCreatureMode();
      if(dofus.Constants.SAVING_THE_WORLD)
      {
         dofus.SaveTheWorld.getInstance().nextAction();
      }
      if(this.api.datacenter.Game.isRunning && this.api.datacenter.Game.isTacticMode)
      {
         this.api.gfx.activateTacticMode(this.api,true);
      }
   }
   function onCreateSolo()
   {
      this.api.datacenter.Player.InteractionsManager.setState(false);
      this.api.gfx.setInteraction(ank.battlefield.Constants.INTERACTION_OBJECT_RELEASE_OVER_OUT);
      this.api.ui.removeCursor();
      this.api.ui.getUIComponent("Banner").shortcuts.setCurrentTab("Items");
      this.api.datacenter.Basics.gfx_isSpritesHidden = false;
      this.api.gfx.spriteHandler.unmaskAllSprites();
      if(this.api.ui.getUIComponent("Banner") == undefined)
      {
         this.api.kernel.OptionsManager.applyAllOptions();
         this.api.ui.loadUIComponent("Banner","Banner",{data:this.api.datacenter.Player},{bAlwaysOnTop:true});
         this.api.ui.setScreenSize(742,432);
      }
      else
      {
         var _loc2_ = this.api.ui.getUIComponent("Banner");
         _loc2_.showPoints(false);
         _loc2_.showNextTurnButton(false);
         _loc2_.showGiveUpButton(false);
         this.api.ui.unloadUIComponent("FightOptionButtons");
         this.api.ui.unloadUIComponent("ChallengeMenu");
      }
      this.api.gfx.cleanMap(2);
   }
   function onPVP(sExtraData, bEnabled)
   {
      if(!bEnabled)
      {
         var _loc4_ = Number(sExtraData);
         this.api.kernel.showMessage(undefined,this.api.lang.getText("ASK_DISABLE_PVP",[_loc4_]),"CAUTION_YESNO",{name:"DisabledPVP",listener:this});
      }
      else
      {
         this.api.kernel.showMessage(undefined,this.api.lang.getText("ASK_ENABLED_PVP"),"CAUTION_YESNO",{name:"EnabledPVP",listener:this});
      }
   }
   function onHuntInfos(sExtraData)
   {
      var sHuntData = sExtraData.substring(1);
      var aDataParts = sHuntData.split("|");
      switch(sExtraData.charAt(0))
      {
         case "I":
            if(sHuntData == undefined || sHuntData.length == 0)
            {
               this.api.datacenter.Basics.pvpHuntedSpriteID = undefined;
            }
            else
            {
               this.api.datacenter.Basics.pvpHuntedSpriteID = sHuntData;
            }
            break;
         case "S":
            var sPreviousStatus = aDataParts[0];
            var sCurrentStatus = aDataParts[1];
            var bStatusChanged = sPreviousStatus != sCurrentStatus;
            var bActiveStatus = true;
            switch(sCurrentStatus)
            {
               case "WAITING_FOR_TARGET":
                  if(sPreviousStatus == "WAITING_FOR_START_CONFIRMATION")
                  {
                     this.api.kernel.showMessage(undefined,this.api.lang.getText("HUNT_NOT_AVAILABLE_ANYMORE"),"HUNT_CHAT");
                  }
                  else if(sPreviousStatus == "NOT_IN_MATCHMAKING")
                  {
                     this.api.kernel.showMessage(undefined,this.api.lang.getText("HUNT_LOOKING_FOR_TARGET_ALIGN_" + this.api.datacenter.Player.alignment.index),"HUNT_CHAT");
                  }
                  break;
               case "WAITING_FOR_START_CONFIRMATION_TIMEOUT":
                  bActiveStatus = false;
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("HUNT_REQUEST_TIMEOUT"),"HUNT_CHAT");
                  break;
               case "PLAYER_LEFT_MATCHMAKING":
                  bActiveStatus = false;
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("HUNTER_HAS_LEFT_MATCHMAKING"),"HUNT_CHAT");
                  break;
               case "HUNT_STARTED":
                  bActiveStatus = false;
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("HUNT_STARTED"),"HUNT_CHAT");
                  break;
               case "WAITING_FOR_START_CONFIRMATION":
                  var sHuntMessage = this.api.lang.getText("HUNT_FOUND_PART_1_ALIGN_" + this.api.datacenter.Player.alignment.index);
                  var nWinLossResult = Number(aDataParts[2]);
                  if(nWinLossResult == 1)
                  {
                     sHuntMessage += this.api.lang.getText("HUNT_FOUND_PART_2_AFTER_WIN");
                  }
                  else if(nWinLossResult == 2)
                  {
                     sHuntMessage += this.api.lang.getText("HUNT_FOUND_PART_2_AFTER_DEFEAT");
                  }
                  sHuntMessage += ". ";
                  sHuntMessage += this.api.lang.getText("HUNT_FOUND_PART_3");
                  this.api.kernel.showMessage(undefined,sHuntMessage,"HUNT_CHAT",undefined,"START_CONFIRMATION");
            }
            this.api.datacenter.Player.huntMatchmakingStatus = new dofus.datacenter.HuntMatchmakingStatus(bActiveStatus,sCurrentStatus);
      }
   }
   function hunterAcceptPvPHunt()
   {
      this.aks.send("GhA");
   }
   function toggleHunterMatchmakingRegister()
   {
      if(this.api.datacenter.Player.isHuntMatchmakingActive())
      {
         this.api.network.Game.hunterMatchmakingUnregister();
      }
      else
      {
         this.api.network.Game.hunterMatchmakingRegister();
      }
   }
   function hunterMatchmakingRegister()
   {
      this.aks.send("Ghr");
   }
   function hunterMatchmakingUnregister()
   {
      this.aks.send("Ghu");
   }
   function onFlag(sExtraData)
   {
      var aDataParts = sExtraData.split("|");
      var sSpriteID = aDataParts[0];
      var nCellNum = Number(aDataParts[1]);
      var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
      var oVisualEffect = new ank.battlefield.datacenter.VisualEffect();
      oVisualEffect.file = dofus.Constants.CLIPS_PATH + "flag.swf";
      oVisualEffect.bInFrontOfSprite = true;
      oVisualEffect.bTryToBypassContainerColor = true;
      this.api.kernel.showMessage(undefined,this.api.lang.getText("PLAYER_SET_FLAG",[oSprite.name,nCellNum]),"INFO_CHAT");
      this.api.gfx.spriteLaunchVisualEffect(sSpriteID,oVisualEffect,nCellNum,11,undefined,undefined,undefined,true);
   }
   function onFightChallenge(sExtraData)
   {
      var aDataParts = sExtraData.split(";");
      if(!this.api.ui.getUIComponent("FightChallenge"))
      {
         this.api.ui.loadUIComponent("FightChallenge","FightChallenge");
      }
      var oChallengeData = new dofus.datacenter.FightChallengeData(_global.parseInt(aDataParts[0]),aDataParts[1] == "1",_global.parseInt(aDataParts[2]),_global.parseInt(aDataParts[3]),_global.parseInt(aDataParts[4]),_global.parseInt(aDataParts[5]),_global.parseInt(aDataParts[6]));
      dofus.graphics.gapi.ui.FightChallenge(dofus.graphics.gapi.ui.FightChallenge(this.api.ui.getUIComponent("FightChallenge"))).addChallenge(oChallengeData);
   }
   function onFightChallengeUpdate(sExtraData, success)
   {
      var nChallengeId = _global.parseInt(sExtraData);
      dofus.graphics.gapi.ui.FightChallenge(dofus.graphics.gapi.ui.FightChallenge(this.api.ui.getUIComponent("FightChallenge"))).updateChallenge(nChallengeId,success);
      var sChallengeMessage = !success ? this.api.lang.getText("FIGHT_CHALLENGE_FAILED") : this.api.lang.getText("FIGHT_CHALLENGE_DONE");
      sChallengeMessage += " : " + this.api.lang.getFightChallenge(nChallengeId).n;
      this.api.kernel.showMessage(undefined,sChallengeMessage,"INFO_CHAT");
   }
   function cancel(oEvent)
   {
      var sComponentName = oEvent.target._name;
   }
   function yes(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "AskYesNoEnabledPVP":
            this.api.network.Game.enabledPVPMode(true);
            break;
         case "AskYesNoDisabledPVP":
            this.api.network.Game.enabledPVPMode(false);
      }
   }
   function no(oEvent)
   {
      var sComponentName = oEvent.target._name;
   }
}
