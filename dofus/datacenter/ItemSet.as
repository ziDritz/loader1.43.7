class dofus.datacenter.ItemSet extends Object
{
   var _nID;
   var api;
   var _aItems;
   var _aEffects;
   var _sEffects;
   function ItemSet(nID, sEffects, aItemIDs)
   {
      super();
      this.initialize(nID,sEffects,aItemIDs);
   }
   function get id()
   {
      return this._nID;
   }
   function get name()
   {
      var _loc2_ = this.api.lang.getItemSetText(this._nID).n;
      if(dofus.Constants.DEBUG)
      {
         _loc2_ += " (" + this.id + ")";
      }
      return _loc2_;
   }
   function get description()
   {
      return this.api.lang.getItemSetText(this._nID).d;
   }
   function get itemCount()
   {
      return this._aItems.length;
   }
   function get items()
   {
      return this._aItems;
   }
   function get effects()
   {
      return dofus.datacenter.Item.getItemDescriptionEffects(this._aEffects,undefined,true,false);
   }
   function initialize(nID, sEffects, aItemIDs)
   {
      if(sEffects == undefined)
      {
         sEffects = "";
      }
      if(aItemIDs == undefined)
      {
         aItemIDs = [];
      }
      this.api = _global.API;
      this._nID = nID;
      this.setEffects(sEffects);
      this.setItems(aItemIDs);
   }
   function setEffects(compressedData)
   {
      this._sEffects = compressedData;
      this._aEffects = [];
      var _loc3_ = compressedData.split(",");
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.length)
      {
         var _loc5_ = _loc3_[_loc4_].split("#");
         _loc5_[0] = _global.parseInt(_loc5_[0],16);
         _loc5_[1] = _loc5_[1] != "0" ? _global.parseInt(_loc5_[1],16) : undefined;
         _loc5_[2] = _loc5_[2] != "0" ? _global.parseInt(_loc5_[2],16) : undefined;
         _loc5_[3] = _loc5_[3] != "0" ? _global.parseInt(_loc5_[3],16) : undefined;
         this._aEffects.push(_loc5_);
         _loc4_ = _loc4_ + 1;
      }
   }
   function setItems(aItemIDs)
   {
      var _loc3_ = this.api.lang.getItemSetText(this._nID).i;
      this._aItems = [];
      var _loc4_ = {};
      for(var k in aItemIDs)
      {
         _loc4_[aItemIDs[k]] = true;
      }
      var _loc5_ = 0;
      while(_loc5_ < _loc3_.length)
      {
         var _loc6_ = Number(_loc3_[_loc5_]);
         if(!_global.isNaN(_loc6_))
         {
            if(_loc6_ < dofus.datacenter.evenemential.ItemUpgrader.UPGRADE_MULTIPLICATOR)
            {
               var _loc7_ = new dofus.datacenter.Item(0,_loc6_,1);
               var _loc8_ = _loc4_[_loc6_] == true || (_loc4_[_loc6_ + dofus.datacenter.evenemential.ItemUpgrader.UPGRADE_MULTIPLICATOR] == true || _loc4_[_loc6_ + 2 * dofus.datacenter.evenemential.ItemUpgrader.UPGRADE_MULTIPLICATOR] == true);
               this._aItems.push({isEquiped:_loc8_,item:_loc7_});
            }
         }
         _loc5_ = _loc5_ + 1;
      }
   }
}
