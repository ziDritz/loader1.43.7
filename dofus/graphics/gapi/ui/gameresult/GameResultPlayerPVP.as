class dofus.graphics.gapi.ui.gameresult.GameResultPlayerPVP extends ank.gapi.core.UIBasicComponent
{
   var _mcList;
   var _oItems;
   var _lblName;
   var api;
   var _pbHonour;
   var _lblWinHonour;
   var _pbDisgrace;
   var _lblWinDisgrace;
   var _lblRank;
   var _lblKama;
   var _lblLevel;
   var _ldrGuild;
   var _mcDeadHead;
   var _mcAlignment;
   var _mcItemPlacer;
   var _mcItems;
   var _ldrAllDrop;
   function GameResultPlayerPVP()
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
         switch(oItem.type)
         {
            case "monster":
            case "taxcollector":
            case "player":
               this._lblName.text = oItem.name;
               if(oItem.rank == 0 && !this.api.datacenter.Basics.aks_current_server.isHardcore())
               {
                  this._pbHonour._visible = false;
                  this._lblWinHonour._visible = false;
                  this._pbDisgrace._visible = false;
                  this._lblWinDisgrace._visible = false;
                  this._lblRank._visible = false;
               }
               else
               {
                  this._pbHonour._visible = true;
                  this._pbDisgrace._visible = true;
                  this._lblWinDisgrace._visible = true;
                  this._lblWinHonour._visible = true;
                  this._lblRank._visible = true;
                  if(this.api.datacenter.Basics.aks_current_server.isHardcore())
                  {
                     if(_global.isNaN(oItem.minxp))
                     {
                        this._pbDisgrace._visible = false;
                     }
                     this._pbDisgrace.minimum = oItem.minxp;
                     this._pbDisgrace.maximum = oItem.maxxp;
                     this._pbDisgrace.value = oItem.xp;
                  }
                  else
                  {
                     var _loc0_ = null;
                     this._pbDisgrace.uberMinimum = _loc0_ = oItem.mindisgrace;
                     this._pbDisgrace.minimum = _loc0_;
                     this._pbDisgrace.uberMaximum = _loc0_ = oItem.maxdisgrace;
                     this._pbDisgrace.maximum = _loc0_;
                     this._pbDisgrace.value = oItem.disgrace;
                     this._pbDisgrace.uberValue = oItem.disgrace - (!_global.isNaN(oItem.windisgrace) ? oItem.windisgrace : 0);
                  }
                  this._pbHonour.uberMinimum = _loc0_ = oItem.minhonour;
                  this._pbHonour.minimum = _loc0_;
                  this._pbHonour.uberMaximum = _loc0_ = oItem.maxhonour;
                  this._pbHonour.maximum = _loc0_;
                  if(oItem.winhonour >= 0)
                  {
                     this._pbHonour.value = oItem.honour;
                     this._pbHonour.uberValue = oItem.honour - oItem.winhonour;
                  }
                  else
                  {
                     this._pbHonour.value = oItem.honour - oItem.winhonour;
                     this._pbHonour.styleName = "BrownProgressBarLoss";
                     this._pbHonour.uberValue = oItem.honour;
                  }
               }
               this._lblWinHonour.text = !_global.isNaN(oItem.winhonour) ? new ank.utils.ExtendedString(oItem.winhonour).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "";
               if(!this.api.datacenter.Basics.aks_current_server.isHardcore())
               {
                  this._lblWinDisgrace.text = !_global.isNaN(oItem.windisgrace) ? oItem.windisgrace : "";
               }
               else
               {
                  this._lblWinDisgrace.text = !_global.isNaN(oItem.winxp) ? new ank.utils.ExtendedString(oItem.winxp).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "";
               }
               this._lblRank.text = !_global.isNaN(oItem.rank) ? oItem.rank : "";
               this._lblKama.text = !_global.isNaN(oItem.kama) ? oItem.kama : "";
               this._lblLevel.text = oItem.level;
               if(oItem.bDead)
               {
                  this._ldrGuild.contentPath = "";
                  this._mcDeadHead._visible = true;
               }
               else
               {
                  this._ldrGuild.contentPath = dofus.Constants.GUILDS_MINI_PATH + oItem.gfx + ".swf";
                  this._mcDeadHead._visible = false;
               }
               var _loc5_ = oItem.alignment;
               if(this._lblRank._visible && _loc5_ > 0)
               {
                  this._mcAlignment.gotoAndStop(_loc5_ + 1);
               }
               this.createEmptyMovieClip("_mcItems",10);
               var _loc6_ = false;
               var _loc7_ = oItem.items.length;
               while((_loc7_ = _loc7_ - 1) >= 0)
               {
                  var _loc8_ = this._mcItemPlacer._x + 24 * _loc7_;
                  if(_loc8_ < this._mcItemPlacer._x + this._mcItemPlacer._width)
                  {
                     var _loc9_ = oItem.items[_loc7_];
                     var _loc10_ = this._mcItems.attachMovie("Container","_ctrItem" + _loc7_,_loc7_,{_x:_loc8_,_y:this._mcItemPlacer._y + 1});
                     _loc10_.setSize(18,18);
                     _loc10_.addEventListener("over",this);
                     _loc10_.addEventListener("out",this);
                     _loc10_.addEventListener("click",this);
                     _loc10_.enabled = true;
                     _loc10_.margin = 0;
                     _loc10_.contentData = _loc9_;
                  }
                  else
                  {
                     _loc6_ = true;
                  }
               }
               this._ldrAllDrop._visible = _loc6_;
         }
      }
      else if(this._lblName.text != undefined)
      {
         this._pbHonour._visible = false;
         this._lblName.text = "";
         this._pbHonour.minimum = 0;
         this._pbHonour.maximum = 100;
         this._pbHonour.value = 0;
         this._pbHonour.uberValue = 0;
         this._pbDisgrace.minimum = 0;
         this._pbDisgrace.maximum = 100;
         this._pbDisgrace.value = 0;
         this._pbDisgrace.uberValue = 0;
         this._lblWinHonour.text = "";
         this._lblWinDisgrace.text = "";
         this._lblKama.text = "";
         this._mcDeadHead._visible = false;
         this._mcItems.removeMovieClip();
      }
   }
   function init()
   {
      super.init(false);
      this._mcItemPlacer._visible = false;
      this._pbHonour._visible = false;
      this._mcDeadHead._visible = false;
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
      this._pbHonour.enabled = true;
      this._pbHonour.addEventListener("over",this);
      this._pbHonour.addEventListener("out",this);
      this._pbDisgrace.enabled = true;
      this._pbDisgrace.addEventListener("over",this);
      this._pbDisgrace.addEventListener("out",this);
   }
   function over(oEvent)
   {
      switch(oEvent.target)
      {
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
         case this._pbHonour:
            this._mcList.gapi.showTooltip(this._oItems.honour + " / " + this._oItems.maxhonour,oEvent.target,20);
            break;
         case this._pbDisgrace:
            this._mcList.gapi.showTooltip(this._oItems.disgrace + " / " + this._oItems.maxdisgrace,oEvent.target,20);
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
