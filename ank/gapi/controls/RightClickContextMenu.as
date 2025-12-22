class ank.gapi.controls.RightClickContextMenu extends ContextMenu
{
   var onSelect;
   function RightClickContextMenu(oAPI, callbackFunction)
   {
      super(callbackFunction);
      this.hideBuiltInItems();
      var proto = ank.gapi.controls.RightClickContextMenu.prototype;
      this.onSelect = function()
      {
         proto.onRightClick(oAPI);
      };
   }
   function onRightClick(api)
   {
      api.ui.hideTooltip();
      var _loc3_ = ank.gapi.controls.PopupMenu.currentPopupMenu;
      if(_loc3_ != undefined)
      {
         _loc3_.onMouseUp();
      }
      api.mouseClicksMemorizer.storeCurrentMouseClick(true);
      if(api.gfx.rollOverMcSprite != undefined && !(api.gfx.rollOverMcSprite.data instanceof dofus.datacenter.Character))
      {
         api.gfx.onSpriteRelease(api.gfx.rollOverMcSprite,true);
         return undefined;
      }
      if(api.gfx.rollOverMcObject != undefined)
      {
         api.gfx.onObjectRelease(api.gfx.rollOverMcObject,true);
         return undefined;
      }
      var _loc4_ = api.ui.uiComponents;
      var _loc5_ = 0;
      while(_loc5_ < _loc4_.length)
      {
         var _loc6_ = api.ui.getUIComponent(_loc4_[_loc5_].name);
         if(_loc6_ != undefined)
         {
            if(_loc6_.getCurrentTab().currentOverItem instanceof dofus.datacenter.Item)
            {
               if(api.ui.getUIComponent("ItemViewer") != undefined)
               {
                  api.ui.unloadUIComponent("ItemViewer");
               }
               var _loc7_ = api.ui.loadUIComponent("ItemViewer","ItemViewer",{item:_loc6_.getCurrentTab().currentOverItem},{bAlwaysOnTop:true});
               _loc7_.hideWarning();
               return undefined;
            }
            var _loc8_ = _loc6_.currentOverItem;
            if(_loc8_ instanceof dofus.datacenter.Item)
            {
               _loc6_.itemViewer.createActionPopupMenu(_loc8_);
               return undefined;
            }
            if(_loc8_ instanceof dofus.datacenter.Spell)
            {
               _loc6_.createSpellActionPopupMenu(_loc8_);
               return undefined;
            }
            if(_loc8_ instanceof dofus.datacenter.InventoryShortcutItem)
            {
               _loc6_.createInventoryShortcutItemActionPopupMenu(_loc8_);
               return undefined;
            }
         }
         _loc5_ = _loc5_ + 1;
      }
      if(api.datacenter.Basics.inGame && api.datacenter.Player.isAuthorized)
      {
         var _loc9_ = api.kernel.AdminManager.getAdminPopupMenu(api.datacenter.Player.Name,true);
         _loc9_.addItem("Client v" + dofus.Constants.VERSION + "." + dofus.Constants.SUBVERSION + "." + dofus.Constants.SUBSUBVERSION + " >>",this,this.printRightClickPopupMenu,[api]);
         _loc9_.items.unshift(_loc9_.items.pop());
         _loc9_.show(_root._xmouse,_root._ymouse,true);
      }
      else
      {
         this.printRightClickPopupMenu(api);
      }
   }
   function printRightClickPopupMenu(api)
   {
      var _loc2_ = api.ui.createPopupMenu();
      _loc2_.addStaticItem("DOFUS RETRO Client v" + dofus.Constants.VERSION + "." + dofus.Constants.SUBVERSION + "." + dofus.Constants.SUBSUBVERSION);
      _loc2_.addStaticItem("Flash player " + System.capabilities.version);
      var o = {};
      var gapi = api.ui;
      o.selectQualities = function()
      {
         var _loc2_ = gapi.createPopupMenu();
         _loc2_.addStaticItem(api.lang.getText("OPTION_DEFAULTQUALITY"));
         _loc2_.addItem(api.lang.getText("QUALITY_LOW"),o,o.setQualityOption,["low"],o.getOption("DefaultQuality") != "low");
         _loc2_.addItem(api.lang.getText("QUALITY_MEDIUM"),o,o.setQualityOption,["medium"],o.getOption("DefaultQuality") != "medium");
         _loc2_.addItem(api.lang.getText("QUALITY_HIGH"),o,o.setQualityOption,["high"],o.getOption("DefaultQuality") != "high");
         _loc2_.show();
      };
      o.setQualityOption = function(sQuality)
      {
         o.setOption("DefaultQuality",sQuality);
      };
      o.setOption = function(sKey, mValue)
      {
         api.kernel.OptionsManager.setOption(sKey,mValue);
      };
      o.getOption = function(sKey)
      {
         return api.kernel.OptionsManager.getOption(sKey);
      };
      _loc2_.addItem(api.lang.getText("OPTION_DEFAULTQUALITY") + " >>",o,o.selectQualities);
      _loc2_.addItem(api.lang.getText("OPTIONS"),gapi,gapi.loadUIComponent,["Options","Options",{_y:(gapi.screenHeight != 432 ? 0 : -50)},{bAlwaysOnTop:true}]);
      _loc2_.addItem(api.lang.getText("OPTION_MOVABLEBAR"),o,function(sKey, mValue)
      {
         o.setOption(sKey,mValue);
         api.kernel.OptionsManager.onMovableBarOptionChanged();
      }
      ,["MovableBar",!o.getOption("MovableBar")]);
      _loc2_.show(_root._xmouse,_root._ymouse,true);
   }
}
