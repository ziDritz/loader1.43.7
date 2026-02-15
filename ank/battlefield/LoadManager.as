class ank.battlefield.LoadManager extends MovieClip
{
   var _mcMainContainer:MovieClip;
   var dispatchEvent;
   static var _aMovieClipLoader:Array;
   static var MAX_PARALLELE_LOAD:Number = 3;
   static var STATE_WAITING:Number = 0;
   static var STATE_LOADING:Number = 1;
   static var STATE_LOADED:Number = 2;
   static var STATE_ERROR:Number = -1;
   static var STATE_UNKNOWN:Number = -1;

   function LoadManager(mcMainContainer:MovieClip)
   {
      super();
      this.initialize(mcMainContainer);
   }

   function processLoad()
   {
      var nIndex:Number = 0;
      while(nIndex < ank.battlefield.LoadManager._aMovieClipLoader.length)
      {
         if(this.waitingRequest > ank.battlefield.LoadManager.MAX_PARALLELE_LOAD)
         {
            return undefined;
         }

         var oLoaderEntry:Object = ank.battlefield.LoadManager._aMovieClipLoader[nIndex];
         if(oLoaderEntry.state == ank.battlefield.LoadManager.STATE_WAITING)
         {
            oLoaderEntry.state = ank.battlefield.LoadManager.STATE_LOADING;
            oLoaderEntry.loader.loadClip(oLoaderEntry.file, oLoaderEntry.container);
         }
         nIndex++;
      }
   }

   function getFileByMc(mcContainer:MovieClip):Object
   {
      var nIndex:Number = 0;
      while(nIndex < ank.battlefield.LoadManager._aMovieClipLoader.length)
      {
         var oLoaderEntry:Object = ank.battlefield.LoadManager._aMovieClipLoader[nIndex];
         if(oLoaderEntry.container === mcContainer)
         {
            return oLoaderEntry;
         }
         nIndex++;
      }
      return undefined;
   }

   function getFileByName(sFile:String):Object
   {
      var nIndex:Number = 0;
      while(nIndex < ank.battlefield.LoadManager._aMovieClipLoader.length)
      {
         var oLoaderEntry:Object = ank.battlefield.LoadManager._aMovieClipLoader[nIndex];
         if(oLoaderEntry.file == sFile)
         {
            return oLoaderEntry;
         }
         nIndex++;
      }
      return undefined;
   }

   function initialize(mcMainContainer:MovieClip)
   {
      mx.events.EventDispatcher.initialize(this);
      ank.battlefield.LoadManager._aMovieClipLoader = [];
      this._mcMainContainer = mcMainContainer;
   }

   function loadFile(sFile:String)
   {
      if(this.isRegister(sFile))
      {
         if(!this.isLoaded(sFile))
         {
            return undefined;
         }
         this.onFileLoaded(sFile);
      }
      else
      {
         var oLoaderEntry:Object = {};
         oLoaderEntry.file = sFile;
         oLoaderEntry.bitLoaded = 0;
         oLoaderEntry.bitTotal = 1;
         oLoaderEntry.state = ank.battlefield.LoadManager.STATE_WAITING;
         oLoaderEntry.loader = new MovieClipLoader();

         var selfRef = this;
         oLoaderEntry.loader.addListener(selfRef);

         oLoaderEntry.container = this._mcMainContainer.createEmptyMovieClip(
            sFile.split("/").join("_").split(".").join("_"),
            this._mcMainContainer.getNextHighestDepth()
         );

         ank.battlefield.LoadManager._aMovieClipLoader.push(oLoaderEntry);

         if(this.waitingRequest > ank.battlefield.LoadManager.MAX_PARALLELE_LOAD)
         {
            return undefined;
         }

         oLoaderEntry.state = ank.battlefield.LoadManager.STATE_LOADING;
         oLoaderEntry.loader.loadClip(sFile, oLoaderEntry.container);
      }
   }

   function loadFiles(aFiles:Array)
   {
      var nIndex:Number = 0;
      while(nIndex < aFiles.length)
      {
         this.loadFile(aFiles[nIndex]);
         nIndex++;
      }
   }

   function get waitingRequest():Number
   {
      var nCount:Number = 0;
      var nIndex:Number = 0;
      while(nIndex < ank.battlefield.LoadManager._aMovieClipLoader.length)
      {
         var oLoaderEntry:Object = ank.battlefield.LoadManager._aMovieClipLoader[nIndex];
         if(oLoaderEntry.state == ank.battlefield.LoadManager.STATE_LOADING)
         {
            nCount++;
         }
         nIndex++;
      }
      return nCount;
   }

   function isRegister(sFile:String):Boolean
   {
      var nIndex:Number = 0;
      while(nIndex < ank.battlefield.LoadManager._aMovieClipLoader.length)
      {
         var oLoaderEntry:Object = ank.battlefield.LoadManager._aMovieClipLoader[nIndex];
         if(sFile == oLoaderEntry.file)
         {
            return true;
         }
         nIndex++;
      }
      return false;
   }

   function isLoaded(sFile:String):Boolean
   {
      if(!this.isRegister(sFile))
      {
         return false;
      }

      var nIndex:Number = 0;
      while(nIndex < ank.battlefield.LoadManager._aMovieClipLoader.length)
      {
         var oLoaderEntry:Object = ank.battlefield.LoadManager._aMovieClipLoader[nIndex];
         if(sFile == oLoaderEntry.file)
         {
            return oLoaderEntry.state == ank.battlefield.LoadManager.STATE_LOADED;
         }
         nIndex++;
      }
   }

   function areRegister(aFiles:Array):Boolean
   {
      var bAllRegistered:Boolean = aFiles.length > 0;
      var nIndex:Number = 0;
      while(nIndex < aFiles.length && bAllRegistered)
      {
         bAllRegistered = bAllRegistered && this.isRegister(aFiles[nIndex]);
         nIndex++;
      }
      return bAllRegistered;
   }

   function areLoaded(aFiles:Array):Boolean
   {
      if(!this.areRegister(aFiles))
      {
         return false;
      }

      var bAllLoaded:Boolean = aFiles.length > 0;
      var nIndex:Number = 0;
      while(nIndex < aFiles.length && bAllLoaded)
      {
         bAllLoaded = bAllLoaded && this.isLoaded(aFiles[nIndex]);
         nIndex++;
      }
      return bAllLoaded;
   }

   function getFileState(sFile:String):Number
   {
      var oLoaderEntry:Object = this.getFileByName(sFile);
      if(oLoaderEntry)
      {
         return oLoaderEntry.state;
      }
      return ank.battlefield.LoadManager.STATE_UNKNOWN;
   }

   function getProgression(sFile:String):Number
   {
      var oLoaderEntry:Object = this.getFileByName(sFile);
      if(!oLoaderEntry)
      {
         return undefined;
      }
      if(oLoaderEntry.state == ank.battlefield.LoadManager.STATE_LOADED)
      {
         return 100;
      }
      return Math.floor(oLoaderEntry.bitLoaded / oLoaderEntry.bitTotal * 100);
   }

   function getProgressions(aFiles:Array):Number
   {
      var nTotalProgress:Number = 0;
      var nIndex:Number = 0;
      while(nIndex < aFiles.length)
      {
         var nProgression:Number = this.getProgression(aFiles[nIndex]);
         if(nProgression == undefined)
         {
            return undefined;
         }
         nTotalProgress += nProgression;
         nIndex++;
      }
      return Math.floor(nTotalProgress / aFiles.length);
   }

   function onFileLoaded(sFile:String)
   {
      this.dispatchEvent({type:"onFileLoaded", value:sFile});
   }

   function onLoadError(mcContainer:MovieClip)
   {
      var oLoaderEntry:Object = this.getFileByMc(mcContainer);
      oLoaderEntry.state = ank.battlefield.LoadManager.STATE_ERROR;
      delete oLoaderEntry.loader;
      this.processLoad();
   }

   function onLoadInit(mcContainer:MovieClip)
   {
      var oLoaderEntry:Object = this.getFileByMc(mcContainer);
      oLoaderEntry.state = ank.battlefield.LoadManager.STATE_LOADED;
      delete oLoaderEntry.loader;
      this.onFileLoaded(oLoaderEntry.file);
      this.processLoad();
   }

   function onLoadProgress(mcContainer:MovieClip, nBitLoaded:Number, nBitTotal:Number)
   {
      var oLoaderEntry:Object = this.getFileByMc(mcContainer);
      if(!oLoaderEntry)
      {
         return undefined;
      }
      oLoaderEntry.bitLoaded = nBitLoaded;
      oLoaderEntry.bitTotal = nBitTotal;
   }
}
