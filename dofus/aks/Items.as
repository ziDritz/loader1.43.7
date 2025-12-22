class dofus.aks.Items extends dofus.aks.Handler
{
   static var EFFECT_APPEND_CHAR = ":";
   static var COMPRESSION_RADIX = 16;
   static var MAX_BATCH_ITEM_USE = 300;
   function Items(oAKS, oAPI)
   {
      super.initialize(oAKS,oAPI);
   }
   function movement(nID, nPosition, nQuantity)
   {
      if(nPosition > 0)
      {
         this.api.kernel.GameManager.setAsModified(nPosition);
      }
      this.aks.send("OM" + nID + "|" + nPosition + (!_global.isNaN(nQuantity) ? "|" + nQuantity : ""),true);
   }
   function drop(nID, nQuantity)
   {
      this.aks.send("OD" + nID + "|" + nQuantity,false);
   }
   function associateMimibiote(nIDToAttach, nIDToEat)
   {
      this.aks.send("AEi1|" + nIDToAttach + "|" + nIDToEat);
   }
   function destroyMimibiote(nID)
   {
      this.aks.send("AEi0|" + nID);
   }
   function selectRouletteItem(nIndex)
   {
      this.aks.send("wc" + nIndex,false);
   }
   function destroy(nID, nQuantity)
   {
      this.aks.send("Od" + nID + "|" + nQuantity,false);
   }
   function reinitialize(nID)
   {
      this.aks.send("OR" + nID,false);
   }
   function use(nID, sSpriteID, nCellNum, bConfirm, nQuantity)
   {
      if(nQuantity == undefined)
      {
         nQuantity = 1;
      }
      this.aks.send("O" + (!bConfirm ? "U" : "u") + nID + (!(sSpriteID != undefined && !_global.isNaN(Number(sSpriteID))) ? "|" : "|" + sSpriteID) + (nCellNum == undefined ? "|" : "|" + nCellNum) + "|" + nQuantity,true);
   }
   function dissociate(nID, nPosition)
   {
      this.aks.send("Ox" + nID + "|" + nPosition,false);
   }
   function setSkin(nID, nPosition, nSkin)
   {
      this.aks.send("Os" + nID + "|" + nPosition + "|" + nSkin,false);
   }
   function feed(nID, nPosition, nFeededItemId)
   {
      this.aks.send("Of" + nID + "|" + nPosition + "|" + nFeededItemId,false);
   }
   function lock(nID, bLock, nDays)
   {
      this.aks.send("Ol" + nID + "," + bLock + "," + (nDays != undefined ? nDays : ""),false);
   }
   function equipItem(oItem)
   {
      if(oItem.isEquiped || oItem.isShortcut)
      {
         return false;
      }
      var _loc3_ = oItem.superType;
      if(oItem.superType != 8)
      {
         var _loc4_ = 0;
         while(_loc4_ < dofus.graphics.gapi.ui.Inventory.SUPERTYPE_NOT_EQUIPABLE.length)
         {
            if(dofus.graphics.gapi.ui.Inventory.SUPERTYPE_NOT_EQUIPABLE[_loc4_] == _loc3_)
            {
               return false;
            }
            _loc4_ = _loc4_ + 1;
         }
      }
      var _loc5_ = this.api.lang.getSlotsFromSuperType(oItem.superType);
      var _loc6_ = undefined;
      var _loc7_ = 0;
      while(_loc7_ < _loc5_.length)
      {
         var _loc8_ = Number(_loc5_[_loc7_]);
         var _loc9_ = this.api.datacenter.Player.InventoryByItemPositions.getItemAt(_loc8_) == undefined;
         if(_loc9_)
         {
            _loc6_ = _loc8_;
            break;
         }
         _loc7_ = _loc7_ + 1;
      }
      var _loc10_ = _loc6_ == undefined;
      if(_loc10_)
      {
         var _loc11_ = getTimer();
         var _loc12_ = 0;
         while(_loc12_ < _loc5_.length)
         {
            if(this.api.kernel.GameManager.getLastModified(_loc5_[_loc12_]) < _loc11_)
            {
               _loc11_ = this.api.kernel.GameManager.getLastModified(_loc5_[_loc12_]);
               _loc6_ = _loc5_[_loc12_];
            }
            _loc12_ = _loc12_ + 1;
         }
      }
      if(_loc6_ == undefined || _global.isNaN(_loc6_))
      {
         return false;
      }
      this.api.network.Items.movement(oItem.ID,_loc6_);
      return true;
   }
   function onAccessories(sExtraData)
   {
      var _loc3_ = sExtraData.split("|");
      var _loc4_ = _loc3_[0];
      var _loc5_ = _loc3_[1].split(",");
      var _loc6_ = [];
      var _loc7_ = 0;
      while(_loc7_ < _loc5_.length)
      {
         if(_loc5_[_loc7_].indexOf("~") != -1)
         {
            var _loc11_ = _loc5_[_loc7_].split("~");
            var _loc8_ = _global.parseInt(_loc11_[0],16);
            var _loc10_ = _global.parseInt(_loc11_[1]);
            var _loc9_ = _global.parseInt(_loc11_[2]) - 1;
            if(_loc9_ < 0)
            {
               _loc9_ = 0;
            }
         }
         else
         {
            _loc8_ = _global.parseInt(_loc5_[_loc7_],16);
            _loc10_ = undefined;
            _loc9_ = undefined;
         }
         if(!_global.isNaN(_loc8_))
         {
            var _loc12_ = new dofus.datacenter.Accessory(_loc8_,_loc10_,_loc9_);
            _loc6_[_loc7_] = _loc12_;
         }
         _loc7_ = _loc7_ + 1;
      }
      var _loc13_ = this.api.datacenter.Sprites.getItemAt(_loc4_);
      _loc13_.accessories = _loc6_;
      this.api.gfx.setForcedSpriteAnim(_loc4_,"static");
      if(_loc4_ == this.api.datacenter.Player.ID)
      {
         this.api.datacenter.Player.updateCloseCombat();
      }
   }
   function onDrop(bSuccess, sExtraData)
   {
      if(!bSuccess)
      {
         switch(sExtraData)
         {
            case "F":
               this.api.kernel.showMessage(undefined,this.api.lang.getText("DROP_FULL"),"ERROR_BOX",{name:"DropFull"});
               break;
            case "E":
               this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_DROP_ITEM"),"ERROR_BOX");
         }
      }
   }
   function onAdd(bSuccess, sExtraData)
   {
      if(!bSuccess)
      {
         switch(sExtraData)
         {
            case "F":
               this.api.kernel.showMessage(undefined,this.api.lang.getText("INVENTORY_FULL"),"ERROR_BOX",{name:"Full"});
               break;
            case "L":
               this.api.kernel.showMessage(undefined,this.api.lang.getText("TOO_LOW_LEVEL_FOR_ITEM"),"ERROR_BOX",{name:"LowLevel"});
               break;
            case "A":
               this.api.kernel.showMessage(undefined,this.api.lang.getText("ALREADY_EQUIPED"),"ERROR_BOX",{name:"Already"});
         }
      }
      else
      {
         var _loc4_ = sExtraData.split("*");
         var _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            var _loc6_ = _loc4_[_loc5_];
            var _loc7_ = _loc6_.charAt(0);
            _loc6_ = _loc6_.substr(1);
            switch(_loc7_)
            {
               case "G":
                  break;
               case "O":
                  var _loc8_ = _loc6_.split(";");
                  var _loc9_ = 0;
                  while(_loc9_ < _loc8_.length)
                  {
                     var _loc10_ = this.api.kernel.CharactersManager.getItemObjectFromData(_loc8_[_loc9_]);
                     if(this.api.datacenter.Basics.aks_exchange_echangeType == 0)
                     {
                        var _loc11_ = this.api.datacenter.Temporary.Shop.inventory;
                        var _loc12_ = 0;
                        while(_loc12_ < _loc11_.length)
                        {
                           var _loc13_ = _loc11_[_loc12_];
                           if(_loc13_.hasCustomResellCustomPrice)
                           {
                              if(_loc10_.unicID == _loc13_.unicID)
                              {
                                 _loc10_.resellCustomPrice = _loc13_.resellCustomPrice;
                                 _loc10_.customMoneyItemId = _loc13_.customMoneyItemId;
                              }
                           }
                           _loc12_ = _loc12_ + 1;
                        }
                     }
                     if(_loc10_ != undefined)
                     {
                        this.api.datacenter.Player.addItem(_loc10_);
                     }
                     _loc9_ = _loc9_ + 1;
                  }
                  break;
               default:
                  ank.utils.Logger.err("Ajout d\'un type obj inconnu");
            }
            _loc5_ = _loc5_ + 1;
         }
      }
   }
   function onChange(sExtraData)
   {
      var _loc3_ = sExtraData.split("*");
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.length)
      {
         var _loc5_ = _loc3_[_loc4_];
         var _loc6_ = _loc5_.split(";");
         var _loc7_ = 0;
         while(_loc7_ < _loc6_.length)
         {
            var _loc8_ = this.api.kernel.CharactersManager.getItemObjectFromData(_loc6_[_loc7_]);
            if(_loc8_ != undefined)
            {
               this.api.datacenter.Player.updateItem(_loc8_);
            }
            _loc7_ = _loc7_ + 1;
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   function onRemove(sExtraData)
   {
      var _loc3_ = Number(sExtraData);
      this.api.datacenter.Player.dropItem(_loc3_);
   }
   function onQuantity(sExtraData)
   {
      var _loc3_ = sExtraData.split("|");
      var _loc4_ = Number(_loc3_[0]);
      var _loc5_ = Number(_loc3_[1]);
      this.api.datacenter.Player.updateItemQuantity(_loc4_,_loc5_);
   }
   function onMovement(sExtraData)
   {
      var _loc3_ = sExtraData.split("|");
      var _loc4_ = Number(_loc3_[0]);
      var _loc5_ = !_global.isNaN(Number(_loc3_[1])) ? Number(_loc3_[1]) : -1;
      this.api.datacenter.Player.updateItemPosition(_loc4_,_loc5_);
   }
   function onTool(sExtraData)
   {
      var _loc3_ = Number(sExtraData);
      if(_global.isNaN(_loc3_))
      {
         this.api.datacenter.Player.currentJobID = undefined;
      }
      else
      {
         this.api.datacenter.Player.currentJobID = _loc3_;
      }
   }
   function onDeletion(sExtraData)
   {
      var _loc3_ = sExtraData.charAt(0);
      if(_loc3_ == "E")
      {
         this.api.kernel.showMessage(undefined,this.api.lang.getText("CANNOT_DELETE_THIS_OBJECT"),"ERROR_CHAT");
      }
   }
   function onWeight(sExtraData)
   {
      var _loc3_ = sExtraData.split("|");
      var _loc4_ = Number(_loc3_[0]);
      var _loc5_ = Number(_loc3_[1]);
      var _loc6_ = Number(_loc3_[2]);
      this.api.datacenter.Player.maxWeight = _loc5_;
      this.api.datacenter.Player.currentWeight = _loc4_;
      this.api.datacenter.Player.maxOverWeight = _loc6_;
   }
   function onItemSet(sExtraData)
   {
      var _loc3_ = sExtraData.charAt(0) == "+";
      var _loc4_ = sExtraData.substr(1).split("|");
      var _loc5_ = Number(_loc4_[0]);
      var _loc6_ = String(_loc4_[1]).split(";");
      var _loc7_ = _loc4_[2];
      if(_loc3_)
      {
         var _loc8_ = new dofus.datacenter.ItemSet(_loc5_,_loc7_,_loc6_);
         this.api.datacenter.Player.ItemSets.addItemAt(_loc5_,_loc8_);
      }
      else
      {
         this.api.datacenter.Player.ItemSets.removeItemAt(_loc5_);
      }
   }
   function onItemUseCondition(sExtraData)
   {
      var _loc3_ = sExtraData.charAt(0);
      switch(_loc3_)
      {
         case "G":
            var _loc4_ = sExtraData.substr(1).split("|");
            var _loc5_ = !_global.isNaN(Number(_loc4_[0])) ? Number(_loc4_[0]) : 0;
            var _loc6_ = !_global.isNaN(Number(_loc4_[1])) ? Number(_loc4_[1]) : undefined;
            var _loc7_ = !_global.isNaN(Number(_loc4_[2])) ? Number(_loc4_[2]) : undefined;
            var _loc8_ = !_global.isNaN(Number(_loc4_[3])) ? Number(_loc4_[3]) : undefined;
            var _loc9_ = {name:"UseItemGold",listener:this,params:{objectID:_loc5_,spriteID:_loc6_,cellID:_loc7_}};
            this.api.kernel.showMessage(undefined,this.api.lang.getText("ITEM_USE_CONDITION_GOLD",[_loc8_]),"CAUTION_YESNO",_loc9_);
            break;
         case "U":
            var _loc10_ = sExtraData.substr(1).split("|");
            var _loc11_ = !_global.isNaN(Number(_loc10_[0])) ? Number(_loc10_[0]) : 0;
            var _loc12_ = !_global.isNaN(Number(_loc10_[1])) ? Number(_loc10_[1]) : undefined;
            var _loc13_ = !_global.isNaN(Number(_loc10_[2])) ? Number(_loc10_[2]) : undefined;
            var _loc14_ = !_global.isNaN(Number(_loc10_[3])) ? Number(_loc10_[3]) : undefined;
            var _loc15_ = {name:"UseItem",listener:this,params:{objectID:_loc11_,spriteID:_loc12_,cellID:_loc13_}};
            var _loc16_ = new dofus.datacenter.Item(-1,_loc14_,1,0,"",0);
            this.api.kernel.showMessage(undefined,this.api.lang.getText("ITEM_USE_CONFIRMATION",[_loc16_.name]),"CAUTION_YESNO",_loc15_);
      }
   }
   function onItemFound(sExtraData)
   {
      var _loc3_ = sExtraData.split("|");
      var _loc4_ = !_global.isNaN(Number(_loc3_[0])) ? Number(_loc3_[0]) : 0;
      var _loc5_ = !_global.isNaN(Number(_loc3_[2])) ? Number(_loc3_[2]) : 0;
      var _loc6_ = _loc3_[1].split("~");
      var _loc7_ = !_global.isNaN(Number(_loc6_[0])) ? Number(_loc6_[0]) : 0;
      var _loc8_ = !_global.isNaN(Number(_loc6_[1])) ? Number(_loc6_[1]) : 0;
      if(_loc4_ == 1)
      {
         if(_loc7_ == 0)
         {
            var _loc9_ = {iconFile:"KamaSymbol"};
         }
         else
         {
            _loc9_ = new dofus.datacenter.Item(0,_loc7_,_loc8_);
         }
         this.api.gfx.addSpriteOverHeadItem(this.api.datacenter.Player.ID,"itemFound",dofus.graphics.battlefield.CraftResultOverHead,[true,_loc9_],2000);
      }
   }
   function yes(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "AskYesNoUseItemGold":
            this.use(oEvent.params.objectID,oEvent.params.spriteID,oEvent.params.cellID,true);
            break;
         case "AskYesNoUseItem":
            this.use(oEvent.params.objectID,oEvent.params.spriteID,oEvent.params.cellID,true);
      }
   }
}
