class dofus.graphics.gapi.controls.ItemSetViewer extends dofus.graphics.gapi.core.DofusAdvancedComponent
{
   var _oItemSet;
   var _btnClose;
   var _lblEffects;
   var _lblItems;
   var _winBg;
   var _lstEffects;
   var dispatchEvent;
   static var CLASS_NAME = "ItemSetViewer";
   function ItemSetViewer()
   {
      super();
   }
   function set itemSet(oItemSet)
   {
      this.addToQueue({object:this,method:function(oSet)
      {
         this._oItemSet = oSet;
         if(this.initialized)
         {
            this.updateData();
         }
      },params:[oItemSet]});
   }
   function init()
   {
      super.init(false,dofus.graphics.gapi.controls.ItemSetViewer.CLASS_NAME);
   }
   function createChildren()
   {
      this.addToQueue({object:this,method:this.initTexts});
      this.addToQueue({object:this,method:this.addListeners});
      this.addToQueue({object:this,method:this.updateData});
   }
   function addListeners()
   {
      this._btnClose.addEventListener("click",this);
      var _loc2_ = 1;
      while(_loc2_ <= 8)
      {
         var _loc3_ = this["_ctr" + _loc2_];
         _loc3_.addEventListener("over",this);
         _loc3_.addEventListener("out",this);
         _loc2_ = _loc2_ + 1;
      }
   }
   function initTexts()
   {
      this._lblEffects.text = this.api.lang.getText("ITEMSET_EFFECTS");
      this._lblItems.text = this.api.lang.getText("ITEMSET_EQUIPED_ITEMS");
   }
   function updateData()
   {
      if(this._oItemSet != undefined)
      {
         var _loc2_ = this._oItemSet.items;
         this._winBg.title = this._oItemSet.name;
         var _loc3_ = this._oItemSet.itemCount != undefined ? this._oItemSet.itemCount : 8;
         var _loc4_ = 1;
         var _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            var _loc6_ = _loc2_[_loc5_];
            if(_loc6_.item.unicID <= dofus.datacenter.evenemential.ItemUpgrader.UPGRADE_MULTIPLICATOR)
            {
               var _loc7_ = this["_ctr" + _loc4_];
               _loc4_ = _loc4_ + 1;
               _loc7_._visible = true;
               _loc7_.contentData = _loc6_.item;
               _loc7_.borderRenderer = !_loc6_.isEquiped ? "ItemSetViewerItemBorder" : "ItemSetViewerItemBorderNone";
            }
            _loc5_ = _loc5_ + 1;
         }
         this._lstEffects.dataProvider = this._oItemSet.effects;
         var _loc8_ = _loc3_ + 1;
         while(_loc8_ <= 8)
         {
            var _loc9_ = this["_ctr" + _loc8_];
            _loc9_._visible = false;
            _loc8_ = _loc8_ + 1;
         }
         this._visible = true;
      }
      else
      {
         ank.utils.Logger.err("[ItemSetViewer] le set n\'est pas défini");
         this._visible = false;
      }
   }
   function click(oEvent)
   {
      var _loc0_ = null;
      if((_loc0_ = oEvent.target._name) === "_btnClose")
      {
         this.dispatchEvent({type:"close"});
      }
   }
   function over(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "_ctr1":
         case "_ctr2":
         case "_ctr3":
         case "_ctr4":
         case "_ctr5":
         case "_ctr6":
         case "_ctr7":
         case "_ctr8":
            var _loc3_ = oEvent.target.contentData;
            var _loc4_ = _loc3_.name;
            this.gapi.showTooltip(_loc4_,oEvent.target,-20,undefined,_loc3_.style + "ToolTip");
      }
   }
   function out(oEvent)
   {
      this.gapi.hideTooltip();
   }
}
