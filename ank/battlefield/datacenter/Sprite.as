/**
 * One-line class purpose:
 * Represents a battlefield **entity**’s data model, holding visual and state properties used to create
 * and manage a sprite from server-sourced data.
 * 
 * Short general description:
 * `Sprite` is a datacenter class that stores identifiers, graphics file paths, positioning, direction,
 * colors, accessories, and runtime flags. It is instantiated when the server sends entity data (e.g., character,
 * monster, NPC) and is consumed by rendering handlers to attach a visual `MovieClip` to the battlefield.
 *
 * Sprite Creation from Server Data process:
 * During “Sprite Creation from Server Data,” network handlers (e.g., `GameIn`) parse server messages
 * and delegate to managers like `CharactersManager` to construct a `Sprite` instance, passing server
 * fields (gfxID, cell, direction, colors, accessories). The `Sprite` constructor/`initialize` stores
 * these values; later, `SpriteHandler.addSprite` uses this data to create the visual on-screen
 * `ank.battlefield.mc.Sprite` clip.
 */

class ank.battlefield.datacenter.Sprite extends Object
{
   // Unique sprite identifier from server
   var id;
   // Visual class to instantiate (usually ank.battlefield.mc.Sprite)
   var clipClass;
   // Path to the SWF graphics file (e.g., from server gfxID)
   var _sGfxFile;
   // Initial cell number on the map
   var _nCellNum;
   // Initial facing direction (default 1)
   var _nDirection;
   // Animation/movement sequencer created at init
   var _oSequencer;
   // Movement flag (initialized to false)
   var _bInMove;
   // Visibility flag (initialized to true)
   var _bVisible;
   // Cleanup flag (initialized to false)
   var _bClear;
   // Container for linked child sprites
   var _eoLinkedChilds;
   // State map for sprite behaviors
   var _states;
   // Timestamp of creation (getTimer) for ordering
   var _nCreationInstant;
   var _sGfxFileName;
   var _oLinkedParent;
   var _oCarriedChild;
   var _oCarriedParent;
   var dispatchEvent;
   var _nStartAnimationTimer;
   var mc;
   // Color customization indices from server
   var _nColor1;
   var _nColor2;
   var _nColor3;
   // Accessory identifiers from server
   var _aAccessories;
   // Mount data when applicable
   var _oMount;
   static var ANGELS_OF_THE_WORLD_SPRITE_ID = "999";
   static var ANGELS_OF_THE_WORLD_REPLACEMENT_SPRITE_ID = "8023";
   var allowGhostMode = true;
   var bAnimLoop = false;
   var _nChildIndex = -1;
   var _nFutureCellNum = -1;
   var _sDefaultAnimation = "static";
   var _sStartAnimation = "static";
   var _nSpeedModerator = 1;
   var _bHidden = false;
   var _bAllDirections = true;
   var _bForceWalk = false;
   var _bForceRun = false;
   var _bNoFlip = false;
   var _bIsPendingClearing = false;
   var _bUncarryingSprite = false;
   var bInCreaturesMode = false;
   var _bIsInvisibleInFight = false;

   /**
    * Sprite
    * Purpose: Initializes a Sprite with server-provided identifiers and initial state.
    * Parameters:
    * `nID`: Server-sent unique sprite ID.
    * `fClipClass`: Visual clip class (typically `ank.battlefield.mc.Sprite`).
    * `sGfxFile`: Graphics SWF path derived from server gfxID.
    * `nCellNum`: Initial map cell number.
    * `nDir`: Initial direction (defaults to 1 if undefined).
    */
   function Sprite(nID, fClipClass, sGfxFile, nCellNum, nDir)
   {
      super();
      this.initialize(nID,fClipClass,sGfxFile,nCellNum,nDir);
   }


   /**
    * initialize
    * Purpose: Sets core properties and runtime structures from creation parameters.
    * Parameters: Same as constructor.
    * Data flow: Parameters populate instance fields; sequencer and event system prepared for later rendering and animation.
    */
   function initialize(sID, fClipClass, sGfxFile, nCellNum, nDir)
   {
      // Step 1: Assign id, clipClass, _sGfxFile
      this.id = sID;
      this.clipClass = fClipClass;
      this._sGfxFile = sGfxFile;

      // Step 2: Call refreshGfxFileName to extract filename from path
      this.refreshGfxFileName();

      // Step 3: Set _nCellNum and _nDirection (default to 1 if undefined)
      this._nCellNum = Number(nCellNum);
      this._nDirection = nDir != undefined ? Number(nDir) : 1;

      // Step 4: Create _oSequencer with 1000ms interval
      this._oSequencer = new ank.utils.Sequencer(1000);

      // Step 5: Initialize flags: _bInMove, _bVisible, _bClear
      this._bInMove = false;
      this._bVisible = true;
      this._bClear = false;

      // Step 6: Initialize _eoLinkedChilds and enable event dispatching
      this._eoLinkedChilds = new ank.utils.ExtendedObject();
      mx.events.EventDispatcher.initialize(this);

      // Step 7: Initialize _states object and record _nCreationInstant
      this._states = {};
      this._nCreationInstant = getTimer();
   }


   /**
    * refreshGfxFileName
    * Purpose: Derives the gfx filename from the full gfx path for identification.
    * Data flow: _sGfxFile → _sGfxFileName used by rendering checks (e.g., invader filtering).
    */
   function refreshGfxFileName()
   {
      // Step 1: Split _sGfxFile by "." then by "/" to isolate the last segment
      var _aPathSegments = this._sGfxFile.split(".")[0].split("/");
      // Step 2: Store result in _sGfxFileName
      this._sGfxFileName = _aPathSegments[_aPathSegments.length - 1];
   }

   function isLocalPlayer(api)
   {
      return this.id == api.datacenter.Player.ID;
   }
   function set uncarryingSprite(bUncarryingSprite)
   {
      this._bUncarryingSprite = bUncarryingSprite;
   }
   function get uncarryingSprite()
   {
      return this._bUncarryingSprite;
   }
   function get hasChilds()
   {
      return this._eoLinkedChilds.getLength() != 0;
   }
   function get hasParent()
   {
      return this.linkedParent != undefined;
   }
   function get childIndex()
   {
      return this._nChildIndex;
   }
   function set childIndex(nChildIndex)
   {
      this._nChildIndex = nChildIndex;
   }
   function get linkedChilds()
   {
      return this._eoLinkedChilds;
   }
   function get linkedParent()
   {
      return this._oLinkedParent;
   }
   function set linkedParent(oLinkedParent)
   {
      this._oLinkedParent = oLinkedParent;
   }
   function hasCarriedChild()
   {
      return this._oCarriedChild != undefined;
   }
   function hasCarriedParent()
   {
      return this._oCarriedParent != undefined;
   }
   function get carriedChild()
   {
      return this._oCarriedChild;
   }
   function set carriedChild(o)
   {
      this._oCarriedChild = o;
   }
   function get carriedParent()
   {
      return this._oCarriedParent;
   }
   function set carriedParent(o)
   {
      this._oCarriedParent = o;
   }
   function get creationInstant()
   {
      return this._nCreationInstant;
   }
   function get gfxFile()
   {
      return this._sGfxFile;
   }
   function set gfxFile(sGfxFile)
   {
      this.dispatchEvent({type:"gfxFileChanged",value:sGfxFile});
      this._sGfxFile = sGfxFile;
      this.refreshGfxFileName();
   }
   function get gfxFileName()
   {
      return this._sGfxFileName;
   }
   function get defaultAnimation()
   {
      return this._sDefaultAnimation;
   }
   function set defaultAnimation(value)
   {
      this._sDefaultAnimation = value;
   }
   function get startAnimation()
   {
      return this._sStartAnimation;
   }
   function set startAnimation(value)
   {
      this._sStartAnimation = value;
   }
   function get startAnimationTimer()
   {
      return this._nStartAnimationTimer;
   }
   function set startAnimationTimer(value)
   {
      this._nStartAnimationTimer = value;
   }
   function get speedModerator()
   {
      return this._nSpeedModerator;
   }
   function set speedModerator(value)
   {
      this._nSpeedModerator = Number(value);
   }
   function get isVisible()
   {
      return this._bVisible;
   }
   function set isVisible(value)
   {
      this._bVisible = value;
   }
   function get isInvisibleInFight()
   {
      return this._bIsInvisibleInFight;
   }
   function set isInvisibleInFight(bIsInvisibleInFight)
   {
      this._bIsInvisibleInFight = bIsInvisibleInFight;
   }
   function setInvisibleInFight(bIsInvisibleInFight)
   {
      this._bIsInvisibleInFight = bIsInvisibleInFight;
   }
   function get isHidden(Void)
   {
      return this._bHidden;
   }
   function set isHidden(value)
   {
      this.mc.isHidden = this._bHidden = value;
   }
   function get isInMove()
   {
      return this._bInMove;
   }
   function set isInMove(value)
   {
      if(!value)
      {
         this._nFutureCellNum = -1;
         this._sMoveSpeedType = undefined;
         this._sMoveAnimation = undefined;
      }
      this._bInMove = value;
      if(this.hasCarriedChild())
      {
         this.carriedChild.isInMove = value;
      }
   }
   function get moveSpeedType()
   {
      return this._sMoveSpeedType;
   }
   function set moveSpeedType(sMoveSpeedType)
   {
      this._sMoveSpeedType = sMoveSpeedType;
   }
   function get moveAnimation()
   {
      return this._sMoveAnimation;
   }
   function set moveAnimation(sMoveAnimation)
   {
      this._sMoveAnimation = sMoveAnimation;
   }
   function get isClear()
   {
      return this._bClear;
   }
   function set isClear(value)
   {
      this._bClear = value;
   }
   function get cellNum()
   {
      return this._nCellNum;
   }
   function set cellNum(value)
   {
      this._nCellNum = Number(value);
   }
   function get futureCellNum()
   {
      return this._nFutureCellNum;
   }
   function set futureCellNum(nFutureCellNum)
   {
      this._nFutureCellNum = nFutureCellNum;
   }
   function get direction()
   {
      return this._nDirection;
   }
   function set direction(value)
   {
      this._nDirection = Number(value);
   }
   function get color1()
   {
      return this._nColor1;
   }
   function set color1(value)
   {
      this._nColor1 = Number(value);
   }
   function get color2()
   {
      return this._nColor2;
   }
   function set color2(value)
   {
      this._nColor2 = Number(value);
   }
   function get color3()
   {
      return this._nColor3;
   }
   function set color3(value)
   {
      this._nColor3 = Number(value);
   }
   function get accessories()
   {
      return this._aAccessories;
   }
   function set accessories(value)
   {
      this.dispatchEvent({type:"accessoriesChanged",value:value});
      this._aAccessories = value;
   }
   function get sequencer()
   {
      return this._oSequencer;
   }
   function set sequencer(value)
   {
      this._oSequencer = value;
   }
   function get allDirections()
   {
      return this._bAllDirections;
   }
   function set allDirections(bAllDirections)
   {
      this._bAllDirections = bAllDirections;
   }
   function get forceWalk()
   {
      return this._bForceWalk;
   }
   function set forceWalk(bForceWalk)
   {
      this._bForceWalk = bForceWalk;
   }
   function get forceRun()
   {
      return this._bForceRun;
   }
   function set forceRun(bForceRun)
   {
      this._bForceRun = bForceRun;
   }
   function get noFlip()
   {
      return this._bNoFlip;
   }
   function set noFlip(bNoFlip)
   {
      this._bNoFlip = bNoFlip;
   }
   function get mount()
   {
      return this._oMount;
   }
   function set mount(v)
   {
      this._oMount = v;
   }
   function get isMounting()
   {
      return this._oMount != undefined;
   }
   function get isPendingClearing()
   {
      return this._bIsPendingClearing;
   }
   function set isPendingClearing(bIsPendingClearing)
   {
      this._bIsPendingClearing = bIsPendingClearing;
   }
   function get states()
   {
      return this._states;
   }
   function isInState(stateID)
   {
      return this._states[stateID] == true;
   }
   function setState(api, stateID, bActivate)
   {
      this._states[stateID] = bActivate;
      if(bActivate)
      {
         dofus.datacenter.States.onStateAdded(api,this,stateID);
      }
      else
      {
         dofus.datacenter.States.onStateRemoved(api,this,stateID);
      }
      this.dispatchEvent({type:"statesChanged",value:this._states});
   }
}
