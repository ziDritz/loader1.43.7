class ank.battlefield.mc.Sprite extends MovieClip
{
   // Field definitions with types and purposes
   // Number: optionally forced horizontal scale for rendering
   var _nForcedXScale;
   // MovieClip: container for sprite graphic loaded from asset
   var _mcGfx;
   // Object: data structure holding sprite state and configs
   var _oData;
   // MovieClip: clip used when carrying other sprites
   var _mcCarried;
   // MovieClip: position reference for chevauchor when mounted
   var _mcChevauchorPos;
   // Boolean: whether the sprite is hidden
   var _bHidden;
   // Battlefield reference managing this sprite
   var _mcBattlefield;
   // Collection of other sprites used for depth calculations
   var _oSprites;
   // MovieClipLoader instance for asynchronous loading
   var _mvlLoader;
   // Alias for action data (often same as _oData)
   var _ACTION;
   // Global API access object
   var api;
   // Extra background clip
   var _mcXtraBack;
   // Extra foreground clip
   var _mcXtraTop;
   // Remaining move distance
   var _nDistance;
   // Timestamp of last frame update during move
   var _nLastTimer;
   // Previous cell number used during map updates
   var _nOldCellNum;
   // Chevauchor clip when mounted
   var _mcChevauchor;
   // Placeholder for onEnterFrame handler
   var onEnterFrame;
   // EventDispatcher methods will be injected here
   var dispatchEvent;
   // Last alpha value saved when toggling ghost view
   var _nLastAlphaValue = 100;
   // Flags for graphic load completion
   var _bGfxLoaded = false;
   var _bChevauchorGfxLoaded = false;
   // Static speed definitions indexed by direction
   static var WALK_SPEEDS = [0.07,0.06,0.06,0.06,0.07,0.06,0.06,0.06];
   static var MOUNT_SPEEDS = [0.23,0.2,0.2,0.2,0.23,0.2,0.2,0.2];
   static var RUN_SPEEDS = [0.17,0.15,0.15,0.15,0.17,0.15,0.15,0.15];
   /**
    * Purpose: constructor initializes sprite instance with battlefield, sprite data collection, and sprite data object.
    * Parameters:
    *   b - battlefield reference used to position and manage sprite
    *   sd - sprite collection the sprite belongs to
    *   d - data object containing state and configuration for this sprite
    * Data flow: stores inputs into instance fields, registers sprite globally, calls initialize.
    */
   function Sprite(b, sd, d)
   {
      // 1. call parent constructor
      super();
      // 2. enable EventDispatcher on this object
      mx.events.EventDispatcher.initialize(this);
      // 3. perform further initialization
      this.initialize(b,sd,d);
   }
   /**
    * Purpose: setter for forced horizontal scale.
    * Parameters:
    *   nForcedXScale - Number to override the xscale of the sprite.
    * Data flow: updates _nForcedXScale and _xscale.
    */
   function set forcedXScale(nForcedXScale)
   {
      // 1. store value
      this._nForcedXScale = nForcedXScale;
      // 2. apply to display
      this._xscale = nForcedXScale;
   }
   /**
    * Purpose: access the graphic clip.
    * Parameters: none.
    * Data flow: returns _mcGfx.
    */
   function get gfx()
   {
      return this._mcGfx;
   }
   /**
    * Purpose: access the data object.
    * Parameters: none.
    * Data flow: returns _oData.
    */
   function get data()
   {
      return this._oData;
   }
   /**
    * Purpose: set the clip used when carrying another sprite.
    * Parameters:
    *   mc - MovieClip of carried object.
    * Data flow: stores mc in _mcCarried.
    */
   function set mcCarried(mc)
   {
      this._mcCarried = mc;
   }
   /**
    * Purpose: set the reference clip for chevauchor positioning.
    * Parameters:
    *   mc - MovieClip used as position marker.
    * Data flow: stores in _mcChevauchorPos.
    */
   function set mcChevauchorPos(mc)
   {
      this._mcChevauchorPos = mc;
   }
   /**
    * Purpose: wrapper setter to change hidden state.
    * Parameters:
    *   b - Boolean hidden flag.
    * Data flow: delegates to setHidden().
    */
   function set isHidden(b)
   {
      this.setHidden(b);
   }
   /**
    * Purpose: getter for hidden state.
    * Parameters: none.
    * Data flow: reads _bHidden.
    */
   function get isHidden()
   {
      return this._bHidden;
   }
   /**
    * Purpose: common initialization logic.
    * Parameters:
    *   b - battlefield reference
    *   sd - sprite collection
    *   d - data object for this sprite
    * Data flow: registers sprite, keeps references, sets position and draws graphics.
    */
   function initialize(b, sd, d)
   {
      // 1. register with global sprite controller
      _global.GAC.addSprite(this,d);
      // 2. store passed references
      this._mcBattlefield = b;
      this._oSprites = sd;
      this._oData = d;
      // 3. prepare loader and add listener
      this._mvlLoader = new MovieClipLoader();
      this._mvlLoader.addListener(this);
      // 4. position based on data cell
      this.setPosition(this._oData.cellNum);
      // 5. draw gfx
      this.draw();
      // 6. store action alias and api pointer
      this._ACTION = d;
      this.api = _global.API;
   }
   /**
    * Purpose: reload and display the sprite graphics.
    * Parameters: none.
    * Data flow: clears current clip, resets flags, and triggers loader.
    */
   function draw()
   {
      // 1. remove existing gfx clip
      this._mcGfx.removeMovieClip();
      // 2. create new empty clip for gfx
      this.createEmptyMovieClip("_mcGfx",20);
      // 3. respect hidden flag
      this.setHidden(this._bHidden);
      // 4. reset load state
      this._bGfxLoaded = false;
      this._bChevauchorGfxLoaded = false;
      // 5. start loading correct file (mount or normal)
      this._mvlLoader.loadClip(!!this._oData.isMounting ? this._oData.mount.gfxFile : this._oData.gfxFile,this._mcGfx);
   }
   /**
    * Purpose: remove sprite from battlefield and cleanup data.
    * Parameters: none.
    * Data flow: unregisters sprite, clears gfx, resets direction, removes extras.
    */
   function clear()
   {
      // 1. remove from cell registration
      this._mcBattlefield.mapHandler.getCellData(this._oData.cellNum).removeSpriteOnID(this._oData.id);
      // 2. remove graphic clip
      this._mcGfx.removeMovieClip();
      // 3. reset direction
      this._oData.direction = 1;
      // 4. remove any extra clips
      this.removeExtraClip();
      // 5. mark as cleared in data
      this._oData.isClear = true;
   }
   /**
    * Purpose: visually select or deselect the sprite.
    * Parameters:
    *   bool - true for selected highlight, false for normal.
    * Data flow: constructs transform and applies via setColorTransform.
    */
   function select(bool)
   {
      var _loc3_ = {};
      // 1. choose transform based on flag
      if(bool)
      {
         _loc3_ = {ra:60,rb:102,ga:60,gb:102,ba:60,bb:102};
      }
      else
      {
         _loc3_ = {ra:100,rb:0,ga:100,gb:0,ba:100,bb:0};
      }
      // 2. apply transform
      this.setColorTransform(_loc3_);
   }
   /**
    * Purpose: attach an extra clip either behind or above the sprite.
    * Parameters:
    *   sFile - String path to SWF or clip
    *   nColor - numeric tint color (optional)
    *   bTop - Boolean true for top layer, false for back
    * Data flow: updates _oData params and loads clip into appropriate container.
    */
   function addExtraClip(sFile, nColor, bTop)
   {
      // 1. exit if no file provided
      if(sFile == undefined)
      {
         return undefined;
      }
      // 2. default to back layer
      if(bTop == undefined)
      {
         bTop = false;
      }
      // 3. clear existing clip in that layer
      this.removeExtraClip(bTop);
      if(bTop)
      {
         var _loc5_ = {};
         _loc5_.file = sFile;
         _loc5_.color = nColor;
         this._oData.xtraClipTopParams = _loc5_;
         if(!this._bGfxLoaded)
         {
            return undefined;
         }
      }
      var _loc6_ = !bTop ? this._mcXtraBack : this._mcXtraTop;
      if(nColor != undefined)
      {
         var _loc7_ = new Color(_loc6_);
         _loc7_.setRGB(nColor);
      }
      _loc6_.loadMovie(sFile);
   }
   /**
    * Purpose: remove additional clips from sprite.
    * Parameters:
    *   bTop - true to remove top clip, false to remove back clip, undefined removes both.
    * Data flow: deletes existing clips and recreates empty placeholders.
    */
   function removeExtraClip(bTop)
   {
      switch(bTop)
      {
         case true:
            this._mcXtraTop.removeMovieClip();
            this.createEmptyMovieClip("_mcXtraTop",30);
            break;
         case false:
            this._mcXtraBack.removeMovieClip();
            this.createEmptyMovieClip("_mcXtraBack",10);
            break;
         default:
            this._mcXtraTop.removeMovieClip();
            this._mcXtraBack.removeMovieClip();
            this.createEmptyMovieClip("_mcXtraTop",30);
            this.createEmptyMovieClip("_mcXtraBack",10);
      }
   }
   /**
    * Purpose: apply a color transform object to the sprite.
    * Parameters:
    *   t - object containing transform fields.
    * Data flow: constructs Color and calls setTransform.
    */
   function setColorTransform(t)
   {
      var _loc3_ = new Color(this);
      _loc3_.setTransform(t);
   }
   /**
    * Purpose: update the cell number stored in data.
    * Parameters:
    *   nCellNum - new cell number
    * Data flow: coerces to Number and writes to _oData.cellNum.
    */
   function setNewCellNum(nCellNum)
   {
      this._oData.cellNum = Number(nCellNum);
   }
   /**
    * Purpose: change sprite facing direction and update animation.
    * Parameters:
    *   nDir - direction index 0..7 (optional).
    * Data flow: updates _oData.direction and calls setAnim.
    */
   function setDirection(nDir)
   {
      if(nDir == undefined)
      {
         nDir = this._oData.direction;
      }
      this._oData.direction = nDir;
      this.setAnim(this._oData.animation);
   }
   /**
    * Purpose: relocate sprite to specified cell and adjust coordinates.
    * Parameters:
    *   nCellNum - target cell number (optional).
    * Data flow: updates map registration, depth and _x/_y using mapHandler.
    */
   function setPosition(nCellNum)
   {
      this.updateMap(nCellNum,this._oData.isVisible);
      this.setDepth(nCellNum);
      if(nCellNum == undefined)
      {
         nCellNum = this._oData.cellNum;
      }
      else
      {
         this.setNewCellNum(nCellNum);
      }
      var _loc3_ = this._mcBattlefield.mapHandler.getCellData(nCellNum);
      var _loc4_ = this._mcBattlefield.mapHandler.getCellHeight(nCellNum);
      var _loc5_ = _loc4_ - Math.floor(_loc4_);
      this._x = _loc3_.x;
      this._y = _loc3_.y - _loc5_ * ank.battlefield.Constants.LEVEL_HEIGHT;
   }
   /**
    * Purpose: compute and set visual depth for rendering order.
    * Parameters:
    *   nCellNum - optional cell number to calculate depth.
    * Data flow: queries SpriteDepthFinder and swaps depths; adjusts carried child.
    */
   function setDepth(nCellNum)
   {
      if(nCellNum == undefined)
      {
         nCellNum = this._oData.cellNum;
      }
      var _loc3_ = ank.battlefield.utils.SpriteDepthFinder.getFreeDepthOnCell(this._mcBattlefield.mapHandler,this._oSprites,nCellNum,this._mcBattlefield.bGhostView);
      this.swapDepths(_loc3_);
      if(this._oData.hasCarriedChild())
      {
         this._oData.carriedChild.mc.setDepth(nCellNum);
      }
   }
   /**
    * Purpose: show or hide sprite and update map registration.
    * Parameters:
    *   bool - visibility flag.
    * Data flow: updates _oData.isVisible and display and calls updateMap.
    */
   function setVisible(bool)
   {
      this._oData.isVisible = bool;
      this._visible = bool;
      this.updateMap(this._oData.cellNum,bool);
   }
   /**
    * Purpose: set alpha transparency on gfx clip.
    * Parameters:
    *   value - numeric alpha percent.
    * Data flow: writes to _mcGfx._alpha.
    */
   function setAlpha(value)
   {
      this._mcGfx._alpha = value;
   }
   /**
    * Purpose: hide or show gfx by moving it offscreen.
    * Parameters:
    *   b - boolean hide flag.
    * Data flow: updates _bHidden and modifies _mcGfx coordinates and visibility.
    */
   function setHidden(b)
   {
      this._bHidden = b;
      if(this._bHidden)
      {
         this._mcGfx._x = this._mcGfx._y = -5000;
         this._mcGfx._visible = false;
      }
      else
      {
         this._mcGfx._x = this._mcGfx._y = 0;
         this._mcGfx._visible = true;
      }
   }
   /**
    * Purpose: toggle ghost view transparency.
    * Parameters:
    *   bool - true for ghost view, false to restore.
    * Data flow: updates depth and alpha using constants.
    */
   function setGhostView(bool)
   {
      this.setDepth();
      if(bool)
      {
         this._nLastAlphaValue = this._mcGfx._alpha;
         this.setAlpha(ank.battlefield.Constants.GHOSTVIEW_SPRITE_ALPHA);
      }
      else
      {
         this.setAlpha(this._nLastAlphaValue);
      }
   }
   /**
    * Purpose: move sprite from current cell to another with animation.
    * Parameters:
    *   seq - sequencer record for action callbacks
    *   cellNum - destination cell index
    *   bStop - whether to stop animation on arrival
    *   sSpeedType - movement type ("walk","run","slide")
    *   sAnimation - animation name to play during move
    *   bForceAnimation - force playing animation even if matching current
    * Data flow: calculates path, direction, speed adjustments, updates map and state, enqueues move loop.
    */
   function moveToCell(seq, cellNum, bStop, sSpeedType, sAnimation, bForceAnimation)
   {
      if(cellNum != this._oData.cellNum)
      {
         // 1. gather start and destination cell data
         var _loc8_ = this._mcBattlefield.mapHandler.getCellData(this._oData.cellNum);
         var _loc9_ = this._mcBattlefield.mapHandler.getCellData(cellNum);
         var _loc10_ = _loc9_.x;
         var _loc11_ = _loc9_.y;
         var _loc12_ = 0.01;
         // 2. adjust for slope
         if(_loc9_.groundSlope != 1)
         {
            _loc11_ -= ank.battlefield.Constants.HALF_LEVEL_HEIGHT;
         }
         // 3. compute new direction if needed
         if(sAnimation.toLowerCase() != "static")
         {
            this._oData.direction = ank.battlefield.utils.Pathfinding.getDirectionFromCoordinates(_loc8_.x,_loc8_.rootY,_loc10_,_loc9_.rootY,true);
         }
         var _loc13_ = this.api.electron.isWindowFocused;
         // 4. choose animation and base speed
         switch(sSpeedType)
         {
            case "slide":
               var _loc14_ = 0.25;
               if(_loc13_)
               {
                  this.setAnim(sAnimation);
               }
               else
               {
                  this.setAnim("static");
               }
               break;
            case "walk":
            default:
               _loc14_ = ank.battlefield.mc.Sprite.WALK_SPEEDS[this._oData.direction];
               if(_loc13_)
               {
                  this.setAnim(sAnimation != undefined ? sAnimation : "walk",undefined,bForceAnimation);
               }
               else
               {
                  this.setAnim("static");
               }
               break;
            case "run":
               _loc14_ = !!this._oData.isMounting ? ank.battlefield.mc.Sprite.MOUNT_SPEEDS[this._oData.direction] : ank.battlefield.mc.Sprite.RUN_SPEEDS[this._oData.direction];
               if(_loc13_)
               {
                  this.setAnim(sAnimation != undefined ? sAnimation : "run",undefined,bForceAnimation);
               }
               else
               {
                  this.setAnim("static");
               }
         }
         // 5. adjust speed for modifiers and terrain
         _loc14_ *= this._oData.speedModerator;
         if(_loc9_.groundLevel < _loc8_.groundLevel)
         {
            _loc14_ += _loc12_;
         }
         else if(_loc9_.groundLevel > _loc8_.groundLevel)
         {
            _loc14_ -= _loc12_;
         }
         else if(_loc8_.groundSlope != _loc9_.groundSlope)
         {
            if(_loc9_.groundSlope == 1)
            {
               _loc14_ += _loc12_;
            }
            else if(_loc8_.groundSlope == 1)
            {
               _loc14_ -= _loc12_;
            }
         }
         // 6. compute distance and vector
         this._nDistance = Math.sqrt(Math.pow(this._x - _loc10_,2) + Math.pow(this._y - _loc11_,2));
         var _loc15_ = Math.atan2(_loc11_ - this._y,_loc10_ - this._x);
         var _loc16_ = Math.cos(_loc15_);
         var _loc17_ = Math.sin(_loc15_);
         this._nLastTimer = getTimer();
         var _loc18_ = Number(cellNum) > this._oData.cellNum;
         // 7. update map registration and state
         this.updateMap(cellNum,this._oData.isVisible,true);
         this.setNewCellNum(cellNum);
         this._oData.isInMove = true;
         this._oData.moveSpeedType = sSpeedType;
         this._oData.moveAnimation = sAnimation;
         if(this._oData.hasCarriedChild())
         {
            var _loc19_ = this._oData.carriedChild;
            var _loc20_ = _loc19_.mc;
            _loc20_.setDirection(this._oData.direction);
            _loc20_.updateMap(cellNum,_loc19_.isVisible);
            _loc20_.setNewCellNum(cellNum);
         }
         if(_loc18_)
         {
            this.setDepth(cellNum);
         }
         // 8. enqueue movement loop
         ank.utils.CyclicExecutor.getInstance().addFunction(this,this,this.basicMove,[_loc14_,_loc16_,_loc17_],this,this.basicMoveEnd,[seq,_loc10_,_loc11_,cellNum,bStop,sSpeedType == "slide",!_loc18_]);
      }
      else
      {
         seq.onActionEnd();
      }
   }
   /**
    * Purpose: callback invoked repeatedly to perform incremental movement.
    * Parameters:
    *   speed - movement velocity per millisecond
    *   cosRot - cosine of movement direction
    *   sinRot - sine of movement direction
    * Data flow: updates position and remaining distance; returns whether to continue.
    */
   function basicMove(speed, cosRot, sinRot)
   {
      // 1. calculate elapsed time
      var _loc5_ = getTimer() - this._nLastTimer;
      // 2. compute step distance (capped)
      var _loc6_ = speed * (_loc5_ <= 125 ? _loc5_ : 125);
      // 3. advance coordinates
      this._x += _loc6_ * cosRot;
      this._y += _loc6_ * sinRot;
      // 4. decrement remaining distance
      this._nDistance -= _loc6_;
      // 5. update timer
      this._nLastTimer = getTimer();
      // 6. determine if movement should continue
      if(this._nDistance <= _loc6_)
      {
         return false;
      }
      return true;
   }
   /**
    * Purpose: finalize move and reset animation/state.
    * Parameters:
    *   seq - sequencer instance
    *   xDest, yDest - final coordinates
    *   cellNum - destination cell
    *   bStop - whether to stop animation
    *   bSlide - indicates slide type
    *   bSetDepth - whether to recalc depth
    * Data flow: cleans old cell, optionally snaps position, resets default animation, triggers seq end.
    */
   function basicMoveEnd(seq, xDest, yDest, cellNum, bStop, bSlide, bSetDepth)
   {
      if(this._nOldCellNum != undefined)
      {
         this._mcBattlefield.mapHandler.getCellData(this._nOldCellNum).removeSpriteOnID(this._oData.id);
         this._nOldCellNum = undefined;
      }
      if(bStop)
      {
         this._x = xDest;
         this._y = yDest;
         this._oData.isInMove = false;
         this.setAnim(this._oData.defaultAnimation);
         if(this.api.gfx.spriteHandler.isShowingMonstersTooltip && this.data instanceof dofus.datacenter.MonsterGroup)
         {
            this._rollOver(true);
         }
      }
      if(bSetDepth)
      {
         this.setDepth(cellNum);
      }
      seq.onActionEnd();
   }
   /**
    * Purpose: remember last animation name on clip(s).
    * Parameters:
    *   sAnim - animation string to store.
    * Data flow: stores on mcAnim of gfx or chevauchor clips.
    */
   function saveLastAnimation(sAnim)
   {
      if(!this._oData.isMounting)
      {
         this._mcGfx.mcAnim.lastAnimation = sAnim;
      }
      else
      {
         this._mcChevauchor.mcAnim.lastAnimation = sAnim;
         this._mcGfx.mcAnimFront.lastAnimation = sAnim;
         this._mcGfx.mcAnimBack.lastAnimation = sAnim;
      }
   }
   /**
    * Purpose: set animation and optionally revert after timer.
    * Parameters:
    *   anim - name to set
    *   bLoop - loop flag
    *   bForced - force change
    *   nTimer - milliseconds before reverting to default
    * Data flow: schedules Timer if timer valid.
    */
   function setAnimTimer(anim, bLoop, bForced, nTimer)
   {
      this.setAnim(anim,bLoop,bForced);
      if(_global.isNaN(Number(nTimer)))
      {
         return undefined;
      }
      if(nTimer < 1)
      {
         return undefined;
      }
      ank.utils.Timer.setTimer(this,"battlefield",this,this.setAnim,nTimer,[this._oData.defaultAnimation]);
   }
   /**
    * Purpose: convert cardinal direction char to index.
    * Parameters:
    *   sDir - direction letter ("S","R","F","L","B")
    * Data flow: returns numeric index or -1.
    */
   static function getDirNumByChar(sDir)
   {
      switch(sDir)
      {
         case "S":
            var _loc3_ = 0;
            break;
         case "R":
            _loc3_ = 1;
            break;
         case "F":
            _loc3_ = 2;
            break;
         case "L":
            _loc3_ = 5;
            break;
         case "B":
            _loc3_ = 6;
            break;
         default:
            _loc3_ = -1;
      }
      return _loc3_;
   }
   /**
    * Purpose: update the sprite's animation, handling direction and extras.
    * Parameters:
    *   anim - animation identifier (defaults to defaultAnimation)
    *   bLoop - boolean to loop animation
    *   bForced - boolean to force even if same anim
    * Data flow: updates _oData fields, attaches movie clips, handles mounting and carried children.
    */
   function setAnim(anim, bLoop, bForced)
   {
      if(this.api.datacenter.Game.isRunning)
      {
         var _loc5_ = this._oData.sequencer.getCurrentAction();
         if(_loc5_ != undefined && (_loc5_.object == this && (_loc5_.fn == this.setAnim && (_loc5_.waitEnd && (!_loc5_.forceTimeout && _loc5_.functionApplied)))))
         {
            return undefined;
         }
      }
      if(anim == undefined)
      {
         anim = this._oData.defaultAnimation;
      }
      anim = String(anim).toLowerCase();
      if(bLoop == undefined)
      {
         bLoop = false;
      }
      if(bForced == undefined)
      {
         bForced = false;
      }
      var _loc6_ = this._oData.noFlip;
      this._oData.bAnimLoop = bLoop;
      var mc = this._mcGfx;
      var _loc7_ = "";
      if(this._oData.hasCarriedChild())
      {
         _loc7_ += "_C";
      }
      var sFullAnim;
      var sDir;
      var nScale;
      switch(this._oData.direction)
      {
         case 0:
            sDir = "S";
            sFullAnim = anim + _loc7_ + sDir;
            var _loc8_ = "staticR";
            nScale = 100;
            break;
         case 1:
            sDir = "R";
            sFullAnim = anim + _loc7_ + sDir;
            _loc8_ = "staticR";
            nScale = 100;
            break;
         case 2:
            sDir = "F";
            sFullAnim = anim + _loc7_ + sDir;
            _loc8_ = "staticR";
            nScale = 100;
            break;
         case 3:
            sDir = "R";
            sFullAnim = anim + _loc7_ + sDir;
            _loc8_ = "staticR";
            if(!_loc6_)
            {
               nScale = -100;
            }
            break;
         case 4:
            sDir = "S";
            sFullAnim = anim + _loc7_ + sDir;
            _loc8_ = "staticL";
            if(!_loc6_)
            {
               nScale = -100;
            }
            break;
         case 5:
            sDir = "L";
            sFullAnim = anim + _loc7_ + sDir;
            _loc8_ = "staticL";
            nScale = 100;
            break;
         case 6:
            sDir = "B";
            sFullAnim = anim + _loc7_ + sDir;
            _loc8_ = "staticL";
            nScale = 100;
            break;
         case 7:
            sDir = "L";
            sFullAnim = anim + _loc7_ + sDir;
            _loc8_ = "staticL";
            if(!_loc6_)
            {
               nScale = -100;
            }
      }
      if(this._nForcedXScale != undefined)
      {
         nScale = this._nForcedXScale;
      }
      var _loc9_ = this._oData.fullAnimation;
      var sOldAnim = this._oData.animation;
      this._oData.animation = anim;
      this._oData.fullAnimation = sFullAnim;
      if(this._oData.xtraClipTopAnimations != undefined)
      {
         if(this._oData.xtraClipTopAnimations[sFullAnim])
         {
            this.addExtraClip(this._oData.xtraClipTopParams.file,this._oData.xtraClipTopParams.color,true);
         }
         else if(this._mcXtraTop != undefined)
         {
            this.removeExtraClip(true);
         }
      }
      if(bForced || sFullAnim != _loc9_)
      {
         var ref = this;
         var _loc10_ = mc.createEmptyMovieClip("mcAnimLoad",31);
         _loc10_._visible = false;
         if(!this._oData.isMounting)
         {
            _loc10_.onEnterFrame = function()
            {
               ref._xscale = nScale;
               var _loc2_ = mc.attachMovie(sFullAnim,"mcAnim",10,{lastAnimation:sOldAnim});
               if(_loc2_ == undefined)
               {
                  _loc2_ = mc.attachMovie("static" + sDir,"mcAnim",10,{lastAnimation:sOldAnim});
               }
               if(_loc2_ != undefined && ank.battlefield.Battlefield.useCacheAsBitmapOnStaticAnim)
               {
                  _loc2_.cacheAsBitmap = _loc2_._totalframes == 1;
               }
               this.removeMovieClip();
               delete this.onEnterFrame;
            };
         }
         else
         {
            _loc10_._visible = false;
            _loc10_.onEnterFrame = function()
            {
               ref._xscale = nScale;
               var _loc2_ = ref._mcChevauchor.attachMovie(sFullAnim,"mcAnim",1,{lastAnimation:sOldAnim});
               if(_loc2_ == undefined)
               {
                  _loc2_ = ref._mcChevauchor.attachMovie("static" + sDir,"mcAnim",1,{lastAnimation:sOldAnim});
               }
               if(_loc2_ == undefined)
               {
                  ref._mcChevauchor.mcAnim.removeMovieClip();
               }
               else if(ank.battlefield.Battlefield.useCacheAsBitmapOnStaticAnim)
               {
                  _loc2_.cacheAsBitmap = _loc2_._totalframes == 1;
               }
               _loc2_ = mc.attachMovie(sFullAnim + "_Front","mcAnimFront",30,{lastAnimation:sOldAnim});
               if(_loc2_ == undefined)
               {
                  _loc2_ = mc.attachMovie("static" + sDir + "_Front","mcAnimFront",30,{lastAnimation:sOldAnim});
               }
               if(_loc2_ == undefined)
               {
                  mc.mcAnimFront.removeMovieClip();
               }
               else if(ank.battlefield.Battlefield.useCacheAsBitmapOnStaticAnim)
               {
                  _loc2_.cacheAsBitmap = _loc2_._totalframes == 1;
               }
               _loc2_ = mc.attachMovie(sFullAnim + "_Back","mcAnimBack",10,{lastAnimation:sOldAnim});
               if(_loc2_ == undefined)
               {
                  _loc2_ = mc.attachMovie("static" + sDir + "_Back","mcAnimBack",10,{lastAnimation:sOldAnim});
               }
               if(_loc2_ == undefined)
               {
                  mc.mcAnimBack.removeMovieClip();
               }
               else if(ank.battlefield.Battlefield.useCacheAsBitmapOnStaticAnim)
               {
                  _loc2_.cacheAsBitmap = _loc2_._totalframes == 1;
               }
               if(ref._oData.isMounting)
               {
                  ank.utils.CyclicExecutor.getInstance().addFunction(ref,ref,ref.updateChevauchorPosition);
               }
               this.removeMovieClip();
               delete this.onEnterFrame;
            };
         }
      }
      else
      {
         this._xscale = nScale;
         if(this._oData.isMounting)
         {
            ank.utils.CyclicExecutor.getInstance().addFunction(this,this,this.updateChevauchorPosition);
         }
      }
      if(this._oData.hasCarriedChild())
      {
         ank.utils.CyclicExecutor.getInstance().addFunction(this,this,this.updateCarriedPosition);
      }
   }
   /**
    * Purpose: adjust carried child's position each frame.
    * Parameters: none.
    * Data flow: transforms coordinates and updates child clip; returns whether to continue updates.
    */
   function updateCarriedPosition()
   {
      if(this._oData.hasCarriedChild())
      {
         if(this._mcCarried != undefined)
         {
            var _loc2_ = {x:this._mcCarried._x,y:this._mcCarried._y};
            this._mcCarried._parent.localToGlobal(_loc2_);
            this._mcBattlefield.container.globalToLocal(_loc2_);
            this._oData.carriedChild.mc._x = _loc2_.x;
            this._oData.carriedChild.mc._y = _loc2_.y;
         }
      }
      return this._oData.animation != "static" || this._oData.isInMove;
   }
   /**
    * Purpose: maintain chevauchor offset for mounted sprites.
    * Parameters: none.
    * Data flow: converts coordinates and applies rotations/scales; returns continuation flag.
    */
   function updateChevauchorPosition()
   {
      if(this._oData.isMounting)
      {
         if(this._mcChevauchorPos != undefined)
         {
            var _loc2_ = {x:this._mcChevauchorPos._x,y:this._mcChevauchorPos._y};
            this._mcChevauchorPos._parent.localToGlobal(_loc2_);
            this._mcGfx.globalToLocal(_loc2_);
            this._mcChevauchor._x = _loc2_.x;
            this._mcChevauchor._y = _loc2_.y;
            this._mcChevauchor._rotation = this._mcChevauchorPos._rotation;
            this._mcChevauchor._xscale = this._mcChevauchorPos._xscale;
            this._mcChevauchor._yscale = this._mcChevauchorPos._yscale;
         }
      }
      return this._oData.animation != "static" || this._oData.isInMove;
   }
   /**
    * Purpose: update sprite registration on map cells, handling visibility.
    * Parameters:
    *   nCellNum - target cell
    *   bVisible - visibility flag
    *   bDontRemoveAllSpriteOn - keep old cell until later if true
    * Data flow: manipulates cell data add/remove methods.
    */
   function updateMap(nCellNum, bVisible, bDontRemoveAllSpriteOn)
   {
      var _loc5_ = this._mcBattlefield.mapHandler.getCellData(nCellNum);
      if(_loc5_ == undefined)
      {
         if(bVisible)
         {
            this._mcBattlefield.mapHandler.getCellData(this._oData.cellNum).addSpriteOnID(this._oData.id);
         }
         else
         {
            this._mcBattlefield.mapHandler.getCellData(this._oData.cellNum).removeSpriteOnID(this._oData.id);
         }
         return undefined;
      }
      if(bDontRemoveAllSpriteOn != true)
      {
         this._mcBattlefield.mapHandler.getCellData(this._oData.cellNum).removeSpriteOnID(this._oData.id);
      }
      else
      {
         this._nOldCellNum = this._oData.cellNum;
      }
      if(bVisible)
      {
         _loc5_.addSpriteOnID(this._oData.id);
      }
   }
   /**
    * Purpose: adjust gfx clip scaling.
    * Parameters:
    *   nScaleX - xscale percentage
    *   nScaleY - yscale percentage (defaults to nScaleX)
    * Data flow: sets _xscale and _yscale on _mcGfx.
    */
   function setScale(nScaleX, nScaleY)
   {
      this._mcGfx._xscale = nScaleX;
      this._mcGfx._yscale = nScaleY == undefined ? nScaleX : nScaleY;
   }
   /**
    * Purpose: loader callback for initialization completion.
    * Parameters:
    *   mc - loaded movie clip
    * Data flow: manages load flags, starts animations once fully loaded, dispatches event.
    */
   function onLoadInit(mc)
   {
      this.onEnterFrame = function()
      {
         if(!this._bGfxLoaded)
         {
            this._bGfxLoaded = true;
            if(this._oData.isMounting)
            {
               this._mcChevauchor = this._mcGfx.createEmptyMovieClip("chevauchor",20);
               this._mvlLoader.loadClip(this._oData.mount.chevauchorGfxFile,this._mcChevauchor);
            }
         }
         else
         {
            this._bChevauchorGfxLoaded = true;
         }
         if(this._bGfxLoaded && (!this._oData.isMounting || this._bChevauchorGfxLoaded))
         {
            if(_global.isNaN(Number(this._oData.startAnimationTimer)))
            {
               this.setAnim(this._oData.startAnimation,undefined,true);
            }
            else
            {
               this.setAnimTimer(this._oData.startAnimation,false,false,this._oData.startAnimationTimer);
            }
            delete this.onEnterFrame;
         }
      };
      this.dispatchEvent({type:"onLoadInit",clip:this});
   }
   /**
    * Purpose: forward release (click) event to battlefield handler.
    * Parameters:
    *   Void - unused
    * Data flow: calls battlefield.onSpriteRelease().
    */
   function _release(Void)
   {
      this._mcBattlefield.onSpriteRelease(this);
   }
   /**
    * Purpose: forward rollOver event to battlefield handler.
    * Parameters:
    *   bFakeEvent - whether event is synthetic
    * Data flow: calls battlefield.onSpriteRollOver().
    */
   function _rollOver(bFakeEvent)
   {
      this._mcBattlefield.onSpriteRollOver(this,bFakeEvent);
   }
   /**
    * Purpose: forward rollOut event to battlefield handler.
    * Parameters:
    *   bFakeEvent - whether event is synthetic
    * Data flow: calls battlefield.onSpriteRollOut().
    */
   function _rollOut(bFakeEvent)
   {
      this._mcBattlefield.onSpriteRollOut(this,bFakeEvent);
   }
}
