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
      var _loc8_ = true;
      switch(nActionType)
      {
         case 1:
            var _loc9_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            if(!this.api.gfx.isMapBuild)
            {
               _loc8_ = false;
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
            var _loc10_ = ank.battlefield.utils.Compressor.extractFullPath(this.api.gfx.mapHandler,sParams);
            if(_loc9_.hasCarriedParent() && !_loc9_.uncarryingSprite)
            {
               _loc9_.uncarryingSprite = true;
               _loc10_.shift();
               oSeq.addAction(174,false,this.api.gfx,this.api.gfx.uncarriedSprite,[sSenderID,_loc10_[0],true,oSeq]);
               oSeq.addAction(36,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[sSenderID,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[_loc9_.Team]]);
            }
            var _loc11_ = _loc9_.forceRun;
            var _loc12_ = _loc9_.forceWalk;
            var _loc13_ = !this.api.datacenter.Game.isFight ? (!(_loc9_ instanceof dofus.datacenter.Character) ? 6 : 3) : 3;
            if(this.api.datacenter.Game.isRunning)
            {
               oSeq.addAction(37,false,this.api.gfx,this.api.gfx.unSelect,[true]);
               oSeq.addAction(175,false,this.api.gfx,this.api.gfx.moveSpriteWithUncompressedPath,[sSenderID,_loc10_,oSeq,false,_loc11_,_loc12_,_loc13_]);
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
               this.api.gfx.moveSpriteWithUncompressedPath(sSenderID,_loc10_,oSeq,true,_loc11_,_loc12_,_loc13_);
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
            var _loc14_ = sParams.split(",");
            var _loc15_ = _loc14_[0];
            var _loc16_ = Number(_loc14_[1]);
            var _loc17_ = this.api.datacenter.Sprites.getItemAt(_loc15_);
            var _loc18_ = _loc17_.mc;
            oSeq.addAction(42,false,_loc18_,_loc18_.setPosition,[_loc16_]);
            break;
         case 5:
            var _loc19_ = sParams.split(",");
            var _loc20_ = _loc19_[0];
            var _loc21_ = Number(_loc19_[1]);
            this.api.gfx.slideSprite(_loc20_,_loc21_,oSeq);
            break;
         case 501:
            var _loc22_ = sParams.split(",");
            var _loc23_ = _loc22_[0];
            var _loc24_ = Number(_loc22_[1]);
            var _loc25_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc26_ = _loc22_[2] != undefined ? "anim" + _loc22_[2] : _loc25_.ToolAnimation;
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               if((this.api.datacenter.Game.nTransmittingStates & dofus.datacenter.Game.STATE_GATHER_BIT) == dofus.datacenter.Game.STATE_NONE)
               {
                  this.api.datacenter.Player._nGatherStat = this.api.datacenter.Player._nGatherStat + 1;
               }
               this.api.datacenter.Game.nTransmittingStates &= dofus.datacenter.Game.STATE_GATHER_BIT ^ -1;
            }
            oSeq.addAction(111,false,this.api.gfx,this.api.gfx.autoCalculateSpriteDirection,[sSenderID,_loc23_]);
            oSeq.addAction(112,sSenderID == this.api.datacenter.Player.ID,this.api.gfx,this.api.gfx.setSpriteLoopAnim,[sSenderID,_loc26_,_loc24_],_loc24_,true);
            break;
         case 617:
            oContext.bSequence = false;
            var _loc27_ = sParams.split(",");
            var _loc28_ = this.api.datacenter.Sprites.getItemAt(Number(_loc27_[0]));
            var _loc29_ = this.api.datacenter.Sprites.getItemAt(Number(_loc27_[1]));
            var _loc30_ = _loc27_[2];
            this.api.gfx.addSpriteBubble(_loc30_,this.api.lang.getText("A_ASK_MARRIAGE_B",[_loc28_.name,_loc29_.name]));
            if(_loc28_.id == this.api.datacenter.Player.ID)
            {
               this.api.kernel.showMessage(this.api.lang.getText("MARRIAGE"),this.api.lang.getText("A_ASK_MARRIAGE_B",[_loc28_.name,_loc29_.name]),"CAUTION_YESNO",{name:"Marriage",listener:this._parent,params:{spriteID:_loc28_.id,refID:sSenderID}});
            }
            break;
         case 618:
         case 619:
            oContext.bSequence = false;
            var _loc31_ = sParams.split(",");
            var _loc32_ = this.api.datacenter.Sprites.getItemAt(Number(_loc31_[0]));
            var _loc33_ = this.api.datacenter.Sprites.getItemAt(Number(_loc31_[1]));
            var _loc34_ = _loc31_[2];
            var _loc35_ = nActionType != 618 ? "A_NOT_MARRIED_B" : "A_MARRIED_B";
            this.api.gfx.addSpriteBubble(_loc34_,this.api.lang.getText(_loc35_,[_loc32_.name,_loc33_.name]));
            break;
         case 900:
            oContext.bSequence = false;
            var _loc36_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc37_ = this.api.datacenter.Sprites.getItemAt(Number(sParams));
            if(_loc36_ == undefined || (_loc37_ == undefined || (this.api.ui.getUIComponent("AskCancelChallenge") != undefined || this.api.ui.getUIComponent("AskYesNoIgnoreChallenge") != undefined)))
            {
               this._parent.refuseChallenge(sSenderID);
               _loc8_ = false;
               break;
            }
            this.api.kernel.showMessage(undefined,this.api.lang.getText("A_CHALENGE_B",[this.api.kernel.ChatManager.getLinkName(_loc36_.id,_loc36_.name),this.api.kernel.ChatManager.getLinkName(_loc37_.id,_loc37_.name)]),"INFO_CHAT");
            if(_loc36_.id == this.api.datacenter.Player.ID)
            {
               this.api.kernel.showMessage(this.api.lang.getText("CHALENGE"),this.api.lang.getText("YOU_CHALENGE_B",[_loc37_.name]),"INFO_CANCEL",{name:"Challenge",listener:this._parent,params:{spriteID:_loc36_.id}});
            }
            if(_loc37_.id == this.api.datacenter.Player.ID)
            {
               if(this.api.kernel.ChatManager.isBlacklisted(_loc36_.name))
               {
                  this._parent.refuseChallenge(_loc36_.id);
                  _loc8_ = false;
                  break;
               }
               this.api.electron.makeNotification(this.api.lang.getText("A_CHALENGE_YOU",[_loc36_.name]));
               this.api.kernel.showMessage(this.api.lang.getText("CHALENGE"),this.api.lang.getText("A_CHALENGE_YOU",[_loc36_.name]),"CAUTION_YESNOIGNORE",{name:"Challenge",player:_loc36_.name,listener:this._parent,params:{spriteID:_loc36_.id,player:_loc36_.name}});
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
            var _loc38_ = sParams;
            var _loc39_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc40_ = this.api.datacenter.Sprites.getItemAt(_loc38_);
            var _loc41_ = _loc39_.name;
            var _loc42_ = _loc40_.name;
            if(_loc41_ == undefined || _loc42_ == undefined)
            {
               break;
            }
            this.api.kernel.showMessage(undefined,this.api.lang.getText("A_ATTACK_B",[this.api.kernel.ChatManager.getLinkName(_loc39_.id,_loc41_),this.api.kernel.ChatManager.getLinkName(_loc40_.id,_loc42_)]),"INFO_CHAT");
            if(_loc38_ == this.api.datacenter.Player.ID)
            {
               this.api.electron.makeNotification(this.api.lang.getText("A_ATTACK_B",[_loc41_,_loc42_]));
               this.api.ui.loadUIComponent("CenterText","CenterText",{text:this.api.lang.getText("YOU_ARE_ATTAC"),background:true,timer:2000},{bForceLoad:true});
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_AGRESSED);
            }
            else
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_AGRESS);
            }
            break;
         case 909:
            var _loc43_ = sParams;
            var _loc44_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc45_ = this.api.datacenter.Sprites.getItemAt(_loc43_);
            this.api.kernel.showMessage(undefined,this.api.lang.getText("A_ATTACK_B",[_loc44_.name,_loc45_.name]),"INFO_CHAT");
            break;
         case 950:
            var _loc46_ = sParams.split(",");
            var _loc47_ = _loc46_[0];
            var _loc48_ = this.api.datacenter.Sprites.getItemAt(_loc47_);
            var _loc49_ = Number(_loc46_[1]);
            var _loc50_ = Number(_loc46_[2]) != 1 ? false : true;
            if(_loc49_ == 8 && (!_loc50_ && (_loc48_.hasCarriedParent() && !_loc48_.uncarryingSprite)))
            {
               _loc48_.uncarryingSprite = true;
               oSeq.addAction(173,false,this.api.gfx,this.api.gfx.uncarriedSprite,[sSenderID,_loc48_.cellNum,false,oSeq]);
               oSeq.addAction(113,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[_loc47_,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[_loc48_.Team]]);
            }
            oSeq.addAction(114,false,_loc48_,_loc48_.setState,[this.api,_loc49_,_loc50_]);
            var _loc51_ = !_loc50_ ? "EXIT_STATE" : "ENTER_STATE";
            oSeq.addAction(115,false,this.api.kernel.ChatManager.feMessagesBuffer,this.api.kernel.ChatManager.feMessagesBuffer.addFightEventMessage,[nActionType,[_loc51_],[this.api.lang.getStateText(_loc49_)],_loc48_.id,_loc48_.name]);
            var _loc52_ = this.api.ui.getUIComponent("Banner");
            oSeq.addAction(116,false,_loc52_,_loc52_.statesChanged,[]);
            break;
         case 998:
            var _loc53_ = sExtraData.split(",");
            var _loc54_ = _loc53_[0];
            var _loc55_ = _loc53_[0];
            var _loc56_ = _loc53_[2];
            var _loc57_ = _loc53_[3];
            var _loc58_ = _loc53_[4];
            var _loc59_ = _loc53_[6];
            var _loc60_ = _loc53_[7];
            var _loc61_ = new dofus.datacenter.Effect(undefined,Number(_loc55_),Number(_loc56_),Number(_loc57_),Number(_loc58_),"",Number(_loc59_),Number(_loc60_));
            var _loc62_ = this.api.datacenter.Sprites.getItemAt(_loc54_);
            _loc62_.EffectsManager.addEffect(_loc61_);
            break;
         case 300:
            var _loc63_ = sParams.split(",");
            var _loc64_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc65_ = Number(_loc63_[0]);
            var _loc66_ = Number(_loc63_[1]);
            var _loc67_ = _loc63_[2];
            var _loc68_ = Number(_loc63_[3]);
            var _loc69_ = Number(_loc63_[4]);
            var _loc70_ = !_global.isNaN(Number(_loc63_[5])) ? (!(_loc63_[5] == "-1" || _loc63_[5] == "-2") ? "anim" + _loc63_[5] : undefined) : String(_loc63_[5]).split("~");
            var _loc71_ = false;
            if(Number(_loc63_[5]) == -2)
            {
               _loc71_ = true;
            }
            var _loc72_ = _loc63_[6] != "1" ? false : true;
            var _loc73_ = new ank.battlefield.datacenter.VisualEffect();
            _loc73_.file = dofus.Constants.SPELLS_PATH + _loc67_ + ".swf";
            _loc73_.level = _loc68_;
            _loc73_.bInFrontOfSprite = _loc72_;
            _loc73_.params = new dofus.datacenter.Spell(_loc65_,_loc68_).elements;
            oSeq.addAction(88,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_LAUNCH_SPELL",[_loc64_.name,this.api.lang.getSpellText(_loc65_).n]),"INFO_FIGHT_CHAT"]);
            if(_loc70_ != undefined || _loc71_)
            {
               if(!this.api.datacenter.Player.isSkippingFightAnimations)
               {
                  this.api.gfx.spriteLaunchVisualEffect(sSenderID,_loc73_,_loc66_,_loc69_,_loc70_);
               }
            }
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               var _loc74_ = this.api.datacenter.Player.SpellsManager;
               var _loc75_ = this.api.gfx.mapHandler.getCellData(_loc66_).spriteOnID;
               var _loc76_ = new dofus.datacenter.LaunchedSpell(_loc65_,_loc75_);
               _loc74_.addLaunchedSpell(_loc76_);
            }
            break;
         case 301:
            var _loc77_ = Number(sParams);
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
               var _loc78_ = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var _loc79_ = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(_loc78_ == _loc79_)
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
            var _loc80_ = Number(sParams);
            var _loc81_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            oSeq.addAction(92,false,this.api.sounds.events,this.api.sounds.events.onGameCriticalMiss,[]);
            oSeq.addAction(93,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_LAUNCH_SPELL",[_loc81_.name,this.api.lang.getSpellText(_loc80_).n]),"INFO_FIGHT_CHAT"]);
            oSeq.addAction(94,false,this.api.kernel,this.api.kernel.showMessage,[undefined,"(" + this.api.lang.getText("CRITICAL_MISS") + ")","INFO_FIGHT_CHAT"]);
            oSeq.addAction(95,false,this.api.gfx,this.api.gfx.addSpriteBubble,[sSenderID,this.api.lang.getText("CRITICAL_MISS")]);
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_OWNER);
            }
            else
            {
               var _loc82_ = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var _loc83_ = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(_loc82_ == _loc83_)
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
            var _loc84_ = sParams.split(";");
            var _loc85_ = _loc84_[0].split(",");
            var _loc86_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc87_ = _loc86_.mc;
            var _loc88_ = _loc86_.ToolAnimation;
            var _loc89_ = Number(_loc85_[0]);
            var _loc90_ = _loc85_[1];
            var _loc91_ = Number(_loc85_[2]);
            var _loc92_ = _loc85_[3] != "1" ? false : true;
            var _loc93_ = new dofus.datacenter.CloseCombat(new dofus.datacenter.Item(undefined,_loc84_[1]),_loc86_.Guild);
            oSeq.addAction(96,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_ATTACK_CC_NAME",[_loc86_.name,_loc84_[1] != 0 ? _loc93_.name : this.api.lang.getSpellText(0).n]),"INFO_FIGHT_CHAT"]);
            var _loc94_ = new ank.battlefield.datacenter.VisualEffect();
            _loc94_.file = dofus.Constants.SPELLS_PATH + _loc90_ + ".swf";
            _loc94_.level = 1;
            _loc94_.bInFrontOfSprite = _loc92_;
            _loc94_.params = _loc93_.elements;
            this.api.gfx.spriteLaunchVisualEffect(sSenderID,_loc94_,_loc89_,_loc91_,_loc88_);
            break;
         case 304:
            var _loc95_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc96_ = _loc95_.mc;
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
               var _loc97_ = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var _loc98_ = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(_loc97_ == _loc98_)
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
            var _loc99_ = sParams.split(";");
            var _loc100_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc101_ = _loc99_[0] != 0 ? new dofus.datacenter.CloseCombat(new dofus.datacenter.Item(undefined,_loc99_[0]),_loc100_.Guild) : this.api.lang.getSpellText(0).n;
            oSeq.addAction(102,false,this.api.sounds.events,this.api.sounds.events.onGameCriticalMiss,[]);
            oSeq.addAction(103,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_ATTACK_CC_NAME",[_loc100_.name,_loc101_.name]),"INFO_FIGHT_CHAT"]);
            oSeq.addAction(104,false,this.api.kernel,this.api.kernel.showMessage,[undefined,"(" + this.api.lang.getText("CRITICAL_MISS") + ")","INFO_FIGHT_CHAT"]);
            oSeq.addAction(105,false,this.api.gfx,this.api.gfx.addSpriteBubble,[sSenderID,this.api.lang.getText("CRITICAL_MISS")]);
            if(sSenderID == this.api.datacenter.Player.ID)
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_EC_OWNER);
            }
            else
            {
               var _loc102_ = this.api.datacenter.Sprites.getItemAt(this.api.datacenter.Player.ID).Team;
               var _loc103_ = this.api.datacenter.Sprites.getItemAt(_global.parseInt(sSenderID)).Team;
               if(_loc102_ == _loc103_)
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
            var _loc104_ = sParams.split(",");
            var _loc105_ = Number(_loc104_[0]);
            var _loc106_ = Number(_loc104_[1]);
            var _loc107_ = _loc104_[2];
            var _loc108_ = Number(_loc104_[3]);
            var _loc109_ = _loc104_[4] != "1" ? false : true;
            var _loc110_ = Number(_loc104_[5]);
            var _loc111_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc112_ = this.api.datacenter.Sprites.getItemAt(_loc110_);
            var _loc113_ = new ank.battlefield.datacenter.VisualEffect();
            _loc113_.id = _loc105_;
            _loc113_.file = dofus.Constants.SPELLS_PATH + _loc107_ + ".swf";
            _loc113_.level = _loc108_;
            _loc113_.bInFrontOfSprite = _loc109_;
            oSeq.addAction(106,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_START_TRAP",[_loc111_.name,this.api.lang.getSpellText(_loc113_.id).n,_loc112_.name]),"INFO_FIGHT_CHAT"]);
            oSeq.addAction(107,false,this.api.gfx,this.api.gfx.addVisualEffectOnSprite,[_loc110_,_loc113_,_loc106_,11],1000);
            break;
         case 307:
            var _loc114_ = sParams.split(",");
            var _loc115_ = Number(_loc114_[0]);
            var _loc116_ = Number(_loc114_[1]);
            var _loc117_ = Number(_loc114_[3]);
            var _loc118_ = Number(_loc114_[5]);
            var _loc119_ = this.api.datacenter.Sprites.getItemAt(sSenderID);
            var _loc120_ = this.api.datacenter.Sprites.getItemAt(_loc118_);
            var _loc121_ = new dofus.datacenter.Spell(_loc115_,_loc117_);
            oSeq.addAction(108,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_START_GLIPH",[_loc119_.name,_loc121_.name,_loc120_.name]),"INFO_FIGHT_CHAT"]);
            break;
         case 308:
            var _loc122_ = sParams.split(",");
            var _loc123_ = this.api.datacenter.Sprites.getItemAt(Number(_loc122_[0]));
            var _loc124_ = Number(_loc122_[1]);
            oSeq.addAction(109,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_DODGE_AP",[_loc123_.name,_loc124_]),"INFO_FIGHT_CHAT"]);
            break;
         case 309:
            var _loc125_ = sParams.split(",");
            var _loc126_ = this.api.datacenter.Sprites.getItemAt(Number(_loc125_[0]));
            var _loc127_ = Number(_loc125_[1]);
            oSeq.addAction(110,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("HAS_DODGE_MP",[_loc126_.name,_loc127_]),"INFO_FIGHT_CHAT"]);
      }
      return _loc8_;
   }
}
