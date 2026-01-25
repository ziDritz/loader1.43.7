class dofus.DofusLoader extends ank.utils.QueueEmbedMovieClip
{
   var firstChild;
   var childNodes;
   var _sPrefixURL;
   var _mcContainer;
   var _mcLocalFileList;
   var _bNonCriticalError;
   var _bUpdate;
   var _sStep;
   var _mcModules;
   var _mclLoader;
   var _lblConnexionServer;
   var _lblConfiguration;
   var _mcTotalProgressBarGroup;
   var _btnChoose;
   var _btnContinue;
   var _btnClearCache;
   var _btnNext;
   var _btnShowLogs;
   var _btnCopyLogsToClipbard;
   var _lstConfiguration;
   var _lstConnexionServer;
   var LANG_TEXT;
   var ERRORS;
   var _currentLogger;
   var _cLogger;
   var _cLoggerInit;
   var _cLoggerError;
   var _mcProgressBarGroup;
   var _mcWaitBar;
   var _mcLoadingWindow;
   var _bBannerDisplay;
   var _mcBanner;
   var _mcBannerPlacer;
   var _nOccurenceId;
   var _nLoadedLangFiles;
   var _aCurrentDataBanks;
   var _aCurrentModules;
   var _aCurrentModule;
   var _mcCurrentModule;
   var _timedProgress;
   var _nTotalXtraFilesToLoad;
   var _nRemainingXtraFilesToLoad;
   var TABULATION = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
   var _sLogs = "";
   var _sLang = "fr";
   var _bLocalFileListLoaded = false;
   var _bSkipDistantLoad = false;
   var _aCurrentXtraLoadFile = [];
   var _aXtraCurrentVersion = [];
   var _aCurrentXtra = [];
   var _aXtraList = [];
   var _aDistantFilesList = [];
   var _aLoadingBannersFiles = [];
   var _bLoadingBannersFilesLoaded = false;
   var _nProgressIndex = 0;
   var _nTimerJs = 0;
   var _bJsTimer = true;
   function DofusLoader()
   {
      super();
      ank.utils.Extensions.addExtensions();
      this.initLoader(_root);
   }
   static function main(mcRoot)
   {
      var oAPI = _global.API;
      if(oAPI != undefined)
      {
         var oKernel = oAPI.kernel;
         oKernel.setQuality(oKernel.OptionsManager.getOption("DefaultQuality"));
      }
      if(_root.dofusPreLoaderMc == undefined)
      {
         return undefined;
      }
      System.security.allowDomain("*");
      fscommand("trapallkeys","true");
      fscommand("CustomerStart","");
      var oElectron = _root.electron;
      _root = mcRoot;
      _root.electron = oElectron;
      dofus.DofusLoader.registerAllClasses();
      _root._quality = "HIGH";
      if(dofus.Constants.TRIPLEFRAMERATE)
      {
         _root.attachMovie("DofusLoader_TripleFramerate","_loader",_root.getNextHighestDepth());
      }
      else
      {
         _root.attachMovie("DofusLoader","_loader",_root.getNextHighestDepth());
      }
      _root.attachMovie("LoaderBorder","_loaderBorder",_root.getNextHighestDepth(),{_x:-3,_y:-2});
      _root.createEmptyMovieClip("_misc",_root.getNextHighestDepth());
   }
   function addLoadingBannersFiles(bShow)
   {
      var xDoc = new XML();
      xDoc.onLoad = function(bSuccess)
      {
         if(bSuccess)
         {
            var oNode = this.firstChild.firstChild;
            if(oNode != null && this.childNodes.length > 0)
            {
               while(oNode != null)
               {
                  if(oNode.nodeName == "loadingbanner")
                  {
                     var sFile = oNode.attributes.file;
                     xDoc.parent._aLoadingBannersFiles.push(sFile);
                  }
                  oNode = oNode.nextSibling;
               }
            }
         }
         xDoc.parent._bLoadingBannersFilesLoaded = true;
         xDoc.parent.showBanner(xDoc.bShow);
      };
      xDoc.ignoreWhite = true;
      xDoc.bShow = bShow;
      xDoc.parent = this;
      xDoc.load(dofus.Constants.XML_LOADING_BANNERS_PATH);
   }
   function initLoader(mcRoot)
   {
      this._sPrefixURL = this._url.substr(0,this._url.lastIndexOf("/") + 1);
      _global.CONFIG = new dofus.utils.DofusConfiguration();
      this.clearlogs();
      this.showMainLogger(false);
      this.showShowLogsButton(false);
      this.showConfigurationChoice(false);
      this.showNextButton(false);
      this.showContinueButton(false);
      this.showClearCacheButton(false);
      this.showCopyLogsButton(false);
      this.showProgressBar(false);
      this._mcContainer = this.createEmptyMovieClip("__ANKDATA__",this.getNextHighestDepth());
      this._mcLocalFileList = this.createEmptyMovieClip("__ANKFILEDATA__",this.getNextHighestDepth());
      _global.CONFIG.isNewAccount = _root.htmlLogin != undefined && (_root.htmlPassword != undefined && (_root.htmlLogin != null && (_root.htmlPassword != null && (_root.htmlLogin != "null" && (_root.htmlPassword != "null" && (_root.htmlLogin != "" && _root.htmlPassword != ""))))));
      this._bNonCriticalError = false;
      this._bUpdate = false;
      this._sStep = null;
      ank.gapi.styles.StylesManager.loadStylePackage(ank.gapi.styles.DefaultStylePackage);
      ank.gapi.styles.StylesManager.loadStylePackage(dofus.graphics.gapi.styles.DofusStylePackage);
      ank.utils.Extensions.addExtensions();
      if(System.capabilities.playerType == "StandAlone")
      {
         Key.addListener(this);
      }
      this._mcModules = mcRoot.createEmptyMovieClip("mcModules",mcRoot.getNextHighestDepth());
      this._mclLoader = new MovieClipLoader();
      this._mclLoader.addListener(this);
      this.addToQueue({object:this,method:this.initTexts});
      this.addToQueue({object:this,method:this.initComponents});
      this.addToQueue({object:this,method:this.showBasicInformations,params:[true]});
   }
   function initComponents()
   {
      this._lblConnexionServer.text = this.getText("SERVER");
      this._lblConfiguration.text = this.getText("CONFIGURATION");
      this._mcTotalProgressBarGroup.txtInfo.text = "Loading";
      this._btnChoose.label = this.getText("VALID");
      this._btnChoose.addEventListener("click",this);
      this._btnContinue.label = this.getText("CONTINUE");
      this._btnContinue.addEventListener("click",this);
      this._btnClearCache.label = this.getText("CLEAR_CACHE");
      this._btnClearCache.addEventListener("click",this);
      this._btnNext.label = this.getText("NEXT");
      this._btnNext.addEventListener("click",this);
      this._btnShowLogs.label = this.getText("SHOW_LOGS");
      this._btnShowLogs.addEventListener("click",this);
      this._btnCopyLogsToClipbard.label = this.getText("COPY_LOGS");
      this._btnCopyLogsToClipbard.addEventListener("click",this);
      this._lstConfiguration.addEventListener("itemSelected",this);
      this._lstConnexionServer.addEventListener("itemSelected",this);
      this.launchBannerAnim(true);
   }
   function initTexts()
   {
      var oLogger = new dofus.DofusLoaderLogger();
      this.LANG_TEXT = oLogger.langs;
      this.ERRORS = oLogger.errors;
   }
   static function registerAllClasses()
   {
      Object.registerClass("ButtonNormalDown",ank.gapi.controls.button.ButtonBackground);
      Object.registerClass("ButtonNormalUp",ank.gapi.controls.button.ButtonBackground);
      Object.registerClass("ButtonToggleDown",ank.gapi.controls.button.ButtonBackground);
      Object.registerClass("ButtonToggleUp",ank.gapi.controls.button.ButtonBackground);
      Object.registerClass("ButtonSimpleRectangleUpDown",ank.gapi.controls.button.ButtonBackground);
      Object.registerClass("Label",ank.gapi.controls.Label);
      Object.registerClass("Button",ank.gapi.controls.Button);
      Object.registerClass("SelectableRow",ank.gapi.controls.list.SelectableRow);
      Object.registerClass("DefaultCellRenderer",ank.gapi.controls.list.DefaultCellRenderer);
      Object.registerClass("List",ank.gapi.controls.List);
      Object.registerClass("ConsoleLogger",ank.gapi.controls.ConsoleLogger);
      Object.registerClass("DofusLoader",dofus.DofusLoader);
      Object.registerClass("DofusLoader_TripleFramerate",dofus.DofusLoader);
      Object.registerClass("Loader",ank.gapi.controls.Loader);
   }
   function log(sText, sHColor, sLColor)
   {
      if(sHColor == undefined)
      {
         sHColor = "#CCCCCC";
      }
      if(sLColor == undefined)
      {
         sLColor = "#666666";
      }
      this._currentLogger.log(sText,sHColor,sLColor);
      this.addToSaveLog(sText);
   }
   function getDataBankLogHeader(nDataBank)
   {
      return "[DataBank " + nDataBank + "] ";
   }
   function addToSaveLog(sText)
   {
      this._sLogs += new ank.utils.ExtendedString(sText).replace("&nbsp;"," ") + "\r\n";
   }
   function logTitle(sText)
   {
      this.log("");
      this.log(sText,"#CCCCCC","#CCCCCC");
   }
   function logRed(sText)
   {
      this.log(sText,"#FF0000","#DD0000");
   }
   function logGreen(sText)
   {
      this.log(sText,"#00FF00","#00AA00");
   }
   function logOrange(sText)
   {
      this.log(sText,"#FF9900","#DD7700");
   }
   function logYellow(sText)
   {
      this.log(sText,"#FFFF00","#AAAA00");
   }
   function getText(key, aParams)
   {
      var sText = this.LANG_TEXT[key][_global.CONFIG.language];
      if(sText == undefined || sText.length == 0)
      {
         sText = _global[dofus.Constants.GLOBAL_SO_LANG_NAME + "_" + dofus.utils.DofusTranslator.STANDARD_DATA_BANK].data[key];
      }
      if(sText == undefined || sText.length == 0)
      {
         sText = this.LANG_TEXT[key].fr;
      }
      return this.replaceText(sText,aParams);
   }
   function replaceText(sText, aParams)
   {
      if(aParams == undefined)
      {
         aParams = [];
      }
      var aSearchPatterns = [];
      var aReplaceValues = [];
      var nIndex = 0;
      while(nIndex < aParams.length)
      {
         aSearchPatterns.push("%" + (nIndex + 1));
         aReplaceValues.push(aParams[nIndex]);
         nIndex = nIndex + 1;
      }
      return new ank.utils.ExtendedString(sText).replace(aSearchPatterns,aReplaceValues);
   }
   function clearlogs()
   {
      this._cLogger.clear();
      this._cLoggerInit.clear();
      this._cLoggerError.clear();
   }
   function setProgressBarValue(nValue, nMax)
   {
      this.showProgressBar(true);
      if(nValue > nMax)
      {
         nValue = nMax;
      }
      this._mcProgressBarGroup.mcProgressBar._width = nValue / nMax * 100;
      this._mcProgressBarGroup.txtPercent.text = Math.floor(Number(this._mcProgressBarGroup.mcProgressBar._width)) + "%";
   }
   function showProgressBar(bShow)
   {
      if(this._mcProgressBarGroup._visible != bShow)
      {
         this._mcProgressBarGroup._visible = bShow;
      }
   }
   function moveProgressBar(nX)
   {
   }
   function showWaitBar(bShow)
   {
      if(bShow)
      {
         this._mcWaitBar = this.attachMovie("GrayWaitBar","_mcWaitBar",1000,{_x:this._mcProgressBarGroup._x + this._mcProgressBarGroup.mcProgressBarBorder._x,_y:this._mcProgressBarGroup._y + this._mcProgressBarGroup.mcProgressBarBorder._y});
         this._mcWaitBar.txtInfo.text = "Waiting";
      }
      else
      {
         this._mcWaitBar.removeMovieClip();
      }
      if(bShow)
      {
         this.showProgressBar(false);
      }
   }
   function setTotalBarValue(nValue, nMax)
   {
      this.showTotalBar(true);
      if(nValue > nMax)
      {
         nValue = nMax;
      }
      this._mcTotalProgressBarGroup.mcProgressBar._width = nValue / nMax * 100;
      this._mcTotalProgressBarGroup.txtPercent.text = Math.floor(Number(this._mcTotalProgressBarGroup.mcProgressBar._width)) + "%";
   }
   function showTotalBar(bShow)
   {
      if(bShow)
      {
         var nColor = 10079232;
         var nRed = (nColor & 0xFF0000) >> 16;
         var nGreen = (nColor & 0xFF00) >> 8;
         var nBlue = nColor & 0xFF;
         var oColorObj = new Color(this._mcTotalProgressBarGroup.mcProgressBar);
         var oColorTransform = {};
         oColorTransform = {ra:"0",rb:nRed,ga:"0",gb:nGreen,ba:"0",bb:nBlue,aa:"100",ab:"0"};
         oColorObj.setTransform(oColorTransform);
         this._mcLoadingWindow._visible = true;
         this._mcTotalProgressBarGroup._visible = true;
      }
      else
      {
         this._mcTotalProgressBarGroup._visible = false;
         this._mcLoadingWindow._visible = false;
      }
   }
   function showConfigurationChoice(bShow)
   {
      this._lblConfiguration._visible = bShow;
      this._lstConfiguration._visible = bShow;
      this._lblConnexionServer._visible = bShow;
      this._lstConnexionServer._visible = bShow;
      this._btnChoose._visible = bShow;
   }
   function showNextButton(bShow)
   {
      this._btnNext._visible = bShow;
   }
   function showShowLogsButton(bShow)
   {
      this._btnShowLogs._visible = bShow;
   }
   function showContinueButton(bShow)
   {
      this._btnContinue._visible = bShow;
   }
   function showClearCacheButton(bShow)
   {
      this._btnClearCache._visible = bShow;
   }
   function showCopyLogsButton(bShow)
   {
      this._btnCopyLogsToClipbard._visible = bShow;
   }
   function showMainLogger(bShow)
   {
      if(bShow == undefined)
      {
         bShow = !this._cLogger._visible;
      }
      this._cLogger._visible = bShow;
   }
   function nonCriticalError(sError, sTab)
   {
      this.logOrange(sTab + "<b>" + this.getText("WARNING") + "</b> : " + sError);
      this._bNonCriticalError = true;
   }
   function criticalError(sError, sTab, bShowClearCacheButton, aParams, sFrom)
   {
      var oErrorData = this.ERRORS[sError];
      this.ERRORS.current = sError;
      this.ERRORS.from = sFrom;
      var sErrorMessage = this.replaceText(oErrorData[_global.CONFIG.language],aParams);
      if(sErrorMessage == undefined || sErrorMessage.length == 0)
      {
         sErrorMessage = this.replaceText(oErrorData.fr,aParams);
      }
      this._cLoggerError.log("<b>" + this.getText("ERROR") + "</b> : " + sErrorMessage,"#FF0000","#DD0000");
      var sHelpLink = "<u><a href=\'" + oErrorData["link" + _global.CONFIG.language] + "\' target=\'_blank\'>" + this.getText("LINK_HELP") + "</a></u>";
      this._cLoggerError.log(sHelpLink,"#FF0000","#DD0000");
      this.addToSaveLog(sTab + "<b>" + this.getText("ERROR") + "</b> : " + sErrorMessage);
      this.showCopyLogsButton(true);
      this.showShowLogsButton(true);
      this.showContinueButton(true);
      if(bShowClearCacheButton)
      {
         this.showClearCacheButton(true);
      }
   }
   function getLangSharedObject(nDataBank)
   {
      return ank.utils.SharedObjectFix.getLocal(dofus.Constants.LANG_SHAREDOBJECT_NAME + "_" + nDataBank);
   }
   function getXtraSharedObject(nDataBank)
   {
      return ank.utils.SharedObjectFix.getLocal(dofus.Constants.XTRA_SHAREDOBJECT_NAME + "_" + nDataBank);
   }
   function getOptionsSharedObject()
   {
      return ank.utils.SharedObjectFix.getLocal(dofus.Constants.GLOBAL_SO_OPTIONS_NAME);
   }
   function getShortcutsSharedObject()
   {
      return ank.utils.SharedObjectFix.getLocal(dofus.Constants.GLOBAL_SO_SHORTCUTS_NAME);
   }
   function getOccurencesSharedObject()
   {
      return ank.utils.SharedObjectFix.getLocal(dofus.Constants.GLOBAL_SO_OCCURENCES_NAME);
   }
   function getCacheDateSharedObject()
   {
      return ank.utils.SharedObjectFix.getLocal(dofus.Constants.GLOBAL_SO_CACHEDATE_NAME);
   }
   function launchBannerAnim(bPlay)
   {
      if(!this._bBannerDisplay)
      {
         this.showBanner(true);
      }
      if(bPlay)
      {
         this._mcBanner.playAll();
      }
      else
      {
         this._mcBanner.stopAll();
      }
   }
   function showBanner(bShow)
   {
      if(!this._bLoadingBannersFilesLoaded)
      {
         this.addLoadingBannersFiles(bShow);
      }
      else
      {
         var bShowBanner = bShow != undefined ? bShow : !this._bBannerDisplay;
         if(bShowBanner)
         {
            if(this._bBannerDisplay)
            {
               return undefined;
            }
            var sEmptyStr = "";
            if(this._aLoadingBannersFiles.length > 0)
            {
               var nRandomIndex = Math.floor(Math.random() * (this._aLoadingBannersFiles.length + 1));
               if(nRandomIndex < this._aLoadingBannersFiles.length)
               {
                  var sBannerFile = this._aLoadingBannersFiles[nRandomIndex];
                  var mcBanner = this.createEmptyMovieClip("_mcBanner",this.getNextHighestDepth());
                  org.utils.Bitmap.loadBitmapSmoothed(dofus.Constants.LOADING_BANNERS_PATH + sBannerFile,mcBanner);
               }
            }
            var sLangStr = "";
            if(!mcBanner)
            {
               mcBanner = this.attachMovie("LoadingBanner_" + _global.CONFIG.language,"_mcBanner",this.getNextHighestDepth(),this._mcBannerPlacer);
            }
            if(!mcBanner)
            {
               mcBanner = this.attachMovie("LoadingBanner_" + sLangStr,"_mcBanner",this.getNextHighestDepth(),this._mcBannerPlacer);
            }
            if(!mcBanner)
            {
               mcBanner = this.attachMovie("LoadingBanner","_mcBanner",this.getNextHighestDepth(),this._mcBannerPlacer);
            }
            mcBanner.cacheAsBitmap = true;
            mcBanner.swapDepths(this._mcBannerPlacer);
         }
         else
         {
            if(!this._bBannerDisplay)
            {
               return undefined;
            }
            this._mcBanner.swapDepths(this._mcBannerPlacer);
            this._mcBanner.removeMovieClip();
         }
         this._bBannerDisplay = bShowBanner;
      }
   }
   function copyAndOrganizeDataServersForDataBank(nDataBank)
   {
      var aAllDataBanks = _global.CONFIG.dataBanks;
      var aServerList = aAllDataBanks[nDataBank].slice(0);
      var nIndex = 0;
      while(nIndex < aServerList.length)
      {
         var oServer = aServerList[nIndex];
         if(oServer.nPriority == undefined || _global.isNaN(oServer.nPriority))
         {
            oServer.nPriority = 0;
         }
         var nPriority = oServer.priority;
         oServer.rand = random(99999);
         nIndex = nIndex + 1;
      }
      aServerList.sortOn(["priority","rand"],Array.DESCENDING);
      var nCount = 0;
      while(nCount < aServerList.length)
      {
         nCount = nCount + 1;
      }
      return aServerList;
   }
   function copyAndOrganizeDataBanks()
   {
      var aDataBanksCopy = [];
      var aAllDataBanks = _global.CONFIG.dataBanks;
      var nBankIndex = 0;
      while(nBankIndex < aAllDataBanks.length)
      {
         aDataBanksCopy[nBankIndex] = aAllDataBanks[nBankIndex].slice(0);
         nBankIndex = nBankIndex + 1;
      }
      var nOuterIndex = 0;
      while(nOuterIndex < aDataBanksCopy.length)
      {
         var aCurrentBank = aDataBanksCopy[nOuterIndex];
         var nInnerIndex = 0;
         while(nInnerIndex < aCurrentBank.length)
         {
            var oCurrentServer = aCurrentBank[nInnerIndex];
            if(oCurrentServer.nPriority == undefined || _global.isNaN(oCurrentServer.nPriority))
            {
               oCurrentServer.nPriority = 0;
            }
            var nPriority = oCurrentServer.priority;
            oCurrentServer.rand = random(99999);
            nInnerIndex = nInnerIndex + 1;
         }
         aCurrentBank.sortOn(["priority","rand"],Array.DESCENDING);
         var nCount = 0;
         while(nCount < aCurrentBank.length)
         {
            nCount = nCount + 1;
         }
         nOuterIndex = nOuterIndex + 1;
      }
      return aDataBanksCopy;
   }
   function checkOccurences()
   {
      var nMaxOccurrences = _global.API.lang.getConfigText("MAXIMUM_CLIENT_OCCURENCES");
      if(nMaxOccurrences == undefined || (_global.isNaN(nMaxOccurrences) || nMaxOccurrences < 1))
      {
         return true;
      }
      var aOccurrences = this.getOccurencesSharedObject().data.occ;
      var aValidOccurrences = [];
      var nIndex = 0;
      while(nIndex < aOccurrences.length)
      {
         if(aOccurrences[nIndex].tick + dofus.Constants.MAX_OCCURENCE_DELAY > new Date().getTime())
         {
            aValidOccurrences.push(aOccurrences[nIndex]);
         }
         nIndex = nIndex + 1;
      }
      var nCurrentCount = aValidOccurrences.length;
      if(!_global.API.datacenter.Player.isAuthorized && nCurrentCount + 1 > nMaxOccurrences)
      {
         this.criticalError("TOO_MANY_OCCURENCES",this.TABULATION,false);
         return false;
      }
      this._nOccurenceId = Math.round(Math.random() * 1000);
      aValidOccurrences.push({id:this._nOccurenceId,tick:new Date().getTime()});
      this.getOccurencesSharedObject().data.occ = aValidOccurrences;
      _global.setInterval(this,"refreshOccurenceTick",dofus.Constants.OCCURENCE_REFRESH);
      return true;
   }
   function refreshOccurenceTick()
   {
      var aOccurrences = this.getOccurencesSharedObject().data.occ;
      var nIndex = 0;
      while(nIndex < aOccurrences.length)
      {
         if(aOccurrences[nIndex].id == this._nOccurenceId)
         {
            aOccurrences[nIndex].tick = new Date().getTime();
            break;
         }
         nIndex = nIndex + 1;
      }
      this.getOccurencesSharedObject().data.occ = aOccurrences;
   }
   function checkFlashPlayer()
   {
      var sFlashVersion = System.capabilities.version;
      var nMajorVersion = Number(sFlashVersion.split(" ")[1].split(",")[0]);
      if(_root.electron != undefined)
      {
         var sElectronVersion = String(flash.external.ExternalInterface.call("getElectronVersion"));
         var sNodejsVersion = String(flash.external.ExternalInterface.call("getNodejsVersion"));
         var sVersionInfo = " (Electron <b>" + sElectronVersion + "</b> | Node.js <b>" + sNodejsVersion + "</b>)";
      }
      else
      {
         sVersionInfo = System.capabilities.playerType.length != 0 ? " (" + System.capabilities.playerType + ")" : " ";
      }
      var sLogMessage = "Flash player" + sVersionInfo + " <b>" + sFlashVersion + "</b>";
      this.log(this.TABULATION + sLogMessage);
      if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
      {
         this.getURL("JavaScript:WriteLog(\'checkFlashPlayer;" + nMajorVersion + "\')");
         this.getURL("JavaScript:WriteLog(\'versionDate;" + dofus.Constants.VERSIONDATE + "\')");
      }
      if(nMajorVersion >= 8)
      {
         var sSandboxType = System.security.sandboxType;
         if(sSandboxType != "localTrusted" && sSandboxType != "remote")
         {
            this.criticalError("BAD_FLASH_SANDBOX",this.TABULATION,false);
            return false;
         }
         return true;
      }
      this.criticalError("BAD_FLASH_PLAYER",this.TABULATION,false);
      this.showBanner(false);
      return false;
   }
   function click(oEvent)
   {
      switch(oEvent.target)
      {
         case this._btnChoose:
            this.chooseConfiguration(this._lstConfiguration.selectedItem.data,this._lstConnexionServer.selectedItem.data,true);
            break;
         case this._btnClearCache:
            this.clearCache();
            this.reboot();
            break;
         case this._btnCopyLogsToClipbard:
            System.setClipboard(this._sLogs);
            break;
         case this._btnShowLogs:
            this.showBanner(false);
            this.showMainLogger();
            break;
         case this._btnContinue:
            switch(this.ERRORS.current)
            {
               case "CHECK_LAST_VERSION_FAILED":
                  var oLoadVars1 = new LoadVars();
                  oLoadVars1.f = "";
                  this.onCheckLanguage(true,oLoadVars1,"","");
                  break;
               case "CHECK_LAST_VERSION_FAILED":
                  var oLoadVars2 = new LoadVars();
                  oLoadVars2.f = "";
                  this.onCheckLanguage(true,oLoadVars2,"","");
            }
            break;
         case this._btnNext:
            this.showNextButton(false);
            switch(this._sStep)
            {
               case "MODULE":
                  this.initCore(_global.MODULE_CORE);
                  break;
               case "XTRA":
                  this.initAndLoginFinished();
            }
      }
   }
   function itemSelected(oEvent)
   {
      switch(oEvent.target)
      {
         case this._lstConfiguration:
            this.selectConfiguration();
            break;
         case this._lstConnexionServer:
            this.selectConnexionServer();
      }
   }
   function onKeyUp()
   {
      if(Key.getCode() == Key.ESCAPE)
      {
         fscommand("quit","");
      }
   }
   function setDisplayStyle(sStyleName)
   {
      if(System.capabilities.playerType == "PlugIn" && (!_global.CONFIG.isStreaming && _root.electron == undefined))
      {
         this.getURL("javascript:setFlashStyle(\'flashid\', \'" + sStyleName + "\');");
      }
   }
   function closeBrowserWindow()
   {
      if(System.capabilities.playerType == "PlugIn")
      {
         this.getURL("javascript:closeBrowserWindow();");
      }
   }
   function reboot()
   {
      var nIndex = 0;
      while(nIndex < dofus.Constants.MODULES_LIST.length)
      {
         this._mclLoader.unloadClip(_global["MODULE_" + dofus.Constants.MODULES_LIST[nIndex][4]]);
         nIndex = nIndex + 1;
      }
      dofus.DofusCore.getClip().removeMovieClip();
      this.initLoader(_root);
   }
   function clearCache()
   {
      var oOptionsSharedObject = this.getOptionsSharedObject();
      var nDatabankCount = oOptionsSharedObject.data.dataBanksCount;
      if(nDatabankCount == undefined || _global.isNaN(nDatabankCount))
      {
         return undefined;
      }
      var nIndex = 0;
      while(nIndex < nDatabankCount)
      {
         var oLangSharedObject = this.getLangSharedObject(nIndex);
         var oXtraSharedObject = this.getXtraSharedObject(nIndex);
         oLangSharedObject.clear();
         oXtraSharedObject.clear();
         nIndex = nIndex + 1;
      }
   }
   function showLoader(bShow, bNotClear)
   {
      this._visible = bShow;
   }
   function showBasicInformations(bContinue)
   {
      this._currentLogger = this._cLoggerInit;
      this.logTitle(this.getText("STARTING"));
      this.log(this.TABULATION + "Dofus Retro <b>v" + dofus.Constants.VERSION + "." + dofus.Constants.SUBVERSION + "." + dofus.Constants.SUBSUBVERSION + "</b> " + (dofus.Constants.BETAVERSION <= 0 ? "" : "(<font color=\"#FF0000\"><i><b>BETA " + dofus.Constants.BETAVERSION + "</b></i></font>) ") + "(<b>" + dofus.Constants.VERSIONDATE + "</b>" + (!dofus.Constants.ALPHA ? "" : " <font color=\"#00FF00\"><i><b>ALPHA BUILD</b></i></font>") + ")");
      if(!this.checkFlashPlayer())
      {
         this.showShowLogsButton(false);
         this.showCopyLogsButton(false);
         return undefined;
      }
      this.checkCacheVersion();
      this._currentLogger = this._cLogger;
      if(bContinue)
      {
         this.addToQueue({object:this,method:this.loadConfig});
      }
   }
   function loadConfig()
   {
      this.showLoader(true);
      this.moveProgressBar(0);
      this.logTitle(this.getText("LOADING_CONFIG_FILE"));
      var xConfigDocument = new XML();
      var loader = this;
      xConfigDocument.ignoreWhite = true;
      xConfigDocument.onLoad = function(bSuccess)
      {
         loader.onConfigLoaded(bSuccess,this);
      };
      this.showWaitBar(true);
      if(!dofus.Electron.getUserDataTextFileXMLContent(xConfigDocument,dofus.Constants.CONFIG_XML_FILE))
      {
         xConfigDocument.load(dofus.Constants.CONFIG_XML_FILE);
      }
   }
   function onConfigLoaded(bSuccess, xDoc)
   {
      this.showWaitBar(false);
      if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
      {
         this.getURL("JavaScript:WriteLog(\'onConfigLoaded;" + bSuccess + "\')");
      }
      if(bSuccess)
      {
         this.setTotalBarValue(50,100);
         var xConfigNode = xDoc.firstChild.firstChild;
         if(xDoc.childNodes.length == 0 || xConfigNode == null)
         {
            this.criticalError("CORRUPT_CONFIG_FILE",this.TABULATION,false);
            return undefined;
         }
         _global.CONFIG.cacheAsBitmap = [];
         var aConfigurations = new ank.utils.ExtendedArray();
         var bProcessing = false;
         while(xConfigNode != null)
         {
            switch(xConfigNode.nodeName)
            {
               case "delay":
                  _global.CONFIG.delay = xConfigNode.attributes.value;
                  break;
               case "rdelay":
                  _global.CONFIG.rdelay = xConfigNode.attributes.value;
                  break;
               case "rcount":
                  _global.CONFIG.rcount = xConfigNode.attributes.value;
                  break;
               case "hardcore":
                  _global.CONFIG.onlyHardcore = true;
                  break;
               case "streaming":
                  _global.CONFIG.isStreaming = true;
                  if(xConfigNode.attributes.method)
                  {
                     _global.CONFIG.streamingMethod = xConfigNode.attributes.method;
                  }
                  else
                  {
                     _global.CONFIG.streamingMethod = "compact";
                  }
                  _root._misc.attachMovie("UI_Misc","miniClip",_root._misc.getNextHighestDepth());
                  break;
               case "expo":
                  _global.CONFIG.isExpo = true;
                  break;
               case "conf":
                  var sConfName = xConfigNode.attributes.name;
                  var sConfType = xConfigNode.attributes.type;
                  if(sConfName != undefined && (dofus.Constants.TEST != true && sConfType != "test" || dofus.Constants.TEST == true && sConfType == "test"))
                  {
                     var oConfiguration = {};
                     oConfiguration.name = sConfName;
                     var nZaapPort = Number(xConfigNode.attributes.zaapconnectport);
                     oConfiguration.zaapConnectPort = !(nZaapPort == undefined || _global.isNaN(nZaapPort)) ? nZaapPort : dofus.ZaapConnect.TCP_DEFAULT_PORT;
                     oConfiguration.debug = xConfigNode.attributes.boo == "1";
                     oConfiguration.debugRequests = xConfigNode.attributes.debugrequests == "1" || xConfigNode.attributes.debugrequests == "2";
                     oConfiguration.logRequests = xConfigNode.attributes.debugrequests == "2";
                     oConfiguration.openRetroChat = xConfigNode.attributes.openRetroChat == "1";
                     oConfiguration.openRetroConsole = xConfigNode.attributes.openRetroConsole == "1";
                     oConfiguration.connexionServers = new ank.utils.ExtendedArray();
                     oConfiguration.dataBanks = [];
                     var aDataBanks = oConfiguration.dataBanks;
                     var xDataBankNode = xConfigNode.firstChild;
                     while(xDataBankNode != null)
                     {
                        switch(xDataBankNode.nodeName)
                        {
                           case "databank":
                              var nDatabankId = Number(xDataBankNode.attributes.id);
                              if(_global.isNaN(nDatabankId))
                              {
                                 break;
                              }
                              var aCurrentBank = aDataBanks[nDatabankId];
                              if(aCurrentBank == undefined)
                              {
                                 aCurrentBank = [];
                                 aDataBanks[nDatabankId] = aCurrentBank;
                              }
                              var xServerNode = xDataBankNode.firstChild;
                              while(xServerNode != null)
                              {
                                 var xNodeName = null;
                                 if((xNodeName = xServerNode.nodeName) === "dataserver")
                                 {
                                    var sServerUrl = xServerNode.attributes.url;
                                    var sServerType = xServerNode.attributes.type;
                                    var nPriority = Number(xServerNode.attributes.priority);
                                    if(sServerUrl != undefined && sServerUrl != "")
                                    {
                                       aCurrentBank.push({url:sServerUrl,type:sServerType,priority:nPriority,dataBankId:nDatabankId});
                                       System.security.allowDomain(sServerUrl);
                                    }
                                 }
                                 xServerNode = xServerNode.nextSibling;
                              }
                              var oOptionsSharedObject = this.getOptionsSharedObject();
                              oOptionsSharedObject.data.dataBanksCount = aCurrentBank.length;
                              oOptionsSharedObject.flush();
                              break;
                           case "dataserver":
                              var nStandardDatabankId = dofus.utils.DofusTranslator.STANDARD_DATA_BANK;
                              var aStandardBank = aDataBanks[nStandardDatabankId];
                              if(aStandardBank == undefined)
                              {
                                 aStandardBank = [];
                                 aDataBanks[nStandardDatabankId] = aStandardBank;
                              }
                              var sStandardUrl = xDataBankNode.attributes.url;
                              var sStandardType = xDataBankNode.attributes.type;
                              var nStandardPriority = Number(xDataBankNode.attributes.priority);
                              if(sStandardUrl != undefined && sStandardUrl != "")
                              {
                                 aStandardBank.push({url:sStandardUrl,type:sStandardType,priority:nStandardPriority,dataBankId:nStandardDatabankId});
                                 System.security.allowDomain(sStandardUrl);
                              }
                              var oStandardSharedObject = this.getOptionsSharedObject();
                              oStandardSharedObject.data.dataBanksCount = aStandardBank.length;
                              oStandardSharedObject.flush();
                              break;
                           case "connserver":
                              var sConnServerName = xDataBankNode.attributes.name;
                              var sConnServerIp = xDataBankNode.attributes.ip;
                              var sConnServerPort = xDataBankNode.attributes.port;
                              if(sConnServerName != undefined && (sConnServerIp != "" && sConnServerPort != undefined))
                              {
                                 oConfiguration.connexionServers.push({label:sConnServerName,data:{name:sConnServerName,ip:sConnServerIp,port:sConnServerPort}});
                              }
                              break;
                           default:
                              this.nonCriticalError(this.getText("UNKNOWN_TYPE_NODE") + " (" + xConfigNode.nodeName + ")",this.TABULATION);
                        }
                        xDataBankNode = xDataBankNode.nextSibling;
                     }
                     if(aDataBanks[dofus.utils.DofusTranslator.STANDARD_DATA_BANK].length > 0)
                     {
                        aConfigurations.push({label:oConfiguration.name,data:oConfiguration});
                     }
                  }
                  break;
               case "languages":
                  _global.CONFIG.xmlLanguages = xConfigNode.attributes.value.split(",");
                  _global.CONFIG.skipLanguageVerification = xConfigNode.attributes.skipcheck == "true" || xConfigNode.attributes.skipcheck == "1";
                  break;
               case "cacheasbitmap":
                  var xCacheNode = xConfigNode.firstChild;
                  while(xCacheNode != null)
                  {
                     var sCacheElement = xCacheNode.attributes.element;
                     var bCacheValue = xCacheNode.attributes.value == "true";
                     _global.CONFIG.cacheAsBitmap[sCacheElement] = bCacheValue;
                     xCacheNode = xCacheNode.nextSibling;
                  }
                  break;
               case "servers":
                  var xServerListNode = xConfigNode.firstChild;
                  _global.CONFIG.customServersIP = [];
                  while(xServerListNode != null)
                  {
                     var sServerId = xServerListNode.attributes.id;
                     var sServerIp = xServerListNode.attributes.ip;
                     var sServerPort = xServerListNode.attributes.port;
                     _global.CONFIG.customServersIP[sServerId] = {ip:sServerIp,port:sServerPort};
                     xServerListNode = xServerListNode.nextSibling;
                  }
                  break;
               default:
                  this.nonCriticalError(this.getText("UNKNOWN_TYPE_NODE") + " (" + xConfigNode.nodeName + ")",this.TABULATION);
            }
            xConfigNode = xConfigNode.nextSibling;
         }
         if(aConfigurations.length == 0)
         {
            this.criticalError("CORRUPT_CONFIG_FILE",this.TABULATION,false);
            return undefined;
         }
         this.log(this.TABULATION + this.getText("CONFIG_FILE_LOADED"));
         this.askForConfiguration(aConfigurations);
      }
      this.criticalError("NO_CONFIG_FILE",this.TABULATION,false);
      return undefined;
   }
   function askForConfiguration(eaConfigurations)
   {
      if(eaConfigurations.length == 1 && eaConfigurations[0].data.connexionServers.length == 0)
      {
         this.chooseConfiguration(eaConfigurations[0].data,undefined,false);
      }
      else
      {
         this.logTitle(this.getText("CHOOSE_CONFIGURATION"));
         this._lstConfiguration.dataProvider = eaConfigurations;
         var sLastConfName = this.getOptionsSharedObject().data.loaderLastConfName;
         if(sLastConfName != undefined)
         {
            var nIndex = 0;
            while(nIndex < eaConfigurations.length)
            {
               if(eaConfigurations[nIndex].data.name == sLastConfName)
               {
                  this._lstConfiguration.selectedIndex = nIndex;
                  break;
               }
               nIndex = nIndex + 1;
            }
         }
         else
         {
            this._lstConfiguration.selectedIndex = 0;
         }
         this.selectConfiguration();
         this.showConfigurationChoice(true);
      }
   }
   function selectConfiguration()
   {
      var aConnServers = this._lstConfiguration.selectedItem.data.connexionServers;
      this._lstConnexionServer.dataProvider = aConnServers;
      var oOptions = this.getOptionsSharedObject();
      var sLastServer = oOptions.data.loaderConf[this._lstConfiguration.selectedItem.label];
      if(sLastServer != undefined)
      {
         var nIndex = 0;
         while(nIndex < aConnServers.length)
         {
            if(aConnServers[nIndex].data.name == sLastServer)
            {
               this._lstConnexionServer.selectedIndex = nIndex;
               break;
            }
            nIndex = nIndex + 1;
         }
      }
      else if(aConnServers.length > 0)
      {
         this._lstConnexionServer.selectedIndex = 0;
      }
      var sConfigName = this._lstConfiguration.selectedItem.label;
      var bConfigChanged = sConfigName != oOptions.data.loaderLastConfName;
      if(bConfigChanged)
      {
         this.clearCache();
      }
      oOptions.data.loaderLastConfName = sConfigName;
      oOptions.flush();
      this.selectConnexionServer();
   }
   function selectConnexionServer()
   {
      var oOptions = this.getOptionsSharedObject();
      if(oOptions.data.loaderConf == undefined)
      {
         oOptions.data.loaderConf = {};
      }
      oOptions.data.loaderConf[this._lstConfiguration.selectedItem.label] = this._lstConnexionServer.selectedItem.label;
      oOptions.flush();
   }
   function chooseConfiguration(oConf, oServer, bLog)
   {
      this.showConfigurationChoice(false);
      if(bLog)
      {
         this.log(this.TABULATION + this.getText("CURRENT_CONFIG",[oConf.name]));
         if(oServer != undefined)
         {
            this.log(this.TABULATION + this.getText("CURRENT_SERVER",[oServer.name]));
         }
      }
      _global.CONFIG.dataBanks = oConf.dataBanks;
      _global.CONFIG.connexionServer = oServer;
      _global.CONFIG.zaapConnectPort = oConf.zaapConnectPort;
      if(oConf.debug)
      {
         dofus.Constants.DEBUG = true;
         this.logYellow(this.TABULATION + this.getText("DEBUG_MODE"));
      }
      if(oConf.debugRequests)
      {
         dofus.Constants.DEBUG_DATAS = true;
      }
      if(oConf.logRequests)
      {
         dofus.Constants.LOG_DATAS = true;
      }
      if(oConf.openRetroChat)
      {
         dofus.Electron.retroChatOpen();
      }
      if(oConf.openRetroConsole)
      {
         dofus.Electron.retroConsoleOpen();
      }
      dofus.ZaapConnect.newInstance();
      this.loadLocalFileList();
   }
   function startJsTimer()
   {
      this._nTimerJs = this._nTimerJs - 1;
      if(this._nTimerJs <= 0)
      {
         this._nTimerJs = 20;
         this.getURL("javascript:startTimer()");
      }
      if(this._bJsTimer)
      {
         this.addToQueue({object:this,method:this.startJsTimer});
      }
   }
   function loadLanguage()
   {
      if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
      {
         this.getURL("javascript:startTimer()");
         this.startJsTimer();
      }
      this.logTitle(this.getText("LOAD_LANG_FILE"));
      this._sStep = "LANG";
      this._nLoadedLangFiles = 0;
      var aDataBanks = this.copyAndOrganizeDataBanks();
      this._aCurrentDataBanks = aDataBanks;
      var nIndex = 0;
      while(nIndex < aDataBanks.length)
      {
         var oLangSharedObject = this.getLangSharedObject(nIndex);
         var nLangVersion = oLangSharedObject.data.VERSIONS.lang;
         _global[dofus.Constants.GLOBAL_SO_LANG_NAME + "_" + nIndex] = oLangSharedObject;
         var sDataBankHeader = this.getDataBankLogHeader(nIndex);
         this.log(this.TABULATION + sDataBankHeader + this.getText("CURRENT_LANG_FILE_VERSION",[nLangVersion != undefined ? nLangVersion : "Aucune"]));
         this.log(this.TABULATION + sDataBankHeader + this.getText("CHECK_LAST_VERSION"));
         var aXtraVersion = this._aXtraCurrentVersion[nIndex];
         if(aXtraVersion == undefined)
         {
            aXtraVersion = [];
            this._aXtraCurrentVersion[nIndex] = aXtraVersion;
         }
         aXtraVersion.lang = !_global.isNaN(nLangVersion) ? Number(nLangVersion) : 0;
         this.checkLanguageWithNextHost("lang," + nLangVersion,nIndex);
         nIndex = nIndex + 1;
      }
   }
   function checkLanguageWithNextHost(sFiles, nDataBank)
   {
      var aServers = this._aCurrentDataBanks[nDataBank];
      if(aServers.length < 1)
      {
         if(!this._bLocalFileListLoaded)
         {
            this.criticalError("CHECK_LAST_VERSION_FAILED",this.TABULATION,true,[],"checkXtra");
         }
         else
         {
            this.nonCriticalError("CHECK_LAST_VERSION_FAILED",this.TABULATION,true);
            var oLoadVars = new LoadVars();
            var aFileList = [];
            var oLocalVersions = this._mcLocalFileList.VERSIONS[_global.CONFIG.language];
            for(var i in oLocalVersions)
            {
               aFileList.push(i + "," + _global.CONFIG.language + "," + oLocalVersions[i]);
            }
            oLoadVars.f = aFileList.join("|");
            this.onCheckLanguage(true,oLoadVars,undefined,undefined,nDataBank);
         }
         return undefined;
      }
      var oServer = aServers.shift();
      if(oServer.type == "local")
      {
         this.checkLanguageWithNextHost(sFiles,nDataBank);
         return undefined;
      }
      var sURL = oServer.url + "lang/versions_" + _global.CONFIG.language + ".txt" + "?wtf=" + Math.random();
      var oVersionVars = new LoadVars();
      var loader = this;
      oVersionVars.onLoad = function(bSuccess)
      {
         if(!bSuccess)
         {
            loader.nonCriticalError(loader.getText("IMPOSSIBLE_TO_GET_FILE",[sURL]),loader.TABULATION + loader.TABULATION);
         }
         loader.onCheckLanguage(bSuccess,this,oServer.url,sFiles,nDataBank);
      };
      this.showWaitBar(true);
      oVersionVars.load(sURL,this,"GET");
   }
   function onCheckLanguage(bSuccess, lv, sServer, sFiles, nDataBank)
   {
      this.showWaitBar(false);
      if(bSuccess && lv.f != undefined)
      {
         this.setTotalBarValue(100,100);
         this._aDistantFilesList[nDataBank] = lv.f;
         var aLanguageVersionParts = lv.f.substr(lv.f.indexOf("lang,")).split("|")[0].split(",");
         var bLanguageUpToDate = false;
         if(lv.f != "")
         {
            var nRemoteLanguageVersion = aLanguageVersionParts[2];
            if(_global.CONFIG.language == this.getLangSharedObject(nDataBank).data.LANGUAGE && (this._aXtraCurrentVersion[nDataBank].lang != undefined && nRemoteLanguageVersion == this._aXtraCurrentVersion[nDataBank].lang))
            {
               bLanguageUpToDate = true;
            }
            else
            {
               this.log(this.TABULATION + this.getDataBankLogHeader(nDataBank) + this.getText("NEW_LANG_FILE_AVAILABLE",[aLanguageVersionParts[2]]));
               if(this._bSkipDistantLoad)
               {
                  if(this._aXtraCurrentVersion[nDataBank].lang == 0)
                  {
                     nRemoteLanguageVersion = this._mcLocalFileList.VERSIONS[_global.CONFIG.language].lang;
                  }
               }
               this.updateLanguage(aLanguageVersionParts[2],nDataBank);
            }
         }
         else
         {
            bLanguageUpToDate = true;
         }
         if(bLanguageUpToDate)
         {
            this._nLoadedLangFiles = this._nLoadedLangFiles + 1;
            this.log(this.TABULATION + this.getText("NO_NEW_VERSION_AVAILABLE"));
            if(this._aCurrentDataBanks.length == this._nLoadedLangFiles)
            {
               this.loadModules();
            }
         }
      }
      else
      {
         this.nonCriticalError(this.getText("IMPOSSIBLE_TO_JOIN_SERVER",[sServer]),this.TABULATION + this.TABULATION);
         this.checkLanguageWithNextHost(sFiles,nDataBank);
      }
   }
   function updateLanguage(nFileNumber, nDataBank)
   {
      this._bUpdate = true;
      this.showWaitBar(true);
      var oLangFileLoader = new dofus.utils.LangFileLoader();
      oLangFileLoader.addListener(this);
      var sLangSOName = dofus.Constants.LANG_SHAREDOBJECT_NAME + "_" + nDataBank;
      var aServers = this.copyAndOrganizeDataServersForDataBank(nDataBank);
      var mcContainer = this.getDataBankMcContainer(nDataBank);
      oLangFileLoader.loadLangFile(aServers,"lang/swf/lang_" + _global.CONFIG.language + "_" + nFileNumber + ".swf",mcContainer,sLangSOName,"lang",_global.CONFIG.language,false);
   }
   function getDataBankMcContainer(nDataBank)
   {
      var sContainerName = "db" + nDataBank;
      var mcDataBankContainer = this._mcContainer[sContainerName];
      if(mcDataBankContainer == undefined)
      {
         mcDataBankContainer = this._mcContainer.createEmptyMovieClip(sContainerName,this._mcContainer.getNextHighestDepth());
      }
      return mcDataBankContainer;
   }
   function loadModules()
   {
      this.logTitle(this.getText("LOAD_MODULES"));
      this._sStep = "MODULE";
      this._aCurrentModules = dofus.Constants.MODULES_LIST.slice(0);
      this.loadNextModule();
   }
   function loadNextModule()
   {
      if(this._aCurrentModules.length < 1)
      {
         this.logTitle(this.getText("INIT_END"));
         this.onCoreLoaded(_global.MODULE_CORE);
         return undefined;
      }
      this._aCurrentModule = this._aCurrentModules.shift();
      var sModuleGroup = this._aCurrentModule[0];
      var sModulePath = this._aCurrentModule[1];
      var sModuleId = this._aCurrentModule[2];
      var sModuleName = this._aCurrentModule[4];
      this._mcCurrentModule = this._mcModules.createEmptyMovieClip("mc" + sModuleName,this._mcModules.getNextHighestDepth());
      this._timedProgress = _global.setInterval(this.onTimedProgress,1000,this,this._mclLoader,this._mcCurrentModule);
      this._mclLoader.loadClip(sModulePath,this._mcCurrentModule);
   }
   function onCoreLoaded(mcCore)
   {
      if(_global.CONFIG.isStreaming)
      {
         this._bJsTimer = false;
         this.getURL("javascript:stopTimer()");
      }
      if((this._bNonCriticalError || this._bUpdate) && (dofus.Constants.DEBUG && dofus.Kernel.FAST_SWITCHING_SERVER_REQUEST == undefined))
      {
         this.showNextButton(true);
         this.showCopyLogsButton(true);
         this.showShowLogsButton(true);
      }
      else
      {
         this.initCore(mcCore);
      }
   }
   function initCore(mcCore)
   {
      Key.removeListener(this);
      var oDofusCore = null;
      if((oDofusCore = dofus.DofusCore.getInstance()) == undefined)
      {
         oDofusCore = new dofus.DofusCore(mcCore);
         if(Key.isDown(Key.SHIFT))
         {
            Stage.scaleMode = "exactFit";
         }
      }
      oDofusCore.initStart();
      this._bNonCriticalError = false;
      this._bUpdate = false;
   }
   function loadLocalFileList()
   {
      this.logTitle(this.getText("LOAD_XTRA_FILES"));
      this._aCurrentDataBanks = this.copyAndOrganizeDataBanks();
      this.checkLocalFileListWithNextHost(dofus.Constants.LANG_LOCAL_FILE_LIST);
      this.showWaitBar(true);
   }
   function checkLocalFileListWithNextHost(sFiles)
   {
      var aServers = this._aCurrentDataBanks[dofus.utils.DofusTranslator.STANDARD_DATA_BANK];
      if(aServers.length < 1)
      {
         this.nonCriticalError("CHECK_LAST_VERSION_FAILED",this.TABULATION + this.TABULATION,true);
         this.loadLanguage();
         return undefined;
      }
      var oServer = aServers.shift();
      var sURL = oServer.url + sFiles;
      var loader = this;
      var oMCLoader = new MovieClipLoader();
      var oEventHandler = {};
      oEventHandler.onLoadInit = function(mc)
      {
         loader.loadLanguage();
         loader._bLocalFileListLoaded = true;
      };
      oEventHandler.onLoadError = function(mc)
      {
         loader.nonCriticalError(loader.getText("IMPOSSIBLE_TO_GET_FILE",[sURL]),loader.TABULATION + loader.TABULATION);
         loader.checkLocalFileListWithNextHost(sFiles);
      };
      oMCLoader.addListener(oEventHandler);
      this.log(this.TABULATION + this.getDataBankLogHeader(oServer.dataBankId) + this.getText("CHECKING_VERSIONS"));
      oMCLoader.loadClip(sURL,this._mcLocalFileList);
   }
   function loadXtra()
   {
      this.clearlogs();
      this.showLoader(true);
      this.showBanner(true);
      this.showMainLogger(false);
      this.showShowLogsButton(false);
      this.showConfigurationChoice(false);
      this.showNextButton(false);
      this.showContinueButton(false);
      this.showClearCacheButton(false);
      this.showCopyLogsButton(false);
      this.showProgressBar(false);
      this.launchBannerAnim(true);
      this.setTotalBarValue(0,100);
      this.showBasicInformations();
      if(!this.checkOccurences())
      {
         this.showShowLogsButton(false);
         this.showCopyLogsButton(false);
         return undefined;
      }
      this.logTitle(this.getText("LOAD_XTRA_FILES"));
      this.log(this.TABULATION + this.getText("CHECK_LAST_VERSION"));
      this._sStep = "XTRA";
      this.moveProgressBar(-60);
      var oApi = dofus.utils.Api.getInstance();
      if(oApi != undefined)
      {
         oApi.lang.clearSOXtraCache();
      }
      var aDataBanks = this.copyAndOrganizeDataBanks();
      this._aCurrentDataBanks = aDataBanks;
      this.showWaitBar(false);
      this._nTotalXtraFilesToLoad = 0;
      var aXtraFiles = _global.API.lang.getConfigText("XTRA_FILE");
      var nDatabankIndex = 0;
      while(nDatabankIndex < aDataBanks.length)
      {
         var oXtraSharedObject = this.getXtraSharedObject(nDatabankIndex);
         _global[dofus.Constants.GLOBAL_SO_XTRA_NAME + "_" + nDatabankIndex] = oXtraSharedObject;
         var oVersionData = oXtraSharedObject.data.VERSIONS;
         var nXtraIndex = 0;
         while(nXtraIndex < aXtraFiles.length)
         {
            var sXtraFile = aXtraFiles[nXtraIndex];
            var nXtraVersion = oVersionData[sXtraFile] != undefined ? oVersionData[sXtraFile] : 0;
            var aXtraVersionArray = this._aXtraCurrentVersion[nDatabankIndex];
            if(aXtraVersionArray == undefined)
            {
               aXtraVersionArray = [];
               this._aXtraCurrentVersion[nDatabankIndex] = aXtraVersionArray;
            }
            aXtraVersionArray[sXtraFile] = nXtraVersion;
            nXtraIndex = nXtraIndex + 1;
         }
         var aDistantFiles = this._aDistantFilesList[nDatabankIndex].split("|");
         this._aXtraList[nDatabankIndex] = aDistantFiles;
         this._nTotalXtraFilesToLoad += aDistantFiles.length;
         nDatabankIndex = nDatabankIndex + 1;
      }
      this._nRemainingXtraFilesToLoad = this._nTotalXtraFilesToLoad;
      var nLoaderIndex = 0;
      while(nLoaderIndex < aDataBanks.length)
      {
         this.updateNextXtra(nLoaderIndex);
         nLoaderIndex = nLoaderIndex + 1;
      }
   }
   function updateNextXtra(nDataBank)
   {
      var aXtraFiles = this._aXtraList[nDataBank];
      var aCurrentXtraFile = this._aCurrentXtraLoadFile[nDataBank];
      if(this._bSkipDistantLoad && aCurrentXtraFile != undefined)
      {
         aXtraFiles.push(aCurrentXtraFile);
      }
      if(aXtraFiles.length >= 1)
      {
         while(true)
         {
            if(aXtraFiles.length > 0)
            {
               this.setTotalBarValue(10 + (90 - 90 / this._nTotalXtraFilesToLoad * this._nRemainingXtraFilesToLoad),100);
               this._nRemainingXtraFilesToLoad = this._nRemainingXtraFilesToLoad - 1;
               var aXtraData = aXtraFiles.shift().split(",");
               this._aCurrentXtra[nDataBank] = aXtraData;
               if(aXtraFiles.length > 0 && aXtraData[2])
               {
                  if(!this._bSkipDistantLoad)
                  {
                     this._aCurrentXtraLoadFile[nDataBank] = aXtraData;
                  }
                  var sXtraName = aXtraData[0];
                  var sLanguage = aXtraData[1];
                  var sVersion = aXtraData[2];
                  if(sXtraName != "lang")
                  {
                     this._mcProgressBarGroup.txtInfo.text = sXtraName;
                     var nCurrentVersion = this._aXtraCurrentVersion[nDataBank][sXtraName];
                     if(!(! (_global.CONFIG.language == this.getLangSharedObject(nDataBank).data.LANGUAGE && Number(sVersion) == nCurrentVersion))
                     {
                        if(this._bLocalFileListLoaded)
                        {
                           if(this._bSkipDistantLoad)
                           {
                              if(this._aXtraCurrentVersion[nDataBank][sXtraName] != 0)
                              {
                                 continue;
                              }
                              sVersion = this._mcLocalFileList.VERSIONS[_global.CONFIG.language][sXtraName];
                           }
                           break;
                        }
                        if(this._bSkipDistantLoad)
                        {
                           return undefined;
                        }
                        break;
                     }
                  }
               }
               continue;
            }
            this.noMoreXtra();
         }
         this._bUpdate = true;
         aXtraData[3] = aXtraData[0] + "_" + aXtraData[1] + "_" + aXtraData[2];
         this.log(this.TABULATION + this.getDataBankLogHeader(nDataBank) + this.getText("UPDATE_FILE",[sXtraName]));
         this.showWaitBar(true);
         var oXtraLoader = new dofus.utils.LangFileLoader();
         oXtraLoader.addListener(this);
         if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
         {
            this.getURL("JavaScript:WriteLog(\'updateNextXtra;" + sXtraName + "_" + _global.CONFIG.language + "_" + sVersion + "\')");
         }
         var sXtraSOName = dofus.Constants.XTRA_SHAREDOBJECT_NAME + "_" + nDataBank;
         var aServers = this.copyAndOrganizeDataServersForDataBank(nDataBank);
         var mcContainer = this.getDataBankMcContainer(nDataBank);
         oXtraLoader.loadLangFile(aServers,"lang/swf/" + sXtraName + "_" + _global.CONFIG.language + "_" + sVersion + ".swf",mcContainer,sXtraSOName,sXtraName,_global.CONFIG.language,true);
         return undefined;
      }
      this.noMoreXtra();
   }
   function noMoreXtra()
   {
      var bHasMoreFiles = true;
      var nIndex = 0;
      while(nIndex < this._aXtraList.length)
      {
         var aFiles = this._aXtraList[nIndex];
         if(aFiles != undefined && aFiles.length > 0)
         {
            bHasMoreFiles = false;
            break;
         }
         nIndex = nIndex + 1;
      }
      if(!bHasMoreFiles)
      {
         return undefined;
      }
      this.logTitle(this.getText("INIT_END"));
      if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
      {
         this.getURL("JavaScript:WriteLog(\'XtraLangLoadEnd\')");
      }
      if((this._bNonCriticalError || this._bUpdate) && (dofus.Constants.DEBUG && (Key.isDown(Key.SHIFT) && dofus.Kernel.FAST_SWITCHING_SERVER_REQUEST == undefined)))
      {
         this.showBanner(false);
         this.showMainLogger();
         this.showNextButton(true);
         this.showCopyLogsButton(true);
         this.showShowLogsButton(true);
      }
      else
      {
         this.initAndLoginFinished();
      }
   }
   function initAndLoginFinished()
   {
      this.showLoader(false);
      _global.API.kernel.onInitAndLoginFinished();
      this._bNonCriticalError = false;
      this._bUpdate = false;
      this.launchBannerAnim(false);
      this.showBanner(false);
   }
   function checkCacheVersion()
   {
      var dCurrentDate = new Date();
      var sDateString = dCurrentDate.getFullYear() + "-" + (dCurrentDate.getMonth() + 1) + "-" + dCurrentDate.getDate();
      if(!this.getCacheDateSharedObject().data.clearDate)
      {
         this.clearCache();
         this.getCacheDateSharedObject().data.clearDate = sDateString;
         this.getCacheDateSharedObject().flush(100);
         return false;
      }
      var oLangData = _global[dofus.Constants.GLOBAL_SO_LANG_NAME + "_" + dofus.utils.DofusTranslator.STANDARD_DATA_BANK];
      if(oLangData && (oLangData.data.C.CLEAR_DATE && oLangData.data.C.ENABLED_AUTO_CLEARCACHE))
      {
         if(this.getCacheDateSharedObject().data.clearDate < oLangData.data.C.CLEAR_DATE)
         {
            this.clearCache();
            this.getCacheDateSharedObject().data.clearDate = oLangData.data.C.CLEAR_DATE;
            this.getCacheDateSharedObject().flush();
            this.reboot();
            return false;
         }
      }
      return true;
   }
   function onLoadStart(mc)
   {
      this.showWaitBar(false);
      this.setProgressBarValue(0,100);
   }
   function onTimedProgress(shit, ldr, target)
   {
      var oProgressData = ldr.getProgress(target);
      shit.setProgressBarValue(Number(oProgressData.bytesLoaded),Number(oProgressData.bytesTotal));
   }
   function onLoadError(mc, errorCode, httpStatus, oServer)
   {
      _global.clearInterval(this._timedProgress);
      this.showProgressBar(false);
      this.showWaitBar(false);
      var nDatabankId = oServer.dataBankId;
      switch(this._sStep)
      {
         case "LANG":
            if(oServer.type == "local")
            {
               this.log(this.TABULATION + this.TABULATION + this.getDataBankLogHeader(nDatabankId) + this.getText("NO_FILE_IN_LOCAL",["lang",oServer.url]));
            }
            else
            {
               if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
               {
                  this.getURL("JavaScript:WriteLog(\'onLoadError LANG-" + oServer.url + "lang" + "\')");
               }
               this.nonCriticalError(this.getText("IMPOSSIBLE_TO_DOWNLOAD_FILE",["lang",oServer.url]),this.TABULATION + this.TABULATION + this.getDataBankLogHeader(nDatabankId));
            }
            break;
         case "MODULE":
            if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
            {
               this.getURL("JavaScript:WriteLog(\'onLoadError MODULE-" + this._aCurrentModule[4] + "\')");
            }
            this.criticalError("IMPOSSIBLE_TO_LOAD_MODULE",this.TABULATION,true,[this._aCurrentModule[4]]);
            break;
         case "XTRA":
            var aCurrentExtraFile = this._aCurrentXtra[nDatabankId];
            if(oServer.type == "local")
            {
               this.log(this.TABULATION + this.TABULATION + this.getDataBankLogHeader(nDatabankId) + this.getText("NO_FILE_IN_LOCAL",[aCurrentExtraFile[3],oServer.url]));
            }
            else
            {
               if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
               {
                  this.getURL("JavaScript:WriteLog(\'onLoadError XTRA-" + oServer.url + aCurrentExtraFile[3] + "\')");
               }
               this.nonCriticalError(this.getText("IMPOSSIBLE_TO_DOWNLOAD_FILE",[aCurrentExtraFile[3],oServer.url]),this.TABULATION + this.TABULATION + this.getDataBankLogHeader(nDatabankId));
            }
      }
   }
   function onLoadComplete(mc)
   {
      _global.clearInterval(this._timedProgress);
      if(this._sStep == "MODULE")
      {
         _global["MODULE_" + this._aCurrentModule[4]] = mc;
      }
   }
   function onLoadInit(mc, oServer)
   {
      this.showProgressBar(false);
      var nDatabankId = oServer.dataBankId;
      switch(this._sStep)
      {
         case "LANG":
            this._nLoadedLangFiles = this._nLoadedLangFiles + 1;
            this.logGreen(this.TABULATION + this.getDataBankLogHeader(nDatabankId) + this.getText("UPDATE_FINISH",["lang",oServer.url]));
            if(this._aCurrentDataBanks.length == this._nLoadedLangFiles)
            {
               if(!this.checkCacheVersion())
               {
                  return undefined;
               }
               this.loadModules();
            }
            break;
         case "MODULE":
            this.log(this.TABULATION + this.getText("MODULE_LOADED",[this._aCurrentModule[4]]));
            if(!this.checkCacheVersion())
            {
               return undefined;
            }
            this.loadNextModule();
            break;
         case "XTRA":
            var aCurrentExtraFile = this._aCurrentXtra[nDatabankId];
            if(oServer.type == "local")
            {
               this.logGreen(this.TABULATION + this.TABULATION + this.getDataBankLogHeader(nDatabankId) + this.getText("FILE_LOADED",[aCurrentExtraFile[3],oServer.url]));
            }
            else
            {
               this.logGreen(this.TABULATION + this.TABULATION + this.getDataBankLogHeader(nDatabankId) + this.getText("UPDATE_FINISH",[aCurrentExtraFile[3],oServer.url]));
            }
            this._aCurrentXtraLoadFile[nDatabankId] = undefined;
            this.updateNextXtra(nDatabankId);
      }
   }
   function onCorruptFile(mc, totalBytes, oServer)
   {
      switch(this._sStep)
      {
         case "LANG":
            this.nonCriticalError(this.getText("CORRUPT_FILE",["lang",oServer.url,totalBytes]),this.TABULATION + this.TABULATION);
            break;
         case "XTRA":
            this.nonCriticalError(this.getText("CORRUPT_FILE",[this._aCurrentXtra[3],oServer.url,totalBytes]),this.TABULATION + this.TABULATION);
      }
   }
   function onCantWrite(mc)
   {
      switch(this._sStep)
      {
         case "LANG":
            this.criticalError("WRITE_FAILED",this.TABULATION + this.TABULATION,true,["lang"]);
            break;
         case "XTRA":
            this.criticalError("WRITE_FAILED",this.TABULATION + this.TABULATION,true,[this._aCurrentXtra[3]]);
      }
   }
   function onAllLoadFailed(mc)
   {
      this.showProgressBar(false);
      this.showWaitBar(false);
      if(dofus.Constants.USE_JS_LOG && _global.CONFIG.isNewAccount)
      {
         this.getURL("JavaScript:WriteLog(\'onAllLoadFailed;" + this._sStep + "\')");
      }
      switch(this._sStep)
      {
         case "LANG":
            if(!this._bSkipDistantLoad)
            {
               this.criticalError("CANT_UPDATE_FILE",this.TABULATION + this.TABULATION,true,["lang"]);
            }
            else
            {
               this.nonCriticalError("CANT_UPDATE_FILE",this.TABULATION + this.TABULATION,true,["lang"]);
            }
            this._bSkipDistantLoad = true;
            break;
         case "XTRA":
            this._bSkipDistantLoad = true;
            this.nonCriticalError("CANT_UPDATE_FILE",this.TABULATION + this.TABULATION,true,[this._aCurrentXtra[3]]);
            this.updateNextXtra();
      }
   }
   function onCoreDisplayed()
   {
      this.launchBannerAnim(false);
      this.showBanner(false);
      this.showLoader(false);
   }
}
