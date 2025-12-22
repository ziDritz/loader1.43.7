class dofus.graphics.gapi.controls.ItemViewer extends dofus.graphics.gapi.core.DofusAdvancedComponent
{
   var _bPrice;
   var _bShowBaseEffects;
   var _bDesc;
   var _txtDescription;
   var _oItem;
   var _nDisplayWidth;
   var _lstInfos;
   var _mcTitle;
   var _lblLevel;
   var _btnTabCharacteristics;
   var _pbEthereal;
   var _ldrTwoHanded;
   var _btnTabEffects;
   var _btnTabConditions;
   var _btnAction;
   var _btnDialog;
   var _btnUnlink;
   var _lblName;
   var _ldrIcon;
   var _txtPriceLabel;
   var _mcKamaSymbol;
   var _ldrMoneyIcon;
   var _lblWeight;
   var dispatchEvent;
   static var CLASS_NAME = "ItemViewer";
   var _bUseButton = false;
   var _bDestroyButton = false;
   var _bTargetButton = false;
   var _sCurrentTab = "Effects";
   function ItemViewer()
   {
      super();
   }
   function set useButton(bUseButton)
   {
      this._bUseButton = bUseButton;
   }
   function get useButton()
   {
      return this._bUseButton;
   }
   function set destroyButton(bDestroyButton)
   {
      this._bDestroyButton = bDestroyButton;
   }
   function get destroyButton()
   {
      return this._bDestroyButton;
   }
   function set targetButton(bTargetButton)
   {
      this._bTargetButton = bTargetButton;
   }
   function get targetButton()
   {
      return this._bTargetButton;
   }
   function set displayPrice(bDisplayPrice)
   {
      this._bPrice = bDisplayPrice;
   }
   function get displayPrice()
   {
      return this._bPrice;
   }
   function set showBaseEffects(bShowBaseEffects)
   {
      this._bShowBaseEffects = bShowBaseEffects;
   }
   function get showBaseEffects()
   {
      return this._bShowBaseEffects;
   }
   function set hideDesc(bDisplayDesc)
   {
      this._bDesc = !bDisplayDesc;
      this._txtDescription._visible = this._bDesc;
      this._txtDescription.scrollBarRight = this._bDesc;
   }
   function get hideDesc()
   {
      return this._bDesc;
   }
   function set itemData(oItem)
   {
      this._oItem = oItem;
      this.addToQueue({object:this,method:this.showItemData,params:[oItem]});
   }
   function get itemData()
   {
      return this._oItem;
   }
   function set displayWidth(nDisplayWidth)
   {
      this._nDisplayWidth = nDisplayWidth + 2;
   }
   function init()
   {
      super.init(false,dofus.graphics.gapi.controls.ItemViewer.CLASS_NAME);
   }
   function arrange()
   {
      this._lstInfos._width = this._nDisplayWidth - this._lstInfos._x;
      this._txtDescription._width = this._nDisplayWidth - this._txtDescription._x - 1;
      this._mcTitle._width = this._nDisplayWidth - this._mcTitle._x;
      this._lblLevel._x = this._nDisplayWidth - (316 - this._lblLevel._x);
   }
   function createChildren()
   {
      this.addToQueue({object:this,method:this.initTexts});
      this.addToQueue({object:this,method:this.addListeners});
      this._btnTabCharacteristics._visible = false;
      this._pbEthereal._visible = false;
      this._ldrTwoHanded._visible = false;
   }
   function initTexts()
   {
      this._btnTabEffects.label = this.api.lang.getText("EFFECTS");
      this._btnTabConditions.label = this.api.lang.getText("CONDITIONS");
      this._btnTabCharacteristics.label = this.api.lang.getText("CHARACTERISTICS");
   }
   function addListeners()
   {
      this._btnAction.addEventListener("click",this);
      this._btnAction.addEventListener("over",this);
      this._btnAction.addEventListener("out",this);
      this._btnDialog.addEventListener("over",this);
      this._btnDialog.addEventListener("out",this);
      this._btnUnlink.addEventListener("click",this);
      this._btnTabEffects.addEventListener("click",this);
      this._btnTabCharacteristics.addEventListener("click",this);
      this._btnTabConditions.addEventListener("click",this);
      this._pbEthereal.addEventListener("over",this);
      this._pbEthereal.addEventListener("out",this);
      this._ldrTwoHanded.addEventListener("over",this);
      this._ldrTwoHanded.addEventListener("out",this);
   }
   function showItemData(oItem)
   {
      if(oItem != undefined)
      {
         this._lblName.text = oItem.name;
         if(oItem.style == "")
         {
            this._lblName.styleName = "WhiteLeftMediumBoldLabel";
         }
         else
         {
            this._lblName.styleName = oItem.style + "LeftMediumBoldLabel";
         }
         this._lblLevel.text = this.api.lang.getText("LEVEL_SMALL") + oItem.level;
         this._txtDescription.text = oItem.description;
         this._ldrIcon.contentParams = oItem.params;
         this._ldrIcon.contentPath = oItem.iconFile;
         if(this.api.datacenter.Basics.aks_current_server.isTemporis())
         {
            this._ldrIcon.holder.filters = undefined;
            if(oItem.realUnicId >= dofus.Constants.REFFINED_ITEM.minimumID)
            {
               oItem.addGlowOnItemIcon(this._ldrIcon.holder,dofus.Constants.REFFINED_ITEM.color,dofus.Constants.REFFINED_ITEM.alpha,dofus.Constants.REFFINED_ITEM.blur,dofus.Constants.REFFINED_ITEM.intensity);
            }
            else if(oItem.realUnicId >= dofus.Constants.IMPROVED_ITEM.minimumID)
            {
               oItem.addGlowOnItemIcon(this._ldrIcon.holder,dofus.Constants.IMPROVED_ITEM.color,dofus.Constants.IMPROVED_ITEM.alpha,dofus.Constants.IMPROVED_ITEM.blur,dofus.Constants.IMPROVED_ITEM.intensity);
            }
         }
         this.getItemEffects(this._bShowBaseEffects);
         if(oItem.superType == 2)
         {
            this._btnTabCharacteristics._visible = true;
         }
         else
         {
            if(this._sCurrentTab == "Characteristics")
            {
               this.setCurrentTab("Effects");
            }
            this._btnTabCharacteristics._visible = false;
         }
         this._txtPriceLabel._visible = this._bPrice;
         if(this._bPrice)
         {
            var _loc3_ = oItem.price != undefined ? this.api.lang.getText("UNIT_PRICE") + " : " + new ank.utils.ExtendedString(oItem.price).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) : "";
            if(oItem.averagePrice != undefined && oItem.averagePrice != -1)
            {
               _loc3_ = "<u>Avg</u> : " + new ank.utils.ExtendedString(oItem.averagePrice).addMiddleChar(this.api.lang.getConfigText("THOUSAND_SEPARATOR"),3) + ", " + _loc3_;
            }
         }
         if(!oItem.hasCustomMoneyItemId)
         {
            this._mcKamaSymbol._visible = this._bPrice;
            this._ldrMoneyIcon._visible = false;
         }
         else
         {
            this._mcKamaSymbol._visible = false;
            this._ldrMoneyIcon._visible = this._bPrice;
            if(this._bPrice)
            {
               var _loc4_ = new dofus.datacenter.Item(0,oItem.customMoneyItemId);
               this._ldrMoneyIcon.contentParams = _loc4_.params;
               this._ldrMoneyIcon.contentPath = _loc4_.iconFile;
               _loc3_ = _loc3_ + "x " + _loc4_.name;
            }
         }
         if(this._bPrice)
         {
            this._txtPriceLabel.text = _loc3_;
         }
         this._lblWeight.text = oItem.weight + " " + ank.utils.PatternDecoder.combine(this._parent.api.lang.getText("PODS"),"m",oItem.weight < 2);
         if(dofus.Constants.DEBUG)
         {
            var _loc5_ = " (" + oItem.type + "/" + oItem.gfx;
            _loc5_ += ")";
            this._lblWeight.text += _loc5_;
         }
         if(oItem.durability != -1 && oItem.durability != undefined)
         {
            this._pbEthereal.maximum = oItem.durabilityMax;
            this._pbEthereal.value = oItem.durability;
            this._pbEthereal._visible = true;
            if(this._pbEthereal.value / this._pbEthereal.maximum < 0.2)
            {
               this._pbEthereal.styleName = "EtherealCriticalProgressBar";
            }
            else
            {
               this._pbEthereal.styleName = "EtherealNormalProgressBar";
            }
            this._pbEthereal._width = !(oItem.hasSkinItem || oItem.hasCustomSkinItem) ? 62 : 40;
         }
         else if(oItem.skinDurability != -1 && oItem.skinDurability != undefined)
         {
            this._pbEthereal.maximum = oItem.skinDurabilityMax;
            this._pbEthereal.value = oItem.skinDurability;
            this._pbEthereal._visible = true;
            if(this._pbEthereal.value / this._pbEthereal.maximum < 0.2)
            {
               this._pbEthereal.styleName = "SkinDurabilityCriticalProgressBar";
            }
            else
            {
               this._pbEthereal.styleName = "SkinDurabilityNormalProgressBar";
            }
            this._pbEthereal._width = !(oItem.hasSkinItem || oItem.hasCustomSkinItem) ? 62 : 40;
         }
         else
         {
            this._pbEthereal._visible = false;
         }
         this._btnUnlink._visible = oItem.hasSkinItem || oItem.hasCustomSkinItem;
         this._ldrTwoHanded._visible = oItem.needTwoHands;
      }
      else if(this._lblName.text != undefined)
      {
         this._lblName.text = "";
         this._lblLevel.text = "";
         this._txtDescription.text = "";
         this._ldrIcon.contentPath = "";
         this._ldrMoneyIcon.contentPath = "";
         this._lstInfos.removeAll();
         this._txtPriceLabel.text = "";
         this._lblWeight.text = "";
         this._pbEthereal._visible = false;
         this._ldrTwoHanded._visible = false;
         this._mcKamaSymbol._visible = false;
         this._ldrMoneyIcon._visible = false;
         this._txtPriceLabel._visible = false;
      }
   }
   function updateCurrentTabInformations()
   {
      var _loc2_ = new ank.utils.ExtendedArray();
      switch(this._sCurrentTab)
      {
         case "Effects":
            var _loc3_ = this._oItem.visibleEffects;
            for(var s in _loc3_)
            {
               _loc2_.push(_loc3_[s]);
            }
            break;
         case "Characteristics":
            var _loc4_ = this._oItem.characteristics;
            for(var s in _loc4_)
            {
               if(_loc4_[s].length > 0)
               {
                  _loc2_.push(_loc4_[s]);
               }
            }
            break;
         case "Conditions":
            var _loc5_ = this._oItem.conditions;
            for(var s in _loc5_)
            {
               if(_loc5_[s].length > 0)
               {
                  _loc2_.push(_loc5_[s]);
               }
            }
      }
      _loc2_.reverse();
      this._lstInfos.dataProvider = _loc2_;
   }
   function setCurrentTab(sNewTab)
   {
      var _loc3_ = this["_btnTab" + this._sCurrentTab];
      var _loc4_ = this["_btnTab" + sNewTab];
      _loc3_.selected = true;
      _loc3_.enabled = true;
      _loc4_.selected = false;
      if(sNewTab != "Effects")
      {
         _loc4_.enabled = false;
      }
      this._sCurrentTab = sNewTab;
      this.getItemEffects(this._bShowBaseEffects);
   }
   function getItemEffects(bShowBaseEffects)
   {
      if(bShowBaseEffects)
      {
         if(this._sCurrentTab == "Effects")
         {
            var _loc3_ = dofus.datacenter.Item.getBaseItemEffects(this._oItem.unicID);
            var _loc4_ = dofus.datacenter.Item.getItemDescriptionEffects(_loc3_,_loc3_,true,this._oItem.isReallyEnhanceable);
            var _loc5_ = new ank.utils.ExtendedArray();
            for(var s in _loc4_)
            {
               if(_loc4_[s].description.length > 0)
               {
                  _loc5_.push(_loc4_[s]);
               }
            }
            _loc5_.reverse();
            this._lstInfos.dataProvider = _loc5_;
         }
         else
         {
            this.updateCurrentTabInformations();
         }
      }
      else
      {
         this.updateCurrentTabInformations();
      }
   }
   function click(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "_btnTabEffects":
            if(this._sCurrentTab == "Effects")
            {
               var _loc3_ = this["_btnTab" + this._sCurrentTab];
               _loc3_.selected = false;
               this._bShowBaseEffects = !this._bShowBaseEffects;
               this.getItemEffects(this._bShowBaseEffects);
            }
            else
            {
               this.setCurrentTab("Effects");
            }
            break;
         case "_btnTabCharacteristics":
            this.setCurrentTab("Characteristics");
            break;
         case "_btnTabConditions":
            this.setCurrentTab("Conditions");
            break;
         case "_btnAction":
            this.createActionPopupMenu(this._oItem);
            break;
         case "_btnUnlink":
            if(this.api.ui.getUIComponent("Inventory") == undefined)
            {
               this.api.kernel.showMessage(undefined,this.api.lang.getText("CANT_BECAUSE_BUSY"),"ERROR_CHAT");
               break;
            }
            if(this._oItem.hasCustomSkinItem)
            {
               this.dispatchEvent({type:"destroyMimibiote",item:this._oItem});
            }
            else if(this._oItem.hasSkinItem)
            {
               this.dispatchEvent({type:"unlinkSkinItem",item:this._oItem});
            }
            break;
      }
   }
   function createActionPopupMenu(oItem)
   {
      var _loc3_ = this.api.ui.createPopupMenu();
      _loc3_.addStaticItem(oItem.name);
      if(this._bUseButton && oItem.canUse)
      {
         _loc3_.addItem(this.api.lang.getText("CLICK_TO_USE"),this,this.dispatchEvent,[{type:"useItem",item:oItem}]);
         _loc3_.addItem(this.api.lang.getText("CLICK_TO_BATCH_USE"),this,this.dispatchEvent,[{type:"batchUseItem",item:oItem}]);
      }
      _loc3_.addItem(this.api.lang.getText("CLICK_TO_INSERT"),this.api.kernel.GameManager,this.api.kernel.GameManager.insertItemInChat,[oItem]);
      if(this._bTargetButton && oItem.canTarget)
      {
         _loc3_.addItem(this.api.lang.getText("CLICK_TO_TARGET"),this,this.dispatchEvent,[{type:"targetItem",item:oItem}]);
      }
      _loc3_.addItem(this.api.lang.getText("ASSOCIATE_RECEIPTS"),this.api.ui,this.api.ui.loadUIComponent,["ItemUtility","ItemUtility",{item:oItem},{bAlwaysOnTop:true}]);
      if(this._bDestroyButton)
      {
         if(oItem.canDestroy || oItem.isUndestroyable)
         {
            _loc3_.addItem(this.api.lang.getText("CLICK_TO_DESTROY"),this,this.dispatchEvent,[{type:"destroyItem",item:oItem}],!oItem.isUndestroyable);
         }
         if(oItem.hasCustomSkinItem)
         {
            _loc3_.addItem(this.api.lang.getText("CLICK_TO_DESTROY_MIMIBIOTE"),this,this.dispatchEvent,[{type:"destroyMimibiote",item:oItem}],true);
         }
         if(oItem.hasSkinItem)
         {
            _loc3_.addItem(this.api.lang.getText("REMOVE_CEREMONIAL"),this,this.dispatchEvent,[{type:"unlinkSkinItem",item:oItem}],true);
         }
      }
      if(this.api.datacenter.Basics.aks_current_server.isTemporis())
      {
         if(oItem.canBeUnlock)
         {
            _loc3_.addItem(this.api.lang.getText("UNLOCK_ITEM"),this,this.dispatchEvent,[{type:"unlockItem",item:oItem}],true);
         }
         else if(oItem.canBeLock)
         {
            _loc3_.addItem(this.api.lang.getText("LOCK_ITEM"),this,this.dispatchEvent,[{type:"lockItem",item:oItem,delay:-1}],true);
            _loc3_.addItem(this.api.lang.getText("LOCK_ITEM_1_WEEK"),this,this.dispatchEvent,[{type:"lockItem",item:oItem,delay:7}],true);
            _loc3_.addItem(this.api.lang.getText("LOCK_ITEM_1_MONTH"),this,this.dispatchEvent,[{type:"lockItem",item:oItem,delay:30}],true);
         }
      }
      if(oItem.canBeReinitializedByPlayer)
      {
         _loc3_.addItem(this.api.lang.getText("RESET_PET"),this,this.dispatchEvent,[{type:"reinitializeItem",item:oItem}]);
      }
      for(var s in oItem.effects)
      {
         var _loc4_ = oItem.effects[s];
         if(_loc4_.type == 995)
         {
            _loc3_.addItem(this.api.lang.getText("VIEW_MOUNT_DETAILS"),this.api.network.Mount,this.api.network.Mount.data,[_loc4_.param1,_loc4_.param2]);
            break;
         }
      }
      _loc3_.show(_root._xmouse,_root._ymouse);
   }
   function over(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "_pbEthereal":
            if(this._oItem.durability != -1 && this._oItem.durability != undefined)
            {
               var _loc3_ = 812;
               var _loc4_ = this._oItem.durability;
               var _loc5_ = this._oItem.durabilityMax;
            }
            else
            {
               _loc3_ = 2149;
               _loc4_ = this._oItem.skinDurability;
               _loc5_ = this._oItem.skinDurabilityMax;
            }
            var _loc6_ = this.api.lang.getEffectText(_loc3_).d;
            var _loc7_ = ank.utils.PatternDecoder.getDescription(_loc6_,[undefined,_loc4_,_loc5_]);
            this.gapi.showTooltip(_loc7_,oEvent.target,-20);
            break;
         case "_ldrTwoHanded":
            this.gapi.showTooltip(this.api.lang.getText("TWO_HANDS_WEAPON"),this._ldrTwoHanded,-20);
            break;
         case "_btnDialog":
            this.gapi.showTooltip(this._oItem.description,this._btnDialog,-4,{bTopAlign:true});
      }
   }
   function out(oEvent)
   {
      this.gapi.hideTooltip();
   }
}
