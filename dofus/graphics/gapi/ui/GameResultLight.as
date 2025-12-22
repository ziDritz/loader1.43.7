class dofus.graphics.gapi.ui.GameResultLight extends dofus.graphics.gapi.core.DofusAdvancedComponent
{
   var _oData;
   var _lblChallenges;
   var _winBackground;
   var _lblBonus;
   var _sdStars;
   var _btnMaximize;
   var _btnCross;
   var _mcRollOver;
   var _mcChallengesPlacer;
   var _ldrCollector;
   var _ldrChest;
   var _sDrop;
   static var CLASS_NAME = "GameResultLight";
   function GameResultLight()
   {
      super();
   }
   function set data(oData)
   {
      this._oData = oData;
   }
   function init()
   {
      super.init(false,dofus.graphics.gapi.ui.GameResultLight.CLASS_NAME);
      this._lblChallenges._visible = false;
   }
   function callClose()
   {
      this.unloadThis();
      return true;
   }
   function createChildren()
   {
      this.addToQueue({object:this,method:this.initTexts});
      this.addToQueue({object:this,method:this.addListeners});
      this.addToQueue({object:this,method:this.initData});
      this.gapi.unloadLastUIAutoHideComponent();
   }
   function initTexts()
   {
      this._winBackground.title = this.api.lang.getText("GAME_RESULTS");
      this._lblBonus.text = this.api.lang.getText("GAME_RESULTS_BONUS") + " :";
      this._sdStars.value = this.api.datacenter.Basics.aks_game_end_bonus;
      if(this._oData.challenges && this._oData.challenges.length)
      {
         this._lblChallenges._visible = true;
         this._lblChallenges.text = this.api.lang.getText("FIGHT_CHALLENGE_BONUS") + " :";
      }
   }
   function addListeners()
   {
      this._sdStars.addEventListener("over",this);
      this._sdStars.addEventListener("out",this);
      this._btnMaximize.addEventListener("click",this);
      this._btnCross.addEventListener("click",this);
      this._mcRollOver.onRollOver = function()
      {
         this._parent.over({target:this});
      };
      this._mcRollOver.onRollOut = function()
      {
         this._parent.out({target:this});
      };
   }
   function initData()
   {
      var _loc3_ = this._oData.currentPlayerInfosWithChest.length > 0;
      var _loc4_ = this._oData.collectors[0].items.length > 0;
      switch(this._oData.fightType)
      {
         case 0:
            var _loc2_ = "UI_GameResultTeamLight";
            if(this._sdStars.value == -1)
            {
               this._sdStars._visible = false;
               this._lblBonus._visible = false;
            }
            break;
         case 1:
            if(!this.api.datacenter.Player.rank.enable)
            {
               _loc2_ = "UI_GameResultTeamLight";
            }
            else
            {
               _loc2_ = "UI_GameResultTeamLightPVP";
            }
            this._lblBonus._visible = false;
            this._mcChallengesPlacer._visible = false;
            this._sdStars._visible = false;
      }
      !_loc3_ ? this.attachMovie(_loc2_,"_tCurrentPlayer",10,{dataProvider:this._oData.currentPlayerInfos}) : this.attachMovie(_loc2_,"_tCurrentPlayer",10,{dataProvider:this._oData.currentPlayerInfosWithChest});
      if(this._oData.challenges && this._oData.challenges.length)
      {
         this._lblChallenges._y = this._lblBonus._y + 17;
         this._mcChallengesPlacer._y = this._lblBonus._y + 18;
         var _loc6_ = 0;
         while(_loc6_ < this._oData.challenges.length)
         {
            var _loc5_ = dofus.graphics.gapi.controls.FightChallengeIcon(this.attachMovie("FightChallengeIcon","fci" + _loc6_,this.getNextHighestDepth(),{challenge:this._oData.challenges[_loc6_],displayUiOnClick:false}));
            var _loc0_ = null;
            _loc5_._height = _loc0_ = 17;
            _loc5_._width = _loc0_;
            _loc5_._x = _loc6_ * (_loc5_._width + 5) + this._mcChallengesPlacer._x - _loc6_ * 43;
            _loc5_._y = this._mcChallengesPlacer._y;
            _loc6_ = _loc6_ + 1;
         }
      }
      if(_loc4_)
      {
         this._ldrCollector.enabled = true;
         this._ldrCollector.contentPath = dofus.Constants.GUILDS_MINI_PATH + "6000.swf";
         this._ldrCollector.addEventListener("over",this);
         this._ldrCollector.addEventListener("out",this);
      }
      if(_loc3_)
      {
         if(_loc4_)
         {
            this._ldrChest._x += 20;
         }
         this._ldrChest.enabled = true;
         this._ldrChest.contentPath = dofus.Constants.GUILDS_MINI_PATH + "1083.swf";
         this._ldrChest.addEventListener("over",this);
         this._ldrChest.addEventListener("out",this);
      }
   }
   function click(oEvent)
   {
      switch(oEvent.target)
      {
         case this._btnCross:
            this.callClose();
            break;
         case this._btnMaximize:
            this.api.ui.loadUIComponent("GameResult","GameResult",{data:this._oData},{bAlwaysOnTop:true});
            this.api.kernel.OptionsManager.setOption("UseLightEndFightUI",false);
            this.callClose();
      }
   }
   function over(oEvent)
   {
      switch(oEvent.target)
      {
         case this._sdStars:
            this.gapi.showTooltip(this.api.lang.getText("GAME_RESULTS_BONUS_TOOLTIP",[this._sdStars.value]),oEvent.target,-8,{bXLimit:true,bYLimit:false,bTopAlign:true});
            break;
         case this._mcRollOver:
            this.gapi.showTooltip(this.api.lang.getText("TURNS_NUMBER") + " : <b>" + this._oData.currentTableTurn + "</b>\n" + this.api.lang.getText("DURATION") + " : " + this.api.kernel.GameManager.getDurationString(this._oData.duration,true),oEvent.target,-8,{bXLimit:true,bYLimit:false,bTopAlign:true});
            break;
         case this._ldrChest:
            this.gapi.showTooltip(this.api.lang.getText("INFOS_211"),oEvent.target,-8,{bXLimit:true,bYLimit:false,bTopAlign:true});
            break;
         case this._ldrCollector:
            if(this._sDrop == undefined)
            {
               this._sDrop = this.api.lang.getText("TAX_COLLECTOR_HAS_HARVEST") + " : \n\n";
               var _loc3_ = 0;
               while(_loc3_ < this._oData.collectors[0].items.length)
               {
                  var _loc4_ = this._oData.collectors[0].items[_loc3_];
                  if(_loc3_ > 0)
                  {
                     this._sDrop += "\n";
                  }
                  this._sDrop += _loc4_.Quantity + " x " + _loc4_.name;
                  _loc3_ = _loc3_ + 1;
               }
            }
            this.gapi.showTooltip(this._sDrop,oEvent.target,-8,{bXLimit:true,bYLimit:false,bTopAlign:true});
      }
   }
   function out(oEvent)
   {
      this.gapi.hideTooltip();
   }
}
