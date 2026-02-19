/**
 * One-line class purpose
 * `Battlefield` serves as the main container and coordinator for rendering operations,
 * including sprite creation and management from server data on the isometric battlefield.
 *
 * In Sprite Create from Server Data process
 * The sprite creation process in Battlefield.as follows a delegation pattern where Battlefield
 * methods act as facades to **SpriteHandler** operations. Server data flows through the datacenter
 * and is processed by specialized handlers. The actual sprite rendering and MovieClip creation happens
 * in SpriteHandler and the Sprite MC class, which are not covered here but are essential to the
 * complete sprite creation workflow.
 */


class ank.battlefield.Battlefield extends MovieClip
{
   // Boolean: true when the map has finished building and is ready for rendering
   var _bMapBuild;
   // Number: configured screen width (px), fallbacks to constant if undefined
   var _nScreenWidth;
   // Number: configured screen height (px), fallbacks to constant if undefined
   var _nScreenHeight;
   // MovieClip: main visual container that holds the map and sprite layers
   var _mcMainContainer;
   // Object: central data storage for map, sprites, etc.
   var _oDatacenter;
   // String: path to the ground graphics SWF file
   var _sGroundFile;
   // Function callback triggered when initialization fails
   var onInitError;
   // Function reference used to attach class movie clips to this timeline
   var attachClassMovie;
   // LoadManager instance for tracking resource loading operations
   var loadManager;
   // FightPointAnimManager: handles floating point animations during fights
   var fightPointAnimManager;
   // String: path to the object graphics SWF file
   var _sObjectFile;
   // GridHandler instance for drawing map grid overlays
   var gridHandler;
   // MapHandler instance responsible for building and updating cells
   var mapHandler;
   // MovieClip container used when cell id labels are shown
   var _mcCellIds;
   // Reference to the core game API object
   var api;
   // OverHeadHandler instance for managing items above sprites
   var overHeadHandler;
   // TextHandler instance for bubble/chat text around sprites
   var textHandler;
   // PointsHandler instance for displaying numeric feedback on sprites
   var pointsHandler;
   // Callback invoked when map building process starts
   var onMapBuilding;
   // Counter used during frame‑timeout checks on map load
   var _nFrameLoadTimeOut;
   // Reference to onEnterFrame handler function (for load timing)
   var onEnterFrame;
   // Callback invoked once the map has finished loading
   var onMapLoaded;
   // SelectionHandler instance controlling cell selections
   var selectionHandler;
   // InteractionHandler instance toggling interactivity per cell
   var interactionHandler;
   // ZoneHandler instance for drawing/clearing area effects
   var zoneHandler;
   // PointerHandler instance for cursor shapes on the map
   var pointerHandler;
   // SpriteHandler: central manager for sprite lifecycle
   var spriteHandler;
   // VisualEffectHandler instance for non‑sprite fx
   var visualEffectHandler;
   // Callback fired once initial loading completes without error
   var onInitComplete;
   // Callback fired during initialization progress updates
   var onInitProgress;
   // Boolean static: whether to cache static animations as a bitmap for performance
   static var useCacheAsBitmapOnStaticAnim;
   // Boolean: controls jump activation state for movement logic
   var _bJumpActivate = false;
   // Constant: number of frames allowed before giving up on loading
   static var FRAMELOADTIMOUT = 500;
   // Boolean flag indicating custom ground graphics should be used
   var _bUseCustomGroundGfxFile = false;
   // Boolean: true when ghost view is enabled for sprites
   var bGhostView = false;
   // Boolean: indicates a custom graphics file has been loaded
   var bCustomFileLoaded = false;
   // Boolean: whether cell identifiers are currently visible
   var _bShowCellId = false;
   // Boolean: whether invade color mode is active
   var _bInvadeMode = false;
   /**
    * Purpose: Constructor initializes the Battlefield instance.
    * Parameters: none
    * Data flow: calls MovieClip constructor, no external data used.
    */
   function Battlefield()
   {
      // Step 1: call parent class MovieClip constructor
      super();
   }
   /**
    * Purpose: Determine if the battlefield map has been built.
    * Parameters: none
    * Data flow: checks internal flag and logs if not ready.
    */
   function get isMapBuild()
   {
      // Step 1: if map built flag is true, return immediately
      if(this._bMapBuild)
      {
         return true;
      }
      // Step 2: report missing map and return false
      ank.utils.Logger.err("[isMapBuild] Carte non chargée");
      return false;
   }
   /**
    * Purpose: set explicit screen width used for rendering.
    * Parameters:
    *   nScreenWidth - new width value in pixels.
    * Data flow: updates internal configuration.
    */
   function set screenWidth(nScreenWidth)
   {
      // Step 1: overwrite stored width value
      this._nScreenWidth = nScreenWidth;
   }
   /**
    * Purpose: retrieve the currently configured screen width.
    * Parameters: none
    * Data flow: returns stored value or default constant.
    */
   function get screenWidth()
   {
      // Step 1: return explicit width if defined
      return this._nScreenWidth != undefined ? this._nScreenWidth : ank.battlefield.Constants.DISPLAY_WIDTH;
   }
   /**
    * Purpose: set explicit screen height used for rendering.
    * Parameters:
    *   nScreenHeight - new height value in pixels.
    * Data flow: updates internal configuration.
    */
   function set screenHeight(nScreenHeight)
   {
      // Step 1: overwrite stored height
      this._nScreenHeight = nScreenHeight;
   }
   /**
    * Purpose: retrieve the currently configured screen height.
    * Parameters: none
    * Data flow: returns stored value or default constant.
    */
   function get screenHeight()
   {
      // Step 1: return explicit height if defined
      return this._nScreenHeight != undefined ? this._nScreenHeight : ank.battlefield.Constants.DISPLAY_HEIGHT;
   }
   /**
    * Purpose: enable or disable jump activation.
    * Parameters:
    *   bJumpActivate - boolean toggle for jump behavior.
    * Data flow: sets internal flag used by movement logic.
    */
   function set isJumpActivate(bJumpActivate)
   {
      // Step 1: update jump flag
      this._bJumpActivate = bJumpActivate;
   }
   /**
    * Purpose: query whether jump is currently activated.
    * Parameters: none
    * Data flow: returns value of _bJumpActivate flag.
    */
   function get isJumpActivate()
   {
      // Step 1: return stored flag
      return this._bJumpActivate;
   }
   /**
    * Purpose: access the main container movie clip.
    * Parameters: none
    * Data flow: returns _mcMainContainer reference.
    */
   function get container()
   {
      // Step 1: return container reference
      return this._mcMainContainer;
   }
   /**
    * Purpose: check visibility state of the main container.
    * Parameters: none
    * Data flow: returns _visible property of container.
    */
   function get isContainerVisible()
   {
      // Step 1: return visibility boolean
      return this._mcMainContainer._visible;
   }
   /**
    * Purpose: provide access to the battlefield datacenter.
    * Parameters: none
    * Data flow: returns _oDatacenter reference.
    */
   function get datacenter()
   {
      // Step 1: return datacenter object
      return this._oDatacenter;
   }
   /**
    * Purpose: indicate if cell IDs are being shown.
    * Parameters: none
    * Data flow: returns boolean flag _bShowCellId.
    */
   function get showingCellIds()
   {
      // Step 1: return flag
      return this._bShowCellId;
   }


  /**
   * initialize
   * Purpose: Sets up battlefield infrastructure including datacenter and handlers for sprite operations
   * Parameters:
   *   oDatacenter: Central data store for battlefield state
   *   sGroundFile: Path to ground graphics file
   *   sObjectFile: Path to object graphics file
   *   sAccessoriesPath: Path for sprite accessories
   *   api: Game API reference
   * Data flow: Server data → datacenter initialization → handler setup → sprite creation infrastructure
   */
  function initialize(oDatacenter, sGroundFile, sObjectFile, sAccessoriesPath, api)
  {
    // Step 1: Store datacenter reference and file paths
    this._oDatacenter = oDatacenter;
    this._sGroundFile = sGroundFile;
    api;

    // Step 2: Initialize datacenter structures (Map and Sprites)
    if(!this.initializeDatacenter())
    {
      ank.utils.Logger.err("BattleField -> Init datacenter impossible");
      this.onInitError();
    }
    ank.utils.Extensions.addExtensions();

    // Step 3: Set up GlobalSpriteHandler for sprite management
    if(_global.GAC == undefined)
    {
      _global.GAC = new ank.battlefield.GlobalSpriteHandler();
      _global.GAC.setAccessoriesRoot(sAccessoriesPath);
    }

    // Step 4: Create main container and load managers
    this.attachClassMovie(ank.battlefield.mc.Container,"_mcMainContainer",10,[this,this._oDatacenter,sObjectFile]);
    this._bMapBuild = false;
    this.loadManager = new ank.battlefield.LoadManager(this.createEmptyMovieClip("LoadManager",this.getNextHighestDepth()));
    this.fightPointAnimManager = new dofus.managers.FightPointAnimManager(api);
  }

   /**
    * Purpose: enable or disable resource streaming and configure directories.
    * Parameters:
    *   status - boolean indicating whether to use streaming files.
    *   objectsDir - directory path where streamed object SWFs reside.
    *   groundsDir - directory path where streamed ground SWFs reside.
    * Data flow: updates battlefield constants used by loading subsystems.
    */
   function setStreaming(status, objectsDir, groundsDir)
   {
      // Step 1: toggle global flag
      ank.battlefield.Constants.USE_STREAMING_FILES = status;
      // Step 2: set directories for objects and grounds
      ank.battlefield.Constants.STREAMING_OBJECTS_DIR = objectsDir;
      ank.battlefield.Constants.STREAMING_GROUNDS_DIR = groundsDir;
   }
   /**
    * Purpose: specify the streaming method (by filename, identifier, etc.).
    * Parameters:
    *   sName - name of the streaming technique to apply.
    * Data flow: updates battlefield constant read by streaming code.
    */
   function setStreamingMethod(sName)
   {
      // Step 1: store method name in global config
      ank.battlefield.Constants.STREAMING_METHOD = sName;
   }
   /**
    * Purpose: switch to custom graphics files for ground and/or objects.
    * Parameters:
    *   sPathGfxGround - path to a custom ground SWF (optional).
    *   sPathGfxObject - path to a custom object SWF (optional).
    * Data flow: updates internal file references and reinitializes container.
    */
   function setCustomGfxFile(sPathGfxGround, sPathGfxObject)
   {
      // Step 1: if ground path provided and different, store it and mark for reload
      if(sPathGfxGround && (sPathGfxGround != "" && this._sGroundFile != sPathGfxGround))
      {
         this._sGroundFile = sPathGfxGround;
         this._bUseCustomGroundGfxFile = true;
         this.bCustomFileLoaded = false;
      }
      // Step 2: if object path provided and different, reinitialize main container
      if(sPathGfxObject && (sPathGfxObject != "" && this._sObjectFile != sPathGfxObject))
      {
         this._mcMainContainer.initialize(this._mcMainContainer,this._oDatacenter,sPathGfxObject);
         this.bCustomFileLoaded = false;
         this._sObjectFile = sPathGfxObject;
      }
   }


   /**
    * Purpose: switch the battlefield between tactical and normal modes, updating grid visibility.
    * Parameters:
    *   api - reference to main API for game state checks.
    *   bOrig - boolean true to restore original mode, false to activate tactic mode.
    * Data flow: queries game state and grid handler then forwards command to map handler.
    */
   function activateTacticMode(api, bOrig)
   {
      // Step 1: ensure map has been built before any changes
      if(!this.isMapBuild)
      {
         return undefined;
      }
      // Step 2: if restoring original view, hide grid if currently shown
      if(bOrig)
      {
         if(this.gridHandler.bGridVisible)
         {
            this.removeGrid();
         }
      }
      // Step 3: otherwise, draw grid if appropriate (in fight or option enabled)
      else if(!this.gridHandler.bGridVisible && (api.datacenter.Game.isRunning || api.kernel.OptionsManager.getOption("Grid") == true))
      {
         this.drawGrid();
      }
      // Step 4: notify map handler about tactic mode change
      this.mapHandler.tacticMode(bOrig);
   }
   /**
    * Purpose: completely reset battlefield visuals and state.
    * Parameters: none
    * Data flow: clears containers, timers, datacenter and reinitializes handlers.
    */
   function clear()
   {
      // Step 1: wipe the main container graphics
      this._mcMainContainer.clear();

      // Step 2: remove cell ID overlay clip
      this._mcCellIds.removeMovieClip();

      // Step 3: clear file references for ground and objects
      this._sGroundFile = "";
      this._sObjectFile = "";

      // Step 4: cancel battlefield timer
      ank.utils.Timer.clear("battlefield");

      // Step 5: clear any cyclic executor tasks
      ank.utils.CyclicExecutor.getInstance().clear();

      // Step 6: reset datacenter to empty state
      this.initializeDatacenter();

      // Step 7: rebuild all handler objects
      this.createHandlers();

      // Step 8: mark map as not built
      this._bMapBuild = false;
   }

   /**
    * Purpose: apply a tint colour to the battlefield container if not in invade mode.
    * Parameters:
    *   t - colour value to set.
    * Data flow: checks internal flag then forwards request to main container.
    */
   function setColor(t)
   {
      // Step 1: ignore request when invade mode disables colouring
      if(this._bInvadeMode)
      {
         return undefined;
      }
      // Step 2: delegate colour application to container
      this._mcMainContainer.setColor(t);
   }
   /**
    * Purpose: toggle invade mode colouring and update state flag.
    * Parameters:
    *   bInvade - boolean indicating whether invade colour should be active.
    * Data flow: stores mode flag and either forces invade colour or restores normal state.
    */
   function setInvadeColor(bInvade)
   {
      // Step 1: update internal invade flag
      this._bInvadeMode = bInvade;
      // Step 2: apply colour or revert according to the flag
      if(bInvade)
      {
         this._mcMainContainer.setColor(dofus.Constants.INVADE_COLOR);
      }
      else
      {
         this.api.kernel.NightManager.setState();
      }
   }
   /**
    * Purpose: remove visual elements of the current map while optionally preserving data.
    * Parameters:
    *   nPermanentLevel - numeric threshold for cell initialization (infinity default).
    *   bKeepData - whether to retain sprite objects after clearing.
    * Data flow: orchestrates multiple handlers to reset map visuals and state.
    */
   function cleanMap(nPermanentLevel, bKeepData)
   {
      // Step 1: ensure map exists before attempting cleanup
      if(!this.isMapBuild)
      {
         return undefined;
      }
      // Step 2: normalize level parameter
      if(nPermanentLevel == undefined)
      {
         nPermanentLevel = Number.POSITIVE_INFINITY;
      }
      else
      {
         nPermanentLevel = Number(nPermanentLevel);
      }
      // Step 3: reinitialize cells via map handler
      this.mapHandler.initializeMap(nPermanentLevel);
      // Step 4: clear any selections and zones
      this.unSelect(true);
      this.clearAllZones();
      // Step 5: clear pointer and grid overlays
      this.clearPointer();
      this.removeGrid();
      // Step 6: clear sprites and related handlers
      this.clearAllSprites(bKeepData);
      this.overHeadHandler.clear();
      this.textHandler.clear();
      this.pointsHandler.clear();
      // Step 7: cleanup timers and cyclic tasks
      ank.utils.Timer.clean();
      ank.utils.CyclicExecutor.getInstance().clear();
   }
   /**
    * Purpose: return the current zoom level of the battlefield display.
    * Parameters: none
    * Data flow: retrieves value directly from the main container.
    */
   function getZoom()
   {
      // Step 1: delegate to container
      return this._mcMainContainer.getZoom();
   }
   /**
    * Purpose: toggle visibility of the main battlefield container.
    * Parameters:
    *   bool - true to show, false to hide.
    * Data flow: sets _visible property of container.
    */
   function showContainer(bool)
   {
      // Step 1: apply visibility flag
      this._mcMainContainer._visible = bool;
   }
   /**
    * Purpose: adjust zoom scaling factor applied to the battlefield.
    * Parameters:
    *   nFactor - zoom multiplier value.
    * Data flow: forwards factor to container.zoom().
    */
   function zoom(nFactor)
   {
      // Step 1: perform zoom operation
      this._mcMainContainer.zoom(nFactor);
   }
   /**
    * Purpose: start map construction using a supplied Map object instance.
    * Parameters:
    *   oMap - prepopulated map datacenter object (may be undefined).
    *   bBuildAll - flag indicating if all map layers should be rendered.
    * Data flow: resets previous state, notifies listeners, delegates to mapHandler,
    *           and handles asynchronous load completion via onEnterFrame.
    */
   function buildMapFromObject(oMap, bBuildAll)
   {
      // Step 1: clear any existing map or visual state
      this.clear();

      // Step 2: abort early if no map data provided
      if(oMap == undefined)
      {
         return undefined;
      }

      // Step 3: fire map-building event
      this.onMapBuilding();

      // Step 4: ask map handler to perform the actual build
      // second argument is intentionally undefined
      this.mapHandler.build(oMap, undefined, bBuildAll);

      // Step 5: if the handler has nothing to load, dispatch immediately
      if(this.mapHandler.LoaderRequestLeft == 0)
      {
         this.DispatchMapLoaded();
      }
      else
      {
         // Step 6: set timeout counter for frame-based polling
         this._nFrameLoadTimeOut = ank.battlefield.Battlefield.FRAMELOADTIMOUT;

         // Step 7: capture reference to this for nested function
         var ref = this;

         // Step 8: define onEnterFrame handler to monitor progress
         this.onEnterFrame = function()
         {
            // Step 8.1: decrement timeout each frame
            ref._nFrameLoadTimeOut--;

            // Step 8.2: when done or timed out, clean up and dispatch
            if(ref._nFrameLoadTimeOut <= 0 || ref.mapHandler.LoaderRequestLeft <= 0)
            {
               // Remove frame callback
               delete ref.onEnterFrame;

               // Notify listeners that map load is complete
               ref.DispatchMapLoaded();
            }
         };
      }
   }

   /**
    * Purpose: mark the battlefield as built and invoke onMapLoaded callback.
    * Parameters: none
    * Data flow: sets _bMapBuild flag then calls listener.
    */
   function DispatchMapLoaded()
   {
      // Step 1: record build state
      this._bMapBuild = true;
      // Step 2: fire completion event
      this.onMapLoaded();
   }
   /**
    * Purpose: decompress incoming map data packet and convert it to a Map.
    * Parameters:
    *   nID, sName, nWidth, nHeight, nBackID - descriptive attributes of the map.
    *   sCompressedData - raw compressed map string from server.
    *   oMap - optional existing Map object to fill.
    *   bBuildAll - whether to render all map content.
    * Data flow: uses Compressor to populate map object then calls buildMapFromObject.
    */
   function buildMap(nID, sName, nWidth, nHeight, nBackID, sCompressedData, oMap, bBuildAll)
   {
      // If no map object was provided, create a new one
      if(oMap == undefined)
      {
         oMap = new ank.battlefield.datacenter.Map();
      }

      // Step 1: decompress the incoming data into the provided Map instance
      ank.battlefield.utils.Compressor.uncompressMap(
         nID,              // Map ID
         sName,            // Map name
         nWidth,           // Map width
         nHeight,          // Map height
         nBackID,          // Background ID
         sCompressedData,  // Compressed map data
         oMap,             // Target map object to fill
         bBuildAll         // Whether to build all map elements
      );

      // Step 2: hand the populated map to the builder routine
      this.buildMapFromObject(oMap, bBuildAll);
   }
   /**
    * Purpose: update the content of a single cell, optionally with new graphics.
    * Parameters:
    *   nCellNum - numeric cell identifier.
    *   sCompressData - compressed cell data string or undefined to reset.
    *   sMaskHexStr - hex string defining walkable mask.
    *   nPermanentLevel - level at which update is applied.
    * Data flow: decompresses cell data, preserves sprite presence, and forwards to mapHandler.
    */
   function updateCell(nCellNum, sCompressData, sMaskHexStr, nPermanentLevel)
   {
      // Step 1: ensure map is built
      if(!this.isMapBuild)
      {
         return undefined;
      }
      // Step 2: remember existing sprite occupancy if any
      var _loc6_ = this.mapHandler.getCellData(nCellNum);
      if(_loc6_ != undefined)
      {
         var _loc7_ = _loc6_.allSpritesOn;
      }
      // Step 3: either clear the cell or update with uncompressed data
      if(sCompressData == undefined)
      {
         this.mapHandler.initializeCell(nCellNum,Number.POSITIVE_INFINITY,true);
      }
      else
      {
         var _loc8_ = ank.battlefield.utils.Compressor.uncompressCell(sCompressData,true);
         this.mapHandler.updateCell(nCellNum,_loc8_,sMaskHexStr,nPermanentLevel);
      }
      // Step 4: restore sprite occupancy flag if it existed
      if(_loc7_ != undefined)
      {
         _loc6_ = this.mapHandler.getCellData(nCellNum);
         if(_loc6_ != undefined)
         {
            _loc6_.allSpritesOn = _loc7_;
         }
      }
   }
   /**
    * Purpose: set the frame of an object on a given cell.
    * Parameters:
    *   nCellNum - cell identifier.
    *   frame - new frame value.
    * Data flow: forwards request to mapHandler if map exists.
    */
   function setObject2Frame(nCellNum, frame)
   {
      // Step 1: guard against unbuilt map
      if(!this.isMapBuild)
      {
         return undefined;
      }
      // Step 2: delegate to handler
      this.mapHandler.setObject2Frame(nCellNum,frame);
   }
   /**
    * Purpose: toggle interactivity of a cell's object.
    * Parameters:
    *   nCellNum - target cell.
    *   bInteractive - boolean state.
    *   nPermanentLevel - permanence parameter.
    * Data flow: passes through to mapHandler.
    */
   function setObject2Interactive(nCellNum, bInteractive, nPermanentLevel)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.mapHandler.setObject2Interactive(nCellNum,bInteractive,nPermanentLevel);
   }
   /**
    * Purpose: update a cell with an external clip object.
    * Parameters:
    *   nCellNum - cell ID.
    *   sFile - filepath of the external clip.
    *   nPermanentLevel - level persistence.
    *   bInteractive - whether clip responds to clicks.
    *   bAutoSize - auto scale flag.
    *   oExternalData - additional clip data object.
    * Data flow: constructs a Cell object and forwards to mapHandler.updateCell.
    */
   function updateCellObjectExternalWithExternalClip(nCellNum, sFile, nPermanentLevel, bInteractive, bAutoSize, oExternalData)
   {
      // Step 1: build temporary Cell structure
      var _loc8_ = new ank.battlefield.datacenter.Cell();
      _loc8_.layerObjectExternal = sFile;
      _loc8_.layerObjectExternalInteractive = bInteractive != undefined ? bInteractive : true;
      _loc8_.layerObjectExternalAutoSize = bAutoSize;
      _loc8_.layerObjectExternalData = oExternalData;
      // Step 2: update handler with the prepared cell
      this.mapHandler.updateCell(nCellNum,_loc8_,"1C000",nPermanentLevel);
   }
   /**
    * Purpose: change external object frame on a cell.
    * Parameters:
    *   nCellNum - cell ID.
    *   frame - frame index.
    * Data flow: forwards to mapHandler if map is built.
    */
   function setObjectExternalFrame(nCellNum, frame)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.mapHandler.setObjectExternalFrame(nCellNum,frame);
   }
   /**
    * Purpose: initialize a specific cell to default state.
    * Parameters:
    *   nCellNum - cell number.
    *   nPermanentLevel - level for initialization.
    * Data flow: delegates to mapHandler.
    */
   function initializeCell(nCellNum, nPermanentLevel)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.mapHandler.initializeCell(nCellNum,nPermanentLevel);
   }
   /**
    * Purpose: select one or more cells visually.
    * Parameters:
    *   cellList - number or array of cell IDs.
    *   nColor - selection colour.
    *   sLayer - layer name.
    *   nAlpha - transparency value.
    *   bAnimate - whether to animate the selection.
    * Data flow: routes to selectionHandler accordingly.
    */
   function select(cellList, nColor, sLayer, nAlpha, bAnimate)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      if(typeof cellList == "object")
      {
         this.selectionHandler.selectMultiple(true,cellList,nColor,sLayer,nAlpha,bAnimate);
      }
      else if(typeof cellList == "number")
      {
         this.selectionHandler.select(true,cellList,nColor,sLayer,nAlpha,bAnimate);
      }
   }
   /**
    * Purpose: deselect specified cells or clear layers/all selections.
    * Parameters:
    *   bAll - if true, clear everything.
    *   cellList - array or number of cells to unselect.
    *   sLayer - layer name to clear.
    * Data flow: uses selectionHandler to remove highlights.
    */
   function unSelect(bAll, cellList, sLayer)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      if(bAll)
      {
         this.selectionHandler.clear();
      }
      else if(typeof cellList == "object")
      {
         this.selectionHandler.selectMultiple(false,cellList,undefined,sLayer);
      }
      else if(typeof cellList == "number")
      {
         this.selectionHandler.select(false,cellList,undefined,sLayer);
      }
      else if(sLayer != undefined)
      {
         this.selectionHandler.clearLayer(sLayer);
      }
   }
   /**
    * Purpose: clear every layer except a given one.
    * Parameters:
    *   sLayer - layer to keep selected.
    * Data flow: iterates through selection layers and clears others.
    */
   function unSelectAllButOne(sLayer)
   {
      var _loc3_ = this.selectionHandler.getLayers();
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.length)
      {
         if(_loc3_[_loc4_] != sLayer)
         {
            this.selectionHandler.clearLayer(_loc3_[_loc4_]);
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   /**
    * Purpose: enable or disable interactivity globally.
    * Parameters:
    *   nState - state flag (typically 0/1).
    * Data flow: passes value to interactionHandler.
    */
   function setInteraction(nState)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.interactionHandler.setEnabled(nState);
   }
   /**
    * Purpose: set interaction state for a specific cell.
    * Parameters:
    *   nCellNum - cell ID.
    *   nState - enabled/disabled flag.
    * Data flow: forwards to interactionHandler.
    */
   function setInteractionOnCell(nCellNum, nState)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.interactionHandler.setEnabledCell(nCellNum,nState);
   }
   /**
    * Purpose: apply interaction state to multiple cells.
    * Parameters:
    *   aCells - array of cell identifiers.
    *   nState - state flag.
    * Data flow: loops over cells and updates each.
    */
   function setInteractionOnCells(aCells, nState)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      for(var k in aCells)
      {
         this.interactionHandler.setEnabledCell(aCells[k],nState);
      }
   }
   /**
    * Purpose: draw a zone shape on the battlefield.
    * Parameters:
    *   nCellNum - center cell.
    *   nRadiusIn - inner radius.
    *   nRadiusOut - outer radius.
    *   sLayer - layer name.
    *   nColor - colour to use.
    *   nShapeID - identifier for shape type.
    * Data flow: delegates to zoneHandler.
    */
   function drawZone(nCellNum, nRadiusIn, nRadiusOut, sLayer, nColor, nShapeID)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.zoneHandler.drawZone(nCellNum,nRadiusIn,nRadiusOut,sLayer,nColor,nShapeID);
   }
   /**
    * Purpose: clear a previously drawn zone.
    * Parameters:
    *   nCellNum - center cell.
    *   nRadius - radius to clear.
    *   sLayer - layer name.
    * Data flow: forwards to zoneHandler.clearZone.
    */
   function clearZone(nCellNum, nRadius, sLayer)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.zoneHandler.clearZone(nCellNum,nRadius,sLayer);
   }
   /**
    * Purpose: clear all zones on a given layer.
    * Parameters:
    *   sLayer - target layer.
    * Data flow: forwards to zoneHandler.clearZoneLayer.
    */
   function clearZoneLayer(sLayer)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.zoneHandler.clearZoneLayer(sLayer);
   }
   /**
    * Purpose: remove every zone regardless of layer.
    * Parameters: none
    * Data flow: delegates to zoneHandler.clear().
    */
   function clearAllZones(Void)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.zoneHandler.clear();
   }
   /**
    * Purpose: clear pointer overlay.
    * Parameters: none
    * Data flow: simply calls pointerHandler.clear().
    */
   function clearPointer(Void)
   {
      this.pointerHandler.clear();
   }
   /**
    * Purpose: hide the pointer overlay completely.
    * Parameters: none
    * Data flow: calls pointerHandler.hide().
    */
   function hidePointer(Void)
   {
      this.pointerHandler.hide();
   }
   /**
    * Purpose: add a custom shape to the pointer.
    * Parameters:
    *   sShape - identifier for the shape.
    *   mSize - size metric (depends on shape).
    *   nColor - colour of the shape.
    *   nCellNumRef - cell reference for relative positioning.
    * Data flow: forwards parameters to pointerHandler.addShape.
    */
   function addPointerShape(sShape, mSize, nColor, nCellNumRef)
   {
      this.pointerHandler.addShape(sShape,mSize,nColor,nCellNumRef);
   }
   /**
    * Purpose: draw the pointer at a given cell.
    * Parameters:
    *   nCellNum - cell where the pointer should appear.
    * Data flow: calls pointerHandler.draw if map built.
    */
   function drawPointer(nCellNum)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.pointerHandler.draw(nCellNum);
   }


  /**
   * Purpose: Retrieves sprite data by ID
   * Parameters:
   *   sID: Sprite identifier to retrieve
   * Data flow: Sprite ID → SpriteHandler.getSprite() → sprite data object
   */
  function getSprite(sID)
  {
    // Step 1: Delegate to spriteHandler to retrieve sprite data
    return this.spriteHandler.getSprite(sID);
  }


  /**
   * Purpose: Retrieves all sprites collection
   * Parameters: None
   * Data flow: Request → SpriteHandler.getSprites() → all sprites data
   */
  function getSprites()
  {
    // Step 1: Delegate to spriteHandler to get sprites collection
    return this.spriteHandler.getSprites();
  }


  /**
   * Purpose: Checks if a sprite exists on the battlefield
   * Parameters:
   *   sID: Sprite ID to check
   * Data flow: Sprite ID → SpriteHandler.getSpriteMc() → boolean existence check
   */
  function isOnBattlefield(sID)
  {
    // Step 1: Delegate to spriteHandler to check sprite existence
    return this.spriteHandler.getSpriteMc(sID) != undefined;
  }



  /**
   * addSprite
   * Purpose: Creates and adds a new sprite to the battlefield from server data
   * Parameters:
   *   sID: Unique sprite identifier from server
   *   spriteData: Server-provided sprite data object containing properties like gfx, position, direction
   * Data flow: Server sprite data → Battlefield.addSprite() → SpriteHandler.addSprite() → visual sprite on battlefield
   */
  function addSprite(sID, spriteData)
  {
    // Step 1: Verify map is built before proceeding
    if(!this.isMapBuild)
    {
      return undefined;
    }

    // Step 2: Delegate to spriteHandler for actual sprite creation and rendering
    this.spriteHandler.addSprite(sID,spriteData);
  }
  

   function addLinkedSprite(sID, sParentID, nChildIndex, oSprite)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.addLinkedSprite(sID,sParentID,nChildIndex,oSprite);
   }
   function carriedSprite(sID, sParentID)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.carriedSprite(sID,sParentID);
   }
   function removeEffectsByCasterID(sCasterID)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.removeEffectsByCasterID(sCasterID);
   }
   function uncarriedSprite(sID, nCellNum, bWithAnimation, oSeq)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.uncarriedSprite(sID,nCellNum,bWithAnimation,oSeq);
   }
   function mountSprite(sID, oMount)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.mountSprite(sID,oMount);
   }
   function unmountSprite(sID)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.unmountSprite(sID);
   }


  /**
   * clearAllSprites
   * Purpose: Removes all sprites from battlefield
   * Parameters:
   *   bKeepData: Whether to preserve sprite data
   * Data flow: Clear command → SpriteHandler.clear() → all sprites removed
   */
  function clearAllSprites(bKeepData)
  {
    // Step 1: Delegate to spriteHandler to clear all sprites
    this.spriteHandler.clear(bKeepData);
  }


  /**
   * removeSprite
   * Purpose: Removes a sprite from the battlefield
   * Parameters:
   *   sID: Sprite ID to remove
   *   bKeepData: Whether to keep sprite data in memory
   * Data flow: Sprite removal command → SpriteHandler.removeSprite() → sprite removed from battlefield
   */
  function removeSprite(sID, bKeepData)
  {
    // Step 1: Verify map is built
    if(!this.isMapBuild)
    {
      return undefined;
    }

    // Step 2: Delegate to spriteHandler for sprite removal
    this.spriteHandler.removeSprite(sID,bKeepData);
  }


   /**
    * Purpose: hide or show a sprite's movie clip.
    * Parameters:
    *   sID - sprite identifier.
    *   bool - visibility flag.
    * Data flow: checks build state then delegates to spriteHandler.hideSprite.
    */
   function hideSprite(sID, bool)
   {
      // Step 1: ensure map built
      if(!this.isMapBuild)
      {
         return undefined;
      }
      // Step 2: delegate to handler
      this.spriteHandler.hideSprite(sID,bool);
   }
   /**
    * Purpose: move a sprite to a different cell instantly.
    * Parameters:
    *   sID - sprite ID.
    *   nCellNum - destination cell.
    *   dir - facing direction after move.
    * Data flow: forwards to spriteHandler.setSpritePosition when map is ready.
    */
   function setSpritePosition(sID, nCellNum, dir)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpritePosition(sID,nCellNum,dir);
   }
   /**
    * Purpose: change a sprite's direction without moving its cell.
    * Parameters:
    *   sID - sprite identifier.
    *   nDir - new facing direction.
    * Data flow: calls spriteHandler.setSpriteDirection.
    */
   function setSpriteDirection(sID, nDir)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteDirection(sID,nDir);
   }
   /**
    * Purpose: halt a sprite's current movement sequence.
    * Parameters:
    *   sID - sprite ID.
    *   oSeq - sequencer object controlling animation.
    *   nCellNum - optional cell number to leave sprite at.
    * Data flow: forwards stop command to handler.
    */
   function stopSpriteMove(sID, oSeq, nCellNum)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.stopSpriteMove(sID,oSeq,nCellNum);
   }
   /**
    * Purpose: move sprite along a compressed path string.
    * Parameters:
    *   sID - sprite identifier.
    *   compressedPath - compressed movement data.
    *   oSeq - sequencer for animation.
    *   bClearSequencer - whether to clear existing sequence.
    *   bForcedRun/bForcedWalk - force run/walk modes.
    *   nRunLimit - maximum run distance.
    * Data flow: decompresses path then delegates to moveSpriteWithUncompressedPath.
    */
   function moveSprite(sID, compressedPath, oSeq, bClearSequencer, bForcedRun, bForcedWalk, nRunLimit)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      var _loc9_ = ank.battlefield.utils.Compressor.extractFullPath(this.mapHandler,compressedPath);
      this.moveSpriteWithUncompressedPath(sID,_loc9_,oSeq,bClearSequencer,bForcedRun,bForcedWalk,nRunLimit);
   }
   /**
    * Purpose: move sprite using already available uncompressed path array.
    * Parameters:
    *   sID - sprite ID.
    *   aPath - array of cell indices to traverse.
    *   oSeq - animation sequencer.
    *   bClearSequencer - clear prior actions if true.
    *   bForcedRun/bForcedWalk - run/walk modes.
    *   nRunLimit - distance constraint.
    *   sAnimation - optional animation to play.
    * Data flow: forwards path to spriteHandler.moveSprite.
    */
   function moveSpriteWithUncompressedPath(sID, aPath, oSeq, bClearSequencer, bForcedRun, bForcedWalk, nRunLimit, sAnimation)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      if(aPath != undefined)
      {
         this.spriteHandler.moveSprite(sID,aPath,oSeq,bClearSequencer,sAnimation,bForcedRun,bForcedWalk,nRunLimit);
      }
   }
   /**
    * Purpose: slide a sprite to a cell with a specified animation.
    * Parameters:
    *   sID - sprite ID.
    *   nCellNum - destination cell.
    *   oSeq - sequencer.
    *   sAnimation - animation name.
    * Data flow: delegate to handler.slideSprite.
    */
   function slideSprite(sID, nCellNum, oSeq, sAnimation)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.slideSprite(sID,nCellNum,oSeq,sAnimation);
   }
   /**
    * Purpose: recalc sprite facing direction automatically given a cell.
    * Parameters:
    *   sID - sprite ID.
    *   nCellNum - reference cell number.
    * Data flow: calls handler.autoCalculateSpriteDirection.
    */
   function autoCalculateSpriteDirection(sID, nCellNum)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.autoCalculateSpriteDirection(sID,nCellNum);
   }
   /**
    * Purpose: convert altitude value into one of four directional orientations.
    * Parameters:
    *   sID - sprite ID.
    * Data flow: delegates to handler.convertHeightToFourSpriteDirection.
    */
   function convertHeightToFourSpriteDirection(sID)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.convertHeightToFourSpriteDirection(sID);
   }
   /**
    * Purpose: force a sprite into a specific animation regardless of state.
    * Parameters:
    *   sID - sprite ID.
    *   sAnim - animation name.
    * Data flow: calls handler.setSpriteAnim with forced flag.
    */
   function setForcedSpriteAnim(sID, sAnim)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteAnim(sID,sAnim,true);
   }
   /**
    * Purpose: set a sprite's current animation.
    * Parameters:
    *   sID - sprite identifier.
    *   sAnim - animation name.
    * Data flow: forwarded to spriteHandler.
    */
   function setSpriteAnim(sID, sAnim)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteAnim(sID,sAnim);
   }
   /**
    * Purpose: loop a sprite animation for a duration.
    * Parameters:
    *   sID - sprite ID.
    *   sAnim - animation name.
    *   nTimer - loop interval.
    * Data flow: delegates to handler.setSpriteLoopAnim.
    */
   function setSpriteLoopAnim(sID, sAnim, nTimer)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteLoopAnim(sID,sAnim,nTimer);
   }
   /**
    * Purpose: schedule a timed animation on a sprite.
    * Parameters:
    *   sID - sprite ID.
    *   sAnim - animation name.
    *   bForced - whether forcing is applied.
    *   nTimer - duration in ms.
    * Data flow: forwarded to spriteHandler.setSpriteTimerAnim.
    */
   function setSpriteTimerAnim(sID, sAnim, bForced, nTimer)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteTimerAnim(sID,sAnim,bForced,nTimer);
   }
   /**
    * Purpose: change the graphic file used by a sprite.
    * Parameters:
    *   sID - sprite identifier.
    *   sFile - path to new SWF/GFX file.
    * Data flow: forwards call to handler when map built.
    */
   function setSpriteGfx(sID, sFile)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteGfx(sID,sFile);
   }
   /**
    * Purpose: apply color transform to a sprite.
    * Parameters:
    *   sID - sprite ID.
    *   oTransform - color transform object.
    * Data flow: delegated to spriteHandler.
    */
   function setSpriteColorTransform(sID, oTransform)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteColorTransform(sID,oTransform);
   }
   /**
    * Purpose: set sprite transparency.
    * Parameters:
    *   sID - sprite identifier.
    *   nAlpha - alpha value (0‑100).
    * Data flow: forwards parameter to handler.
    */
   function setSpriteAlpha(sID, nAlpha)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.setSpriteAlpha(sID,nAlpha);
   }
   /**
    * Purpose: launch a visual effect on or near a sprite.
    * Parameters:
    *   sID - source sprite ID.
    *   oEffectData - datacenter effect description.
    *   nCellNum - cell where effect should appear.
    *   nDisplayType - display layering info.
    *   mSpriteAnimation - optional animation or motion matrix.
    *   sTargetID - optional target sprite ID.
    *   oSpriteToHideDuringAnimation - clip to hide if necessary.
    *   bForceVisible - whether effect should always be visible.
    *   bBlocking - whether effect blocks other actions.
    * Data flow: forwards all parameters to spriteHandler.launchVisualEffect.
    */
   function spriteLaunchVisualEffect(sID, oEffectData, nCellNum, nDisplayType, mSpriteAnimation, sTargetID, oSpriteToHideDuringAnimation, bForceVisible, bBlocking)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.launchVisualEffect(sID,oEffectData,nCellNum,nDisplayType,mSpriteAnimation,sTargetID,oSpriteToHideDuringAnimation,bForceVisible,bBlocking);
   }
   /**
    * Purpose: launch a carried sprite effect (item carried by another sprite).
    * Parameters:
    *   sID - carrier sprite ID.
    *   oEffectData - effect description.
    *   nCellNum - cell to display effect at.
    *   nDisplayType - layering info.
    * Data flow: delegated to spriteHandler.launchCarriedSprite.
    */
   function spriteLaunchCarriedSprite(sID, oEffectData, nCellNum, nDisplayType)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.launchCarriedSprite(sID,oEffectData,nCellNum,nDisplayType);
   }
   /**
    * Purpose: visually select or deselect a sprite.
    * Parameters:
    *   sID - sprite identifier.
    *   bSelect - true to select, false to unselect.
    * Data flow: passes through to spriteHandler.selectSprite.
    */
   function selectSprite(sID, bSelect)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.spriteHandler.selectSprite(sID,bSelect);
   }
   /**
    * Purpose: display a text bubble above a sprite.
    * Parameters:
    *   sID - sprite identifier.
    *   sText - text content.
    *   nType - bubble type (chat, system, etc.).
    * Data flow: validates sprite existence/visibility then uses textHandler.
    */
   function addSpriteBubble(sID, sText, nType)
   {
      var _loc5_ = this._oDatacenter.Sprites.getItemAt(sID);
      if(_loc5_ == undefined)
      {
         ank.utils.Logger.err("[addSpriteBubble] Sprite inexistant (sprite Id : " + sID + ")");
         return undefined;
      }
      if(_loc5_.isInMove)
      {
         return undefined;
      }
      if(!_loc5_.isVisible)
      {
         return undefined;
      }
      var _loc6_ = _loc5_.mc;
      var _loc7_ = _loc6_._x;
      var _loc8_ = _loc6_._y;
      if(nType == undefined)
      {
         nType = ank.battlefield.TextHandler.BUBBLE_TYPE_CHAT;
      }
      if(_loc7_ == 0 || _loc8_ == 0)
      {
         ank.utils.Logger.err("[addSpriteBubble] le sprite n\'est pas encore placé");
         return undefined;
      }
      this.textHandler.addBubble(sID,_loc7_,_loc8_,sText,nType);
   }
   /**
    * Purpose: remove a bubble from a sprite.
    * Parameters:
    *   sID - sprite identifier.
    * Data flow: verifies sprite exists then calls textHandler.removeBubble.
    */
   function removeSpriteBubble(sID)
   {
      var _loc3_ = this._oDatacenter.Sprites.getItemAt(sID);
      if(_loc3_ == undefined)
      {
         return undefined;
      }
      this.textHandler.removeBubble(sID);
   }
   /**
    * Purpose: show numeric points (damage, healing) above a sprite.
    * Parameters:
    *   sID - sprite ID.
    *   sValue - string value to display.
    *   nTypePoint - type of points (damage, heal, etc.).
    * Data flow: computes position and forwards to pointsHandler.
    */
   function addSpritePoints(sID, sValue, nTypePoint)
   {
      var _loc5_ = this._oDatacenter.Sprites.getItemAt(sID);
      if(_loc5_ == undefined)
      {
         ank.utils.Logger.err("[addSpritePoints] Sprite inexistant");
         return undefined;
      }
      if(!_loc5_.isVisible)
      {
         return undefined;
      }
      var _loc6_ = _loc5_.mc;
      var _loc7_ = _loc6_._x;
      if(this.overHeadHandler.overHeadID == sID)
      {
         var _loc9_ = this.overHeadHandler.overHead.getBounds(this);
         var _loc8_ = Math.max(_loc9_.yMin + 10,50);
         if(_global.isNaN(_loc8_))
         {
            _loc8_ = Math.max(_loc6_._y - ank.battlefield.Constants.DEFAULT_SPRITE_HEIGHT,50);
         }
      }
      else
      {
         _loc8_ = Math.max(_loc6_._y - ank.battlefield.Constants.DEFAULT_SPRITE_HEIGHT,50);
      }
      if(_loc7_ == 0 || _loc8_ == 0)
      {
         ank.utils.Logger.err("[addSpritePoints] le sprite n\'est pas encore placé");
         return undefined;
      }
      this.pointsHandler.addPoints(sID,_loc7_,_loc8_,sValue,nTypePoint);
   }
   /**
    * Purpose: add an overhead UI element above a sprite.
    * Parameters:
    *   sID - target sprite ID.
    *   sLayerName - overhead layer identifier.
    *   className - class name of the overhead component.
    *   aArgs - arguments for the component constructor.
    *   nDelay - optional delay before showing.
    *   bEvenInMove - whether to attach while sprite is moving.
    * Data flow: validates sprite then calls overHeadHandler.addOverHeadItem.
    */
   function addSpriteOverHeadItem(sID, sLayerName, className, aArgs, nDelay, bEvenInMove)
   {
      var _loc8_ = this._oDatacenter.Sprites.getItemAt(sID);
      if(_loc8_ == undefined)
      {
         ank.utils.Logger.err("[addSpriteOverHeadItem] Sprite inexistant");
         return undefined;
      }
      if(_loc8_.isInMove && !bEvenInMove)
      {
         return undefined;
      }
      if(!_loc8_.isVisible)
      {
         return undefined;
      }
      var _loc9_ = _loc8_.mc;
      this.overHeadHandler.addOverHeadItem(sID,_loc9_._x,_loc9_._y,_loc9_,sLayerName,className,aArgs,nDelay);
   }
   /**
    * Purpose: remove a specific overhead layer from a sprite.
    * Parameters:
    *   sID - sprite identifier.
    *   sLayerName - overhead layer to remove.
    * Data flow: directly calls overHeadHandler.removeOverHeadLayer.
    */
   function removeSpriteOverHeadLayer(sID, sLayerName)
   {
      this.overHeadHandler.removeOverHeadLayer(sID,sLayerName);
   }
   /**
    * Purpose: hide the entire overhead display for a sprite.
    * Parameters:
    *   sID - sprite identifier.
    * Data flow: uses overHeadHandler.removeOverHead.
    */
   function hideSpriteOverHead(sID)
   {
      this.overHeadHandler.removeOverHead(sID);
   }
   /**
    * Purpose: attach an extra clip to a sprite and automatically remove it after a timer.
    * Parameters:
    *   sID - sprite ID.
    *   sFile - clip file path.
    *   nColor - tint colour.
    *   bTop - whether clip is on top layer.
    *   nDuration - milliseconds before removal.
    * Data flow: uses addSpriteExtraClip then sets interval to call removal.
    */
   function addSpriteExtraClipOnTimer(sID, sFile, nColor, bTop, nDuration)
   {
      this.addSpriteExtraClip(sID,sFile,nColor,bTop);
      var _loc7_ = {};
      _loc7_.timerId = _global.setInterval(this,"removeSpriteExtraClipOnTimer",nDuration,_loc7_,sID,bTop);
   }
   /**
    * Purpose: handler called by timer to remove extra clip.
    * Parameters:
    *   oTimer - timer object containing id.
    *   sID - sprite ID.
    *   bTop - layer flag.
    * Data flow: clears interval then calls removeSpriteExtraClip.
    */
   function removeSpriteExtraClipOnTimer(oTimer, sID, bTop)
   {
      _global.clearInterval(oTimer.timerId);
      this.removeSpriteExtraClip(sID,bTop);
   }
   /**
    * Purpose: immediately add extra clip to sprite.
    * Parameters:
    *   sID - sprite identifier.
    *   sFile - clip file path.
    *   nColor - colour transform.
    *   bTop - whether clip is on top.
    * Data flow: delegates to spriteHandler.addSpriteExtraClip.
    */
   function addSpriteExtraClip(sID, sFile, nColor, bTop)
   {
      this.spriteHandler.addSpriteExtraClip(sID,sFile,nColor,bTop);
   }
   /**
    * Purpose: remove an extra clip from sprite.
    * Parameters:
    *   sID - sprite identifier.
    *   bTop - layer indicator.
    * Data flow: calls spriteHandler.removeSpriteExtraClip.
    */
   function removeSpriteExtraClip(sID, bTop)
   {
      this.spriteHandler.removeSpriteExtraClip(sID,bTop);
   }
   /**
    * Purpose: display transient points above a sprite via handler.
    * Parameters:
    *   sID - sprite ID.
    *   nValue - numeric value to show.
    *   nColor - colour code.
    * Data flow: delegated to spriteHandler.showSpritePoints.
    */
   function showSpritePoints(sID, nValue, nColor)
   {
      this.spriteHandler.showSpritePoints(sID,nValue,nColor);
   }
   /**
    * Purpose: toggle ghost view mode affecting sprite rendering.
    * Parameters:
    *   bool - whether ghost view is enabled.
    * Data flow: sets flag on battlefield and spriteHandler.
    */
   function setSpriteGhostView(bool)
   {
      this.bGhostView = bool;
      this.spriteHandler.setSpriteGhostView(bool);
   }
   /**
    * Purpose: scale a sprite's display.
    * Parameters:
    *   sID - sprite ID.
    *   nScaleX - horizontal scale percentage.
    *   nScaleY - vertical scale percentage.
    * Data flow: forwards to spriteHandler.setSpriteScale.
    */
   function setSpriteScale(sID, nScaleX, nScaleY)
   {
      this.spriteHandler.setSpriteScale(sID,nScaleX,nScaleY);
   }
   /**
    * Purpose: draw or hide the grid overlay.
    * Parameters:
    *   bAll - whether to draw all grid lines or only relevant ones.
    * Data flow: toggles gridHandler depending on current visibility.
    */
   function drawGrid(bAll)
   {
      // Step 1: require built map
      if(!this.isMapBuild)
      {
         return undefined;
      }
      // Step 2: toggle visibility
      if(this.gridHandler.bGridVisible)
      {
         this.removeGrid();
      }
      else
      {
         this.gridHandler.draw(bAll);
      }
   }
   /**
    * Purpose: remove any grid drawing from the battlefield.
    * Parameters: none
    * Data flow: delegate to gridHandler.clear when map built.
    */
   function removeGrid(Void)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      this.gridHandler.clear();
   }
   /**
    * Purpose: enable display of cell identifiers.
    * Parameters: none
    * Data flow: flips flag and triggers updateCellIds.
    */
   function showCellIds()
   {
      this._bShowCellId = true;
      this.updateCellIds();
   }
   /**
    * Purpose: hide cell id labels.
    * Parameters: none
    * Data flow: flips flag and updates ids.
    */
   function hideCellIds()
   {
      this._bShowCellId = false;
      this.updateCellIds();
   }
   /**
    * Purpose: refresh the visual representation of cell IDs.
    * Parameters: none
    * Data flow: removes existing clip and calls mapHandler.drawCellIds when appropriate.
    */
   function updateCellIds()
   {
      if(this._mcCellIds != undefined)
      {
         this._mcCellIds.removeMovieClip();
         this._mcCellIds = undefined;
      }
      if(this._bShowCellId)
      {
         this._mcCellIds = this.mapHandler.drawCellIds();
      }
   }
   /**
    * Purpose: add a visual effect relative to a sprite.
    * Parameters:
    *   sID - source sprite ID.
    *   oEffectData - effect descriptor.
    *   nCellNum - cell number for effect placement.
    *   nDisplayType - how effect should be layered.
    *   sTargetID - optional target sprite ID.
    * Data flow: gathers sprite references then delegates to visualEffectHandler.
    */
   function addVisualEffectOnSprite(sID, oEffectData, nCellNum, nDisplayType, sTargetID)
   {
      if(!this.isMapBuild)
      {
         return undefined;
      }
      var _loc7_ = this._oDatacenter.Sprites.getItemAt(sID);
      var _loc8_ = this._oDatacenter.Sprites.getItemAt(sTargetID);
      this.visualEffectHandler.addEffect(_loc7_,oEffectData,nCellNum,nDisplayType,_loc8_);
   }
   /**
    * Purpose: clear any spell preview overlays and reset cursor.
    * Parameters: none
    * Data flow: clears selections, zones, pointer and UI cursor.
    */
   function clearSpellPreview()
   {
      this.unSelect(true);
      this.clearZoneLayer("spell");
      this.clearPointer();
      this.api.ui.hideCursor();
   }
   /**
    * Purpose: reset datacenter state to empty map and sprite container.
    * Parameters: none
    * Data flow: wipes existing map and sprite collections.
    */
   function initializeDatacenter(Void)
   {
      if(this._oDatacenter == undefined)
      {
         return false;
      }
      this._oDatacenter.Map.cleanSpritesOn();
      this._oDatacenter.Map = new ank.battlefield.datacenter.Map();
      this._oDatacenter.Sprites = new ank.utils.ExtendedObject();
      return true;
   }
   /**
    * Purpose: instantiate all handler objects used by the battlefield.
    * Parameters: none
    * Data flow: creates handler instances using current container/datacenter references.
    */
   function createHandlers(Void)
   {
      this.mapHandler = new ank.battlefield.MapHandler(this,this._mcMainContainer,this._oDatacenter);
      this.spriteHandler = new ank.battlefield.SpriteHandler(this,this._mcMainContainer.ExternalContainer.Object2,this._oDatacenter.Sprites);
      this.interactionHandler = new ank.battlefield.InteractionHandler(this._mcMainContainer.ExternalContainer.InteractionCell,this._oDatacenter);
      this.zoneHandler = new ank.battlefield.ZoneHandler(this,this._mcMainContainer.ExternalContainer.Zone);
      this.pointerHandler = new ank.battlefield.PointerHandler(this,this._mcMainContainer.ExternalContainer.Pointer);
      this.selectionHandler = new ank.battlefield.SelectionHandler(this,this._mcMainContainer.ExternalContainer,this._oDatacenter);
      this.gridHandler = new ank.battlefield.GridHandler(this._mcMainContainer.ExternalContainer.Grid,this._oDatacenter);
      this.visualEffectHandler = new ank.battlefield.VisualEffectHandler(this,this._mcMainContainer.ExternalContainer.Object2);
      this.textHandler = new ank.battlefield.TextHandler(this,this._mcMainContainer.Text,this._oDatacenter);
      this.pointsHandler = new ank.battlefield.PointsHandler(this,this._mcMainContainer.Points,this._oDatacenter);
      this.overHeadHandler = new ank.battlefield.OverHeadHandler(this,this._mcMainContainer.OverHead);
   }
   /**
    * Purpose: handle initialization callback from loader for each clip.
    * Parameters:
    *   mc - movie clip that finished loading.
    * Data flow: if clip is not ground, extend it and initialize, otherwise finalize init process.
    */
   function onLoadInit(mc)
   {
      var _loc0_ = null;
      if((_loc0_ = mc._name) !== "Ground")
      {
         mc.__proto__ = ank.battlefield.mc.ExternalContainer.prototype;
         mc.initialize(this._sGroundFile);
         this.createHandlers();
      }
      else
      {
         mc._parent.useCustomGroundGfxFile(this._bUseCustomGroundGfxFile);
         this.bCustomFileLoaded = true;
         this.onInitComplete();
      }
   }
   /**
    * Purpose: handle errors during resource loading.
    * Parameters:
    *   mc - movie clip that encountered an error.
    * Data flow: simply invokes the onInitError callback.
    */
   function onLoadError(mc)
   {
      this.onInitError();
   }
   /**
    * Purpose: report progress during loading operations.
    * Parameters:
    *   mc - movie clip being loaded.
    *   nBL - bytes loaded.
    *   nBT - bytes total.
    * Data flow: forwards values to onInitProgress callback.
    */
   function onLoadProgress(mc, nBL, nBT)
   {
      this.onInitProgress(nBL,nBT);
   }
}
