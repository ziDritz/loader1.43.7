class dofus.utils.Api extends Object
{
   var _oConfig;
   var _oKernel;
   var _oDatacenter;
   var _oNetwork;
   var _oGfx;
   var _oUI;
   var _oSounds;
   var _oLang;
   var _oColors;
   var _oElectron;
   var _oMouseClicksMemorizer;
   static var _oLastInstance;
   function Api()
   {
      super();
      dofus.utils.Api._oLastInstance = this;
   }
   static function getInstance()
   {
      return dofus.utils.Api._oLastInstance;
   }
   function get config()
   {
      return this._oConfig;
   }
   function get kernel()
   {
      return this._oKernel;
   }
   function get datacenter()
   {
      return this._oDatacenter;
   }
   function get network()
   {
      return this._oNetwork;
   }
   function get gfx()
   {
      return this._oGfx;
   }
   function get ui()
   {
      return this._oUI;
   }
   function get sounds()
   {
      return this._oSounds;
   }
   function get lang()
   {
      return this._oLang;
   }
   function get colors()
   {
      return this._oColors;
   }
   function get electron()
   {
      return this._oElectron;
   }
   function get mouseClicksMemorizer()
   {
      return this._oMouseClicksMemorizer;
   }
   function initialize()
   {
      this._oConfig = _global.CONFIG;
      this._oLang = new dofus.utils.DofusTranslator();
      var _mcRootClip = dofus.DofusCore.getClip();
      this._oUI = _mcRootClip.GAPI;
      this._oUI.api = this;
      this._oElectron = new dofus.Electron(this);
      this._oKernel = new dofus.Kernel(this);
      this._oSounds = dofus.sounds.AudioManager.getInstance();
      _global.SOMA = this._oSounds;
      this._oDatacenter = new dofus.datacenter.Datacenter(this);
      this._oNetwork = new dofus.aks.Aks(this);
      this._oGfx = _mcRootClip.BATTLEFIELD;
      if(this._oConfig.isStreaming && this._oConfig.streamingMethod == "explod")
      {
         this._oGfx.initialize(this._oDatacenter,dofus.Constants.OBJECTS_LIGHT_FILE,dofus.Constants.OBJECTS_LIGHT_FILE,dofus.Constants.ACCESSORIES_PATH,this);
      }
      else
      {
         this._oGfx.initialize(this._oDatacenter,dofus.Constants.GROUND_FILE,dofus.Constants.OBJECTS_FILE,dofus.Constants.ACCESSORIES_PATH,this);
      }
      this._oColors = _global.GAC;
      this._oConfig.languages = this._oLang.getConfigText("LANGUAGES_LIST");
      this._oMouseClicksMemorizer = new ank.utils.MouseClicksMemorizer();
      _root.menu = new ank.gapi.controls.RightClickContextMenu(this);
      if(this.ui.getUIComponent("Zoom") == undefined)
      {
         this.ui.loadUIComponent("Zoom","Zoom");
      }
   }
   function checkFileSize(sFile, nCheckID)
   {
      var _aParts = sFile.split("*");
      sFile = _aParts[0];
      var arg = "";
      if(_aParts.length > 1)
      {
         arg = _aParts[1];
      }
      var _bShouldCheck = !this.datacenter.Player.isAuthorized && (!this.datacenter.Player.isSkippingFightAnimations && (!this.datacenter.Player.isSkippingLootPanel && this.ui.getUIComponent("Debug") == undefined));
      if(_bShouldCheck)
      {
         var _sServerIp = _global.CONFIG.connexionServer.ip;
         if(_sServerIp == undefined)
         {
            _sServerIp = this.datacenter.Basics.serverHost;
         }
         if(_sServerIp != undefined && (_sServerIp.indexOf("127.0.0.1") == 0 || _sServerIp.indexOf("192.168") == 0))
         {
            _bShouldCheck = !_bShouldCheck;
         }
      }
      var nAddition = !!_bShouldCheck ? -10 : 0;
      var _oCallbacks = {};
      var ref = this;
      _oCallbacks.onLoadInit = function(mc, httpStatus)
      {
         var _nFileBytesTotal = mc.getBytesTotal() + nAddition;
         var _sChallengeProp = "CHALLENGE";
         var _oChallengeFunction = mc[_sChallengeProp];
         if(_oChallengeFunction != undefined)
         {
            var _bFoundDataServer = false;
            var _nServerIndex = 0;
            while(_nServerIndex < ref.config.dataServers.length)
            {
               if(sFile.indexOf(ref.config.dataServers[_nServerIndex].url) == 0)
               {
                  _bFoundDataServer = true;
               }
               _nServerIndex = _nServerIndex + 1;
            }
            if(_bFoundDataServer)
            {
               var _nChallengeValue = Number(_oChallengeFunction.apply(ref,[_root,_global,sFile,nCheckID,arg]));
               if(_global.isNaN(_nChallengeValue))
               {
                  mc.removeMovieClip();
                  return undefined;
               }
               _nFileBytesTotal = _nChallengeValue;
            }
         }
         ref.onFileCheckFinished(true,_nFileBytesTotal,nCheckID);
         mc.removeMovieClip();
      };
      _oCallbacks.onLoadError = function(mc, errorCode, httpStatus)
      {
         var _nFileBytesTotal = mc.getBytesTotal() + nAddition;
         ref.onFileCheckFinished(true,_nFileBytesTotal,nCheckID);
         mc.removeMovieClip();
      };
      var _mcTempContainer = dofus.DofusCore.getInstance().getTemporaryContainer();
      var _mcFileClip = _mcTempContainer.createEmptyMovieClip("FC" + nCheckID,_mcTempContainer.getNextHighestDepth());
      var _oLoader = new MovieClipLoader();
      _oLoader.addListener(_oCallbacks);
      _oLoader.loadClip(sFile,_mcFileClip);
   }
   function onFileCheckFinished(bSuccess, nFileSize, nCheckID)
   {
      this.network.Basics.fileCheckAnswer(nCheckID,!bSuccess ? -1 : nFileSize);
   }
}
