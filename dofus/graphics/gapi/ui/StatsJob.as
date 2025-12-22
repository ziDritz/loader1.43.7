class dofus.graphics.gapi.ui.StatsJob extends dofus.graphics.gapi.core.DofusAdvancedComponent
{
   var _popupQuantity;
   var _mcViewersPlacer;
   var _btnClosePanel;
   var _ctrAlignment;
   var _ctrJob0;
   var _ctrJob1;
   var _ctrJob2;
   var _ctrSpe0;
   var _ctrSpe1;
   var _ctrSpe2;
   var _btn10;
   var _btn11;
   var _btn12;
   var _btn13;
   var _btn14;
   var _btn15;
   var _btnClose;
   var _mcMoreStats;
   var _btnResetStats;
   var _cbModulatedLevel;
   var _mcAboutModulatedLevel;
   var _mcAboutRestats;
   var _mcAboutWisdom;
   var _lblVitality;
   var _lblVitalityValue;
   var _lblWisdom;
   var _lblWisdomValue;
   var _lblForce;
   var _lblForceValue;
   var _lblIntelligence;
   var _lblIntelligenceValue;
   var _lblChance;
   var _lblChanceValue;
   var _lblAgility;
   var _lblAgilityValue;
   var _lblName;
   var _lblEnergy;
   var _mcOverEnergy;
   var _lblCharacteristics;
   var _lblMyJobs;
   var _lblXP;
   var _lblLP;
   var _lblAP;
   var _lblMP;
   var _lblInitiative;
   var _lblDiscernment;
   var _lblCapital;
   var _lblSpecialization;
   var _svStats;
   var _jvJob;
   var _oCurrentJob;
   var _avAlignment;
   var _lblLevel;
   var _pbXP;
   var _mcXP;
   var _lblLPValue;
   var _lblLPmaxValue;
   var _lblAPValue;
   var _lblMPValue;
   var _lblCapitalValue;
   var _mcEnergy;
   var _pbEnergy;
   var _lblInitiativeValue;
   var _lblDiscernmentValue;
   static var CLASS_NAME = "StatsJob";
   function StatsJob()
   {
      super();
   }
   function init()
   {
      super.init(false,dofus.graphics.gapi.ui.StatsJob.CLASS_NAME);
   }
   function destroy()
   {
      this.gapi.hideTooltip();
      if(this._popupQuantity != undefined)
      {
         this._popupQuantity.callClose();
      }
   }
   function callClose()
   {
      this.unloadThis();
      return true;
   }
   function createChildren()
   {
      this.addToQueue({object:this,method:this.addListeners});
      this.addToQueue({object:this,method:this.initData});
      this.addToQueue({object:this,method:this.initTexts});
      this.addToQueue({object:this,method:this.initTemporis});
      this._mcViewersPlacer._visible = false;
      this._btnClosePanel._visible = false;
      if(Key.isDown(Key.SHIFT))
      {
         this.showStats();
      }
      this.api.datacenter.Player.data.addListener(this);
      this.api.datacenter.Player.addEventListener("nameChanged",this);
      this.api.datacenter.Player.addEventListener("levelChanged",this);
      this.api.datacenter.Player.addEventListener("xpChanged",this);
      this.api.datacenter.Player.addEventListener("lpChanged",this);
      this.api.datacenter.Player.addEventListener("lpMaxChanged",this);
      this.api.datacenter.Player.addEventListener("apChanged",this);
      this.api.datacenter.Player.addEventListener("mpChanged",this);
      this.api.datacenter.Player.addEventListener("initiativeChanged",this);
      this.api.datacenter.Player.addEventListener("discernmentChanged",this);
      this.api.datacenter.Player.addEventListener("forceXtraChanged",this);
      this.api.datacenter.Player.addEventListener("vitalityXtraChanged",this);
      this.api.datacenter.Player.addEventListener("wisdomXtraChanged",this);
      this.api.datacenter.Player.addEventListener("chanceXtraChanged",this);
      this.api.datacenter.Player.addEventListener("agilityXtraChanged",this);
      this.api.datacenter.Player.addEventListener("intelligenceXtraChanged",this);
      this.api.datacenter.Player.addEventListener("bonusPointsChanged",this);
      this.api.datacenter.Player.addEventListener("energyChanged",this);
      this.api.datacenter.Player.addEventListener("energyMaxChanged",this);
      this.api.datacenter.Player.addEventListener("alignmentChanged",this);
   }
   function addListeners()
   {
      this._ctrAlignment.addEventListener("click",this);
      this._ctrJob0.addEventListener("click",this);
      this._ctrJob1.addEventListener("click",this);
      this._ctrJob2.addEventListener("click",this);
      this._ctrSpe0.addEventListener("click",this);
      this._ctrSpe1.addEventListener("click",this);
      this._ctrSpe2.addEventListener("click",this);
      this._ctrAlignment.addEventListener("over",this);
      this._ctrJob0.addEventListener("over",this);
      this._ctrJob1.addEventListener("over",this);
      this._ctrJob2.addEventListener("over",this);
      this._ctrSpe0.addEventListener("over",this);
      this._ctrSpe1.addEventListener("over",this);
      this._ctrSpe2.addEventListener("over",this);
      this._ctrAlignment.addEventListener("out",this);
      this._ctrJob0.addEventListener("out",this);
      this._ctrJob1.addEventListener("out",this);
      this._ctrJob2.addEventListener("out",this);
      this._ctrSpe0.addEventListener("out",this);
      this._ctrSpe1.addEventListener("out",this);
      this._ctrSpe2.addEventListener("out",this);
      this._btn10.addEventListener("click",this);
      this._btn10.addEventListener("over",this);
      this._btn10.addEventListener("out",this);
      this._btn11.addEventListener("click",this);
      this._btn11.addEventListener("over",this);
      this._btn11.addEventListener("out",this);
      this._btn12.addEventListener("click",this);
      this._btn12.addEventListener("over",this);
      this._btn12.addEventListener("out",this);
      this._btn13.addEventListener("click",this);
      this._btn13.addEventListener("over",this);
      this._btn13.addEventListener("out",this);
      this._btn14.addEventListener("click",this);
      this._btn14.addEventListener("over",this);
      this._btn14.addEventListener("out",this);
      this._btn15.addEventListener("click",this);
      this._btn15.addEventListener("over",this);
      this._btn15.addEventListener("out",this);
      this.api.datacenter.Game.addEventListener("stateChanged",this);
      this._btnClose.addEventListener("click",this);
      this._btnClosePanel.addEventListener("click",this);
      this._mcMoreStats.onRelease = function()
      {
         this._parent.click({target:this});
      };
      this._btnResetStats.addEventListener("click",this);
      this._btnResetStats.addEventListener("over",this);
      this._btnResetStats.addEventListener("out",this);
      this._cbModulatedLevel.addEventListener("itemSelected",this);
      this._mcMoreStats.onRollOver = function()
      {
         this._parent.gapi.showTooltip(this._parent.api.lang.getText("MORE_STATS"),this,-20);
      };
      this._mcMoreStats.onRollOut = function()
      {
         this._parent.gapi.hideTooltip();
      };
      this._mcAboutModulatedLevel.onRollOver = function()
      {
         this._parent.gapi.showTooltip(this._parent.api.lang.getText("ABOUT_MODULATED_LEVEL"),this,-20);
      };
      this._mcAboutModulatedLevel.onRollOut = function()
      {
         this._parent.gapi.hideTooltip();
      };
      this._mcAboutRestats.onRollOver = function()
      {
         this._parent.gapi.showTooltip(this._parent.api.lang.getText("ABOUT_RESET_STATS"),this,-20);
      };
      this._mcAboutRestats.onRollOut = function()
      {
         this._parent.gapi.hideTooltip();
      };
      this._mcAboutWisdom.onRollOver = function()
      {
         this._parent.gapi.showTooltip(this._parent.api.lang.getText("ABOUT_WISDOM"),this,-20);
      };
      this._mcAboutWisdom.onRollOut = function()
      {
         this._parent.gapi.hideTooltip();
      };
      var ref = this;
      this._lblVitality.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblVitality.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblVitalityValue.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblVitalityValue.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblWisdom.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblWisdom.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblWisdomValue.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblWisdomValue.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblForce.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblForce.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblForceValue.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblForceValue.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblIntelligence.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblIntelligence.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblIntelligenceValue.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblIntelligenceValue.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblChance.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblChance.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblChanceValue.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblChanceValue.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblAgility.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblAgility.onRollOut = function()
      {
         ref.out({target:this});
      };
      this._lblAgilityValue.onRollOver = function()
      {
         ref.over({target:this});
      };
      this._lblAgilityValue.onRollOut = function()
      {
         ref.out({target:this});
      };
   }
   function initData()
   {
      var _loc2_ = this.api.datacenter.Player;
      this.levelChanged({value:_loc2_.Level});
      this.xpChanged({value:_loc2_.XP});
      this.lpChanged({value:_loc2_.LP});
      this.lpMaxChanged({value:_loc2_.LPmax});
      this.apChanged({value:_loc2_.AP});
      this.mpChanged({value:_loc2_.MP});
      this.initiativeChanged({value:_loc2_.Initiative});
      this.discernmentChanged({value:_loc2_.Discernment});
      this.forceXtraChanged({value:_loc2_.ForceXtra});
      this.vitalityXtraChanged({value:_loc2_.VitalityXtra});
      this.wisdomXtraChanged({value:_loc2_.WisdomXtra});
      this.chanceXtraChanged({value:_loc2_.ChanceXtra});
      this.agilityXtraChanged({value:_loc2_.AgilityXtra});
      this.intelligenceXtraChanged({value:_loc2_.IntelligenceXtra});
      this.bonusPointsChanged({value:_loc2_.BonusPoints});
      this.energyChanged({value:_loc2_.Energy});
      this.alignmentChanged({alignment:_loc2_.alignment});
      var _loc3_ = this.api.datacenter.Player.Jobs;
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.length)
      {
         var _loc5_ = _loc3_[_loc4_];
         var _loc6_ = _loc5_.specializationOf;
         if(_loc6_ != 0)
         {
            var _loc7_ = 0;
            while(_loc7_ < 3)
            {
               var _loc8_ = this["_ctrSpe" + _loc7_];
               if(_loc8_.contentData == undefined)
               {
                  _loc8_.contentData = _loc5_;
                  break;
               }
               _loc7_ = _loc7_ + 1;
            }
         }
         else
         {
            var _loc9_ = 0;
            while(_loc9_ < 3)
            {
               var _loc10_ = this["_ctrJob" + _loc9_];
               if(_loc10_.contentData == undefined)
               {
                  _loc10_.contentData = _loc5_;
                  break;
               }
               _loc9_ = _loc9_ + 1;
            }
         }
         _loc4_ = _loc4_ + 1;
      }
      this._lblName.text = this.api.datacenter.Player.Name;
      this.activateBoostButtons(!this.api.datacenter.Game.isFight && this.api.datacenter.Map.bCanBoostStats);
      this._btnResetStats.enabled = this._cbModulatedLevel.enabled = !this.api.datacenter.Game.isFight && !this.api.datacenter.Temporis.isCursedDungeonMap(this.api.datacenter.Map.id);
   }
   function initTexts()
   {
      this._lblEnergy.text = this.api.lang.getText("ENERGY");
      if(this.api.datacenter.Basics.aks_current_server.typeNum == dofus.datacenter.Server.SERVER_HARDCORE)
      {
         this._lblEnergy._alpha = 50;
         this._mcOverEnergy._visible = false;
      }
      this._lblCharacteristics.text = this.api.lang.getText("CHARACTERISTICS");
      this._lblMyJobs.text = this.api.lang.getText("MY_JOBS");
      this._lblXP.text = this.api.lang.getText("EXPERIMENT");
      this._lblLP.text = this.api.lang.getText("LIFEPOINTS");
      this._lblAP.text = this.api.lang.getText("ACTIONPOINTS");
      this._lblMP.text = this.api.lang.getText("MOVEPOINTS");
      this._lblInitiative.text = this.api.lang.getText("INITIATIVE");
      this._lblDiscernment.text = this.api.lang.getText("DISCERNMENT");
      this._lblForce.text = this.api.lang.getText("FORCE");
      this._lblVitality.text = this.api.lang.getText("VITALITY");
      this._lblWisdom.text = this.api.lang.getText("WISDOM");
      this._lblChance.text = this.api.lang.getText("CHANCE");
      this._lblAgility.text = this.api.lang.getText("AGILITY");
      this._lblIntelligence.text = this.api.lang.getText("INTELLIGENCE");
      this._lblCapital.text = this.api.lang.getText("CHARACTERISTICS_POINTS");
      this._lblSpecialization.text = this.api.lang.getText("SPECIALIZATIONS");
   }
   function initTemporis()
   {
      var _loc2_ = this.api.datacenter.Basics.aks_current_server.isTemporis();
      this._mcAboutWisdom._visible = _loc2_;
      this._btnResetStats._visible = _loc2_;
      this._mcAboutRestats._visible = _loc2_;
      this._btnResetStats.enabled = !this.api.datacenter.Game.isFight;
      this._cbModulatedLevel._visible = _loc2_;
      this._mcAboutModulatedLevel._visible = _loc2_;
      this._cbModulatedLevel.enabled = !this.api.datacenter.Game.isFight && !this.api.datacenter.Temporis.isCursedDungeonMap(this.api.datacenter.Map.id);
   }
   function getStatsCostString(oBoost)
   {
      return "<b><u>" + this.api.lang.getText("COST") + " :" + "</u> " + oBoost.cost + "</b> " + this.api.lang.getText("POUR") + " <b>" + oBoost.count + "</b>";
   }
   function showStats()
   {
      this.hideAlignment();
      this.hideJob();
      if(this._svStats == undefined)
      {
         this.attachMovie("StatsViewer","_svStats",this.getNextHighestDepth(),{_x:this._mcViewersPlacer._x,_y:this._mcViewersPlacer._y});
         this._btnClosePanel._visible = true;
         this._btnClosePanel.swapDepths(this.getNextHighestDepth());
         this._btnClosePanel._x += 35;
      }
      else
      {
         this.hideStats();
      }
   }
   function hideStats()
   {
      if(this._svStats != undefined)
      {
         this._btnClosePanel._x -= 35;
      }
      this._svStats.removeMovieClip();
      this._btnClosePanel._visible = false;
   }
   function showJob(oJob)
   {
      this.hideAlignment();
      this.hideStats();
      if(oJob == undefined)
      {
         this.hideJob();
         return undefined;
      }
      if(this._jvJob == undefined)
      {
         this.attachMovie("JobViewer","_jvJob",this.getNextHighestDepth(),{_x:this._mcViewersPlacer._x,_y:this._mcViewersPlacer._y});
      }
      else if(this._oCurrentJob.id == oJob.id)
      {
         this.hideJob();
         return undefined;
      }
      this._btnClosePanel._visible = true;
      this._btnClosePanel.swapDepths(this.getNextHighestDepth());
      this._jvJob.job = oJob;
      this["_ctr" + (this._oCurrentJob.specializationOf != 0 ? "Spe" : "Job") + this._oCurrentJob.id].selected = false;
      this["_ctr" + (oJob.specializationOf != 0 ? "Spe" : "Job") + oJob.id].selected = true;
      this._oCurrentJob = oJob;
   }
   function hideJob()
   {
      this["_ctr" + (this._oCurrentJob.specializationOf != 0 ? "Spe" : "Job") + this._oCurrentJob.id].selected = false;
      this._jvJob.removeMovieClip();
      delete this._oCurrentJob;
      this._btnClosePanel._visible = false;
   }
   function showAlignment()
   {
      this.hideJob();
      this.hideStats();
      if(this._avAlignment == undefined)
      {
         this.attachMovie("AlignmentViewer","_avAlignment",this.getNextHighestDepth(),{_x:this._mcViewersPlacer._x,_y:this._mcViewersPlacer._y});
         this._btnClosePanel._visible = true;
         this._btnClosePanel.swapDepths(this.getNextHighestDepth());
      }
      else
      {
         this.hideAlignment();
      }
   }
   function hideAlignment()
   {
      this._avAlignment.removeMovieClip();
      this._btnClosePanel._visible = false;
   }
   function activateBoostButtons(bActivated)
   {
      var _loc3_ = 10;
      while(_loc3_ < 16)
      {
         this["_btn" + _loc3_].enabled = bActivated;
         _loc3_ = _loc3_ + 1;
      }
   }
   function updateCharacteristicButton(nCharacteristicID)
   {
      var _loc3_ = this.api.datacenter.Player.getBoostCostAndCountForCharacteristic(nCharacteristicID).cost;
      var _loc4_ = this["_btn" + nCharacteristicID];
      if(_loc3_ <= this.api.datacenter.Player.BonusPoints)
      {
         _loc4_._visible = true;
      }
      else
      {
         _loc4_._visible = false;
      }
      if(this.api.datacenter.Basics.aks_current_server.isTemporis())
      {
         this._btn12.enabled = false;
         this._btn12._visible = false;
      }
   }
   function click(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "_btnClosePanel":
            this.hideJob();
            this.hideAlignment();
            this.hideStats();
            break;
         case "_ctrAlignment":
            if(this.api.datacenter.Player.data.alignment.index == 0)
            {
               this.api.kernel.showMessage(undefined,this.api.lang.getText("NEED_ALIGNMENT"),"ERROR_BOX");
            }
            else
            {
               this.showAlignment();
            }
            break;
         case "_btn10":
         case "_btn11":
         case "_btn12":
         case "_btn13":
         case "_btn14":
         case "_btn15":
            this.api.sounds.events.onStatsJobBoostButtonClick();
            var _loc3_ = Number(oEvent.target._name.substr(4));
            if(this.api.datacenter.Player.canBoost(_loc3_))
            {
               var oBoost = this.api.datacenter.Player.getBoostCostAndCountForCharacteristic(_loc3_);
               var nCost = oBoost.cost;
               var _loc4_ = oBoost.possibleCount;
               var nCapital = this.api.datacenter.Player.BonusPoints;
               if(Key.isDown(Key.CONTROL) || Key.isDown(Key.SHIFT))
               {
                  var _loc5_ = "POPUP_QUANTITY_STATS_BOOST_DESCRIPTION";
                  var _loc6_ = [this.getStatsCostString(oBoost),function(nMin, nMax, nValue)
                  {
                     return String(nValue * nCost);
                  },function(nMin, nMax, nValue)
                  {
                     return String(nCapital - nValue * nCost);
                  },function(nMin, nMax, nValue)
                  {
                     return String(nValue * oBoost.count);
                  }];
                  var _loc7_ = this.gapi.loadUIComponent("PopupQuantityWithDescription","PopupQuantity",{descriptionLangKey:_loc5_,descriptionLangKeyParams:_loc6_,value:1,max:_loc4_,isMaxButtonValidationEnabled:false,params:{targetType:"charac",characteristicID:_loc3_}});
                  _loc7_.addEventListener("validate",this);
                  this._popupQuantity = _loc7_;
               }
               else
               {
                  this.api.network.Account.boost(_loc3_,1);
               }
            }
            break;
         case "_btnResetStats":
            var _loc8_ = this.gapi.loadUIComponent("AskYesNo","AskYesNoRestat",{title:this.api.lang.getText("RESET_STATS"),text:this.api.lang.getText("CONFIRM_RESET_STATS")});
            _loc8_.addEventListener("yes",this);
            break;
         case "_btnClose":
            this.callClose();
            break;
         case "_mcMoreStats":
            this.showStats();
            break;
         default:
            this.showJob(oEvent.target.contentData);
      }
   }
   function validate(oEvent)
   {
      var _loc3_ = oEvent.value;
      var _loc0_ = null;
      if((_loc0_ = oEvent.params.targetType) === "charac")
      {
         var _loc4_ = oEvent.params.characteristicID;
         this.api.network.Account.boost(_loc4_,_loc3_);
      }
   }
   function over(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "_btn10":
         case "_btn11":
         case "_btn12":
         case "_btn13":
         case "_btn14":
         case "_btn15":
            var _loc3_ = Number(oEvent.target._name.substr(4));
            var _loc4_ = this.api.datacenter.Player.getBoostCostAndCountForCharacteristic(_loc3_);
            this.gapi.showTooltip(this.getStatsCostString(_loc4_),oEvent.target,-20);
            break;
         case "_ctrAlignment":
            this.gapi.showTooltip(this.api.datacenter.Player.alignment.name,oEvent.target,oEvent.target.height + 5);
            break;
         case "_btnResetStats":
            this.gapi.showTooltip(this.api.lang.getText("RESET_STATS"),oEvent.target,-20);
            break;
         case "_lblVitality":
            this.gapi.showTooltip(this.api.lang.getText("HELP_VITALITY"),oEvent.target,20);
            break;
         case "_lblWisdom":
            this.gapi.showTooltip(this.api.lang.getText("HELP_WISDOM"),oEvent.target,20);
            break;
         case "_lblIntelligence":
            this.gapi.showTooltip(this.api.lang.getText("HELP_INTELLIGENCE"),oEvent.target,20);
            break;
         case "_lblForce":
            this.gapi.showTooltip(this.api.lang.getText("HELP_FORCE"),oEvent.target,20);
            break;
         case "_lblChance":
            this.gapi.showTooltip(this.api.lang.getText("HELP_CHANCE"),oEvent.target,20);
            break;
         case "_lblAgility":
            this.gapi.showTooltip(this.api.lang.getText("HELP_AGILITY"),oEvent.target,20);
            break;
         case "_lblVitalityValue":
            var _loc5_ = 11;
            var _loc6_ = this.api.datacenter.Player.getStatDetail(_loc5_);
            this.gapi.showTooltip(this.api.lang.getText("STAT_DETAILS",[_loc6_.s - _loc6_.a,_loc6_.a,_loc6_.i,_loc6_.d + _loc6_.b]),oEvent.target,20);
            break;
         case "_lblWisdomValue":
            var _loc7_ = 12;
            var _loc8_ = this.api.datacenter.Player.getStatDetail(_loc7_);
            this.gapi.showTooltip(this.api.lang.getText("STAT_DETAILS",[_loc8_.s - _loc8_.a,_loc8_.a,_loc8_.i,_loc8_.d + _loc8_.b]),oEvent.target,20);
            break;
         case "_lblIntelligenceValue":
            var _loc9_ = 15;
            var _loc10_ = this.api.datacenter.Player.getStatDetail(_loc9_);
            this.gapi.showTooltip(this.api.lang.getText("STAT_DETAILS",[_loc10_.s - _loc10_.a,_loc10_.a,_loc10_.i,_loc10_.d + _loc10_.b]),oEvent.target,20);
            break;
         case "_lblForceValue":
            var _loc11_ = 10;
            var _loc12_ = this.api.datacenter.Player.getStatDetail(_loc11_);
            this.gapi.showTooltip(this.api.lang.getText("STAT_DETAILS",[_loc12_.s - _loc12_.a,_loc12_.a,_loc12_.i,_loc12_.d + _loc12_.b]),oEvent.target,20);
            break;
         case "_lblChanceValue":
            var _loc13_ = 13;
            var _loc14_ = this.api.datacenter.Player.getStatDetail(_loc13_);
            this.gapi.showTooltip(this.api.lang.getText("STAT_DETAILS",[_loc14_.s - _loc14_.a,_loc14_.a,_loc14_.i,_loc14_.d + _loc14_.b]),oEvent.target,20);
            break;
         case "_lblAgilityValue":
            var _loc15_ = 14;
            var _loc16_ = this.api.datacenter.Player.getStatDetail(_loc15_);
            this.gapi.showTooltip(this.api.lang.getText("STAT_DETAILS",[_loc16_.s - _loc16_.a,_loc16_.a,_loc16_.i,_loc16_.d + _loc16_.b]),oEvent.target,20);
            break;
         default:
            this.gapi.showTooltip(oEvent.target.contentData.name,oEvent.target,-20);
      }
   }
   function out(oEvent)
   {
      this.gapi.hideTooltip();
   }
   function itemSelected(oEvent)
   {
      var _loc0_ = null;
      if((_loc0_ = oEvent.target) === this._cbModulatedLevel)
      {
         var _loc3_ = this._cbModulatedLevel.selectedItem;
         if(_loc3_.id == 0)
         {
            this.api.network.Temporis.episodeThree.askChangeLevel("real");
         }
         else
         {
            this.api.network.Temporis.episodeThree.askChangeLevel("" + _loc3_.id * 30);
         }
      }
   }
   function yes(oEvent)
   {
      this.api.network.Temporis.episodeThree.askRestat();
   }
   function nameChanged(oEvent)
   {
      this._lblName.text = oEvent.value;
   }
   function levelChanged(oEvent)
   {
      this._lblLevel.text = this.api.lang.getText("LEVEL") + " " + this.api.datacenter.Player.ShowedLevel;
      var _loc3_ = new ank.utils.ExtendedArray();
      _loc3_.push({label:this.api.lang.getText("ACTUAL_LEVEL"),id:0});
      var _loc4_ = 1;
      while(_loc4_ < 7)
      {
         var _loc5_ = _loc4_ * 30;
         if(_loc5_ >= this.api.datacenter.Player.Level)
         {
            break;
         }
         _loc3_.push({label:"" + _loc5_,id:_loc4_});
         _loc4_ = _loc4_ + 1;
      }
      this._cbModulatedLevel.dataProvider = _loc3_;
      if(this.api.datacenter.Player.Level == this.api.datacenter.Player.ShowedLevel)
      {
         this._cbModulatedLevel.selectedIndex = 0;
      }
      else
      {
         var _loc6_ = 1;
         while(_loc6_ < 7)
         {
            var _loc7_ = _loc6_ * 30;
            if(_loc7_ == this.api.datacenter.Player.ShowedLevel)
            {
               this._cbModulatedLevel.selectedIndex = _loc6_;
            }
            _loc6_ = _loc6_ + 1;
         }
      }
   }
   function xpChanged(oEvent)
   {
      this._pbXP.minimum = this.api.datacenter.Player.XPlow;
      this._pbXP.maximum = this.api.datacenter.Player.Level != 200 ? this.api.datacenter.Player.XPhigh : -1;
      this._pbXP.value = oEvent.value;
      this._mcXP.onRollOver = function()
      {
         this._parent.gapi.showTooltip(new ank.utils.ExtendedString(oEvent.value).addMiddleChar(this._parent.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) + " / " + new ank.utils.ExtendedString(this._parent._pbXP.maximum).addMiddleChar(this._parent.api.lang.getConfigText("THOUSAND_SEPARATOR"),3),this,-10);
      };
      this._mcXP.onRollOut = function()
      {
         this._parent.gapi.hideTooltip();
      };
   }
   function lpChanged(oEvent)
   {
      this._lblLPValue.text = String(oEvent.value);
   }
   function lpMaxChanged(oEvent)
   {
      this._lblLPmaxValue.text = String(oEvent.value);
   }
   function apChanged(oEvent)
   {
      this._lblAPValue.text = String(Math.max(0,oEvent.value));
   }
   function mpChanged(oEvent)
   {
      this._lblMPValue.text = String(Math.max(0,oEvent.value));
   }
   function forceXtraChanged(oEvent)
   {
      this._lblForceValue.text = this.api.datacenter.Player.Force + (oEvent.value == 0 ? "" : (oEvent.value <= 0 ? " (" : " (+") + String(oEvent.value) + ")");
      this.updateCharacteristicButton(10);
   }
   function vitalityXtraChanged(oEvent)
   {
      this._lblVitalityValue.text = this.api.datacenter.Player.Vitality + (oEvent.value == 0 ? "" : (oEvent.value <= 0 ? " (" : " (+") + String(oEvent.value) + ")");
      this.updateCharacteristicButton(11);
   }
   function wisdomXtraChanged(oEvent)
   {
      this._lblWisdomValue.text = this.api.datacenter.Player.Wisdom + (oEvent.value == 0 ? "" : (oEvent.value <= 0 ? " (" : " (+") + String(oEvent.value) + ")");
      this.updateCharacteristicButton(12);
   }
   function chanceXtraChanged(oEvent)
   {
      this._lblChanceValue.text = this.api.datacenter.Player.Chance + (oEvent.value == 0 ? "" : (oEvent.value <= 0 ? " (" : " (+") + String(oEvent.value) + ")");
      this.updateCharacteristicButton(13);
   }
   function agilityXtraChanged(oEvent)
   {
      this._lblAgilityValue.text = this.api.datacenter.Player.Agility + (oEvent.value == 0 ? "" : (oEvent.value <= 0 ? " (" : " (+") + String(oEvent.value) + ")");
      this.updateCharacteristicButton(14);
   }
   function intelligenceXtraChanged(oEvent)
   {
      this._lblIntelligenceValue.text = this.api.datacenter.Player.Intelligence + (oEvent.value == 0 ? "" : (oEvent.value <= 0 ? " (" : " (+") + String(oEvent.value) + ")");
      this.updateCharacteristicButton(15);
   }
   function bonusPointsChanged(oEvent)
   {
      this._lblCapitalValue.text = String(oEvent.value);
   }
   function energyChanged(oEvent)
   {
      if(this.api.datacenter.Basics.aks_current_server.typeNum != dofus.datacenter.Server.SERVER_HARDCORE)
      {
         this._mcEnergy.onRollOver = function()
         {
            this._parent.gapi.showTooltip(new ank.utils.ExtendedString(oEvent.value).addMiddleChar(this._parent.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) + " / " + new ank.utils.ExtendedString(Math.max(10000,this._parent._pbEnergy.maximum)).addMiddleChar(this._parent.api.lang.getConfigText("THOUSAND_SEPARATOR"),3),this,-10);
         };
         this._mcEnergy.onRollOut = function()
         {
            this._parent.gapi.hideTooltip();
         };
         this._pbEnergy.maximum = this.api.datacenter.Player.EnergyMax;
         this._pbEnergy.value = oEvent.value;
      }
      else
      {
         this._pbEnergy._alpha = 50;
         this._pbEnergy.enabled = false;
      }
   }
   function energyMaxChanged(oEvent)
   {
      this._pbEnergy.maximum = oEvent.value;
   }
   function alignmentChanged(oEvent)
   {
      this._ctrAlignment.contentPath = oEvent.alignment.iconFile;
   }
   function initiativeChanged(oEvent)
   {
      this._lblInitiativeValue.text = String(oEvent.value);
   }
   function discernmentChanged(oEvent)
   {
      this._lblDiscernmentValue.text = String(oEvent.value);
   }
   function stateChanged(oEvent)
   {
      this.activateBoostButtons(!(oEvent.value > 1 && oEvent.value != undefined));
   }
}
