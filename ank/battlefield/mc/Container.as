class ank.battlefield.mc.Container extends MovieClip
{
   var _mcBattlefield;
   var _oDatacenter;
   var _sObjectsFile;
   var maxDepth;
   var minDepth;
   var ExternalContainer;
   var SpriteInfos;
   var Points;
   var Text;
   var OverHead;
   var LoadManager;
   var _mcMask;
   function Container(b, d, ofile)
   {
      super();
      if(b != undefined)
      {
         this.initialize(b,d,ofile);
      }
   }
   function initialize(b, d, ofile)
   {
      if(d == undefined)
      {
         ank.utils.Logger.err("pas de _oDatacenter !");
      }
      this._mcBattlefield = b;
      this._oDatacenter = d;
      this._sObjectsFile = ofile;
      this.clear(true);
   }
   function clear(bForceReload)
   {
      this.maxDepth = 0;
      this.minDepth = -1000;
      this.zoom(100);
      if(this.ExternalContainer == undefined || bForceReload)
      {
         this.createEmptyMovieClip("ExternalContainer",100);
         var _loc3_ = new MovieClipLoader();
         _loc3_.addListener(this._parent);
         if(bForceReload)
         {
            this.ExternalContainer.clear();
         }
         _loc3_.loadClip(this._sObjectsFile,this.ExternalContainer);
      }
      else
      {
         this.ExternalContainer.clear();
      }
      this.SpriteInfos.removeMovieClip();
      this.createEmptyMovieClip("SpriteInfos",200);
      this.Points.removeMovieClip();
      this.createEmptyMovieClip("Points",300);
      this.Text.removeMovieClip();
      this.createEmptyMovieClip("Text",400);
      this.OverHead.removeMovieClip();
      this.createEmptyMovieClip("OverHead",500);
      if(!this.LoadManager)
      {
         this.createEmptyMovieClip("LoadManager",600);
      }
   }
   function applyMask(bFilled:Boolean)
   {
      // Maximum X cell index of the map (width in cells - 1)
      var nMapMaxX:Number = this._oDatacenter.Map.width - 1;

      // Maximum Y cell index of the map (height in cells - 1)
      var nMapMaxY:Number = this._oDatacenter.Map.height - 1;

      // Default behavior: create a filled (visible) mask
      if (bFilled == undefined)
      {
         bFilled = true;
      }

      // Create the movie clip that will be used as a mask
      this.createEmptyMovieClip("_mcMask", 10);

      if (bFilled)
      {
         // Draw a filled rectangle covering the entire map area
         this._mcMask.beginFill(0);

         // Start drawing from the top-left corner
         this._mcMask.moveTo(0, 0);

         // Top edge
         this._mcMask.lineTo(
            nMapMaxX * ank.battlefield.Constants.CELL_WIDTH,
            0
         );

         // Right edge
         this._mcMask.lineTo(
            nMapMaxX * ank.battlefield.Constants.CELL_WIDTH,
            nMapMaxY * ank.battlefield.Constants.CELL_HEIGHT
         );

         // Bottom edge
         this._mcMask.lineTo(
            0,
            nMapMaxY * ank.battlefield.Constants.CELL_HEIGHT
         );

         // Close the rectangle
         this._mcMask.lineTo(0, 0);

         this._mcMask.endFill();
      }
      else
      {
         // Draw a tiny rectangle far outside the visible area
         // This effectively hides everything when used as a mask
         this._mcMask.beginFill(0);
         this._mcMask.moveTo(-1000, -1000);
         this._mcMask.lineTo(-1000, -999);
         this._mcMask.lineTo(-999, -999);
         this._mcMask.lineTo(-999, -1000);
         this._mcMask.lineTo(-1000, -1000);
         this._mcMask.endFill();
      }

      // Apply the mask to the current movie clip
      this.setMask(this._mcMask);
   }

   function adjusteMap(Void)
   {
      this.zoomMap();
      this.center();
   }
   function setColor(oTransform)
   {
      if(oTransform == undefined)
      {
         oTransform = {};
         oTransform.ra = 100;
         oTransform.rb = 0;
         oTransform.ga = 100;
         oTransform.gb = 0;
         oTransform.ba = 100;
         oTransform.bb = 0;
      }
      var _loc3_ = new Color(this);
      _loc3_.setTransform(oTransform);
   }
   function zoom(zFactor)
   {
      this._xscale = zFactor;
      this._yscale = zFactor;
   }
   function getZoom()
   {
      return this._xscale;
   }
   function setXY(x, y)
   {
      this._x = x;
      this._y = y;
   }
   function center(Void)
   {
      // Current horizontal scale factor (1.0 = 100%)
      var nScaleX:Number = this._xscale / 100;

      // Current vertical scale factor (1.0 = 100%)
      var nScaleY:Number = this._yscale / 100;

      // X offset needed to horizontally center the map on screen
      var nCenterOffsetX:Number =
         (this._mcBattlefield.screenWidth
         - ank.battlefield.Constants.CELL_WIDTH * nScaleX * (this._oDatacenter.Map.width - 1))
         / 2;

      // Y offset needed to vertically center the map on screen
      var nCenterOffsetY:Number =
         (this._mcBattlefield.screenHeight
         - ank.battlefield.Constants.CELL_HEIGHT * nScaleY * (this._oDatacenter.Map.height - 1))
         / 2;

      // Move the map to the computed centered position
      this.setXY(nCenterOffsetX, nCenterOffsetY);
   }
   function zoomMap(Void)
   {
      var _loc3_ = this.getZoomFactor();
      if(_loc3_ == 100)
      {
         return false;
      }
      this.zoom(_loc3_,false);
      return true;
   }
   function getZoomFactor(Void)
   {
      var _loc3_ = this._oDatacenter.Map.width;
      var _loc4_ = this._oDatacenter.Map.height;
      var _loc5_ = 0;
      if(_loc3_ <= ank.battlefield.Constants.DEFAULT_MAP_WIDTH)
      {
         return 100;
      }
      if(_loc4_ <= ank.battlefield.Constants.DEFAULT_MAP_HEIGHT)
      {
         return 100;
      }
      if(_loc4_ > _loc3_)
      {
         _loc5_ = this._mcBattlefield.screenWidth / (ank.battlefield.Constants.CELL_WIDTH * (_loc3_ - 1)) * 100;
      }
      else
      {
         _loc5_ = this._mcBattlefield.screenHeight / (ank.battlefield.Constants.CELL_HEIGHT * (_loc4_ - 1)) * 100;
      }
      return _loc5_;
   }
}
