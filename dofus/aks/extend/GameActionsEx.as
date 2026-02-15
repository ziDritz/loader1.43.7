class dofus.aks.extend.GameActionsEx
{
   var api;
   var _parent;
   function GameActionsEx(oAPI, parent)
   {
      this.api = oAPI;
      this._parent = parent;
   }
   function onActionEx(sExtraData, nActionType, sSenderID, oSeq, sParams, oContext)
   {
      var bCanContinue = true;
      switch(nActionType)
      {
         case 1:
            var oSpriteActing = this.api.datacenter.Sprites.getItemAt(sSenderID);
            if(!this.api.gfx.isMapBuild)
            {
               bCanContinue = false;
               break;
            }
            if(dofus.Constants.USE_JS_LOG && (_global.CONFIG.isNewAccount && !this.api.datacenter.Basics.first_movement))
            {
               getURL("JavaScript:WriteLog(\'Mouvement\')","_self");
               this.api.datacenter.Basics.first_movement = true;
            }
            if(sSenderID == this.api.datacenter.Player.ID && (this.api.datacenter.Game.isFight && this.api.datacenter.Game.isRunning))
            {
               oSeq.addAction(35,false,this.api.gfx,this.api.gfx.setInteraction,[ank.battlefield.Constants.INTERACTION_CELL_NONE]);
            }
            var aFullPath = ank.battlefield.utils.Compressor.extractFullPath(this.api.gfx.mapHandler,sParams);
            if(oSpriteActing.hasCarriedParent() && !oSpriteActing.uncarryingSprite)
            {
               oSpriteActing.uncarryingSprite = true;
               aFullPath.shift();
               oSeq.addAction(174,false,this.api.gfx,this.api.gfx.uncarriedSprite,[sSenderID,aFullPath[0],true,oSeq]);
               oSeq.addAction(36,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[sSenderID,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oSpriteActing.Team]]);
            }
            var bForceRun = oSpriteActing.forceRun;
            var bForceWalk = oSpriteActing.forceWalk;
            var nPathSpeed = !this.api.datacenter.Game.isFight ? (!(oSpriteActing instanceof dofus.datacenter.Character) ? 6 : 3) : 3;
            if(this.api.datacenter.Game.isRunning)
            {
               oSeq.addAction(37,false,this.api.gfx,this.api.gfx.unSelect,[true]);
               oSeq.addAction(175,false,this.api.gfx,this.api.gfx.moveSpriteWithUncompressedPath,[sSenderID,aFullPath,oSeq,false,bForceRun,bForceWalk,nPathSpeed]);
            }
            else
            {
               if(sSenderID == this.api.datacenter.Player.ID)
               {
                  if((this.api.datacenter.Game.nTransmittingStates & dofus.datacenter.Game.STATE_MOVE_BIT) == dofus.datacenter.Game.STATE_NONE)
                  {
                     this.api.datacenter.Player._nMoveStat = this.api.datacenter.Player._nMoveStat + 1;
                  }
                  this.api.datacenter.Game.nTransmittingStates &= dofus.datacenter.Game.STATE_MOVE_BIT ^ -1;
               }
               this.api.gfx.moveSpriteWithUncompressedPath(sSenderID,aFullPath,oSeq,true,bForceRun,bForceWalk,nPathSpeed);
            }
            break;
         case 2:
            if(oSeq == undefined)
            {
               this.api.gfx.clear();
               this.api.datacenter.clearGame();
               if(!this.api.kernel.TutorialManager.isTutorialMode)
               {
                  this.api.ui.loadUIComponent("CenterText","CenterTextMap",{text:this.api.lang.getText("LOADING_MAP"),timer:40000},{bForceLoad:true});
               }
            }
            else
            {
               oSeq.addAction(38,false,this.api.gfx,this.api.gfx.clear);
               oSeq.addAction(39,false,this.api.datacenter,this.api.datacenter.clearGame);
               if(sParams.length == 0)
               {
                  oSeq.addAction(40,true,this.api.ui,this.api.ui.loadUIComponent,["CenterText","CenterTextMap",{text:this.api.lang.getText("LOADING_MAP"),timer:40000},{bForceLoad:true}]);
               }
               else
               {
                  oSeq.addAction(41,true,this.api.ui,this.api.ui.loadUIComponent,["Cinematic","Cinematic",{file:dofus.Constants.CINEMATICS_PATH + sParams + ".swf",sequencer:oSeq,background:true,banner:true,npc:true,frameToStart:1}]);
               }
            }
            break;
         case 4:
            var aParams = sParams.split(",");
            var sSpriteID = aParams[0];
            var nCellID = Number(aParams[1]);
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
            var mcSprite = oSprite.mc;
            oSeq.addAction(42,false,mcSprite,mcSprite.setPosition,[nCellID]);
            break;
         case 5:
            var aParams = sParams.split(",");
            var sSpriteID = aParams[0];
            var nCellID = Number(aParams[1]);
            this.api.gfx.slideSprite(sSpriteID,nCellID,oSeq);
            break;
         case 501:
            var aParams = sParams.split(",");
            var nToolID = aParams[0];
            var nDuration = Number(aParams[1]);
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var sAnimName = aParams[2] != undefined ? "anim" + aParams[2] : oSprite.ToolAnimation;
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               if((this.api.datacenter.Game.nTransmittingStates & dofus.datacenter.Game.STATE_GATHER_BIT) == dofus.datacenter.Game.STATE_NONE)
               {
                  this.api.datacenter.Player._nGatherStat = this.api.datacenter.Player._nGatherStat + 1;
               }
               this.api.datacenter.Game.nTransmittingStates &= dofus.datacenter.Game.STATE_GATHER_BIT ^ -1;
            }
            oSeq.addAction(111,false,this.api.gfx,this.api.gfx.autoCalculateSpriteDirection,[sSenderID,nToolID]);
            oSeq.addAction(112,sSenderID == this.api.datacenter.Player.ID,this.api.gfx,this.api.gfx.setSpriteLoopAnim,[sSenderID,sAnimName,nDuration],nDuration,true);
            break;
         case 617:
            oContext.bSequence = false;
            var aParams = sParams.split(",");
            var oSpriteAsker = this.api.datacenter.Sprites.getItemAt(Number(aParams[0]));
            var oSpriteTarget = this.api.datacenter.Sprites.getItemAt(Number(aParams[1]));
            var sCellID = aParams[2];
            this.api.gfx.addSpriteBubble(sCellID,this.api.lang.getText("A_ASK_MARRIAGE_B",[oSpriteAsker.name,oSpriteTarget.name]));
            if(oSpriteAsker.id == this.api.datacenter.Player.ID)
            {
               this.api.kernel.showMessage(this.api.lang.getText("MARRIAGE"),this.api.lang.getText("A_ASK_MARRIAGE_B",[oSpriteAsker.name,oSpriteTarget.name]),"CAUTION_YESNO",{name:"Marriage",listener:this._parent,params:{spriteID:oSpriteAsker.id,refID:sSenderID}});
            }
            break;
         case 618:
         case 619:
            oContext.bSequence = false;
            var aParams = sParams.split(",");
            var oSpriteA = this.api.datacenter.Sprites.getItemAt(Number(aParams[0]));
            var oSpriteB = this.api.datacenter.Sprites.getItemAt(Number(aParams[1]));
            var sCellID = aParams[2];
            var sMessageKey = nActionType != 618 ? "A_NOT_MARRIED_B" : "A_MARRIED_B";
            this.api.gfx.addSpriteBubble(sCellID,this.api.lang.getText(sMessageKey,[oSpriteA.name,oSpriteB.name]));
            break;
         case 900:
            oContext.bSequence = false;
            var oSprite1 = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var oSprite2 = this.api.datacenter.Sprites.getItemAt(Number(sParams));
            if(oSprite1 == undefined || (oSprite2 == undefined || (this.api.ui.getUIComponent("AskCancelChallenge") != undefined || this.api.ui.getUIComponent("AskYesNoIgnoreChallenge") != undefined)))
            {
               this._parent.refuseChallenge(sSenderID);
               bCanContinue = false;
               break;
            }
            this.api.kernel.showMessage(undefined,this.api.lang.getText("A_CHALENGE_B",[this.api.kernel.ChatManager.getLinkName(oSprite1.id,oSprite1.name),this.api.kernel.ChatManager.getLinkName(oSprite2.id,oSprite2.name)]),"INFO_CHAT");
            if(oSprite1.id == this.api.datacenter.Player.ID)
            {
               this.api.kernel.showMessage(this.api.lang.getText("CHALENGE"),this.api.lang.getText("YOU_CHALENGE_B",[oSprite2.name]),"INFO_CANCEL",{name:"Challenge",listener:this._parent,params:{spriteID:oSprite1.id}});
            }
            if(oSprite2.id == this.api.datacenter.Player.ID)
            {
               if(this.api.kernel.ChatManager.isBlacklisted(oSprite1.name))
               {
                  this._parent.refuseChallenge(oSprite1.id);
                  bCanContinue = false;
                  break;
               }
               this.api.electron.makeNotification(this.api.lang.getText("A_CHALENGE_YOU",[oSprite1.name]));
               this.api.kernel.showMessage(this.api.lang.getText("CHALENGE"),this.api.lang.getText("A_CHALENGE_YOU",[oSprite1.name]),"CAUTION_YESNOIGNORE",{name:"Challenge",player:oSprite1.name,listener:this._parent,params:{spriteID:oSprite1.id,player:oSprite1.name}});
               this.api.sounds.events.onGameInvitation();
            }
            break;
         case 901:
            oContext.bSequence = false;
            if(sSenderID == this.api.datacenter.Player.ID || Number(sParams) == this.api.datacenter.Player.ID)
            {
               this.api.ui.unloadUIComponent("AskCancelChallenge");
            }
            break;
         case 902:
            oContext.bSequence = false;
            this.api.ui.unloadUIComponent("AskYesNoIgnoreChallenge");
            this.api.ui.unloadUIComponent("AskCancelChallenge");
            break;
         case 903:
            oContext.bSequence = false;
            switch(sParams)
            {
               case "c":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CHALENGE_FULL"),"ERROR_CHAT");
                  break;
               case "t":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("TEAM_FULL"),"ERROR_CHAT");
                  break;
               case "a":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("TEAM_DIFFERENT_ALIGNMENT"),"ERROR_CHAT");
                  break;
               case "g":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_DO_BECAUSE_GUILD"),"ERROR_CHAT");
                  break;
               case "l":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_DO_TOO_LATE"),"ERROR_CHAT");
                  break;
               case "m":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_U_ARE_MUTANT"),"ERROR_CHAT");
                  break;
               case "p":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_BECAUSE_MAP"),"ERROR_CHAT");
                  break;
               case "r":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_BECAUSE_ON_RESPAWN"),"ERROR_CHAT");
                  break;
               case "o":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_YOU_R_OCCUPED"),"ERROR_CHAT");
                  break;
               case "z":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_YOU_OPPONENT_OCCUPED"),"ERROR_CHAT");
                  break;
               case "h":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_FIGHT"),"ERROR_CHAT");
                  break;
               case "i":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_FIGHT_NO_RIGHTS"),"ERROR_CHAT");
                  break;
               case "s":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("ERROR_21"),"ERROR_CHAT");
                  break;
               case "n":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("SUBSCRIPTION_OUT"),"ERROR_CHAT");
                  break;
               case "b":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("A_NOT_SUBSCRIB"),"ERROR_CHAT");
                  break;
               case "f":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("TEAM_CLOSED"),"ERROR_CHAT");
                  break;
               case "d":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("NO_ZOMBIE_ALLOWED"),"ERROR_CHAT");
                  break;
               case "x":
                  this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_TARGET_NOT_IN_HOUSE"),"ERROR_CHAT");
            }
            break;
         case 905:
            this.api.ui.loadUIComponent("CenterText","CenterText",{text:this.api.lang.getText("YOU_ARE_ATTAC"),background:true,timer:2000},{bForceLoad:true});
            break;
         case 906:
            var sSpriteID = sParams;
            var oSpriteAttacker = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var oSpriteTarget = this.api.datacenter.Sprites.getItemAt(sSpriteID);
            var sAttackerName = oSpriteAttacker.name;
            var sTargetName = oSpriteTarget.name;
            if(sAttackerName == undefined || sTargetName == undefined)
            {
               break;
            }
            this.api.kernel.showMessage(undefined,this.api.lang.getText("A_ATTACK_B",[this.api.kernel.ChatManager.getLinkName(oSpriteAttacker.id,sAttackerName),this.api.kernel.ChatManager.getLinkName(oSpriteTarget.id,sTargetName)]),"INFO_CHAT");
            if(sSpriteID == this.api.datacenter.Player.ID)
            {
               this.api.electron.makeNotification(this.api.lang.getText("A_ATTACK_B",[sAttackerName,sTargetName]));
               this.api.ui.loadUIComponent("CenterText","CenterText",{text:this.api.lang.getText("YOU_ARE_ATTAC"),background:true,timer:2000},{bForceLoad:true});
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_AGRESSED);
            }
            else
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_AGRESS);
            }
            break;
         case 909:
            var sSpriteID = sParams;
            var oSpriteAttacker = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var oSpriteTarget = this.api.datacenter.Sprites.getItemAt(sSpriteID);
            this.api.kernel.showMessage(undefined,this.api.lang.getText("A_ATTACK_B",[oSpriteAttacker.name,oSpriteTarget.name]),"INFO_CHAT");
            break;
         case 950:
            var aParams = sParams.split(",");
            var sSpriteID = aParams[0];
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
            var nStateID = Number(aParams[1]);
            var bStateBool = Number(aParams[2]) != 1 ? false : true;
            if(nStateID == 8 && (!bStateBool && (oSprite.hasCarriedParent() && !oSprite.uncarryingSprite)))
            {
               oSprite.uncarryingSprite = true;
               oSeq.addAction(173,false,this.api.gfx,this.api.gfx.uncarriedSprite,[sSenderID,oSprite.cellNum,false,oSeq]);
               oSeq.addAction(113,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[sSpriteID,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oSprite.Team]]);
            }
            oSeq.addAction(114,false,oSprite,oSprite.setState,[this.api,nStateID,bStateBool]);
            var sStateAction = !bStateBool ? "EXIT_STATE" : "ENTER_STATE";
            oSeq.addAction(115,false,this.api.kernel.ChatManager.feMessagesBuffer,this.api.kernel.ChatManager.feMessagesBuffer.addFightEventMessage,[nActionType,[sStateAction],[this.api.lang.getStateText(nStateID)],oSprite.id,oSprite.name]);
            var oBannerUI = this.api.ui.getUIComponent("Banner");
            oSeq.addAction(116,false,oBannerUI,oBannerUI.statesChanged,[]);
            break;
         case 998:
            var aExtraData = sExtraData.split(",");
            var sSpriteID = aExtraData[0];
            var nSpellID = aExtraData[0];
            var nValue1 = aExtraData[2];
            var nValue2 = aExtraData[3];
            var nValue3 = aExtraData[4];
            var nValue4 = aExtraData[6];
            var nValue5 = aExtraData[7];
            var oEffect = new dofus.datacenter.Effect(undefined,Number(nSpellID),Number(nValue1),Number(nValue2),Number(nValue3),"",Number(nValue4),Number(nValue5));
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSpriteID);
            oSprite.EffectsManager.addEffect(oEffect);
            break;
         case 300:
            var aParams = sParams.split(",");
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var nSpellID = Number(aParams[0]);
            var nCellID = Number(aParams[1]);
            var sGfxFile = aParams[2];
            var nSpellLevel = Number(aParams[3]);
            var nTargetCellID = Number(aParams[4]);
            var vAnimation = !_global.isNaN(Number(aParams[5])) ? (!(aParams[5] == "-1" || aParams[5] == "-2") ? "anim" + aParams[5] : undefined) : String(aParams[5]).split("~");
            var bIsExtraAnimate = false;
            if(Number(aParams[5]) == -2)
            {
               bIsExtraAnimate = true;
            }
            var bInFrontOfSprite = aParams[6] != "1" ? false : true;
            var oVisualEffect = new ank.battlefield.datacenter.VisualEffect();
            oVisualEffect.file = dofus.Constants.SPELLS_PATH + sGfxFile + ".swf";
            oVisualEffect.level = nSpellLevel;
            oVisualEffect.bInFrontOfSprite = bInFrontOfSprite;
            oVisualEffect.params = new dofus.datacenter.Spell(nSpellID,nSpellLevel).elements;
            oSeq.addAction(88,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_LAUNCH_SPELL",[oSprite.name,this.api.lang.getSpellText(nSpellID).n]),"INFO_FIGHT_CHAT"]);
            if(vAnimation != undefined || bIsExtraAnimate)
            {
               if(!this.api.datacenter.Player.isSkippingFightAnimations)
               {
                  this.api.gfx.spriteLaunchVisualEffect(sSenderID,oVisualEffect,nCellID,nTargetCellID,vAnimation);
               }
            }
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               var oSpellsManager = this.api.datacenter.Player.SpellsManager;
               var nSpriteOnCellID = this.api.gfx.mapHandler.getCellData(nCellID).spriteOnID;
               var oLaunchedSpell = new dofus.datacenter.LaunchedSpell(nSpellID,nSpriteOnCellID);
               oSpellsManager.addLaunchedSpell(oLaunchedSpell);
            }
            break;
         case 301:
            var nSpellID = Number(sParams);
            oSeq.addAction(89,false,this.api.sounds.events,this.api.sounds.events.onGameCriticalHit,[]);
            oSeq.addAction(90,false,this.api.kernel,this.api.kernel.showMessage,[undefined,"(" + this.api.lang.getText("CRITICAL_HIT") + ")","INFO_FIGHT_CHAT"]);
            if(!this.api.datacenter.Player.isSkippingFightAnimations && this.api.electron.isWindowFocused)
            {
               oSeq.addAction(91,false,this.api.gfx,this.api.gfx.addSpriteExtraClipOnTimer,[sSenderID,dofus.Constants.CRITICAL_HIT_XTRA_FILE,undefined,true,dofus.Constants.CRITICAL_HIT_DURATION]);
            }
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_CC_OWNER);
            }
            else
            {
               var nPlayerTeam = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var nSpriteTeam = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(nPlayerTeam == nSpriteTeam)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_CC_ALLIED);
               }
               else
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_CC_ENEMY);
               }
            }
            break;
         case 302:
            var nSpellID = Number(sParams);
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSenderID);
            oSeq.addAction(92,false,this.api.sounds.events,this.api.sounds.events.onGameCriticalMiss,[]);
            oSeq.addAction(93,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_LAUNCH_SPELL",[oSprite.name,this.api.lang.getSpellText(nSpellID).n]),"INFO_FIGHT_CHAT"]);
            oSeq.addAction(94,false,this.api.kernel,this.api.kernel.showMessage,[undefined,"(" + this.api.lang.getText("CRITICAL_MISS") + ")","INFO_FIGHT_CHAT"]);
            oSeq.addAction(95,false,this.api.gfx,this.api.gfx.addSpriteBubble,[sSenderID,this.api.lang.getText("CRITICAL_MISS")]);
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_OWNER);
            }
            else
            {
               var nPlayerTeam = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var nSpriteTeam = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(nPlayerTeam == nSpriteTeam)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_ALLIED);
               }
               else
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_ENEMY);
               }
            }
            break;
         case 303:
            var aParams = sParams.split(";");
            var aFirstParams = aParams[0].split(",");
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var mcSprite = oSprite.mc;
            var sToolAnimName = oSprite.ToolAnimation;
            var nCellID = Number(aFirstParams[0]);
            var sGfxFile = aFirstParams[1];
            var nTargetCellID = Number(aFirstParams[2]);
            var bInFrontOfSprite = aFirstParams[3] != "1" ? false : true;
            var oCloseCombat = new dofus.datacenter.CloseCombat(new dofus.datacenter.Item(undefined,aParams[1]),oSprite.Guild);
            oSeq.addAction(96,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_ATTACK_CC_NAME",[oSprite.name,aParams[1] != 0 ? oCloseCombat.name : this.api.lang.getSpellText(0).n]),"INFO_FIGHT_CHAT"]);
            var oVisualEffect = new ank.battlefield.datacenter.VisualEffect();
            oVisualEffect.file = dofus.Constants.SPELLS_PATH + sGfxFile + ".swf";
            oVisualEffect.level = 1;
            oVisualEffect.bInFrontOfSprite = bInFrontOfSprite;
            oVisualEffect.params = oCloseCombat.elements;
            this.api.gfx.spriteLaunchVisualEffect(sSenderID,oVisualEffect,nCellID,nTargetCellID,sToolAnimName);
            break;
         case 304:
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var mcSprite = oSprite.mc;
            oSeq.addAction(99,false,this.api.sounds.events,this.api.sounds.events.onGameCriticalHit,[]);
            oSeq.addAction(100,false,this.api.kernel,this.api.kernel.showMessage,[undefined,"(" + this.api.lang.getText("CRITICAL_HIT") + ")","INFO_FIGHT_CHAT"]);
            if(!this.api.datacenter.Player.isSkippingFightAnimations && this.api.electron.isWindowFocused)
            {
               oSeq.addAction(101,false,this.api.gfx,this.api.gfx.addSpriteExtraClipOnTimer,[sSenderID,dofus.Constants.CRITICAL_HIT_XTRA_FILE,undefined,true,dofus.Constants.CRITICAL_HIT_DURATION]);
            }
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_CC_OWNER);
            }
            else
            {
               var nPlayerTeam = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var nSpriteTeam = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(nPlayerTeam == nSpriteTeam)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_CC_ALLIED);
               }
               else
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_CC_ENEMY);
               }
            }
            break;
         case 305:
            var aParams = sParams.split(";");
            var oSprite = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var vCloseCombatName = aParams[0] != 0 ? new dofus.datacenter.CloseCombat(new dofus.datacenter.Item(undefined,aParams[0]),oSprite.Guild) : this.api.lang.getSpellText(0).n;
            oSeq.addAction(102,false,this.api.sounds.events,this.api.sounds.events.onGameCriticalMiss,[]);
            oSeq.addAction(103,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_ATTACK_CC_NAME",[oSprite.name,vCloseCombatName.name]),"INFO_FIGHT_CHAT"]);
            oSeq.addAction(104,false,this.api.kernel,this.api.kernel.showMessage,[undefined,"(" + this.api.lang.getText("CRITICAL_MISS") + ")","INFO_FIGHT_CHAT"]);
            oSeq.addAction(105,false,this.api.gfx,this.api.gfx.addSpriteBubble,[sSenderID,this.api.lang.getText("CRITICAL_MISS")]);
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_OWNER);
            }
            else
            {
               var nPlayerTeam = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var nSpriteTeam = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(nPlayerTeam == nSpriteTeam)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_ALLIED);
               }
               else
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_ENEMY);
               }
            }
            break;
         case 306:
            var aParams = sParams.split(",");
            var nSpellID = Number(aParams[0]);
            var nCellID = Number(aParams[1]);
            var sGfxFile = aParams[2];
            var nSpellLevel = Number(aParams[3]);
            var bInFrontOfSprite = aParams[4] != "1" ? false : true;
            var nTargetSpriteID = Number(aParams[5]);
            var oSpellCaster = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var oSpellTarget = this.api.datacenter.Sprites.getItemAt(nTargetSpriteID);
            var oVisualEffect = new ank.battlefield.datacenter.VisualEffect();
            oVisualEffect.id = nSpellID;
            oVisualEffect.file = dofus.Constants.SPELLS_PATH + sGfxFile + ".swf";
            oVisualEffect.level = nSpellLevel;
            oVisualEffect.bInFrontOfSprite = bInFrontOfSprite;
            oSeq.addAction(106,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_START_TRAP",[oSpellCaster.name,this.api.lang.getSpellText(oVisualEffect.id).n,oSpellTarget.name]),"INFO_FIGHT_CHAT"]);
            oSeq.addAction(107,false,this.api.gfx,this.api.gfx.addVisualEffectOnSprite,[nTargetSpriteID,oVisualEffect,nCellID,11],1000);
            break;
         case 307:
            var aParams = sParams.split(",");
            var nSpellID = Number(aParams[0]);
            var nCellID = Number(aParams[1]);
            var nSpellLevel = Number(aParams[3]);
            var nTargetSpriteID = Number(aParams[5]);
            var oSpellCaster = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var oSpellTarget = this.api.datacenter.Sprites.getItemAt(nTargetSpriteID);
            var oSpell = new dofus.datacenter.Spell(nSpellID,nSpellLevel);
            oSeq.addAction(108,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_START_GLIPH",[oSpellCaster.name,oSpell.name,oSpellTarget.name]),"INFO_FIGHT_CHAT"]);
            break;
         case 308:
            var aParams = sParams.split(",");
            var oSprite = this.api.datacenter.Sprites.getItemAt(Number(aParams[0]));
            var nAPDodge = Number(aParams[1]);
            oSeq.addAction(109,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_DODGE_AP",[oSprite.name,nAPDodge]),"INFO_FIGHT_CHAT"]);
            break;
         case 309:
            var aParams = sParams.split(",");
            var oSprite = this.api.datacenter.Sprites.getItemAt(Number(aParams[0]));
            var nMPDodge = Number(aParams[1]);
            oSeq.addAction(110,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_DODGE_MP",[oSprite.name,nMPDodge]),"INFO_FIGHT_CHAT"]);
      }
      return bCanContinue;
   }
}
