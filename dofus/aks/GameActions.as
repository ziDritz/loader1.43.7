class dofus.aks.GameActions extends dofus.aks.Handler
{
   var _ex;
   function GameActions(oAKS, oAPI)
   {
      super.initialize(oAKS,oAPI);
      this._ex = new dofus.aks.extend.GameActionsEx(oAPI,this);
   }
   function warning(sWarning)
   {
      this.infoImportanteDecompilo("Hello, we would like to tell you that modifying your Dofus client or sharing a modified client is strictly FORBIDDEN.");
      this.infoImportanteDecompilo("Modifying your client in any way will also flag you as a bot by our security systems.");
      this.infoImportanteDecompilo("Bonjour, nous souhaitons vous avertir que toute modification du client ou partage d\'un client modifié est strictement INTERDIT.");
      this.infoImportanteDecompilo("Modifier votre client (et ce quelque soit le type de modification) aura également pour conséquence de vous identifier comme un BOT par nos systèmes de sécurité.");
   }
   function infoImportanteDecompilo(sInfoPourLesMargoulins)
   {
   }
   function sendActions(nActionType, aParams)
   {
      var sUnused = new String();
      this.aks.send("GA" + new ank.utils.ExtendedString(nActionType).addLeftChar("0",3) + aParams.join(";"));
   }
   function actionAck(nActionID)
   {
      this.aks.send("GKK" + nActionID,false);
   }
   function actionCancel(nActionID, params)
   {
      this.aks.send("GKE" + nActionID + "|" + params,false);
   }
   function challenge(sSpriteID)
   {
      this.sendActions(900,[sSpriteID]);
   }
   function acceptChallenge(sSpriteID)
   {
      this.sendActions(901,[sSpriteID]);
   }
   function refuseChallenge(sSpriteID)
   {
      this.sendActions(902,[sSpriteID]);
   }
   function joinChallenge(nChallengeID, sSpriteID)
   {
      this.sendActions(903,[nChallengeID,sSpriteID]);
   }
   function joinChallengeAsSpectator(nChallengeID, sSpriteID)
   {
      if(this.api.datacenter.Game.isRunning || this.api.datacenter.Exchange != undefined)
      {
         this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_BECAUSE_BUSY"),"ERROR_CHAT");
         return undefined;
      }
      if(sSpriteID == undefined)
      {
         sSpriteID = "-1";
      }
      this.sendActions(976,[nChallengeID,sSpriteID]);
   }
   function attack(sSpriteID)
   {
      this.sendActions(906,[sSpriteID]);
   }
   function attackTaxCollector(sSpriteID)
   {
      this.sendActions(909,[sSpriteID]);
   }
   function mutantAttack(sSpriteID)
   {
      this.sendActions(910,[sSpriteID]);
   }
   function attackPrism(sSpriteID)
   {
      this.sendActions(912,[sSpriteID]);
   }
   function usePrism(sSpriteID)
   {
      this.sendActions(512,[sSpriteID]);
   }
   function acceptMarriage(sSpriteID)
   {
      this.sendActions(618,[sSpriteID]);
   }
   function refuseMarriage(sSpriteID)
   {
      this.sendActions(619,[sSpriteID]);
   }
   function bringHuntTarget()
   {
      this.sendActions(920,[]);
   }
   function onActionsStart(sExtraData)
   {
      var sPlayerID = sExtraData;
      if(sPlayerID != this.api.datacenter.Player.ID)
      {
         return undefined;
      }
      var oPlayerData = this.api.datacenter.Player.data;
      oPlayerData.GameActionsManager.m_bNextAction = true;
      if(this.api.datacenter.Game.isFight)
      {
         var oSequencer = oPlayerData.sequencer;
         oSequencer.execute();
      }
   }
   function onActionsFinish(sExtraData)
   {
      var aDataParts = sExtraData.split("|");
      var nActionID = Number(aDataParts[0]);
      var sPlayerID = aDataParts[1];
      if(sPlayerID != this.api.datacenter.Player.ID)
      {
         return undefined;
      }
      var oPlayerData = this.api.datacenter.Player.data;
      var oSequencer = oPlayerData.sequencer;
      oPlayerData.GameActionsManager.m_bNextAction = false;
      if(this.api.datacenter.Game.isFight)
      {
         oSequencer.addAction(32,false,this.api.kernel.GameManager,this.api.kernel.GameManager.setEnabledInteractionIfICan,[ank.battlefield.Constants.INTERACTION_CELL_RELEASE_OVER_OUT]);
         if(nActionID != undefined)
         {
            oSequencer.addAction(33,false,this,this.actionAck,[nActionID]);
         }
         oSequencer.addAction(34,false,this.api.kernel.GameManager,this.api.kernel.GameManager.cleanPlayer,[sPlayerID]);
         this.api.gfx.mapHandler.resetEmptyCells();
         oSequencer.execute();
         if(nActionID == 2)
         {
            this.api.kernel.TipsManager.showNewTip(dofus.managers.TipsManager.TIP_FIGHT_ENDMOVE);
         }
      }
   }
   function onActions(sExtraData)
   {
      var nSeparatorIndex = sExtraData.indexOf(";");
      var nFrameID = Number(sExtraData.substring(0,nSeparatorIndex));
      if(dofus.Constants.SAVING_THE_WORLD)
      {
         if(sExtraData == ";0")
         {
            dofus.SaveTheWorld.getInstance().nextActionIfOnSafe();
         }
      }
      sExtraData = sExtraData.substring(nSeparatorIndex + 1);
      nSeparatorIndex = sExtraData.indexOf(";");
      var nActionType = Number(sExtraData.substring(0,nSeparatorIndex));
      sExtraData = sExtraData.substring(nSeparatorIndex + 1);
      nSeparatorIndex = sExtraData.indexOf(";");
      var sActorID = sExtraData.substring(0,nSeparatorIndex);
      var sActionParams = sExtraData.substring(nSeparatorIndex + 1);
      if(sActorID.length == 0)
      {
         sActorID = this.api.datacenter.Player.ID;
      }
      var nCurrentPlayerID = this.api.datacenter.Game.currentPlayerID;
      if(this.api.datacenter.Game.isFight && nCurrentPlayerID != undefined)
      {
         var nActiveSpriteID = nCurrentPlayerID;
      }
      else
      {
         nActiveSpriteID = sActorID;
      }
      var oSprite = this.api.datacenter.Sprites.getItemAt(nActiveSpriteID);
      var oSequencer = oSprite.sequencer;
      var oGameActionsManager = oSprite.GameActionsManager;
      var oContext = {};
      oContext.bSequence = true;
      var nServerResponse = oGameActionsManager.onServerResponse(nFrameID);
      if(!this._ex.onActionEx(sExtraData,nActionType,sActorID,oSequencer,sActionParams,oContext))
      {
         return undefined;
      }
      switch(nActionType)
      {
         case 0:
            return undefined;
         case 11:
            var aParams = sActionParams.split(",");
            var sSpriteID = aParams[0];
            var nDirection = Number(aParams[1]);
            oSequencer.addAction(43,false,this.api.gfx,this.api.gfx.setSpriteDirection,[sSpriteID,nDirection]);
            break;
         case 50:
            var sSpriteWithCarryID = sActionParams;
            oSequencer.addAction(44,false,this.api.gfx,this.api.gfx.carriedSprite,[sSpriteWithCarryID,sActorID]);
            oSequencer.addAction(45,false,this.api.gfx,this.api.gfx.removeSpriteExtraClip,[sSpriteWithCarryID]);
            break;
         case 51:
            var nCellNum = Number(sActionParams);
            var oCarrierSprite = this.api.datacenter.Sprites.getItemAt(sActorID);
            var oCarriedChild = oCarrierSprite.carriedChild;
            var oVisualEffect = new ank.battlefield.datacenter.VisualEffect();
            oVisualEffect.file = dofus.Constants.SPELLS_PATH + "1200.swf";
            oVisualEffect.level = 1;
            oVisualEffect.bInFrontOfSprite = true;
            oVisualEffect.bTryToBypassContainerColor = false;
            this.api.gfx.spriteLaunchCarriedSprite(sActorID,oVisualEffect,nCellNum,31,10);
            oSequencer.addAction(46,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[oCarriedChild.id,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oCarriedChild.Team]]);
            break;
         case 52:
            var aParams23 = sActionParams.split(",");
            var sSpriteToUncarryID = aParams23[0];
            var oSpriteToUncarry = this.api.datacenter.Sprites.getItemAt(sSpriteToUncarryID);
            var nDropCellNum = Number(aParams23[1]);
            if(oSpriteToUncarry.hasCarriedParent() && !oSpriteToUncarry.uncarryingSprite)
            {
               oSpriteToUncarry.uncarryingSprite = true;
               oSequencer.addAction(47,false,this.api.gfx,this.api.gfx.uncarriedSprite,[sSpriteToUncarryID,nDropCellNum,true,oSequencer]);
               oSequencer.addAction(48,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[sSpriteToUncarryID,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oSpriteToUncarry.Team]]);
            }
            break;
         case 100:
         case 108:
         case 110:
            var aLPData = sActionParams.split(",");
            var sSpriteID27 = aLPData[0];
            var oTargetSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID27);
            var nLPDamage = Number(aLPData[1]);
            var nElementID = Number(aLPData[2]);
            var sElementColor = dofus.Constants.getElementColorById(nElementID);
            var bIsNegativeDamage = nLPDamage <= 0;
            var sMessageKey = !bIsNegativeDamage ? "WIN_LP" : "LOST_LP";
            var aMessageParams = [];
            aMessageParams.push(Math.abs(nLPDamage));
            if(sElementColor != undefined && this.api.kernel.OptionsManager.getOption("SeeDamagesColor"))
            {
               aMessageParams.push(sElementColor);
            }
            oSequencer.addAction(49,false,this.api.kernel.ChatManager.feMessagesBuffer,this.api.kernel.ChatManager.feMessagesBuffer.addFightEventMessage,[nActionType,[sMessageKey],aMessageParams,oTargetSprite.id,oTargetSprite.name]);
            if(nLPDamage != 0)
            {
               oSequencer.addAction(50,false,oTargetSprite,oTargetSprite.updateLP,[nLPDamage]);
               oSequencer.addAction(51,false,this.api.ui.getUIComponent("Timeline").timelineControl,this.api.ui.getUIComponent("Timeline").timelineControl.updateCharacters);
            }
            break;
         case 101:
         case 102:
         case 111:
         case 120:
         case 168:
            var aAPData = sActionParams.split(",");
            var oAPSprite = this.api.datacenter.Sprites.getItemAt(aAPData[0]);
            var nAPChange = Number(aAPData[1]);
            if(nAPChange == 0)
            {
               break;
            }
            if(nActionType == 101 || (nActionType == 111 || (nActionType == 120 || nActionType == 168)))
            {
               var bIsNegativeAP = nAPChange < 0;
               var sAPMessageKey = !bIsNegativeAP ? "WIN_AP" : "LOST_AP";
               var sAPValue = String(Math.abs(nAPChange));
               oSequencer.addAction(53,false,this.api.kernel.ChatManager.feMessagesBuffer,this.api.kernel.ChatManager.feMessagesBuffer.addFightEventMessage,[nActionType,[sAPMessageKey],[sAPValue],oAPSprite.id,oAPSprite.name]);
            }
            oSequencer.addAction(54,false,oAPSprite,oAPSprite.updateAP,[nAPChange,nActionType == 102]);
            break;
         case 127:
         case 129:
         case 128:
         case 78:
         case 169:
            var aMPData = sActionParams.split(",");
            var sMPSpriteID = aMPData[0];
            var nMPChange = Number(aMPData[1]);
            var oMPSprite = this.api.datacenter.Sprites.getItemAt(sMPSpriteID);
            if(nMPChange == 0)
            {
               break;
            }
            if(nActionType == 127 || (nActionType == 128 || (nActionType == 169 || nActionType == 78)))
            {
               var bIsNegativeMP = nMPChange < 0;
               var sMPMessageKey = !bIsNegativeMP ? "WIN_MP" : "LOST_MP";
               var sMPValue = String(Math.abs(nMPChange));
               oSequencer.addAction(55,false,this.api.kernel.ChatManager.feMessagesBuffer,this.api.kernel.ChatManager.feMessagesBuffer.addFightEventMessage,[nActionType,[sMPMessageKey],[sMPValue],oMPSprite.id,oMPSprite.name]);
            }
            oSequencer.addAction(56,false,oMPSprite,oMPSprite.updateMP,[nMPChange,nActionType == 129]);
            break;
         case 103:
            var sDeadSpriteID = sActionParams;
            var oDeadSprite = this.api.datacenter.Sprites.getItemAt(sDeadSpriteID);
            var mcDeadSprite = oDeadSprite.mc;
            if(mcDeadSprite == undefined)
            {
               return undefined;
            }
            oDeadSprite.isPendingClearing = true;
            var sDeadSpriteGender = oDeadSprite.sex != 1 ? "m" : "f";
            oSequencer.addAction(57,false,this.api.kernel.ChatManager.feMessagesBuffer,this.api.kernel.ChatManager.feMessagesBuffer.addFightEventMessage,[nActionType,["DIE"],sDeadSpriteGender,oDeadSprite.id,oDeadSprite.name]);
            var oTimelineUI = this.api.ui.getUIComponent("Timeline");
            oSequencer.addAction(58,false,oTimelineUI,oTimelineUI.hideItem,[sDeadSpriteID]);
            oSequencer.addAction(176,false,this.api.gfx,this.api.gfx.removeEffectsByCasterID,[sDeadSpriteID]);
            this.warning("You\'re not allowed to change the behaviour of the game animations. Please play legit !");
            this.warning("Toute modification du comportement des animations est détectée et sanctionnée car c\'est considéré comme de la triche, merci de jouer legit !");
            if(!this.api.datacenter.Player.isSkippingFightAnimations)
            {
               oSequencer.addAction(59,true,mcDeadSprite,mcDeadSprite.setAnim,["Die"],1500,true);
            }
            this.warning("Vous n\'êtes même pas sensé pouvoir lire ce message, mais un rappel de plus n\'est pas de trop pour certains : modification du client = ban ;)");
            oSequencer.addAction(61,false,mcDeadSprite,mcDeadSprite.clear);
            if(oDeadSprite.hasCarriedChild() && !oDeadSprite.uncarryingSprite)
            {
               oDeadSprite.uncarryingSprite = true;
               oSequencer.addAction(172,false,this.api.gfx,this.api.gfx.uncarriedSprite,[oDeadSprite.carriedSprite.id,oDeadSprite.cellNum,false,oSequencer]);
               oSequencer.addAction(60,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[oDeadSprite.carriedChild.id,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oDeadSprite.carriedChild.Team]]);
            }
            if(this.api.datacenter.Player.summonedCreaturesID[sDeadSpriteID])
            {
               this.api.datacenter.Player.SummonedCreatures--;
               delete this.api.datacenter.Player.summonedCreaturesID[sDeadSpriteID];
               this.api.ui.getUIComponent("Banner").shortcuts.setSpellStateOnAllContainers();
            }
            if(sDeadSpriteID == this.api.datacenter.Player.ID)
            {
               if(sActorID == this.api.datacenter.Player.ID)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_KILLED_HIMSELF);
               }
               else
               {
                  var nPlayerTeam = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
                  var nAttackerTeam = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sActorID)).Team;
                  if(nPlayerTeam == nAttackerTeam)
                  {
                     this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_KILLED_BY_ALLY);
                  }
                  else
                  {
                     this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_KILLED_BY_ENEMY);
                  }
               }
               this.api.datacenter.Player.isDead = true;
               this.api.ui.getUIComponent("Banner").shortcuts.setSpellStateOnAllContainers();
               this.api.gfx.clearSpellPreview();
            }
            else if(sActorID == this.api.datacenter.Player.ID)
            {
               var nPlayerTeam56 = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var nVictimTeam = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sDeadSpriteID)).Team;
               if(nPlayerTeam56 == nVictimTeam)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_KILL_ALLY);
               }
               else
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_KILL_ENEMY);
               }
            }
            break;
         case 104:
            var oBlockedSprite = this.api.datacenter.Sprites.getItemAt(sActorID);
            var mcBlockedSprite = oBlockedSprite.mc;
            oSequencer.addAction(62,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("CANT_MOVEOUT"),"INFO_FIGHT_CHAT"]);
            if(!this.api.datacenter.Player.isSkippingFightAnimations && this.api.electron.isWindowFocused)
            {
               oSequencer.addAction(63,false,mcBlockedSprite,mcBlockedSprite.setAnim,["Hit"]);
            }
            break;
         case 105:
         case 164:
            var aReduceDmgData = sActionParams.split(",");
            var sTargetID = aReduceDmgData[0];
            var sReduction = nActionType != 164 ? aReduceDmgData[1] : aReduceDmgData[1] + "%";
            var oTargetSprite63 = this.api.datacenter.Sprites.getItemAt(sTargetID);
            oSequencer.addAction(64,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("REDUCE_DAMAGES",[oTargetSprite63.name,sReduction]),"INFO_FIGHT_CHAT"]);
            break;
         case 106:
            var aReturnSpellData = sActionParams.split(",");
            var sReturnSpellTargetID = aReturnSpellData[0];
            var bReturnSpellSuccess = sReturnSpellData[1] == "1";
            var oReturnSpellSprite = this.api.datacenter.Sprites.getItemAt(sReturnSpellTargetID);
            var sReturnSpellMessage = !bReturnSpellSuccess ? this.api.lang.getText("RETURN_SPELL_NO",[oReturnSpellSprite.name]) : this.api.lang.getText("RETURN_SPELL_OK",[oReturnSpellSprite.name]);
            oSequencer.addAction(65,false,this.api.kernel,this.api.kernel.showMessage,[undefined,sReturnSpellMessage,"INFO_FIGHT_CHAT"]);
            break;
         case 107:
            var aReturnDmgData = sActionParams.split(",");
            var sReturnDmgTargetID = aReturnDmgData[0];
            var nReturnDmgValue = aReturnDmgData[1];
            var oReturnDmgSprite = this.api.datacenter.Sprites.getItemAt(sReturnDmgTargetID);
            oSequencer.addAction(66,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("RETURN_DAMAGES",[oReturnDmgSprite.name,nReturnDmgValue]),"INFO_FIGHT_CHAT"]);
            break;
         case 130:
            var nGoldStolen = Number(sActionParams);
            var oThiefSprite = this.api.datacenter.Sprites.getItemAt(sActorID);
            oSequencer.addAction(67,false,this.api.kernel,this.api.kernel.showMessage,[undefined,ank.utils.PatternDecoder.combine(this.api.lang.getText("STEAL_GOLD",[oThiefSprite.name,nGoldStolen]),"m",nGoldStolen < 2),"INFO_FIGHT_CHAT"]);
            break;
         case 132:
            var oDebuffer = this.api.datacenter.Sprites.getItemAt(sActorID);
            var oDebuffTarget = this.api.datacenter.Sprites.getItemAt(sActionParams);
            oSequencer.addAction(68,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("REMOVE_ALL_EFFECTS",[oDebuffer.name,oDebuffTarget.name]),"INFO_FIGHT_CHAT"]);
            oSequencer.addAction(69,false,oDebuffTarget.CharacteristicsManager,oDebuffTarget.CharacteristicsManager.terminateAllEffects);
            oSequencer.addAction(70,false,oDebuffTarget.EffectsManager,oDebuffTarget.EffectsManager.terminateAllEffects);
            break;
         case 140:
            var nPassTurnValue = Number(sActionParams);
            var oPassTurnCaster = this.api.datacenter.Sprites.getItemAt(sActorID);
            var oPassTurnTarget = this.api.datacenter.Sprites.getItemAt(sActionParams);
            oSequencer.addAction(71,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("A_PASS_NEXT_TURN",[oPassTurnTarget.name]),"INFO_FIGHT_CHAT"]);
            break;
         case 151:
            var nObstacleSpellID = Number(sActionParams);
            var oObstacleSprite = this.api.datacenter.Sprites.getItemAt(sActorID);
            var sObstacleMessage = nObstacleSpellID != -1 ? this.api.lang.getText("INVISIBLE_OBSTACLE",[oObstacleSprite.name,this.api.lang.getSpellText(nObstacleSpellID).n]) : this.api.lang.getText("CANT_DO_INVISIBLE_OBSTACLE");
            oSequencer.addAction(72,false,this.api.kernel,this.api.kernel.showMessage,[undefined,sObstacleMessage,"ERROR_CHAT"]);
            break;
         case 166:
            var aReturnAPData = sActionParams.split(",");
            var nReturnAPCasterID = Number(aReturnAPData[0]);
            var oReturnAPSprite = this.api.datacenter.Sprites.getItemAt(sActorID);
            var nReturnAPAmount = Number(aReturnAPData[1]);
            oSequencer.addAction(73,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("RETURN_AP",[oReturnAPSprite.name,nReturnAPAmount]),"INFO_FIGHT_CHAT"]);
            break;
         case 164:
            var aReduceLPDmgData = sActionParams.split(",");
            var nReduceLPDmgCasterID = Number(aReduceLPDmgData[0]);
            var oReduceLPDmgSprite = this.api.datacenter.Sprites.getItemAt(sActorID);
            var nReduceLPDmgAmount = Number(aReduceLPDmgData[1]);
            oSequencer.addAction(74,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("REDUCE_LP_DAMAGES",[oReduceLPDmgSprite.name,nReduceLPDmgAmount]),"INFO_FIGHT_CHAT"]);
            break;
         case 780:
            if(sActorID == this.api.datacenter.Player.ID)
            {
               this.api.datacenter.Player.SummonedCreatures = this.api.datacenter.Player.SummonedCreatures + 1;
               var nSummonedID = _global.parseInt(sActionParams.split(";")[3]);
               this.api.datacenter.Player.summonedCreaturesID[nSummonedID] = true;
            }
         case 147:
            var sSummonedSpriteID = sActionParams.split(";")[3];
            var oTimelineUI147 = this.api.ui.getUIComponent("Timeline");
            oSequencer.addAction(75,false,oTimelineUI147,oTimelineUI147.showItem,[sSummonedSpriteID]);
            oSequencer.addAction(76,false,this.aks.Game.extendIn,this.aks.Game.extendIn.onMovement,[sActionParams,true]);
            if(sSummonedSpriteID == this.api.datacenter.Player.ID)
            {
               this.api.datacenter.Player.isDead = false;
               this.api.ui.getUIComponent("Banner").shortcuts.setSpellStateOnAllContainers();
            }
            break;
         case 180:
         case 181:
            var sSummonedCreatureID = sActionParams.split(";")[3];
            if(sActorID == this.api.datacenter.Player.ID)
            {
               this.api.datacenter.Player.SummonedCreatures = this.api.datacenter.Player.SummonedCreatures + 1;
               this.api.datacenter.Player.summonedCreaturesID[sSummonedCreatureID] = true;
            }
            oSequencer.addAction(77,false,this.aks.Game.extendIn,this.aks.Game.extendIn.onMovement,[sActionParams,true]);
            break;
         case 185:
            oSequencer.addAction(78,false,this.aks.Game.extendIn,this.aks.Game.extendIn.onMovement,[sActionParams]);
            break;
         case 2144:
            oSequencer.addAction(179,false,this.aks.Game.extendIn,this.aks.Game.extendIn.onMovement,[sActionParams]);
            break;
         case 2011:
            var aSpellParamsData = sActionParams.split(",");
            var sSpellTargetID = aSpellParamsData[0];
            var oSpellTargetSprite = this.api.datacenter.Sprites.getItemAt(sSpellTargetID);
            var oEffectsManager = oSpellTargetSprite.EffectsManager;
            oEffectsManager.removeEffectsByType(2010);
         case 117:
         case 116:
         case 115:
         case 122:
         case 112:
         case 142:
         case 145:
         case 138:
         case 114:
         case 182:
         case 118:
         case 157:
         case 123:
         case 152:
         case 126:
         case 155:
         case 119:
         case 154:
         case 124:
         case 156:
         case 125:
         case 153:
         case 160:
         case 161:
         case 162:
         case 163:
         case 606:
         case 607:
         case 608:
         case 609:
         case 610:
         case 611:
         case 186:
         case 210:
         case 211:
         case 212:
         case 213:
         case 214:
         case 215:
         case 216:
         case 217:
         case 218:
         case 219:
         case 240:
         case 241:
         case 242:
         case 243:
         case 244:
         case 245:
         case 246:
         case 247:
         case 248:
         case 249:
         case 178:
         case 179:
         case 225:
         case 226:
         case 2008:
         case 2009:
         case 2010:
         case 2112:
         case 2113:
         case 2114:
            var aEffectData = sActionParams.split(",");
            var sEffectTargetID = aEffectData[0];
            var oEffectTargetSprite = this.api.datacenter.Sprites.getItemAt(sEffectTargetID);
            var nEffectValue1 = Number(aEffectData[1]);
            var nEffectValue2 = Number(aEffectData[2]);
            var oCharacteristicsManager = oEffectTargetSprite.CharacteristicsManager;
            var oNewEffect = new dofus.datacenter.Effect(undefined,nActionType,nEffectValue1,undefined,undefined,undefined,nEffectValue2);
            oSequencer.addAction(79,false,oCharacteristicsManager,oCharacteristicsManager.addEffect,[oNewEffect]);
            oSequencer.addAction(80,false,this.api.kernel.ChatManager.feMessagesBuffer,this.api.kernel.ChatManager.feMessagesBuffer.addFightEventMessage,[nActionType,undefined,[oNewEffect.description],oEffectTargetSprite.id,oEffectTargetSprite.name]);
            break;
         case 149:
            var aSpecialEffectData = sActionParams.split(",");
            var sSpecialEffectTargetID = aSpecialEffectData[0];
            var oSpecialEffectSprite = this.api.datacenter.Sprites.getItemAt(sSpecialEffectTargetID);
            var nSpecialEffectParam1 = Number(aSpecialEffectData[1]);
            var nSpecialEffectParam2 = Number(aSpecialEffectData[2]);
            var nSpecialEffectParam3 = Number(aSpecialEffectData[3]);
            var nSpecialEffectParam4 = Number(aSpecialEffectData[4]);
            var nSpecialEffectParam5 = Number(aSpecialEffectData[5]);
            oSequencer.addAction(81,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("GFX",[oSpecialEffectSprite.name]),"INFO_FIGHT_CHAT"]);
            var oSpecialCharManager = oSpecialEffectSprite.CharacteristicsManager;
            var oSpecialNewEffect = new dofus.datacenter.Effect(undefined,nActionType,nSpecialEffectParam1,nSpecialEffectParam2,undefined,nSpecialEffectParam4 + "," + nSpecialEffectParam5,nSpecialEffectParam3);
            oSequencer.addAction(82,false,oSpecialCharManager,oSpecialCharManager.addEffect,[oSpecialNewEffect]);
            break;
         case 150:
            var aInvisibilityData = sActionParams.split(",");
            var sInvisTargetID = aInvisibilityData[0];
            var oInvisTargetSprite = this.api.datacenter.Sprites.getItemAt(sInvisTargetID);
            var nInvisibilityLevel = Number(aInvisibilityData[1]);
            var bInvisibilityVisible = Number(aInvisibilityData[2]) == 1;
            if(nInvisibilityLevel > 0)
            {
               oSequencer.addAction(83,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("INVISIBILITY",[oInvisTargetSprite.name]),"INFO_FIGHT_CHAT"]);
               oSequencer.addAction(177,false,oInvisTargetSprite,oInvisTargetSprite.setInvisibleInFight,[true]);
               if(sInvisTargetID == this.api.datacenter.Player.ID || bInvisibilityVisible)
               {
                  oSequencer.addAction(84,false,oInvisTargetSprite.mc,oInvisTargetSprite.mc.setAlpha,[40]);
               }
               else
               {
                  oSequencer.addAction(85,false,oInvisTargetSprite.mc,oInvisTargetSprite.mc.setVisible,[false]);
               }
            }
            else
            {
               oSequencer.addAction(86,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("VISIBILITY",[oInvisTargetSprite.name]),"INFO_FIGHT_CHAT"]);
               oSequencer.addAction(178,false,oInvisTargetSprite,oInvisTargetSprite.setInvisibleInFight,[false]);
               this.api.gfx.hideSprite(sInvisTargetID,false);
               if(oInvisTargetSprite.allowGhostMode && this.api.gfx.bGhostView)
               {
                  this.api.gfx.setSpriteAlpha(sInvisTargetID,ank.battlefield.Constants.GHOSTVIEW_SPRITE_ALPHA);
               }
               else
               {
                  this.api.gfx.setSpriteAlpha(sInvisTargetID,100);
               }
            }
            break;
         case 165:
            var aDebilityData = sActionParams.split(",");
            var sDebilitySpriteID = aDebilityData[0];
            var nDebilityValue1 = Number(aDebilityData[1]);
            var nDebilityValue2 = Number(aDebilityData[2]);
            var nDebilityValue3 = Number(aDebilityData[3]);
            break;
         case 200:
            var aObjectData = sActionParams.split(",");
            var nObjectID = Number(aObjectData[0]);
            var nObjectFrame = Number(aObjectData[1]);
            oSequencer.addAction(87,false,this.api.gfx,this.api.gfx.setObject2Frame,[nObjectID,nObjectFrame]);
            break;
         case 208:
            var aVisualEffectData = sActionParams.split(",");
            var oCasterSprite = this.api.datacenter.Sprites.getItemAt(sActorID);
            var nEffectCellNum = Number(aVisualEffectData[0]);
            var sEffectFile = aVisualEffectData[1];
            var nEffectDelay = Number(aVisualEffectData[2]);
            var aAnimFrames = !_global.isNaN(Number(aVisualEffectData[3])) ? "anim" + aVisualEffectData[3] : String(aVisualEffectData[3]).split("~");
            var nEffectLevel = aVisualEffectData[4] == undefined ? 1 : Number(aVisualEffectData[4]);
            var oVisualEffect208 = new ank.battlefield.datacenter.VisualEffect();
            oVisualEffect208.file = dofus.Constants.SPELLS_PATH + sEffectFile + ".swf";
            oVisualEffect208.level = nEffectLevel;
            oVisualEffect208.bInFrontOfSprite = true;
            oVisualEffect208.bTryToBypassContainerColor = true;
            this.api.gfx.spriteLaunchVisualEffect(sActorID,oVisualEffect208,nEffectCellNum,nEffectDelay,aAnimFrames);
            break;
         case 228:
            var aVisualEffect228Data = sActionParams.split(",");
            var oCasterSprite228 = this.api.datacenter.Sprites.getItemAt(sActorID);
            var nEffectCell228 = Number(aVisualEffect228Data[0]);
            var sEffectFile228 = aVisualEffect228Data[1];
            var nEffectDelay228 = Number(aVisualEffect228Data[2]);
            var aAnimFrames228 = !_global.isNaN(Number(aVisualEffect228Data[3])) ? "anim" + aVisualEffect228Data[3] : String(aVisualEffect228Data[3]).split("~");
            var nEffectLevel228 = aVisualEffect228Data[4] == undefined ? 1 : Number(aVisualEffect228Data[4]);
            var oVisualEffect228 = new ank.battlefield.datacenter.VisualEffect();
            oVisualEffect228.file = dofus.Constants.SPELLS_PATH + sEffectFile228 + ".swf";
            oVisualEffect228.level = nEffectLevel228;
            oVisualEffect228.bInFrontOfSprite = true;
            oVisualEffect228.bTryToBypassContainerColor = false;
            this.api.gfx.spriteLaunchVisualEffect(sActorID,oVisualEffect228,nEffectCell228,nEffectDelay228,aAnimFrames228);
            break;
         case 857:
            var aCinematicData = sActionParams.split(",");
            var sCinematicFile = aCinematicData[0];
            var bCinematicBackground = !!Number(aCinematicData[1]);
            var bCinematicBanner = !!Number(aCinematicData[2]);
            var bCinematicNPC = !!Number(aCinematicData[3]);
            var nCinematicFrameStart = Number(aCinematicData[4]);
            var bCinematicCanCancel = !!Number(aCinematicData[5]);
            var bCinematicMonster = !!aCinematicData[6];
            this.api.ui.loadUIComponent("Cinematic","Cinematic",{file:dofus.Constants.CINEMATICS_PATH + sCinematicFile + ".swf",background:bCinematicBackground,banner:bCinematicBanner,npc:bCinematicNPC,frameToStart:nCinematicFrameStart,canCancel:bCinematicCanCancel,monster:bCinematicMonster});
            break;
         case 999:
            oSequencer.addAction(116,false,this.aks,this.aks.processCommand,[sActionParams]);
      }
      if(!_global.isNaN(nFrameID) && sActorID == this.api.datacenter.Player.ID)
      {
         oSequencer.addAction(117,false,oGameActionsManager,oGameActionsManager.ack,[nFrameID]);
      }
      else
      {
         oGameActionsManager.end(nActiveSpriteID == this.api.datacenter.Player.ID);
      }
      if(!oSequencer.isPlaying() && oContext.bSequence)
      {
         oSequencer.execute(true);
      }
   }
   function cancel(oEvent)
   {
      var sComponentName = null;
      if((sComponentName = oEvent.target._name) === "AskCancelChallenge")
      {
         this.refuseChallenge(oEvent.params.spriteID);
      }
   }
   function yes(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "AskYesNoIgnoreChallenge":
            this.acceptChallenge(oEvent.params.spriteID);
            break;
         case "AskYesNoMarriage":
            this.acceptMarriage(oEvent.params.refID);
            this.api.gfx.addSpriteBubble(oEvent.params.spriteID,this.api.lang.getText("YES"));
      }
   }
   function no(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "AskYesNoIgnoreChallenge":
            this.refuseChallenge(oEvent.params.spriteID);
            break;
         case "AskYesNoMarriage":
            this.refuseMarriage(oEvent.params.refID);
            this.api.gfx.addSpriteBubble(oEvent.params.spriteID,this.api.lang.getText("NO"));
      }
   }
   function ignore(oEvent)
   {
      var sComponentName = null;
      if((sComponentName = oEvent.target._name) === "AskYesNoIgnoreChallenge")
      {
         this.api.kernel.ChatManager.addToBlacklist(oEvent.params.player);
         this.api.kernel.showMessage(undefined,this.api.lang.getText("TEMPORARY_BLACKLISTED",[oEvent.params.player]),"INFO_CHAT");
         this.refuseChallenge(oEvent.params.spriteID);
      }
   }
}
