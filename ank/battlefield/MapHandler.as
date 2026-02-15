class ank.battlefield.MapHandler
{
   var _nLoadRequest;
   var _oDatacenter;
   var _mcBattlefield;
   var _mcContainer;
   var api;
   var _nLastCellCount;
   var _nAdjustTimer;
   static var OBJECT_TYPE_BACKGROUND = 1;
   static var OBJECT_TYPE_GROUND = 2;
   static var OBJECT_TYPE_OBJECT1 = 3;
   static var OBJECT_TYPE_OBJECT2 = 4;
   static var TIME_BEFORE_AJUSTING_MAP = 500;
   var _oLoadingCells = {};
   var _oSettingFrames = {};
   var _mclLoader = new MovieClipLoader();
   var _nMaxMapRender = 1;
   var _bShowingFightCells = false;
   var _bTacticMode = false;
   function MapHandler(b, c, d)
   {
      if(b != undefined)
      {
         this.initialize(b,c,d);
      }
      this._mclLoader.addListener(this);
   }
   function get showingFightCells()
   {
      return this._bShowingFightCells;
   }
   function set showingFightCells(bShowingFightCells)
   {
      this._bShowingFightCells = bShowingFightCells;
   }
   function get LoaderRequestLeft()
   {
      return this._nLoadRequest;
   }
   function get validCellsData()
   {
      return this._oDatacenter.Map.validCells;
   }
   function initialize(b, c, d)
   {
      this._mcBattlefield = b;
      this._oDatacenter = d;
      this._mcContainer = c;
      this.api = _global.API;
   }

   function build(oMap, nCellNum, bBuildAll)
   {
      this._oDatacenter.Map = oMap;
      var nCellWidth = ank.battlefield.Constants.CELL_WIDTH;
      var nCellHalfWidth = ank.battlefield.Constants.CELL_HALF_WIDTH;
      var nCellHalfHeight = ank.battlefield.Constants.CELL_HALF_HEIGHT;
      var nLevelHeight = ank.battlefield.Constants.LEVEL_HEIGHT;
      var nCol = -1;
      var nRow = 0;
      var nXOffset = 0;
      var oCellData = oMap.data;
      var nCellCount = oCellData.length;
      var nMaxCol = oMap.width - 1;
      var mcExternalContainer = this._mcContainer.ExternalContainer;
      var bSingleCell = nCellNum != undefined;
      var bRenderingEmptyCells = false;
      var bSameCellCount = this._nLastCellCount == nCellCount;
      this._nLoadRequest = 0;
      if(!bSingleCell && (ank.battlefield.Constants.USE_STREAMING_FILES && ank.battlefield.Constants.STREAMING_METHOD == "explod"))
      {
         this._mcContainer.applyMask(false);
      }
      if(oMap.backgroundNum != 0)
      {
         if(ank.battlefield.Constants.USE_STREAMING_FILES && (ank.battlefield.Constants.STREAMING_METHOD == "explod" && !bSingleCell))
         {
            var mcBackground = mcExternalContainer.Ground.createEmptyMovieClip("background",-1);
            mcBackground.cacheAsBitmap = _global.CONFIG.cacheAsBitmap["mapHandler/BACKGROUND"];
            this._mclLoader.loadClip(ank.battlefield.Constants.STREAMING_GROUNDS_DIR + oMap.backgroundNum + ".swf",mcBackground);
            this._nLoadRequest = this._nLoadRequest + 1;
         }
         else if(ank.battlefield.Constants.STREAMING_METHOD != "")
         {
            mcExternalContainer.Ground.attachMovie(oMap.backgroundNum,"background",-1).cacheAsBitmap = _global.CONFIG.cacheAsBitmap["mapHandler/BACKGROUND"];
         }
         else
         {
            mcExternalContainer.Ground.attach(oMap.backgroundNum,"background",-1).cacheAsBitmap = _global.CONFIG.cacheAsBitmap["mapHandler/BACKGROUND"];
         }
      }
      var nCellIndex = -1;
      // Loop through all map cells
      while ((nCellIndex = nCellIndex + 1) < nCellCount)
      {
         // =====================================================
         // GRID POSITIONING (row / column / isometric offset)
         // =====================================================

         // If we reached the last column of the current row
         if (nCol == nMaxCol)
         {
            // Move to next row
            nCol = 0;
            nRow += 1;

            // Alternate horizontal offset for isometric layout
            if (nXOffset == 0)
            {
               nXOffset = nCellHalfWidth;
               nMaxCol -= 1; // odd row → fewer columns
            }
            else
            {
               nXOffset = 0;
               nMaxCol += 1; // even row → more columns
            }
         }
         else
         {
            // Move to next column in the same row
            nCol = nCol + 1;
         }

         // =====================================================
         // SINGLE CELL RENDERING MODE
         // =====================================================

         // Used when rendering only one specific cell
         if (bSingleCell)
         {
            if (nCellIndex < nCellNum)
            {
               continue; // skip until target cell
            }
            if (nCellIndex > nCellNum)
            {
               return undefined; // stop once done
            }
         }

         // Retrieve cell data
         var oCellData = oCellData[nCellIndex];

         // =====================================================
         // ACTIVE CELL
         // =====================================================

         if (oCellData.active)
         {
            // -------------------------------------------------
            // Compute isometric screen coordinates
            // -------------------------------------------------

            var nCellX = nCol * nCellWidth + nXOffset;
            var nCellY = nRow * nCellHalfHeight
                        - nLevelHeight * (oCellData.groundLevel - 7);

            // Store coordinates in cell data
            oCellData.x = nCellX;
            oCellData.y = nCellY;

            // =================================================
            // INTERACTION CELL (clickable / movement cell)
            // =================================================

            if (oCellData.movement || bBuildAll)
            {
               // Create interaction cell only if it does not exist
               if (!bSameCellCount && !mcExternalContainer.InteractionCell["cell" + nCellIndex])
               {
                  if (!bRenderingEmptyCells)
                  {
                     // (streaming logic ignored)
                     mcInteractionCell =
                        mcExternalContainer.InteractionCell.attachMovie(
                           "i" + oCellData.groundSlope,
                           "cell" + nCellIndex,
                           nCellIndex,
                           {_x:nCellX,_y:nCellY}
                        );
                  }
                  else
                  {
                     // Create empty placeholder
                     mcInteractionCell =
                        mcExternalContainer.InteractionCell.createEmptyMovieClip(
                           "cell" + nCellIndex,
                           nCellIndex,
                           {_x:nCellX,_y:nCellY}
                        );
                  }

                  // Assign Cell prototype and initialize
                  mcInteractionCell.__proto__ = ank.battlefield.mc.Cell.prototype;
                  mcInteractionCell.initialize(this._mcBattlefield);
               }
               else
               {
                  // Reuse existing interaction cell
                  mcInteractionCell = mcExternalContainer.InteractionCell["cell" + nCellIndex];
               }

               // Link cell data
               oCellData.mc = mcInteractionCell;
               mcInteractionCell.data = oCellData;
            }
            else
            {
               // Remove interaction cell if movement is disabled
               mcExternalContainer.InteractionCell["cell" + nCellIndex].removeMovieClip();
            }

            // =================================================
            // GROUND LAYER
            // =================================================

            if (oCellData.layerGroundNum != 0)
            {
               // (streaming logic ignored)

               if (!bRenderingEmptyCells)
               {
                  mcGround =
                     mcExternalContainer.Ground.attach(
                        oCellData.layerGroundNum,
                        "cell" + nCellIndex,
                        nCellIndex
                     );
               }
               else
               {
                  mcGround = new MovieClip();
               }

               mcGround.cacheAsBitmap =
                  _global.CONFIG.cacheAsBitmap["mapHandler/Cell/Ground"];

               mcGround._x = nCellX;
               mcGround._y = nCellY;

               // Apply slope frame
               if (oCellData.groundSlope != 1)
               {
                  mcGround.gotoAndStop(oCellData.groundSlope);
               }
               // Apply rotation if flat ground
               else if (oCellData.layerGroundRot != 0)
               {
                  mcGround._rotation = oCellData.layerGroundRot * 90;

                  // Correct scaling for diagonal rotation
                  if (mcGround._rotation % 180)
                  {
                     mcGround._yscale = 192.86;
                     mcGround._xscale = 51.85;
                  }
               }

               // Horizontal flip
               if (oCellData.layerGroundFlip)
               {
                  mcGround._xscale *= -1;
               }
            }
            else
            {
               // No ground → remove clip
               mcExternalContainer.Ground["cell" + nCellIndex].removeMovieClip();
            }

            // =================================================
            // OBJECT LAYER 1
            // =================================================

            if (oCellData.layerObject1Num != 0)
            {
               // (streaming logic ignored)

               if (!bRenderingEmptyCells)
               {
                  mcObject1 =
                     mcExternalContainer.Object1.attachMovie(
                        oCellData.layerObject1Num,
                        "cell" + nCellIndex,
                        nCellIndex
                     );
               }
               else
               {
                  mcObject1 = new MovieClip();
               }

               mcObject1.cacheAsBitmap =
                  _global.CONFIG.cacheAsBitmap["mapHandler/Cell/Object1"];

               mcObject1._x = nCellX;
               mcObject1._y = nCellY;

               // Rotation only on flat ground
               if (oCellData.groundSlope == 1 && oCellData.layerObject1Rot != 0)
               {
                  mcObject1._rotation = oCellData.layerObject1Rot * 90;

                  if (mcObject1._rotation % 180)
                  {
                     mcObject1._yscale = 192.86;
                     mcObject1._xscale = 51.85;
                  }
               }

               // Horizontal flip
               if (oCellData.layerObject1Flip)
               {
                  mcObject1._xscale *= -1;
               }

               oCellData.mcObject1 = mcObject1;
            }
            else
            {
               mcExternalContainer.Object1["cell" + nCellIndex].removeMovieClip();
            }

            // =================================================
            // EXTERNAL INTERACTIVE OBJECT
            // =================================================

            if (oCellData.layerObjectExternal != "")
            {
               if (!bRenderingEmptyCells)
               {
                  var mcExternalObject =
                     mcExternalContainer.Object2.attachClassMovie(
                        ank.battlefield.mc.InteractiveObject,
                        "cellExt" + nCellIndex,
                        nCellIndex * 100 + 1
                     );
               }

               mcExternalObject.cacheAsBitmap =
                  _global.CONFIG.cacheAsBitmap["mapHandler/Cell/ObjectExternal"];

               mcExternalObject.initialize(
                  this._mcBattlefield,
                  oCellData,
                  oCellData.layerObjectExternalInteractive
               );

               mcExternalObject.loadExternalClip(
                  oCellData.layerObjectExternal,
                  oCellData.layerObjectExternalAutoSize
               );

               mcExternalObject._x = nCellX;
               mcExternalObject._y = nCellY;

               oCellData.mcObjectExternal = mcExternalObject;
            }
            else
            {
               mcExternalContainer.Object2["cellExt" + nCellIndex].removeMovieClip();
               delete oCellData.mcObjectExternal;
            }

            // =================================================
            // OBJECT LAYER 2 (top layer)
            // =================================================

            if (oCellData.layerObject2Num != 0)
            {
               // (streaming logic ignored)

               if (!bRenderingEmptyCells)
               {
                  mcObject2 =
                     mcExternalContainer.Object2.attachMovie(
                        oCellData.layerObject2Num,
                        "cell" + nCellIndex,
                        nCellIndex * 100
                     );
               }
               else
               {
                  mcObject2 = new MovieClip();
               }

               if (mcObject2)
               {
                  mcObject2.cacheAsBitmap =
                     _global.CONFIG.cacheAsBitmap["mapHandler/Cell/Object2"];

                  // Interactive object
                  if (oCellData.layerObject2Interactive)
                  {
                     mcObject2.__proto__ =
                        ank.battlefield.mc.InteractiveObject.prototype;

                     mcObject2.initialize(this._mcBattlefield, oCellData, true);
                  }

                  mcObject2._x = nCellX;
                  mcObject2._y = nCellY;

                  // Horizontal flip
                  if (oCellData.layerObject2Flip)
                  {
                     mcObject2._xscale = -100;
                  }

                  oCellData.mcObject2 = mcObject2;
               }
               else
               {
                  // Cleanup if creation failed
                  oCellData.layerObject2Num = 0;
                  mcExternalContainer.Object2["cell" + nCellIndex].removeMovieClip();
                  delete oCellData.mcObject2;
               }
            }
            else
            {
               mcExternalContainer.Object2["cell" + nCellIndex].removeMovieClip();
               delete oCellData.mcObject2;
            }
         }

         // =====================================================
         // INACTIVE CELL (build-all mode only)
         // =====================================================

         else if (bBuildAll)
         {
            var nInactiveCellX = nCol * nCellWidth + nXOffset;
            var nInactiveCellY = nRow * nCellHalfHeight;

            oCellData.x = nInactiveCellX;
            oCellData.y = nInactiveCellY;

            var mcInactiveCell =
               mcExternalContainer.InteractionCell.attachMovie(
                  "i1",
                  "cell" + nCellIndex,
                  nCellIndex,
                  {_x:nInactiveCellX,_y:nInactiveCellY}
               );

            mcInactiveCell.__proto__ = ank.battlefield.mc.Cell.prototype;
            mcInactiveCell.initialize(this._mcBattlefield);

            oCellData.mc = mcInactiveCell;
            mcInactiveCell.data = oCellData;
         }
      }

      // Only adjust the map when rendering the full map
      // (skip when updating a single cell)
      if (!bSingleCell)
      {
         // Check if streaming mode requires delayed adjustment
         if (ank.battlefield.Constants.USE_STREAMING_FILES
            && ank.battlefield.Constants.STREAMING_METHOD == "explod")
         {
            // If an adjustment timer already exists, do nothing
            // (prevents scheduling multiple adjustments)
            if (this._nAdjustTimer != undefined)
            {
               return undefined;
            }

            // Schedule map adjustment after a short delay
            // This allows streamed assets to finish loading
            this._nAdjustTimer =
               _global.setInterval(
                  this,
                  "adjustAndMaskMap",
                  ank.battlefield.MapHandler.TIME_BEFORE_AJUSTING_MAP
               );
         }
         else
         {
            // No streaming delay needed → adjust immediately
            this.adjustAndMaskMap();
         }
      }
   }
   function tacticMode(bOrig)
   {
      var bModeChanged = this._bTacticMode != bOrig;
      if(!bModeChanged)
      {
         return undefined;
      }
      var oMapData = this._oDatacenter.Map;
      var oMapCellsData = oMapData.data;
      if(bOrig)
      {
         this._mcContainer.ExternalContainer.clearGround();
         if(oMapData.savedBackgroundNum == undefined && oMapData.backgroundNum != 631)
         {
            oMapData.savedBackgroundNum = oMapData.backgroundNum;
         }
         oMapData.backgroundNum = 631;
      }
      else if(oMapData.savedBackgroundNum != undefined)
      {
         if(oMapData.savedBackgroundNum == 0)
         {
            oMapData.backgroundNum = 632;
         }
         else
         {
            oMapData.backgroundNum = oMapData.savedBackgroundNum;
         }
      }
      for(var mapCell in oMapCellsData)
      {
         this.tacticModeRefreshCell(Number(mapCell),bOrig);
      }
      this._bTacticMode = bOrig;
   }
   function tacticModeRefreshCell(nCellNum, bOrig)
   {
      if(nCellNum > this.getCellCount())
      {
         ank.utils.Logger.err("[MapHandler] (tacticModeRefreshCell) Cellule " + nCellNum + " inexistante");
         return undefined;
      }
      var oMapData = this._oDatacenter.Map;
      var oCellData = oMapData.data[nCellNum];
      if(oCellData.layerObject2Num == 4561 || oCellData.layerObject2Num == 4562)
      {
         return undefined;
      }
      if(!oCellData.active)
      {
         return undefined;
      }
      if(!bOrig)
      {
         var oBackupCellData = ank.battlefield.datacenter.Cell(oMapData.originalsCellsBackup.getItemAt(String(nCellNum)));
         if(oBackupCellData == undefined)
         {
            ank.utils.Logger.err("[MapHandler] (tacticModeRefreshCell) La case est déjà dans son état init");
            return undefined;
         }
         oCellData.layerGroundNum = oBackupCellData.layerGroundNum;
         oCellData.groundSlope = oBackupCellData.groundSlope;
         oCellData.layerObject1Rot = oBackupCellData.layerObject1Rot;
         oCellData.layerObject1Num = oBackupCellData.layerObject1Num;
         if(oCellData.layerObject2Num != 25)
         {
            oCellData.layerObject2Num = oBackupCellData.layerObject2Num;
         }
      }
      else
      {
         if(oCellData.nPermanentLevel == 0)
         {
            var oNewCellData = new ank.battlefield.datacenter.Cell();
            for(var cellData in oCellData)
            {
               oNewCellData[cellData] = oCellData[cellData];
            }
            oMapData.originalsCellsBackup.addItemAt(String(nCellNum),oNewCellData);
         }
         oCellData.turnTactic(this,oMapData);
      }
      this.build(oMapData,nCellNum);
   }
   function updateCell(nCellNum, oNewCell, sMaskHex, nPermanentLevel)
   {
      if(nCellNum > this.getCellCount())
      {
         ank.utils.Logger.err("[updateCell] Cellule " + nCellNum + " inexistante");
         return undefined;
      }
      if(nPermanentLevel == undefined || _global.isNaN(nPermanentLevel))
      {
         nPermanentLevel = 0;
      }
      else
      {
         nPermanentLevel = Number(nPermanentLevel);
      }
      var nMaskValue = _global.parseInt(sMaskHex,16);
      var bUpdateLayerObjectExternalAutoSize = (nMaskValue & 0x010000) != 0;
      var bUpdateLayerObjectExternalInteractive = (nMaskValue & 0x8000) != 0;
      var bUpdateLayerObjectExternal = (nMaskValue & 0x4000) != 0;
      var bUpdateActive = (nMaskValue & 0x2000) != 0;
      var bUpdateLineOfSight = (nMaskValue & 0x1000) != 0;
      var bUpdateMovement = (nMaskValue & 0x0800) != 0;
      var bUpdateGroundLevel = (nMaskValue & 0x0400) != 0;
      var bUpdateGroundSlope = (nMaskValue & 0x0200) != 0;
      var bUpdateLayerGroundNum = (nMaskValue & 0x0100) != 0;
      var bUpdateLayerGroundFlip = (nMaskValue & 0x80) != 0;
      var bUpdateLayerGroundRot = (nMaskValue & 0x40) != 0;
      var bUpdateLayerObject1Num = (nMaskValue & 0x20) != 0;
      var bUpdateLayerObject1Flip = (nMaskValue & 0x10) != 0;
      var bUpdateLayerObject1Rot = (nMaskValue & 8) != 0;
      var bUpdateLayerObject2Num = (nMaskValue & 4) != 0;
      var bUpdateLayerObject2Flip = (nMaskValue & 2) != 0;
      var bUpdateLayerObject2Interactive = (nMaskValue & 1) != 0;
      var oCellData = this._oDatacenter.Map.data[nCellNum];
      if(nPermanentLevel > 0)
      {
         if(oCellData.nPermanentLevel == 0)
         {
            var oBackupCellData = new ank.battlefield.datacenter.Cell();
            for(var k in oCellData)
            {
               oBackupCellData[k] = oCellData[k];
            }
            this._oDatacenter.Map.originalsCellsBackup.addItemAt(nCellNum,oBackupCellData);
            oCellData.nPermanentLevel = nPermanentLevel;
         }
      }
      if(bUpdateActive)
      {
         oCellData.active = oNewCell.active;
      }
      if(bUpdateLineOfSight)
      {
         oCellData.lineOfSight = oNewCell.lineOfSight;
      }
      if(bUpdateMovement)
      {
         oCellData.movement = oNewCell.movement;
      }
      if(bUpdateGroundLevel)
      {
         oCellData.groundLevel = oNewCell.groundLevel;
      }
      if(bUpdateGroundSlope)
      {
         oCellData.groundSlope = oNewCell.groundSlope;
      }
      if(bUpdateLayerGroundNum)
      {
         oCellData.layerGroundNum = oNewCell.layerGroundNum;
      }
      if(bUpdateLayerGroundFlip)
      {
         oCellData.layerGroundFlip = oNewCell.layerGroundFlip;
      }
      if(bUpdateLayerGroundRot)
      {
         oCellData.layerGroundRot = oNewCell.layerGroundRot;
      }
      if(bUpdateLayerObject1Num)
      {
         oCellData.layerObject1Num = oNewCell.layerObject1Num;
      }
      if(bUpdateLayerObject1Rot)
      {
         oCellData.layerObject1Rot = oNewCell.layerObject1Rot;
      }
      if(bUpdateLayerObject1Flip)
      {
         oCellData.layerObject1Flip = oNewCell.layerObject1Flip;
      }
      if(bUpdateLayerObject2Flip)
      {
         oCellData.layerObject2Flip = oNewCell.layerObject2Flip;
      }
      if(bUpdateLayerObject2Interactive)
      {
         oCellData.layerObject2Interactive = oNewCell.layerObject2Interactive;
      }
      if(bUpdateLayerObject2Num)
      {
         oCellData.layerObject2Num = oNewCell.layerObject2Num;
      }
      if(bUpdateLayerObjectExternal)
      {
         oCellData.layerObjectExternal = oNewCell.layerObjectExternal;
      }
      if(bUpdateLayerObjectExternalInteractive)
      {
         oCellData.layerObjectExternalInteractive = oNewCell.layerObjectExternalInteractive;
      }
      if(bUpdateLayerObjectExternalAutoSize)
      {
         oCellData.layerObjectExternalAutoSize = oNewCell.layerObjectExternalAutoSize;
      }
      oCellData.layerObjectExternalData = oNewCell.layerObjectExternalData;
      this.build(this._oDatacenter.Map,nCellNum);
   }
   function initializeMap(nPermanentLevel)
   {
      if(nPermanentLevel == undefined)
      {
         nPermanentLevel = Number.POSITIVE_INFINITY;
      }
      else
      {
         nPermanentLevel = Number(nPermanentLevel);
      }
      var oMapData = this._oDatacenter.Map;
      if(oMapData.savedBackgroundNum != undefined)
      {
         if(oMapData.savedBackgroundNum == 0)
         {
            oMapData.backgroundNum = 632;
         }
         else
         {
            oMapData.backgroundNum = oMapData.savedBackgroundNum;
         }
      }
      var oCellsData = oMapData.data;
      var oBackupCells = oMapData.originalsCellsBackup.getItems();
      for(var k in oBackupCells)
      {
         this.initializeCell(Number(k),nPermanentLevel);
      }
      this._bTacticMode = false;
   }
   function initializeCell(nCellNum, nPermanentLevel, bSaveTacticMode)
   {
      if(nPermanentLevel == undefined)
      {
         nPermanentLevel = Number.POSITIVE_INFINITY;
      }
      else
      {
         nPermanentLevel = Number(nPermanentLevel);
      }
      var oMapData = this._oDatacenter.Map;
      var oCellsData = oMapData.data;
      var oBackupCellData = oMapData.originalsCellsBackup.getItemAt(String(nCellNum));
      if(oBackupCellData == undefined)
      {
         ank.utils.Logger.err("[MapHandler] (initializeCell) La case est déjà dans son état init");
         return undefined;
      }
      if(oCellsData[nCellNum].nPermanentLevel <= nPermanentLevel)
      {
         if(bSaveTacticMode == true)
         {
            var bIsCellTactic = oCellsData[nCellNum].isTactic(oMapData);
            var oNewCellData = new ank.battlefield.datacenter.Cell();
            for(var cellData in oBackupCellData)
            {
               oNewCellData[cellData] = oBackupCellData[cellData];
            }
            if(bIsCellTactic)
            {
               oNewCellData.turnTactic(this,oMapData);
            }
            oCellsData[nCellNum] = oNewCellData;
            this.build(oMapData,nCellNum);
            if(!bIsCellTactic)
            {
               oMapData.originalsCellsBackup.removeItemAt(String(nCellNum));
            }
         }
         else
         {
            oCellsData[nCellNum] = oBackupCellData;
            this.build(oMapData,nCellNum);
            oMapData.originalsCellsBackup.removeItemAt(String(nCellNum));
         }
      }
   }
   // CERTAINS OBJECT 2 ONT PLUSIEURS FRAMS DANS LEUR SWF, JE PENSE QUE C'EST ICI QU'EST SET QUELLE FRAME CHOISIR
   function setObject2Frame(nCellNum, frame)
   {
      if(typeof frame == "number" && frame < 1)
      {
         ank.utils.Logger.err("[setObject2Frame] frame " + frame + " incorecte");
         return undefined;
      }
      if(nCellNum > this.getCellCount())
      {
         ank.utils.Logger.err("[setObject2Frame] Cellule " + nCellNum + " inexistante");
         return undefined;
      }
      var oCellData = this._oDatacenter.Map.data[nCellNum];
      var mcObject2 = oCellData.mcObject2;
      if(ank.battlefield.Constants.USE_STREAMING_FILES && (ank.battlefield.Constants.STREAMING_METHOD == "explod" && !mcObject2.fullLoaded))
      {
         this._oSettingFrames[nCellNum] = frame;
      }
      else if(ank.battlefield.Constants.USE_STREAMING_FILES && ank.battlefield.Constants.STREAMING_METHOD == "explod")
      {
         for(var sPropertyName in mcObject2)
         {
            if(mcObject2[sPropertyName] instanceof MovieClip)
            {
               mcObject2[sPropertyName].gotoAndStop(frame);
            }
         }
      }
      else
      {
         mcObject2.gotoAndStop(frame);
      }
   }
   function setObjectExternalFrame(nCellNum, frame)
   {
      if(typeof frame == "number" && frame < 1)
      {
         ank.utils.Logger.err("[setObject2Frame] frame " + frame + " incorecte");
         return undefined;
      }
      if(nCellNum > this.getCellCount())
      {
         ank.utils.Logger.err("[setObject2Frame] Cellule " + nCellNum + " inexistante");
         return undefined;
      }
      var oCellData = this._oDatacenter.Map.data[nCellNum];
      var mcExternalMovieClip = oCellData.mcObjectExternal._mcExternal;
      mcExternalMovieClip.gotoAndStop(frame);
   }
   function setObject2Interactive(nCellNum, bInteractive, nPermanentLevel)
   {
      if(nCellNum > this.getCellCount())
      {
         ank.utils.Logger.err("[setObject2State] Cellule " + nCellNum + " inexistante");
         return undefined;
      }
      var oCellData = this._oDatacenter.Map.data[nCellNum];
      if(oCellData.mcObject2 == this.api.gfx.rollOverMcObject)
      {
         this.api.gfx.onObjectRollOut(oCellData.mcObject2);
      }
      var oNewCellData = new ank.battlefield.datacenter.Cell();
      oNewCellData.layerObject2Interactive = bInteractive;
      this.updateCell(nCellNum,oNewCellData,"1",nPermanentLevel);
   }
   function getCellCount(Void)
   {
      return this._oDatacenter.Map.data.length;
   }
   function getCellData(nCellNum)
   {
      return this._oDatacenter.Map.data[nCellNum];
   }
   function getCellsData(Void)
   {
      return this._oDatacenter.Map.data;
   }
   function getWidth(Void)
   {
      return this._oDatacenter.Map.width;
   }
   function getHeight(Void)
   {
      return this._oDatacenter.Map.height;
   }
   function getCaseNum(nX, nY)
   {
      var nMapWidth_n = this.getWidth();
      return nX * nMapWidth_n + nY * (nMapWidth_n - 1);
   }
   function getCellHeight(nCellNum)
   {
      var oCellData_o = this.getCellData(nCellNum);
      var nSlopeOffset_n = !(oCellData_o.groundSlope == undefined || oCellData_o.groundSlope == 1) ? 0.5 : 0;
      var nLevelOffset_n = oCellData_o.groundLevel != undefined ? oCellData_o.groundLevel - 7 : 0;
      return nLevelOffset_n + nSlopeOffset_n;
   }
   function getLayerByCellPropertyName(oCellPropertyName)
   {
      var aPropertyValues = [];
      for(var i in this._oDatacenter.Map.data)
      {
         aPropertyValues.push(this._oDatacenter.Map.data[i][oCellPropertyName]);
      }
      return aPropertyValues;
   }
   function resetEmptyCells()
   {
      var oSprites = this._mcBattlefield.spriteHandler.getSprites().getItems();
      var oCellWithSprites = [];
      for(var k in oSprites)
      {
         var oSprite = oSprites[k];
         if(!( oSprite.isPendingClearing || (oSprite.isClear || oSprite.mc.gfx._width == 0 && getTimer() - oSprite.creationInstant > 1000)))
         {
            oCellWithSprites[oSprite.cellNum] = true;
         }
      }
      var nCellCount = this.getCellCount();
      var nRemovedSpriteCount = 0;
      var nCellIndex = 0;
      while(nCellIndex < nCellCount)
      {
         if(oCellWithSprites[nCellIndex] != true)
         {
            var oCellData = this._mcBattlefield.mapHandler.getCellData(nCellIndex);
            var nSpriteOnCount = oCellData.spriteOnCount;
            if(nSpriteOnCount != 0)
            {
               nRemovedSpriteCount += nSpriteOnCount;
               oCellData.removeAllSpritesOnID();
            }
         }
         nCellIndex = nCellIndex + 1;
      }
      if(nRemovedSpriteCount > 0)
      {
      }
   }
   function adjustAndMaskMap()
   {
      // If an adjustment timer exists, cancel it
      // This prevents repeated or duplicated adjustments
      if (this._nAdjustTimer != undefined)
      {
         _global.clearInterval(this._nAdjustTimer);
         this._nAdjustTimer = undefined;
      }

      // Apply a mask to the map container
      // This limits the visible area of the map
      this._mcContainer.applyMask(true);

      // Adjust the map layout (position / size)
      // Ensures the map fits correctly inside its container
      this._mcContainer.adjusteMap();
   }
   function onLoadInit(mc)
   {
      this._nLoadRequest = this._nLoadRequest - 1;
      if(this._oLoadingCells[mc] == undefined)
      {
         return undefined;
      }
      var aMovieClipPath = String(mc).split(".");
      var sLayerName = aMovieClipPath[aMovieClipPath.length - 2];
      var oCellData = this._oLoadingCells[mc];
      switch(sLayerName)
      {
         case "Ground":
            mc.cacheAsBitmap = _global.CONFIG.cacheAsBitmap["mapHandler/Cell/Ground"];
            mc._x = Number(oCellData.x);
            mc._y = Number(oCellData.y);
            if(oCellData.groundSlope == 1 && oCellData.layerGroundRot != 0)
            {
               mc._rotation = oCellData.layerGroundRot * 90;
               if(mc._rotation % 180)
               {
                  mc._yscale = 192.86;
                  mc._xscale = 51.85;
               }
               else
               {
                  var nScale_n = 100;
                  mc._xscale = nScale_n;
                  mc._yscale = nScale_n;
               }
            }
            else
            {
               mc._rotation = 0;
               var nScale_n = 100;
               mc._xscale = nScale_n;
               mc._yscale = nScale_n;
            }
            if(oCellData.layerGroundFlip)
            {
               mc._xscale *= -1;
            }
            else
            {
               mc._xscale *= 1;
            }
            if(oCellData.groundSlope != 1)
            {
               mc.gotoAndStop(oCellData.groundSlope);
            }
            mc.lastGroundID = oCellData.layerGroundNum;
            break;
         case "Object1":
            mc.cacheAsBitmap = _global.CONFIG.cacheAsBitmap["mapHandler/Cell/Object1"];
            mc._x = Number(oCellData.x);
            mc._y = Number(oCellData.y);
            if(oCellData.groundSlope == 1 && oCellData.layerObject1Rot != 0)
            {
               mc._rotation = oCellData.layerObject1Rot * 90;
               if(mc._rotation % 180)
               {
                  mc._yscale = 192.86;
                  mc._xscale = 51.85;
               }
               else
               {
                  var nScale_n = 100;
                  mc._xscale = nScale_n;
                  mc._yscale = nScale_n;
               }
            }
            else
            {
               mc._rotation = 0;
               var nScale_n = 100;
               mc._xscale = nScale_n;
               mc._yscale = nScale_n;
            }
            if(oCellData.layerObject1Flip)
            {
               mc._xscale *= -1;
            }
            else
            {
               mc._xscale *= 1;
            }
            mc.lastObject1ID = oCellData.layerObject1Num;
            break;
         case "Object2":
            mc.cacheAsBitmap = _global.CONFIG.cacheAsBitmap["mapHandler/Cell/Object2"];
            mc._x = Number(oCellData.x);
            mc._y = Number(oCellData.y);
            if(oCellData.layerObject2Interactive)
            {
               mc.__proto__ = ank.battlefield.mc.InteractiveObject.prototype;
               mc.initialize(this._mcBattlefield,oCellData,true);
            }
            else
            {
               mc.__proto__ = MovieClip.prototype;
            }
            if(oCellData.layerObject2Flip)
            {
               mc._xscale = -100;
            }
            else
            {
               mc._xscale = 100;
            }
            mc.lastObject2ID = oCellData.layerObject2Num;
      }
      if(this._oSettingFrames[oCellData.num] != undefined)
      {
         var oMcObject2s_o = this._oDatacenter.Map.data[oCellData.num].mcObject2;
         for(var s in oMcObject2s_o)
         {
            if(oMcObject2s_o[s] instanceof MovieClip)
            {
               oMcObject2s_o[s].gotoAndStop(this._oSettingFrames[oCellData.num]);
            }
         }
         delete this._oSettingFrames[oCellData.num];
      }
      mc.fullLoaded = true;
      delete this._oLoadingCells[mc];
   }
   function showTriggers()
   {
      var aCells_o = this.getCellsData();
      for(var i in aCells_o)
      {
         var oCell_o = aCells_o[i];
         var bIsTrigger_b = oCell_o.isTrigger;
         if(bIsTrigger_b)
         {
            this.flagCellNonBlocking(oCell_o.num);
         }
      }
   }
   function showFightCells(sTeam1Cells, sTeam2Cells)
   {
      if(sTeam1Cells == undefined || sTeam2Cells == undefined)
      {
         var oMapText_o = this.api.lang.getMapText(this._oDatacenter.Map.id);
         if(oMapText_o.p1 == undefined || oMapText_o.p2 == undefined)
         {
            return undefined;
         }
         sTeam1Cells = oMapText_o.p1;
         sTeam2Cells = oMapText_o.p2;
      }
      this._bShowingFightCells = true;
      var nIndex1_n = 0;
      while(nIndex1_n < sTeam1Cells.length)
      {
         var nCellNum_n = ank.utils.Compressor.decode64(sTeam1Cells.charAt(nIndex1_n)) << 6;
         nCellNum_n += ank.utils.Compressor.decode64(sTeam1Cells.charAt(nIndex1_n + 1));
         this.api.gfx.select(nCellNum_n,dofus.Constants.TEAMS_COLOR[0],"startPosition");
         nIndex1_n += 2;
      }
      var nIndex2_n = 0;
      while(nIndex2_n < sTeam2Cells.length)
      {
         var nCellNum2_n = ank.utils.Compressor.decode64(sTeam2Cells.charAt(nIndex2_n)) << 6;
         nCellNum2_n += ank.utils.Compressor.decode64(sTeam2Cells.charAt(nIndex2_n + 1));
         this.api.gfx.select(nCellNum2_n,dofus.Constants.TEAMS_COLOR[1],"startPosition");
         nIndex2_n += 2;
      }
   }
   function flagCellNonBlocking(nCellNum, sSprite)
   {
      if(sSprite == undefined)
      {
         sSprite = this.api.datacenter.Player.ID;
      }
      var oVisualEffect_o = new ank.battlefield.datacenter.VisualEffect();
      oVisualEffect_o.file = dofus.Constants.CLIPS_PATH + "flag.swf";
      oVisualEffect_o.bInFrontOfSprite = true;
      oVisualEffect_o.bTryToBypassContainerColor = true;
      this.api.gfx.spriteLaunchVisualEffect(sSprite,oVisualEffect_o,nCellNum,11,undefined,undefined,undefined,true,false);
   }
   function drawCellIds()
   {
      var mcCellIds_mc = this._mcContainer.createEmptyMovieClip("mcCellIds",this._mcContainer.getNextHighestDepth());
      mcCellIds_mc.cacheAsBitmap = true;
      var aValidCells_o = this.validCellsData;
      var nIndex_n = 0;
      while(nIndex_n < aValidCells_o.length)
      {
         var oCell_o = aValidCells_o[nIndex_n];
         var tfCell_tf = mcCellIds_mc.createTextField("cell" + oCell_o.num,mcCellIds_mc.getNextHighestDepth(),oCell_o.x,oCell_o.y,0,0);
         tfCell_tf.selectable = false;
         tfCell_tf.mouseWheelEnabled = false;
         tfCell_tf.autoSize = true;
         var tfFormat_o = new TextFormat();
         tfFormat_o.align = "center";
         tfFormat_o.size = 8;
         if(oCell_o.isTrigger)
         {
            tfFormat_o.color = 16773939;
         }
         else
         {
            tfFormat_o.color = 16777215;
         }
         tfFormat_o.bold = true;
         tfCell_tf.setNewTextFormat(tfFormat_o);
         tfCell_tf._alpha = 70;
         tfCell_tf.text = String(oCell_o.num);
         tfCell_tf._x -= tfCell_tf._width / 2;
         tfCell_tf._y -= tfCell_tf._height / 2;
         var aFilters_o = [];
         aFilters_o.push(new flash.filters.GlowFilter(0,40,2,2,4,1,false,false));
         tfCell_tf.filters = aFilters_o;
         nIndex_n = nIndex_n + 1;
      }
      return mcCellIds_mc;
   }
}
