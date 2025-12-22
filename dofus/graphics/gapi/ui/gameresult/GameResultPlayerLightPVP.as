class dofus.graphics.gapi.ui.gameresult.GameResultPlayerLightPVP extends ank.gapi.core.UIBasicComponent
{
   var _mcList;
   var _oItems;
   var api;
   var _lblWinHonour;
   var _lblRank;
   var _pbXP;
   var _lblCurrentHonour;
   var _lblKama;
   var _sDisgrace;
   var _sHonour;
   var _mcAlignment;
   var _mcItemPlacer;
   var _mcItems;
   var _ldrAllDrop;
   function GameResultPlayerLightPVP()
   {
      super();
   }
   function set list(mcList)
   {
      this._mcList = mcList;
   }
   function setValue(bUsed, sSuggested, oItem)
   {
      this._oItems = oItem;
      if(bUsed)
      {
         if(oItem.rank == 0 && !this.api.datacenter.Basics.aks_current_server.isHardcore())
         {
            this._lblWinHonour._visible = false;
            this._lblRank._visible = false;
            this._pbXP._visible = false;
         }
         else
         {
            this._lblWinHonour._visible = true;
            this._lblRank._visible = true;
            this._pbXP._visible = true;
            if(oItem.winhonour >= 0)
            {
               this._lblCurrentHonour.text = "" + (oItem.honour - oItem.winhonour);
               this._lblWinHonour.text = !_global.isNaN(oItem.winhonour) ? " + " + new ank.utils.ExtendedString(oItem.winhonour).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "";
            }
            else
            {
               var _loc5_ = Math.abs(oItem.winhonour);
               this._lblCurrentHonour.text = "" + (oItem.honour - oItem.winhonour);
               this._lblWinHonour.text = !_global.isNaN(_loc5_) ? " - " + new ank.utils.ExtendedString(_loc5_).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "";
            }
            this._lblRank.text = !_global.isNaN(oItem.rank) ? oItem.rank : "";
            this._lblKama.text = !_global.isNaN(oItem.kama) ? new ank.utils.ExtendedString(oItem.kama).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "0";
            this._sDisgrace = !_global.isNaN(oItem.disgrace) ? new ank.utils.ExtendedString(oItem.disgrace).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "";
            this._sHonour = !_global.isNaN(oItem.honour) ? new ank.utils.ExtendedString(oItem.honour).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "";
            this._pbXP.minimum = this._pbXP.uberMinimum = oItem.minhonour;
            this._pbXP.maximum = this._pbXP.uberMaximum = oItem.maxhonour;
            if(oItem.winhonour >= 0)
            {
               this._pbXP.value = oItem.honour;
               this._pbXP.uberValue = oItem.honour - oItem.winhonour;
            }
            else
            {
               this._pbXP.value = oItem.honour - oItem.winhonour;
               this._pbXP.styleName = "BrownProgressBarLoss";
               this._pbXP.uberValue = oItem.honour;
            }
            var _loc6_ = oItem.alignment;
            if(this._lblRank._visible && _loc6_ > 0)
            {
               this._mcAlignment.gotoAndStop(_loc6_ + 1);
            }
            this.createEmptyMovieClip("_mcItems",10);
            var _loc7_ = false;
            var _loc8_ = oItem.items.length;
            while((_loc8_ = _loc8_ - 1) >= 0)
            {
               var _loc9_ = this._mcItemPlacer._x + 24 * _loc8_;
               var _loc10_ = this._mcItemPlacer._y + 24 * _loc8_;
               if(_loc9_ < this._mcItemPlacer._x + this._mcItemPlacer._width)
               {
                  var _loc11_ = oItem.items[_loc8_];
                  var _loc12_ = this._mcItems.attachMovie("Container","_ctrItem" + _loc8_,_loc8_,{_x:_loc9_,_y:this._mcItemPlacer._y + 1});
                  _loc12_.setSize(18,18);
                  _loc12_.addEventListener("over",this);
                  _loc12_.addEventListener("out",this);
                  _loc12_.addEventListener("click",this);
                  _loc12_.enabled = true;
                  _loc12_.margin = 0;
                  _loc12_.contentData = _loc11_;
               }
               else
               {
                  _loc7_ = true;
               }
            }
            this._ldrAllDrop._visible = _loc7_;
         }
      }
   }
   function init()
   {
      super.init(false);
      this._mcItemPlacer._alpha = 0;
      this.addToQueue({object:this,method:this.addListeners});
      this.api = _global.API;
   }
   function size()
   {
      super.size();
   }
   function addListeners()
   {
      var _loc2_ = this;
      this._ldrAllDrop.addEventListener("over",this);
      this._ldrAllDrop.addEventListener("out",this);
      this._pbXP.addEventListener("over",this);
      this._pbXP.addEventListener("out",this);
   }
   function over(oEvent)
   {
      switch(oEvent.target)
      {
         case this._pbXP:
            this.gapi.showTooltip(this.api.lang.getText("HONOUR_POINTS") + " : " + this._sHonour + "\n" + this.api.lang.getText("DISGRACE_POINTS") + " : " + this._sDisgrace,this._lblCurrentHonour,22,{bXLimit:true,bYLimit:false});
            break;
         case this._ldrAllDrop:
            var _loc3_ = this._oItems.items;
            var _loc4_ = "";
            var _loc5_ = 0;
            while(_loc5_ < _loc3_.length)
            {
               var _loc6_ = _loc3_[_loc5_];
               if(_loc5_ > 0)
               {
                  _loc4_ += "\n";
               }
               _loc4_ += _loc6_.Quantity + " x " + _loc6_.name;
               _loc5_ = _loc5_ + 1;
            }
            if(_loc4_ != "")
            {
               this._mcList.gapi.showTooltip(_loc4_,oEvent.target,30);
            }
            break;
         default:
            var _loc7_ = oEvent.target.contentData;
            var _loc8_ = _loc7_.style + "ToolTip";
            this._mcList.gapi.showTooltip(_loc7_.Quantity + " x " + _loc7_.name,oEvent.target,20,undefined,_loc8_);
      }
   }
   function out(oEvent)
   {
      this._mcList.gapi.hideTooltip();
   }
   function click(oEvent)
   {
      var _loc3_ = oEvent.target.contentData;
      if(Key.isDown(dofus.Constants.CHAT_INSERT_ITEM_KEY) && _loc3_ != undefined)
      {
         this._mcList._parent.gapi.api.kernel.GameManager.insertItemInChat(_loc3_);
      }
   }
}
