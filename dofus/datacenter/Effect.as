class dofus.datacenter.Effect extends Object
{
   var _nType;
   var _nParam1;
   var _nParam2;
   var _nParam3;
   var _sParam4;
   var _nRemainingTurn;
   var _nSpellID;
   var api;
   var _bDispellable;
   var _sCasterID;
   var _sConditions;
   var _bOver;
   var _bExo;
   var _nPropability = 0;
   var _nModificator = -1;
   function Effect(sCasterID, mType, mParam1, mParam2, mParam3, mParam4, mRemainingTurn, mSpellID, nModificator, sConditions, bDispellable)
   {
      super();
      this.initialize(sCasterID,mType,mParam1,mParam2,mParam3,mParam4,mRemainingTurn,mSpellID,nModificator,sConditions,bDispellable != undefined ? bDispellable : true);
   }
   function get type()
   {
      return this._nType;
   }
   function set probability(nProbability)
   {
      this._nPropability = nProbability;
   }
   function get probability()
   {
      return this._nPropability;
   }
   function get param1()
   {
      return this._nParam1;
   }
   function set param1(value)
   {
      this._nParam1 = value;
   }
   function get param2()
   {
      return this._nParam2;
   }
   function set param2(value)
   {
      this._nParam2 = value;
   }
   function get param3()
   {
      return this._nParam3;
   }
   function set param3(value)
   {
      this._nParam3 = value;
   }
   function get param4()
   {
      return this._sParam4;
   }
   function set param4(value)
   {
      this._sParam4 = value;
   }
   function set remainingTurn(nRremainingTurn)
   {
      this._nRemainingTurn = nRremainingTurn;
   }
   function get remainingTurn()
   {
      return this._nRemainingTurn;
   }
   function get remainingTurnStr()
   {
      return this.getTurnCountStr(true);
   }
   function get spellID()
   {
      return this._nSpellID;
   }
   function get isNothing()
   {
      var _loc2_ = this.api.lang.getEffectText(this._nType).d;
      if(_loc2_ == "null" || (_loc2_ == null || _loc2_ == undefined))
      {
         return true;
      }
      return false;
   }
   function get description()
   {
      return this.getDescription(true);
   }
   function get isDispellable()
   {
      return this._bDispellable;
   }
   function getDescription(bShowRemainingTurns)
   {
      var _loc3_ = this.api.lang.getEffectText(this._nType).d;
      var _loc4_ = [this._nParam1,this._nParam2,this._nParam3,this._sParam4];
      switch(this._nType)
      {
         case 10:
            _loc4_[2] = this.api.lang.getEmoteText(this._nParam3).n;
            break;
         case 181:
            _loc4_[0] = this.api.lang.getMonstersText(this._nParam1).n;
            break;
         case 197:
         case 239:
            _loc4_[0] = this.api.lang.getMonstersText(this._nParam1).n;
            break;
         case 165:
            _loc4_[0] = this._nParam1 != 0 ? this.api.lang.getItemTypeText(this._nParam1).n : this.api.lang.getText("WEAPONS");
            break;
         case 293:
         case 294:
         case 787:
            _loc4_[0] = this.api.lang.getSpellText(this._nParam1).n;
            break;
         case 601:
            var _loc5_ = this.api.lang.getMapText(this._nParam2);
            _loc4_[0] = this.api.lang.getMapSubAreaName(_loc5_.sa);
            _loc4_[1] = _loc5_.x;
            _loc4_[2] = _loc5_.y;
            break;
         case 603:
            _loc4_[2] = this.api.lang.getJobText(this._nParam3).n;
            break;
         case 604:
            var _loc6_ = this.api.datacenter.Player.getSpellIDFromLevelID(this._nParam3);
            _loc4_[2] = this.api.lang.getSpellText(_loc6_).n;
            break;
         case 614:
            _loc4_[0] = this._nParam3;
            _loc4_[1] = this.api.lang.getJobText(this._nParam2).n;
            break;
         case 615:
            _loc4_[2] = this.api.lang.getJobText(this._nParam3).n;
            break;
         case 616:
         case 624:
            _loc4_[2] = this.api.lang.getSpellText(this._nParam3).n;
            break;
         case 699:
            _loc4_[0] = this.api.lang.getJobText(this._nParam1).n;
            break;
         case 621:
            _loc4_[2] = this.api.lang.getMonstersText(this._nParam2).n;
            break;
         case 905:
            _loc4_[1] = this.api.lang.getMonstersText(this._nParam2).n;
            break;
         case 628:
         case 623:
            _loc4_[2] = this.api.lang.getMonstersText(this._nParam3).n;
            break;
         case 715:
            _loc4_[0] = this.api.lang.getMonstersSuperRaceText(this._nParam1).n;
            break;
         case 716:
            _loc4_[0] = this.api.lang.getMonstersRaceText(this._nParam1).n;
            break;
         case 717:
            _loc4_[0] = this.api.lang.getMonstersText(this._nParam1).n;
            break;
         case 724:
            _loc4_[2] = this.api.lang.getTitle(this._nParam3).t;
            break;
         case 725:
            _loc4_[3] = this.api.datacenter.Player.guildInfos.name;
            break;
         case 805:
         case 808:
         case dofus.datacenter.Item.OBJECT_ACTION_LINK_ACCOUNT:
         case dofus.datacenter.Item.OBJECT_ACTION_LOCK_TEMPORARY:
            if(this._nParam1 != undefined && this._nParam1 == -1)
            {
               _loc4_[0] = this.api.lang.getText("LINKED_TO_ACCOUNT");
            }
            else
            {
               this._nParam3 = this._nParam3 != undefined ? this._nParam3 : 0;
               var _loc7_ = String(Math.floor(this._nParam2) / 100).split(".");
               var _loc8_ = Number(_loc7_[0]);
               var _loc9_ = this._nParam2 - _loc8_ * 100;
               var _loc10_ = String(Math.floor(this._nParam3) / 100).split(".");
               var _loc11_ = Number(_loc10_[0]);
               var _loc12_ = this._nParam3 - _loc11_ * 100;
               _loc4_[0] = ank.utils.PatternDecoder.getDescription(this.api.lang.getConfigText("DATE_FORMAT"),[this._nParam1,new ank.utils.ExtendedString(_loc8_ + 1).addLeftChar("0",2),new ank.utils.ExtendedString(_loc9_).addLeftChar("0",2),_loc11_,new ank.utils.ExtendedString(_loc12_).addLeftChar("0",2)]);
            }
            break;
         case 806:
            if(this._nParam2 == undefined && this._nParam3 == undefined)
            {
               _loc4_[0] = this.api.lang.getText("NORMAL");
            }
            else
            {
               _loc4_[0] = this._nParam2 <= 6 ? (this._nParam3 <= 6 ? this.api.lang.getText("NORMAL") : this.api.lang.getText("LEAN")) : this.api.lang.getText("FAT");
            }
            break;
         case 807:
            if(this._nParam3 == undefined)
            {
               _loc4_[0] = this.api.lang.getText("NO_LAST_MEAL");
            }
            else
            {
               _loc4_[0] = this.api.lang.getItemUnicText(this._nParam3).n;
            }
            break;
         case 814:
            _loc4_[0] = this.api.lang.getItemUnicText(this._nParam3).n;
            break;
         case 2152:
            _loc4_[2] = this.api.lang.getItemUnicText(this._nParam3).n;
            break;
         case 950:
         case 951:
         case 2128:
         case 2129:
         case 2137:
            _loc4_[2] = this.api.lang.getStateText(this._nParam3);
            break;
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_AP_COST:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_RANGE:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_RANGEABLE:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_RANGE_NO_RANGEABLE_TRIGGER:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_DMG:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_HEAL:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_AP_COST:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_CAST_INTVL:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_SET_INTVL:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_CC:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_CASTOUTLINE:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_NOLINEOFSIGHT:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_MAXPERTURN:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_MAXPERTARGET:
         case dofus.managers.SpellsBoostsManager.ACTION_BOOST_SPELL_DMG_PERCENT:
            _loc4_[0] = this.api.lang.getSpellText(Number(_loc4_[0])).n;
            break;
         case 939:
         case 940:
         case 969:
            var _loc13_ = new dofus.datacenter.Item(-1,Number(_loc4_[2]),1,0,"",0);
            _loc4_[2] = _loc13_.name;
            break;
         case 649:
         case 960:
            _loc4_[2] = this.api.lang.getAlignment(this._nParam3).n;
            break;
         case 999:
            break;
         case 2143:
            _loc4_[0] = this.api.lang.getMonstersText(this._nParam3).n;
            break;
         case 2146:
            if(Number(_loc4_[2]) < 10)
            {
               _loc4_[2] = "0" + _loc4_[2];
            }
      }
      if(this.api.lang.getEffectText(this._nType).j && this.api.kernel.OptionsManager.getOption("ViewDicesDammages"))
      {
         var _loc14_ = this._sParam4.toLowerCase().split("d");
         _loc14_[1] = _loc14_[1].split("+");
         if(!(_loc14_[0] == undefined || (_loc14_[1] == undefined || (_loc14_[1][0] == undefined || _loc14_[1][0] == undefined))))
         {
            var _loc15_ = "";
            _loc15_ += !(_loc14_[0] != "0" && _loc14_[1][0] != "0") ? "" : _loc14_[0] + "d" + _loc14_[1][0];
            _loc15_ += _loc14_[1][1] == "0" ? "" : (_loc15_ == "" ? "" : "+") + _loc14_[1][1];
            _loc4_[0] = _loc15_;
            var _loc0_ = null;
            _loc4_[4] = _loc0_ = undefined;
            _loc4_[2] = _loc0_;
            _loc4_[1] = _loc0_;
         }
      }
      var _loc16_ = "";
      if(this._nPropability > 0 && this._nPropability != undefined)
      {
         _loc16_ += " - " + this.api.lang.getText("IN_CASE_PERCENT",[this._nPropability]) + ": ";
      }
      if(this._nType == 666)
      {
         _loc16_ += this.api.lang.getText("DO_NOTHING");
      }
      else if(this._nType == 300)
      {
         _loc16_ += this.api.lang.getText("PASSIVE");
      }
      else
      {
         var _loc17_ = ank.utils.PatternDecoder.getDescription(_loc3_,_loc4_);
         _loc16_ += _loc17_;
      }
      if(this._nModificator > 0 && this.api.kernel.SpellsBoostsManager.isBoostedHealingOrDamagingEffect(this._nType))
      {
         _loc16_ += " " + this.api.lang.getText("BOOSTED_SPELLS_EFFECT_COMPLEMENT",[this._nModificator]);
      }
      if(!bShowRemainingTurns)
      {
         return _loc16_;
      }
      var _loc18_ = this.getTurnCountStr(false);
      if(_loc18_.length == 0)
      {
         return _loc16_;
      }
      return _loc16_ + " (" + _loc18_ + ")";
   }
   function get characteristic()
   {
      return this.api.lang.getEffectText(this._nType).c;
   }
   function get operator()
   {
      return this.api.lang.getEffectText(this._nType).o;
   }
   function get element()
   {
      return this.api.lang.getEffectText(this._nType).e;
   }
   function get spellName()
   {
      return this.api.lang.getSpellText(this._nSpellID).n;
   }
   function get spellDescription()
   {
      return this.api.lang.getSpellText(this._nSpellID).d;
   }
   function get showInTooltip()
   {
      return this.api.lang.getEffectText(this._nType).t;
   }
   function get sCasterID()
   {
      return this._sCasterID;
   }
   function get hasInvocationConditions()
   {
      var _loc2_ = dofus.managers.EffectsManager.getConditionalElementFromString("FZ",this._sConditions);
      if(_loc2_ != undefined)
      {
         return true;
      }
      _loc2_ = dofus.managers.EffectsManager.getConditionalElementFromString("Fz",this._sConditions);
      if(_loc2_ != undefined)
      {
         return true;
      }
      return false;
   }
   function get conditions()
   {
      return dofus.managers.EffectsManager.parseConditionsString(this._sConditions);
   }
   function get conditionalStateID()
   {
      var _loc2_ = dofus.managers.EffectsManager.getConditionalElementFromString("FS",this._sConditions);
      return _loc2_ == undefined ? undefined : Number(_loc2_);
   }
   function get conditionalAlignmentID()
   {
      var _loc2_ = dofus.managers.EffectsManager.getConditionalElementFromString("Ps",this._sConditions);
      return _loc2_ == undefined ? undefined : Number(_loc2_);
   }
   function set isOver(bOver)
   {
      this._bOver = bOver;
   }
   function set isExo(bExo)
   {
      this._bExo = bExo;
   }
   function get isOver()
   {
      return this._bOver;
   }
   function get isExo()
   {
      return this._bExo;
   }
   function initialize(sCasterID, mType, mParam1, mParam2, mParam3, mParam4, mRemainingTurn, mSpellID, nModificator, sConditions, bDispellable)
   {
      this.api = _global.API;
      this._nType = Number(mType);
      this._sCasterID = sCasterID;
      this._nParam1 = !_global.isNaN(Number(mParam1)) ? Number(mParam1) : undefined;
      this._nParam2 = !_global.isNaN(Number(mParam2)) ? Number(mParam2) : undefined;
      this._nParam3 = !_global.isNaN(Number(mParam3)) ? Number(mParam3) : undefined;
      this._sParam4 = mParam4;
      this._nRemainingTurn = mRemainingTurn != undefined ? Number(mRemainingTurn) : 0;
      if(this._nRemainingTurn < 0 || this._nRemainingTurn >= 63)
      {
         this._nRemainingTurn = Number.POSITIVE_INFINITY;
      }
      this._nSpellID = Number(mSpellID);
      this._nModificator = Number(nModificator);
      this._sConditions = sConditions;
      this._bDispellable = bDispellable;
   }
   function getParamWithOperator(nParamID)
   {
      var _loc3_ = this.operator != "-" ? 1 : -1;
      return this["_nParam" + nParamID] * _loc3_;
   }
   function getTurnCountStr(bShowLast)
   {
      var _loc3_ = new String();
      if(this._nRemainingTurn == undefined)
      {
         return "";
      }
      if(_global.isFinite(this._nRemainingTurn))
      {
         if(this._nRemainingTurn > 1)
         {
            return String(this._nRemainingTurn) + " " + this.api.lang.getText("TURNS");
         }
         if(this._nRemainingTurn == 0)
         {
            return "";
         }
         if(bShowLast)
         {
            return this.api.lang.getText("LAST_TURN");
         }
         return String(this._nRemainingTurn) + " " + this.api.lang.getText("TURN");
      }
      return this.api.lang.getText("INFINIT");
   }
}
