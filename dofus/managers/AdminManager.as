class dofus.managers.AdminManager extends dofus.utils.ApiElement
{
   var _bExecutingBatch;
   var _aPendingModReportAppendCommands;
   var _eoHotKeysBatchNodes;
   var myPlayerObject;
   var playerObject;
   var playerName;
   var _nUICounter;
   var _bRightClick;
   var xml;
   var xmlRightClick;
   var _sCurrentSearch;
   var _nSearchRefreshTimeout;
   var parent;
   var firstChild;
   var _aPreparedReplaceVars;
   var _startupNode;
   var _preStartupNode;
   var _sSaveNode;
   var _sCurrentNode;
   static var _sSelf = null;
   static var DELAYED_REFRESH_DURATION = 100;
   function AdminManager()
   {
      super();
      dofus.managers.AdminManager._sSelf = this;
   }
   static function getInstance()
   {
      return dofus.managers.AdminManager._sSelf;
   }
   function get isExecutingBatch()
   {
      return this._bExecutingBatch != undefined && this._bExecutingBatch;
   }
   function get pendingModReportAppendCommands()
   {
      return this._aPendingModReportAppendCommands;
   }
   function getBatchNodeByKey(nASCII)
   {
      if(this._eoHotKeysBatchNodes == undefined || nASCII == undefined)
      {
         return undefined;
      }
      return XMLNode(this._eoHotKeysBatchNodes.getItemAt(nASCII));
   }
   function executeHotKeyBatch(sPlayerName)
   {
      if(!Key.isDown(Key.getCode()))
      {
         return false;
      }
      var _loc3_ = Key.getAscii();
      var _loc4_ = this.getBatchNodeByKey(_loc3_);
      if(_loc4_ == undefined)
      {
         return false;
      }
      var _loc5_ = this.api.datacenter.Sprites.getItems();
      var _loc6_ = false;
      for(var _loc7_ in _loc5_)
      {
         var _loc8_ = _loc5_[_loc7_];
         if(_loc8_.name.toUpperCase() == this.api.datacenter.Player.Name.toUpperCase())
         {
            this.myPlayerObject = _loc8_;
         }
         if(_loc8_.name.toUpperCase() == sPlayerName.toUpperCase())
         {
            this.playerObject = _loc8_;
            _loc6_ = true;
         }
      }
      if(!_loc6_)
      {
         this.playerObject = null;
      }
      if(sPlayerName != undefined)
      {
         this.playerName = sPlayerName;
      }
      var _loc9_ = _loc4_.cloneNode(true);
      this.api.kernel.showMessage(undefined,"Batch on HotKey \"" + String.fromCharCode(_loc3_) + "\" executed for : " + sPlayerName,"COMMANDS_CHAT");
      this.batch(_loc9_);
      return true;
   }
   function initialize(oAPI)
   {
      super.initialize(oAPI);
      this._nUICounter = 0;
      this.loadXMLs();
   }
   function refreshVisually()
   {
      var _loc2_ = !this._bRightClick ? this.xml : this.xmlRightClick;
      var _loc3_ = _loc2_.firstChild.firstChild;
      this.createAndShowPopupMenuWithSearch(_loc3_,this._bRightClick);
   }
   function updateSearch(nASCII, nKeyCode)
   {
      var _loc5_ = this.api.ui.currentPopupMenu;
      if(_loc5_.removed == undefined || (_loc5_.removed || !_loc5_.adminPopupMenu))
      {
         return false;
      }
      if(nASCII <= 0)
      {
         switch(nKeyCode)
         {
            case 38:
               _loc5_.selectPreviousItem();
               break;
            case 40:
               _loc5_.selectNextItem();
         }
         return true;
      }
      switch(nASCII)
      {
         case 8:
            if(this._sCurrentSearch.length > 0)
            {
               this._sCurrentSearch = this._sCurrentSearch.substring(0,this._sCurrentSearch.length - 1);
            }
            if(this._nSearchRefreshTimeout != undefined)
            {
               _global.clearTimeout(this._nSearchRefreshTimeout);
            }
            this._nSearchRefreshTimeout = _global.setTimeout(this,"refreshVisually",dofus.managers.AdminManager.DELAYED_REFRESH_DURATION);
            return true;
         case 127:
         case 27:
            if(this._sCurrentSearch.length == 0)
            {
               _loc5_.removePopupMenu();
               return true;
            }
            this._sCurrentSearch = "";
            if(this._nSearchRefreshTimeout != undefined)
            {
               _global.clearTimeout(this._nSearchRefreshTimeout);
            }
            this._nSearchRefreshTimeout = _global.setTimeout(this,"refreshVisually",dofus.managers.AdminManager.DELAYED_REFRESH_DURATION);
            return true;
            break;
         case 13:
            if(!_loc5_.executeSelectedItem())
            {
               _loc5_.selectFirstEnabled();
            }
            return true;
         default:
            var _loc6_ = String.fromCharCode(nASCII);
            this._sCurrentSearch += _loc6_;
            if(this._nSearchRefreshTimeout != undefined)
            {
               _global.clearTimeout(this._nSearchRefreshTimeout);
            }
            this._nSearchRefreshTimeout = _global.setTimeout(this,"refreshVisually",dofus.managers.AdminManager.DELAYED_REFRESH_DURATION);
            return true;
      }
   }
   function loadXMLs(bShow)
   {
      this.loadXml(bShow);
      this.loadRightClickXml(false);
   }
   function loadXml(bShow)
   {
      var _loc2_ = new XML();
      _loc2_.parent = this;
      _loc2_.onLoad = function(bSuccess)
      {
         if(bSuccess)
         {
            this.parent.xml = this;
            this.parent.initStartup(this.firstChild.firstChild);
         }
         else
         {
            this.parent.xml = undefined;
         }
         if(bShow)
         {
            var _loc4_ = this.parent.getAdminPopupMenu(undefined,false);
            _loc4_.show(_root._xmouse,_root._ymouse,true);
         }
      };
      _loc2_.ignoreWhite = true;
      if(!dofus.Electron.getUserDataTextFileXMLContent(_loc2_,dofus.Constants.XML_ADMIN_MENU_PATH))
      {
         _loc2_.load(dofus.Constants.XML_ADMIN_MENU_PATH);
      }
   }
   function loadRightClickXml(bShow)
   {
      var _loc2_ = new XML();
      _loc2_.parent = this;
      _loc2_.onLoad = function(bSuccess)
      {
         if(bSuccess)
         {
            this.parent.xmlRightClick = this;
         }
         else
         {
            this.parent.xmlRightClick = undefined;
         }
         if(bShow)
         {
            var _loc4_ = this.parent.getAdminPopupMenu(undefined,true);
            _loc4_.show(_root._xmouse,_root._ymouse,true);
         }
      };
      _loc2_.ignoreWhite = true;
      if(!dofus.Electron.getUserDataTextFileXMLContent(_loc2_,dofus.Constants.XML_ADMIN_RIGHT_CLICK_MENU_PATH))
      {
         _loc2_.load(dofus.Constants.XML_ADMIN_RIGHT_CLICK_MENU_PATH);
      }
   }
   function getAdminPopupMenu(sPlayerName, bRightClick)
   {
      this._bRightClick = bRightClick;
      Selection.setFocus(null);
      this._aPendingModReportAppendCommands = [];
      var _loc4_ = this.api.datacenter.Sprites.getItems();
      var _loc5_ = false;
      for(var _loc6_ in _loc4_)
      {
         var _loc7_ = _loc4_[_loc6_];
         if(_loc7_.name.toUpperCase() == this.api.datacenter.Player.Name.toUpperCase())
         {
            this.myPlayerObject = _loc7_;
         }
         if(_loc7_.name.toUpperCase() == sPlayerName.toUpperCase())
         {
            this.playerObject = _loc7_;
            _loc5_ = true;
         }
      }
      if(!_loc5_)
      {
         this.playerObject = null;
      }
      if(sPlayerName != undefined)
      {
         this.playerName = sPlayerName;
      }
      var _loc8_ = !bRightClick ? this.xml : this.xmlRightClick;
      if(_loc8_ != undefined)
      {
         var _loc9_ = this.createPopupMenu(_loc8_.firstChild.firstChild,bRightClick);
      }
      else
      {
         _loc9_ = this.api.ui.createPopupMenu();
         _loc9_.addStaticItem("XML not found");
         _loc9_.addItem("Reload XML",this,!bRightClick ? this.loadXml : this.loadRightClickXml,[true]);
      }
      return _loc9_;
   }
   function generateDateString()
   {
      var _loc2_ = new ank.utils.ExtendedDate();
      return _loc2_.getFullYear() + "/" + _loc2_.getMonthPadded() + "/" + _loc2_.getDatePadded();
   }
   function generateHourString()
   {
      var _loc2_ = new ank.utils.ExtendedDate();
      return _loc2_.getHoursPadded() + ":" + _loc2_.getMinutesPadded() + ":" + _loc2_.getSecondsPadded();
   }
   function generatePreparedReplaceVars()
   {
      var _loc2_ = [];
      _loc2_[0] = this.generateDateString();
      _loc2_[1] = this.generateHourString();
      _loc2_[2] = this.api.electron.getCurrentDate();
      _loc2_[3] = this.api.electron.getYesterdayDate();
      this._aPreparedReplaceVars = _loc2_;
   }
   function createPopupMenuWithSearch(node, bRightClick)
   {
      if(this._sCurrentSearch == undefined || this._sCurrentSearch.length == 0)
      {
         return this.createPopupMenu(node,bRightClick);
      }
      var _loc4_ = this.api.ui.createPopupMenu(undefined,true);
      this.generatePreparedReplaceVars();
      _loc4_.addStaticItem("Search : " + this._sCurrentSearch);
      if(this._sCurrentSearch.length < 2)
      {
         return _loc4_;
      }
      var sSearch = this._sCurrentSearch.toLowerCase();
      var _loc5_ = function(sLabel)
      {
         var _loc2_ = sLabel != undefined && sLabel.removeAccents().toLowerCase().indexOf(sSearch) != -1;
         return _loc2_;
      };
      var _loc6_ = [];
      var _loc7_ = [];
      var _loc8_ = 0;
      while(node != null && node != undefined)
      {
         var _loc9_ = true;
         switch(node.attributes.type)
         {
            case "menu":
               if(_loc5_.call(this,node.attributes.label))
               {
                  var _loc10_ = this.replaceLabel(node.attributes.label);
                  _loc6_.push([_loc10_ + " >>",this,this.createAndShowPopupMenu,[node.firstChild,bRightClick]]);
               }
               break;
            case "menuDebug":
               if(dofus.Constants.DEBUG)
               {
                  if(_loc5_.call(this,node.attributes.label))
                  {
                     var _loc11_ = this.replaceLabel(node.attributes.label);
                     _loc6_.push([_loc11_ + " >>",this,this.createAndShowPopupMenu,[node.firstChild,bRightClick]]);
                  }
               }
               break;
            case "loadXML":
               if(_loc5_.call(this,node.attributes.label))
               {
                  var _loc12_ = this.replaceLabel(node.attributes.label);
                  _loc7_.push([_loc12_,this,!bRightClick ? this.loadXml : this.loadRightClickXml,[true]]);
               }
               break;
            case "startup":
            case "prestartup":
            case "hotkeys":
               _loc9_ = false;
               break;
            case "batch":
            case "sendCommand":
            case "prepareCommand":
            case "sendChat":
            case "prepareChat":
            case "copyCommand":
               _loc9_ = false;
               if(_loc5_.call(this,node.attributes.label))
               {
                  var _loc13_ = this.replaceLabel(node.attributes.label);
                  _loc7_.push([_loc13_,this,this.executeFirst,[node]]);
                  break;
               }
         }
         if(_loc9_ && node.childNodes.length > 0)
         {
            _loc8_ += 1;
            node = node.firstChild;
         }
         else
         {
            var _loc14_ = node.nextSibling;
            if(_loc14_ == undefined || _loc14_ == null)
            {
               while(_loc8_ > 0)
               {
                  _loc8_ -= 1;
                  node = node.parentNode;
                  var _loc15_ = node.nextSibling;
                  if(_loc15_ != undefined && _loc15_ != null)
                  {
                     _loc14_ = _loc15_;
                     break;
                  }
                  if(_loc8_ == 0)
                  {
                     _loc14_ = undefined;
                  }
               }
            }
            node = _loc14_;
         }
      }
      var _loc16_ = 0;
      var _loc17_ = 0;
      while(_loc17_ < _loc6_.length)
      {
         _loc4_.addItem.apply(_loc4_,_loc6_[_loc17_]);
         _loc16_ += 1;
         if(_loc16_ > 0 && _loc16_ % 13 == 0)
         {
            _loc4_.addNewColumn();
         }
         _loc17_ += 1;
      }
      var _loc18_ = 0;
      while(_loc18_ < _loc7_.length)
      {
         _loc4_.addItem.apply(_loc4_,_loc7_[_loc18_]);
         _loc16_ += 1;
         if(_loc16_ > 0 && _loc16_ % 13 == 0)
         {
            _loc4_.addNewColumn();
         }
         _loc18_ += 1;
      }
      return _loc4_;
   }
   function createPopupMenu(node, bRightClick)
   {
      this._sCurrentSearch = "";
      var _loc4_ = this.api.ui.createPopupMenu("CustomAdminPopupMenu",true);
      this.generatePreparedReplaceVars();
      while(node != null && node != undefined)
      {
         var _loc5_ = this.replaceLabel(node.attributes.label);
         switch(node.attributes.type)
         {
            case "static":
               _loc4_.addStaticItem(_loc5_);
               break;
            case "newColumn":
               _loc4_.addNewColumn();
               break;
            case "menu":
               _loc4_.addItem(_loc5_ + " >>",this,this.createAndShowPopupMenu,[node.firstChild,bRightClick]);
               break;
            case "menuDebug":
               if(dofus.Constants.DEBUG)
               {
                  _loc4_.addItem(_loc5_ + " >>",this,this.createAndShowPopupMenu,[node.firstChild,bRightClick]);
               }
               break;
            case "loadXML":
               _loc4_.addItem(_loc5_,this,!bRightClick ? this.loadXml : this.loadRightClickXml,[true]);
               break;
            case "startup":
            case "prestartup":
            case "hotkeys":
               break;
            default:
               _loc4_.addItem(_loc5_,this,this.executeFirst,[node]);
               break;
         }
         node = node.nextSibling;
      }
      return _loc4_;
   }
   function createAndShowPopupMenu(node, bRightClick)
   {
      var _loc5_ = this.api.ui.currentPopupMenu;
      var _loc6_ = _loc5_.x;
      var _loc7_ = _loc5_.y;
      var _loc8_ = this.createPopupMenu(node,bRightClick);
      if(_loc6_ != undefined && _loc7_ != undefined)
      {
         _loc8_.show(_loc6_,_loc7_,true);
      }
      else
      {
         _loc8_.show(_root._xmouse,_root._ymouse,true);
      }
   }
   function createAndShowPopupMenuWithSearch(node, bRightClick)
   {
      var _loc5_ = this.api.ui.currentPopupMenu;
      var _loc6_ = _loc5_.x;
      var _loc7_ = _loc5_.y;
      var _loc8_ = this.createPopupMenuWithSearch(node,bRightClick);
      if(_loc6_ != undefined && _loc7_ != undefined)
      {
         _loc8_.show(_loc6_,_loc7_,true);
      }
      else
      {
         _loc8_.show(_root._xmouse,_root._ymouse,true);
      }
   }
   function initStartup(node)
   {
      this._eoHotKeysBatchNodes = new ank.utils.ExtendedObject();
      var _loc3_ = false;
      while(node != null && node != undefined)
      {
         if(node.attributes.type == "startup")
         {
            this._startupNode = node;
         }
         else if(node.attributes.type == "prestartup")
         {
            this._preStartupNode = node;
         }
         else if(node.attributes.type == "hotkeys")
         {
            _loc3_ = true;
            var _loc4_ = node.firstChild;
            while(_loc4_ != null && _loc4_ != undefined)
            {
               var _loc5_ = _loc4_.attributes.hotkey.charCodeAt(0);
               if(_loc5_ != undefined && _loc4_.attributes.type == "batch")
               {
                  if(_loc4_.attributes.type == "batch")
                  {
                     this._eoHotKeysBatchNodes.addItemAt(_loc5_,_loc4_);
                  }
               }
               _loc4_ = _loc4_.nextSibling;
            }
         }
         if(this._startupNode != undefined && (this._preStartupNode != undefined && _loc3_))
         {
            break;
         }
         node = node.nextSibling;
      }
   }
   function executeFirst(node)
   {
      this.removeInterval();
      this._sSaveNode = node.cloneNode(true);
      this.execute(this._sSaveNode,false);
   }
   function execute(node)
   {
      if(node.attributes.check != true)
      {
         this.generatePreparedReplaceVars();
         this._sCurrentNode = node;
         var _loc3_ = node.attributes.command;
         var _loc4_ = false;
         if(_loc3_ != undefined)
         {
            var _loc5_ = _loc3_.split(" ");
            _loc4_ = _loc5_.length > 1 && _loc5_[1] == "%p";
            _loc3_ = this.replaceCommand(_loc3_);
            if(_loc3_ == null)
            {
               return false;
            }
         }
         switch(node.attributes.type)
         {
            case "copyCommand":
               this.copyCommand(_loc3_);
               break;
            case "sendCommand":
               var _loc6_ = node.attributes.appendmodreportdescription == "1";
               var _loc7_ = node.attributes.appendmodreportcomplementary == "1";
               if(_loc6_ || _loc7_)
               {
                  var _loc8_ = [];
                  if(_loc6_)
                  {
                     _loc8_.push(1);
                  }
                  if(_loc7_)
                  {
                     _loc8_.push(2);
                  }
                  var _loc9_ = new ank.utils.ExtendedString(_loc3_).trim().toString().split(dofus.aks.Basics.MULTIPLE_ADMIN_COMMANDS_SPLIT_STR);
                  var _loc10_ = 0;
                  while(_loc10_ < _loc9_.length)
                  {
                     var _loc11_ = _loc9_[_loc10_];
                     if(_loc4_)
                     {
                        var _loc12_ = _loc11_.split(" ");
                        var _loc13_ = _loc12_[0];
                        var _loc14_ = _loc12_[1].split(",");
                        _loc12_.splice(0,2);
                        var _loc15_ = _loc12_.length <= 0 ? "" : _loc12_.join(" ");
                        var _loc16_ = 0;
                        while(_loc16_ < _loc14_.length)
                        {
                           this._aPendingModReportAppendCommands.push({types:_loc8_,command:_loc13_ + " " + _loc14_[_loc16_] + (_loc15_.length != 0 ? " " + _loc15_ : "")});
                           _loc16_ += 1;
                        }
                     }
                     else
                     {
                        this._aPendingModReportAppendCommands.push({types:_loc8_,command:_loc11_});
                     }
                     _loc10_ += 1;
                  }
               }
               this.sendCommand(_loc3_);
               break;
            case "sendChat":
               this.sendChat(_loc3_);
               break;
            case "prepareCommand":
               this.prepareCommand(_loc3_);
               break;
            case "prepareChat":
               this.prepareChat(_loc3_);
               break;
            case "clearConsole":
               this.clearConsole();
               break;
            case "openConsole":
               this.openConsole();
               break;
            case "closeConsole":
               this.closeConsole();
               break;
            case "move":
               this.move(Number(node.attributes.cell),!!node.attributes.dirs);
               break;
            case "emote":
               this.emote(Number(node.attributes.num));
               break;
            case "smiley":
               this.smiley(Number(node.attributes.num));
               break;
            case "direction":
               this.direction(Number(node.attributes.num));
               break;
            case "summoner":
               this.itemSummoner();
               break;
            case "batch":
               return this.batch(node.firstChild);
         }
         node.attributes.check = true;
      }
      return true;
   }
   function batch(node)
   {
      var _loc4_ = false;
      this._bExecutingBatch = true;
      while(node != null && node != undefined)
      {
         var _loc5_ = this.execute(node);
         if(_loc5_ == false)
         {
            return false;
         }
         if(node.attributes.type == "sendCommand")
         {
            var _loc6_ = node.attributes.command;
            if(_loc6_.indexOf("/makereport") == 0 && !node.attributes.makeReportCheck)
            {
               _loc4_ = true;
               node.attributes.makeReportCheck = true;
            }
         }
         var _loc7_ = node.nextSibling;
         var _loc8_ = Number(node.attributes.delay);
         if(!_global.isNaN(_loc8_) && node.attributes.delayCheck != true)
         {
            if(_loc4_)
            {
               _loc4_ = false;
               var _loc9_ = this.api.datacenter.Temporary.Report;
               if(_loc9_ != undefined)
               {
                  this.api.network.Basics.askReportInfos(2,_loc9_.currentTargetPseudos,_loc9_.currentTargetIsAllAccounts);
               }
            }
            ank.utils.Timer.setTimer(this,"batch",this,this.onCommandDelay,_loc8_);
            return false;
         }
         var _loc10_ = node.parentNode;
         if(_loc10_.attributes.repeatCheck == undefined)
         {
            _loc10_.attributes.repeatCheck = 1;
         }
         var _loc11_ = _loc10_.attributes.repeat;
         if(_loc7_ == undefined && (!_global.isNaN(_loc11_) && _loc10_.attributes.repeatCheck < _loc11_))
         {
            var _loc12_ = 0;
            while(_loc12_ < _loc10_.childNodes.length)
            {
               _loc10_.childNodes[_loc12_].attributes.check = false;
               _loc10_.childNodes[_loc12_].attributes.delayCheck = false;
               _loc12_ += 1;
            }
            _loc10_.attributes.repeatCheck += 1;
            _loc7_ = _loc10_.childNodes[0];
         }
         node = _loc7_;
      }
      this._bExecutingBatch = false;
      if(_loc4_)
      {
         var _loc13_ = this.api.datacenter.Temporary.Report;
         if(_loc13_ != undefined)
         {
            this.api.network.Basics.askReportInfos(2,_loc13_.currentTargetPseudos,_loc13_.currentTargetIsAllAccounts);
         }
      }
      return true;
   }
   function onCommandDelay()
   {
      this._sCurrentNode.attributes.delayCheck = true;
      this.removeInterval();
      this.resumeExecute();
   }
   function removeInterval()
   {
      ank.utils.Timer.removeTimer(this,"batch");
   }
   function resumeExecute()
   {
      this.execute(this._sSaveNode);
   }
   function openConsole()
   {
      this.api.ui.loadUIComponent("Debug","Debug",undefined,{bAlwaysOnTop:true});
   }
   function closeConsole()
   {
      this.api.ui.unloadUIComponent("Debug");
   }
   function prepareCommand(sCommand)
   {
      if(this.api.electron.isShowingWidescreenPanel && this.api.electron.getWidescreenPanelId() == dofus.Electron.WIDESCREEN_PANEL_CONSOLE)
      {
         var _loc3_ = dofus.graphics.gapi.ui.Debug(this.api.ui.getUIComponent("Debug"));
         if(_loc3_ != undefined)
         {
            _loc3_.tiCommandLine = sCommand;
         }
         this.api.electron.retroConsoleSetPromptText(sCommand,true);
      }
      else
      {
         this.api.ui.loadUIComponent("Debug","Debug",{command:sCommand},{bStayIfPresent:true,bAlwaysOnTop:true});
      }
   }
   function sendCommand(sCommand)
   {
      this.api.kernel.DebugConsole.process(sCommand);
   }
   function prepareChat(sCommand)
   {
      this.api.ui.getUIComponent("Banner").txtConsole = sCommand;
      this.api.electron.retroChatSetPromptText(sCommand,true);
   }
   function sendChat(sCommand)
   {
      this.api.kernel.Console.process(sCommand);
   }
   function copyCommand(sCommand)
   {
      System.setClipboard(sCommand);
   }
   function clearConsole()
   {
      this.api.ui.getUIComponent("Debug").clear();
   }
   function move(nCellNum, bAllDirections)
   {
      this.api.datacenter.Player.InteractionsManager.calculatePath(this.api.gfx.mapHandler,nCellNum,true,this.api.datacenter.Game.isFight,true,bAllDirections);
      if(this.api.datacenter.Basics.interactionsManager_path.length != 0)
      {
         var _loc4_ = ank.battlefield.utils.Compressor.compressPath(this.api.datacenter.Basics.interactionsManager_path);
         if(_loc4_ != undefined)
         {
            this.myPlayerObject.GameActionsManager.clear();
            this.myPlayerObject.GameActionsManager.transmittingMove(1,[_loc4_]);
            delete this.api.datacenter.Basics.interactionsManager_path;
         }
      }
   }
   function smiley(nIndex)
   {
      this.api.network.Chat.useSmiley(nIndex);
   }
   function emote(nIndex)
   {
      this.api.network.Emotes.useEmote(nIndex);
   }
   function direction(nIndex)
   {
      this.api.network.Emotes.setDirection(nIndex);
   }
   function itemSummoner()
   {
      this.api.ui.loadUIComponent("ItemSummoner","ItemSummoner");
   }
   function replaceLabel(sText)
   {
      return this.replace(sText,true);
   }
   function replace(sText, bLabel)
   {
      var _loc4_ = [];
      _loc4_.push({f:"%et",t:this._aPreparedReplaceVars[2]});
      _loc4_.push({f:"%ey",t:this._aPreparedReplaceVars[3]});
      _loc4_.push({f:"%g",t:this.playerObject.guildName});
      _loc4_.push({f:"%c",t:this.playerObject.cellNum});
      _loc4_.push({f:"%p",t:this.playerName});
      _loc4_.push({f:"%n",t:this.api.datacenter.Player.Name});
      _loc4_.push({f:"%d",t:this._aPreparedReplaceVars[0]});
      _loc4_.push({f:"%h",t:this._aPreparedReplaceVars[1]});
      _loc4_.push({f:"%t",t:this.api.kernel.NightManager.time});
      _loc4_.push({f:"%s",t:this.api.datacenter.Basics.aks_a_prompt});
      _loc4_.push({f:"%m",t:this.api.datacenter.Map.id});
      _loc4_.push({f:"%v",t:dofus.Constants.VERSION + "." + dofus.Constants.SUBVERSION + "." + dofus.Constants.SUBSUBVERSION + " (" + dofus.Constants.VERSIONDATE + ")"});
      if(bLabel)
      {
         var _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            var _loc6_ = _loc4_[_loc5_].f;
            if(_loc6_ == "%p")
            {
               var _loc7_ = _loc4_[_loc5_].t.split(",").length;
               if(_loc7_ > 8)
               {
                  _loc4_[_loc5_].t = "%p contains " + _loc7_ + " pseudos";
               }
            }
            _loc5_ += 1;
         }
      }
      var _loc8_ = 0;
      while(_loc8_ < _loc4_.length)
      {
         sText = sText.split(_loc4_[_loc8_].f).join(_loc4_[_loc8_].t);
         _loc8_ += 1;
      }
      return sText;
   }
   function replaceCommand(sText)
   {
      var _loc3_ = [];
      _loc3_.push({f:"#item",ui:"ItemSelector"});
      _loc3_.push({f:"#look",ui:"MonsterAndLookSelector"});
      _loc3_.push({f:"#monster",ui:"MonsterAndLookSelector",p:{monster:true}});
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.length)
      {
         if(sText.indexOf(_loc3_[_loc4_].f) != -1)
         {
            var _loc5_ = this.api.ui.loadUIComponent(_loc3_[_loc4_].ui,_loc3_[_loc4_].ui + this._nUICounter++,_loc3_[_loc4_].p);
            _loc5_.addEventListener("select",this);
            _loc5_.addEventListener("cancel",this);
            return null;
         }
         _loc4_ += 1;
      }
      return this.replace(sText);
   }
   function replaceUI(sText, sToReplace, sReplacer)
   {
      var _loc4_ = sText.indexOf(sToReplace);
      var _loc5_ = sText.split("");
      _loc5_.splice(_loc4_,sToReplace.length,sReplacer);
      var _loc6_ = _loc5_.join("");
      return _loc6_;
   }
   function cancel(oEvent)
   {
   }
   function characterSelected()
   {
      if(this._preStartupNode == null || this._preStartupNode == undefined)
      {
         return undefined;
      }
      this.playerObject = this.api.datacenter.Player;
      this.playerName = dofus.datacenter.LocalPlayer(this.playerObject).Name;
      this.batch(this._preStartupNode.firstChild);
   }
   function characterEnteringGame()
   {
      if(this._startupNode == null || this._startupNode == undefined)
      {
         return undefined;
      }
      this.playerObject = this.api.datacenter.Player;
      this.playerName = dofus.datacenter.LocalPlayer(this.playerObject).Name;
      this.batch(this._startupNode.firstChild);
   }
   function select(oEvent)
   {
      switch(oEvent.ui)
      {
         case "ItemSelector":
            var _loc3_ = this.replaceUI(this._sCurrentNode.attributes.command,"#item",oEvent.itemId + " " + oEvent.itemQuantity);
            if(_loc3_ != undefined)
            {
               _loc3_ = this.replaceCommand(_loc3_);
            }
            if(_loc3_ != null)
            {
               this.sendCommand(_loc3_);
            }
            break;
         case "LookSelector":
            this._sCurrentNode.attributes.command = this.replaceUI(this._sCurrentNode.attributes.command,"#look",oEvent.lookId);
            this.resumeExecute();
            break;
         case "MonsterSelector":
            this._sCurrentNode.attributes.command = this.replaceUI(this._sCurrentNode.attributes.command,"#monster",oEvent.monsterId);
            this.resumeExecute();
      }
   }
}
