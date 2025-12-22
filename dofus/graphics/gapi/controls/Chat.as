class dofus.graphics.gapi.controls.Chat extends dofus.graphics.gapi.core.DofusAdvancedComponent
{
   var _replacementPanelsManager;
   var _mcReplacementPanel;
   var _mcMiniMapReplacementPanel;
   var _chatFilters;
   var _txtChat;
   var _btnOpenClose;
   var _mcReplacementPanelMask;
   var _sSmileys;
   var _bSmileysOpened;
   var _btnSitDown;
   var _btnSmileys;
   var dispatchEvent;
   static var CLASS_NAME = "Chat";
   static var OPEN_OFFSET = 350;
   static var XTRA_MASK_OPEN_OFFSET = 300;
   static var REPLACEMENT_PANEL_DEPTH = 10;
   static var MINIMAP_REPLACEMENT_PANEL_DEPTH = 9;
   static var HIDDEN_ITEM = 12009;
   var _bOpened = false;
   function Chat()
   {
      super();
   }
   function get replacementPanelsManager()
   {
      return this._replacementPanelsManager;
   }
   function get shortcutsReplacementPanel()
   {
      if(this.replacementPanelsManager.currentReplacementPanel != dofus.graphics.gapi.ui.chat.ChatReplacementPanelsManager.SHORTCUTS)
      {
         return undefined;
      }
      return dofus.graphics.gapi.controls.chat.ShortcutsChatReplacementPanel(this._mcReplacementPanel);
   }
   function get miniMapReplacementPanel()
   {
      if(this.replacementPanelsManager.currentReplacementPanel != dofus.graphics.gapi.ui.chat.ChatReplacementPanelsManager.MINIMAP)
      {
         return undefined;
      }
      return dofus.graphics.gapi.controls.MiniMap(this._mcMiniMapReplacementPanel);
   }
   function get fightSpectatorReplacementPanel()
   {
      if(this.replacementPanelsManager.currentReplacementPanel != dofus.graphics.gapi.ui.chat.ChatReplacementPanelsManager.FULL_WIDTH_FIGHTER_EFFECTS)
      {
         return undefined;
      }
      return dofus.graphics.gapi.controls.chat.FighterEffectsReplacementPanel(this._mcReplacementPanel);
   }
   function get filters()
   {
      return this._chatFilters.filters;
   }
   function get selectable()
   {
      return this._txtChat.selectable;
   }
   function set selectable(bSelectable)
   {
      this._txtChat.selectable = bSelectable;
   }
   function get isAutoScrollingEnabled()
   {
      return this._txtChat.isAutoScrollingEnabled;
   }
   function set isAutoScrollingEnabled(bAutoScrolling)
   {
      this._txtChat.isAutoScrollingEnabled = bAutoScrolling;
   }
   function open(bOpen)
   {
      var _loc3_ = dofus.graphics.gapi.ui.Banner(this.api.ui.getUIComponent("Banner"));
      if(_loc3_ != undefined && (!_loc3_.useFlashChat && !bOpen))
      {
         return undefined;
      }
      if(bOpen == !this._bOpened)
      {
         return undefined;
      }
      if(!bOpen && this.api.datacenter.Player.isAuthorized)
      {
         if(this.api.kernel.OptionsManager.getOption("DebugSizeIndex") != dofus.graphics.gapi.ui.Debug.CONSOLE_MINIMIZED)
         {
            var _loc4_ = dofus.graphics.gapi.ui.Debug(this.api.ui.getUIComponent("Debug"));
            if(_loc4_ != undefined)
            {
               this.api.kernel.OptionsManager.setOption("DebugSizeIndex",dofus.graphics.gapi.ui.Debug.CONSOLE_MINIMIZED);
               _loc4_.applySizeIndex(false);
            }
         }
      }
      this._btnOpenClose.selected = !bOpen;
      if(bOpen)
      {
         var _loc5_ = -1;
      }
      else
      {
         _loc5_ = 1;
      }
      this._txtChat.setSize(this._txtChat.width,this._txtChat.height + _loc5_ * dofus.graphics.gapi.controls.Chat.OPEN_OFFSET);
      var _loc6_ = this._mcReplacementPanelMask._height + _loc5_ * dofus.graphics.gapi.controls.Chat.XTRA_MASK_OPEN_OFFSET;
      this._mcReplacementPanelMask._height = _loc6_;
      var _loc7_ = this.miniMapReplacementPanel;
      if(_loc7_ != undefined)
      {
         _loc7_.customBgScaleHeight = this._mcReplacementPanelMask._height;
         _loc7_.setScale(dofus.graphics.gapi.controls.MiniMap.SCALE_CUSTOM,true);
      }
      this._y -= _loc5_ * dofus.graphics.gapi.controls.Chat.OPEN_OFFSET;
      this._bOpened = !bOpen;
   }
   function useReplacementPanel(nReplacementPanel, aArgs)
   {
      var _loc4_ = nReplacementPanel == dofus.graphics.gapi.ui.chat.ChatReplacementPanelsManager.NO_REPLACEMENT_PANEL;
      this._chatFilters._visible = _loc4_;
      this._txtChat._visible = _loc4_;
      this._mcReplacementPanel._visible = !_loc4_;
      this._mcMiniMapReplacementPanel._visible = nReplacementPanel == dofus.graphics.gapi.ui.chat.ChatReplacementPanelsManager.MINIMAP && (!_loc4_ && !this._replacementPanelsManager.isCurrentReplacementPanelTemporary);
      this._mcReplacementPanelMask._visible = !_loc4_;
      this.addToQueue({object:this._replacementPanelsManager,method:this._replacementPanelsManager.changeReplacementPanel,params:[nReplacementPanel,undefined,aArgs]});
   }
   function useTemporaryReplacementPanel(nReplacementPanel, aArgs)
   {
      this._replacementPanelsManager.currentTemporaryReplacementPanel = nReplacementPanel;
      this.addToQueue({object:this._replacementPanelsManager,method:this._replacementPanelsManager.changeReplacementPanel,params:[nReplacementPanel,undefined,aArgs]});
   }
   function removeTemporaryReplacementPanel()
   {
      this.replacementPanelsManager.currentTemporaryReplacementPanel = undefined;
      var _loc2_ = this.api.kernel.OptionsManager.getOption("chatReplacementPanel");
      this.addToQueue({object:this._replacementPanelsManager,method:this._replacementPanelsManager.changeReplacementPanel,params:[_loc2_]});
   }
   function setText(sText)
   {
      this._txtChat.text = sText;
   }
   function updateSmileysEmotes()
   {
      this._sSmileys.update();
   }
   function hideSmileys(bHide)
   {
      this._sSmileys._visible = !bHide;
      this._bSmileysOpened = !bHide;
   }
   function showSitDown(bShow)
   {
      this._btnSitDown._visible = bShow;
   }
   function selectFilter(nFilter, bSelect)
   {
      this._chatFilters.selectFilter(nFilter,bSelect);
   }
   function init()
   {
      super.init(false,dofus.graphics.gapi.controls.Chat.CLASS_NAME);
      this._replacementPanelsManager = new dofus.graphics.gapi.ui.chat.ChatReplacementPanelsManager(this.api,this);
      this.api.kernel.ChatManager.updateRigth();
   }
   function createChildren()
   {
      this.addToQueue({object:this,method:this.addListeners});
      this.hideSmileys(true);
   }
   function addListeners()
   {
      this._btnOpenClose.addEventListener("click",this);
      this._btnSmileys.addEventListener("click",this);
      this._btnSitDown.addEventListener("click",this);
      this._btnOpenClose.addEventListener("over",this);
      this._btnSmileys.addEventListener("over",this);
      this._btnSitDown.addEventListener("over",this);
      this._btnOpenClose.addEventListener("out",this);
      this._btnSmileys.addEventListener("out",this);
      this._btnSitDown.addEventListener("out",this);
      this._sSmileys.addEventListener("selectSmiley",this);
      this._sSmileys.addEventListener("selectEmote",this);
      this._txtChat.addEventListener("href",this);
      this._chatFilters.addEventListener("filterChanged",this);
      var chat = this;
      this._mcReplacementPanelMask.onRelease = function()
      {
         var _loc2_ = {};
         _loc2_.target = this;
         chat.replacementPanelsManager.click(_loc2_);
      };
      this.api.kernel.ChatManager.refresh();
   }
   function filterChanged(oEvent)
   {
      this.dispatchEvent({type:"filterChanged",filter:oEvent.filter,selected:oEvent.selected});
   }
   function click(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "_btnSitDown":
            this.api.sounds.events.onBannerChatButtonClick();
            var _loc3_ = this.api.lang.getEmoteID("sit");
            if(_loc3_ != undefined)
            {
               this.api.network.Emotes.useEmote(_loc3_);
            }
            break;
         case "_btnSmileys":
            this.api.sounds.events.onBannerChatButtonClick();
            this.hideSmileys(this._bSmileysOpened);
            break;
         case "_btnOpenClose":
            this.api.sounds.events.onBannerChatButtonClick();
            this.open(!oEvent.target.selected);
      }
   }
   function over(oEvent)
   {
      switch(oEvent.target._name)
      {
         case "_btnSmileys":
            this.gapi.showTooltip(this.api.lang.getText("CHAT_SHOW_SMILEYS"),oEvent.target,-20,{bXLimit:true,bYLimit:false});
            break;
         case "_btnOpenClose":
            this.gapi.showTooltip(this.api.lang.getText("CHAT_SHOW_MORE"),oEvent.target,-33,{bXLimit:true,bYLimit:false});
            break;
         case "_btnSitDown":
            this.gapi.showTooltip(this.api.lang.getText("SITDOWN_TOOLTIP"),oEvent.target,-46,{bXLimit:true,bYLimit:false});
      }
   }
   function out(oEvent)
   {
      this.gapi.hideTooltip();
   }
   function selectSmiley(oEvent)
   {
      if(!this.api.datacenter.Player.data.isInMove)
      {
         this.dispatchEvent(oEvent);
         if(this.api.kernel.OptionsManager.getOption("AutoHideSmileys"))
         {
            this.hideSmileys(true);
            this._btnSmileys.selected = false;
         }
      }
   }
   function selectEmote(oEvent)
   {
      if(!this.api.datacenter.Player.data.isInMove)
      {
         this.dispatchEvent(oEvent);
         if(this.api.kernel.OptionsManager.getOption("AutoHideSmileys"))
         {
            this.hideSmileys(true);
         }
         this._btnSmileys.selected = false;
      }
   }
   function href(oEvent)
   {
      this.dispatchEvent(oEvent);
   }
}
