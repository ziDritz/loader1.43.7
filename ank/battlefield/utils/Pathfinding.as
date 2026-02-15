class ank.battlefield.utils.Pathfinding
{
   static var DIRECTION_EAST = 0;
   static var DIRECTION_SOUTH_EAST = 1;
   static var DIRECTION_SOUTH = 2;
   static var DIRECTION_SOUTH_WEST = 3;
   static var DIRECTION_WEST = 4;
   static var DIRECTION_NORTH_WEST = 5;
   static var DIRECTION_NORTH = 6;
   static var DIRECTION_NORTH_EAST = 7;
   function Pathfinding()
   {
   }
   static function pathFind(api, mapHandler, nCellBegin, nCellEnd, oParams)
   {
      var bIsFight_b = api.datacenter.Game.isFight;
      if(nCellBegin == undefined)
      {
         return null;
      }
      if(nCellEnd == undefined)
      {
         return null;
      }
      if(bIsFight_b == undefined)
      {
         bIsFight_b = false;
      }
      var bAllDirections_b = oParams.bAllDirections != undefined ? oParams.bAllDirections : true;
      var nMaxLength_n = oParams.nMaxLength != undefined ? oParams.nMaxLength : 500;
      var bIgnoreSprites_b = oParams.bIgnoreSprites != undefined ? oParams.bIgnoreSprites : false;
      var bCellNumOnly_b = oParams.bCellNumOnly != undefined ? oParams.bCellNumOnly : false;
      var bWithBeginCellNum_b = oParams.bWithBeginCellNum != undefined ? oParams.bWithBeginCellNum : false;
      var nMapWidth_n = mapHandler.getWidth();
      if(bAllDirections_b)
      {
         var nDirCount_n = 8;
         var aDirOffsets_a = [1,nMapWidth_n,nMapWidth_n * 2 - 1,nMapWidth_n - 1,-1,- nMapWidth_n,- nMapWidth_n * 2 + 1,- (nMapWidth_n - 1)];
         var aDirCosts_a = [1.5,1,1.5,1,1.5,1,1.5,1];
      }
      else
      {
         nDirCount_n = 4;
         aDirOffsets_a = [nMapWidth_n,nMapWidth_n - 1,- nMapWidth_n,- (nMapWidth_n - 1)];
         aDirCosts_a = [1,1,1,1];
      }
      var aCellsData_a = mapHandler.getCellsData();
      var oOpenList_o = {};
      var oClosedList_o = {};
      var bOpenEmpty_b = false;
      var oResult_o = null;
      var oStartNode_o = oOpenList_o["oCell" + nCellBegin] = {};
      oStartNode_o.num = nCellBegin;
      oStartNode_o.g = 0;
      oStartNode_o.v = 0;
      oStartNode_o.h = ank.battlefield.utils.Pathfinding.goalDistEstimate(mapHandler,nCellBegin,nCellEnd);
      oStartNode_o.f = oStartNode_o.h;
      oStartNode_o.l = aCellsData_a[nCellBegin].groundLevel;
      oStartNode_o.m = aCellsData_a[nCellBegin].movement;
      oStartNode_o.parent = null;
      var aUnwalkableLayer_a = [];
      var nIndex_n = 0;
      while(nIndex_n < aCellsData_a.length - 1)
      {
         aUnwalkableLayer_a[nIndex_n] = aCellsData_a[nIndex_n].isUnwalkableLayerObject;
         nIndex_n = nIndex_n + 1;
      }
      var aTriggerCells_a = [];
      if(!bIgnoreSprites_b && !bIsFight_b)
      {
         var nTriggerIndex_n = 0;
         while(nTriggerIndex_n < aCellsData_a.length - 1)
         {
            aTriggerCells_a[nTriggerIndex_n] = aCellsData_a[nTriggerIndex_n].isTrigger;
            nTriggerIndex_n = nTriggerIndex_n + 1;
         }
      }
      while(!bOpenEmpty_b)
      {
         var sBestKey_s = null;
         var nBestF_n = 500000;
         for(var k in oOpenList_o)
         {
            if(oOpenList_o[k].f < nBestF_n)
            {
               nBestF_n = oOpenList_o[k].f;
               sBestKey_s = k;
            }
         }
         var oCurrentNode_o = oOpenList_o[sBestKey_s];
         delete oOpenList_o[sBestKey_s];
         if(oCurrentNode_o.num == nCellEnd)
         {
            var aPath_a = [];
            while(oCurrentNode_o.num != nCellBegin)
            {
               if(oCurrentNode_o.m == 0)
               {
                  aPath_a = [];
               }
               else if(bCellNumOnly_b)
               {
                  aPath_a.splice(0,0,oCurrentNode_o.num);
               }
               else
               {
                  aPath_a.splice(0,0,{num:oCurrentNode_o.num,dir:ank.battlefield.utils.Pathfinding.getDirection(mapHandler,oCurrentNode_o.parent.num,oCurrentNode_o.num)});
               }
               oCurrentNode_o = oCurrentNode_o.parent;
            }
            if(bWithBeginCellNum_b)
            {
               if(bCellNumOnly_b)
               {
                  aPath_a.splice(0,0,nCellBegin);
               }
               else
               {
                  aPath_a.splice(0,0,{num:nCellBegin,dir:ank.battlefield.utils.Pathfinding.getDirection(mapHandler,oCurrentNode_o.parent.num,nCellBegin)});
               }
            }
            return aPath_a;
         }
         var bEndMovementBlocked_b = false;
         var nDirIdx_n = 0;
         for(; nDirIdx_n < nDirCount_n; nDirIdx_n = nDirIdx_n + 1)
         {
            var nNeighborCell_n = oCurrentNode_o.num + aDirOffsets_a[nDirIdx_n];
            if(Math.abs(aCellsData_a[nNeighborCell_n].x - aCellsData_a[oCurrentNode_o.num].x) <= 53)
            {
               var oNeighborCell_o = aCellsData_a[nNeighborCell_n];
               bEndMovementBlocked_b = !(nNeighborCell_n == nCellEnd && oNeighborCell_o.movement == 1) ? false : true;
               var nNeighborGroundLevel_n = oNeighborCell_o.groundLevel;
               var bLevelOk_b = oCurrentNode_o.l == undefined || Math.abs(nNeighborGroundLevel_n - oCurrentNode_o.l) < 2;
               if(!bLevelOk_b || (!oNeighborCell_o.active || oNeighborCell_o.movement == 1 && !bEndMovementBlocked_b))
               {
                  continue;
               }
               var bPassable_b = true;
               if(!bIgnoreSprites_b)
               {
                  var nSpriteId_n = oNeighborCell_o.spriteOnID;
                  if(bIsFight_b)
                  {
                     bPassable_b = nSpriteId_n == undefined ? true : false;
                  }
                  else
                  {
                     var oSprite_o = api.gfx.spriteHandler.getSprite(nSpriteId_n);
                     bPassable_b = !(oSprite_o != undefined && (oSprite_o instanceof dofus.datacenter.Character && nNeighborCell_n != nCellEnd)) ? true : false;
                  }
                  if(bPassable_b && (nNeighborCell_n != nCellEnd && aTriggerCells_a[nNeighborCell_n] == true))
                  {
                     bPassable_b = false;
                  }
               }
               if(bPassable_b && (nNeighborCell_n != nCellEnd && aUnwalkableLayer_a[nNeighborCell_n] == true))
               {
                  bPassable_b = false;
               }
               if(!bPassable_b)
               {
                  continue;
               }
               var sNeighborKey_s = "oCell" + nNeighborCell_n;
               var nVcost_n = oCurrentNode_o.v + aDirCosts_a[nDirIdx_n] + (!(oNeighborCell_o.movement == 0 || oNeighborCell_o.movement == 1) ? 0 : 1000 + (nDirIdx_n % 2 != 0 ? 0 : 3)) + (!(oNeighborCell_o.movement == 1 && bEndMovementBlocked_b) ? (nDirIdx_n == oCurrentNode_o.d ? 0 : 0.5) + (5 - oNeighborCell_o.movement) / 3 : -1000);
               var nGcost_n = oCurrentNode_o.g + aDirCosts_a[nDirIdx_n];
               var nExistingVcost_n = null;
               if(oOpenList_o[sNeighborKey_s])
               {
                  nExistingVcost_n = oOpenList_o[sNeighborKey_s].v;
               }
               else if(oClosedList_o[sNeighborKey_s])
               {
                  nExistingVcost_n = oClosedList_o[sNeighborKey_s].v;
               }
               if((nExistingVcost_n == null || nExistingVcost_n > nVcost_n) && nGcost_n <= nMaxLength_n)
               {
                  if(oClosedList_o[sNeighborKey_s])
                  {
                     delete oClosedList_o[sNeighborKey_s];
                  }
                  var oNewNode_o = {};
                  oNewNode_o.num = nNeighborCell_n;
                  oNewNode_o.g = nGcost_n;
                  oNewNode_o.v = nVcost_n;
                  oNewNode_o.h = ank.battlefield.utils.Pathfinding.goalDistEstimate(mapHandler,nNeighborCell_n,nCellEnd);
                  oNewNode_o.f = oNewNode_o.v + oNewNode_o.h;
                  oNewNode_o.d = nDirIdx_n;
                  oNewNode_o.l = nNeighborGroundLevel_n;
                  oNewNode_o.m = oNeighborCell_o.movement;
                  oNewNode_o.parent = oCurrentNode_o;
                  oOpenList_o[sNeighborKey_s] = oNewNode_o;
               }
            }
         }
         oClosedList_o["oCell" + oCurrentNode_o.num] = {v:oCurrentNode_o.v};
         bOpenEmpty_b = true;
         for(var k in oOpenList_o)
         {
            bOpenEmpty_b = false;
            break;
         }
      }
      return null;
   }
   static function goalDistEstimate(mapHandler, nCell1, nCell2)
   {
      var oCoords1_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,nCell1);
      var oCoords2_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,nCell2);
      var nDx_n = Math.abs(oCoords1_o.x - oCoords2_o.x);
      var nDy_n = Math.abs(oCoords1_o.y - oCoords2_o.y);
      return Math.sqrt(Math.pow(nDx_n,2) + Math.pow(nDy_n,2));
   }
   static function goalDistance(mapHandler, nCell1, nCell2)
   {
      var oCoordsA_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,nCell1);
      var oCoordsB_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,nCell2);
      var nDx_n = Math.abs(oCoordsA_o.x - oCoordsB_o.x);
      var nDy_n = Math.abs(oCoordsA_o.y - oCoordsB_o.y);
      return nDx_n + nDy_n;
   }
   static function getCaseCoordonnee(mapHandler, nNum)
   {
      var nWidth_n = mapHandler.getWidth();
      var nRow_n = Math.floor(nNum / (nWidth_n * 2 - 1));
      var nRemainder_n = nNum - nRow_n * (nWidth_n * 2 - 1);
      var nCol_n = nRemainder_n % nWidth_n;
      var oCoords_o = {};
      oCoords_o.y = nRow_n - nCol_n;
      oCoords_o.x = (nNum - (nWidth_n - 1) * oCoords_o.y) / nWidth_n;
      return oCoords_o;
   }
   static function getTranslation1(nDir)
   {
      switch(nDir)
      {
         case ank.battlefield.utils.Pathfinding.DIRECTION_SOUTH_EAST:
            return 1;
         case ank.battlefield.utils.Pathfinding.DIRECTION_NORTH_WEST:
            return -1;
         default:
            return 0;
      }
   }
   static function getTranslation2(nDir)
   {
      switch(nDir)
      {
         case ank.battlefield.utils.Pathfinding.DIRECTION_SOUTH_WEST:
            return 1;
         case ank.battlefield.utils.Pathfinding.DIRECTION_NORTH_EAST:
            return -1;
         default:
            return 0;
      }
   }
   static function getDirection(mapHandler, nCell1, nCell2)
   {
      var nW_n = mapHandler.getWidth();
      var aOffsets_a = [1,nW_n,nW_n * 2 - 1,nW_n - 1,-1,- nW_n,- nW_n * 2 + 1,- (nW_n - 1)];
      var nDiff_n = nCell2 - nCell1;
      var nDir_n = 7;
      while(nDir_n >= 0)
      {
         if(aOffsets_a[nDir_n] == nDiff_n)
         {
            return nDir_n;
         }
         nDir_n = nDir_n - 1;
      }
      var oCoord1_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,nCell1);
      var oCoord2_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,nCell2);
      var nDx_n = oCoord2_o.x - oCoord1_o.x;
      var nDy_n = oCoord2_o.y - oCoord1_o.y;
      if(nDx_n == 0)
      {
         if(nDy_n > 0)
         {
            return 3;
         }
         return 7;
      }
      if(nDx_n > 0)
      {
         return 1;
      }
      return 5;
   }
   static function getDirectionCasterToImpact(casterCoords, impactCoords)
   {
      if(casterCoords.x > impactCoords.x)
      {
         return ank.battlefield.utils.Pathfinding.DIRECTION_NORTH_WEST;
      }
      if(casterCoords.x < impactCoords.x)
      {
         return ank.battlefield.utils.Pathfinding.DIRECTION_SOUTH_EAST;
      }
      if(casterCoords.y < impactCoords.y)
      {
         return ank.battlefield.utils.Pathfinding.DIRECTION_SOUTH_WEST;
      }
      return ank.battlefield.utils.Pathfinding.DIRECTION_NORTH_EAST;
   }
   static function getDirectionFromCoordinates(x1, y1, x2, y2, bAllDirections)
   {
      var nAngle_n = Math.atan2(y2 - y1,x2 - x1);
      if(bAllDirections)
      {
         if(nAngle_n >= (- Math.PI) / 8 && nAngle_n < Math.PI / 8)
         {
            return 0;
         }
         if(nAngle_n >= Math.PI / 8 && nAngle_n < Math.PI / 3)
         {
            return 1;
         }
         if(nAngle_n >= Math.PI / 3 && nAngle_n < 2 * Math.PI / 3)
         {
            return 2;
         }
         if(nAngle_n >= 2 * Math.PI / 3 && nAngle_n < 7 * Math.PI / 8)
         {
            return 3;
         }
         if(nAngle_n >= 7 * Math.PI / 8 || nAngle_n < -7 * Math.PI / 8)
         {
            return 4;
         }
         if(nAngle_n >= -7 * Math.PI / 8 && nAngle_n < -2 * Math.PI / 3)
         {
            return 5;
         }
         if(nAngle_n >= -2 * Math.PI / 3 && nAngle_n < (- Math.PI) / 3)
         {
            return 6;
         }
         if(nAngle_n >= (- Math.PI) / 3 && nAngle_n < (- Math.PI) / 8)
         {
            return 7;
         }
      }
      else
      {
         if(nAngle_n >= 0 && nAngle_n < Math.PI / 2)
         {
            return 1;
         }
         if(nAngle_n >= Math.PI / 2 && nAngle_n <= Math.PI)
         {
            return 3;
         }
         if(nAngle_n >= - Math.PI && nAngle_n < (- Math.PI) / 2)
         {
            return 5;
         }
         if(nAngle_n >= (- Math.PI) / 2 && nAngle_n < 0)
         {
            return 7;
         }
      }
      return 1;
   }
   static function getArroundCellNum(mapHandler, nCellNum, nDirectionModerator, nIndex)
   {
      var nW_n = mapHandler.getWidth();
      var aOffsets_a = [1,nW_n,nW_n * 2 - 1,nW_n - 1,-1,- nW_n,- nW_n * 2 + 1,- (nW_n - 1)];
      var nResultDir_n = 0;
      switch(nIndex % 8)
      {
         case 0:
            nResultDir_n = 2;
            break;
         case 1:
            nResultDir_n = 6;
            break;
         case 2:
            nResultDir_n = 4;
            break;
         case 3:
            nResultDir_n = 0;
            break;
         case 4:
            nResultDir_n = 3;
            break;
         case 5:
            nResultDir_n = 5;
            break;
         case 6:
            nResultDir_n = 1;
            break;
         case 7:
            nResultDir_n = 7;
      }
      nResultDir_n = (nResultDir_n + nDirectionModerator) % 8;
      var nResultCell_n = nCellNum + aOffsets_a[nResultDir_n];
      var aCellsData_a = mapHandler.getCellsData();
      var oResultCell_o = aCellsData_a[nResultCell_n];
      if(oResultCell_o.active && (aCellsData_a[nResultCell_n] != undefined && Math.abs(aCellsData_a[nResultCell_n].x - aCellsData_a[nCellNum].x) <= 53))
      {
         return nResultCell_n;
      }
      return nCellNum;
   }
   static function convertHeightToFourDirection(nDirection)
   {
      return nDirection | 1;
   }
   static function getSlopeOk(slope1, level1, slope2, level2, dir)
   {
      switch(dir)
      {
         case 0:
            if(((slope1 - 1 & 2) >> 1) + level1 != (slope2 - 1 & 1) + level2)
            {
               return false;
            }
            break;
         case 1:
            if(((slope1 - 1 & 4) >> 2) + level1 != ((slope2 - 1 & 2) >> 1) + level2)
            {
               return false;
            }
            if(((slope1 - 1 & 8) >> 3) + level1 != (slope2 - 1 & 1) + level2)
            {
               return false;
            }
            break;
         case 2:
            if(((slope1 - 1 & 8) >> 3) + level1 != ((slope2 - 1 & 2) >> 1) + level2)
            {
               return false;
            }
            break;
         case 3:
            if(((slope1 - 1 & 8) >> 3) + level1 != ((slope2 - 1 & 4) >> 2) + level2)
            {
               return false;
            }
            if((slope1 - 1 & 1) + level1 != ((slope2 - 1 & 2) >> 1) + level2)
            {
               return false;
            }
            break;
         case 4:
            if((slope1 - 1 & 1) + level1 != ((slope2 - 1 & 4) >> 2) + level2)
            {
               return false;
            }
            break;
         case 5:
            if((slope1 - 1 & 1) + level1 != ((slope2 - 1 & 8) >> 3) + level2)
            {
               return false;
            }
            if(((slope1 - 1 & 2) >> 1) + level1 != ((slope2 - 1 & 4) >> 2) + level2)
            {
               return false;
            }
            break;
         case 6:
            if(((slope1 - 1 & 2) >> 1) + level1 != ((slope2 - 1 & 8) >> 3) + level2)
            {
               return false;
            }
            break;
         case 7:
            if(((slope1 - 1 & 2) >> 1) + level1 != (slope2 - 1 & 1) + level2)
            {
               return false;
            }
            if(((slope1 - 1 & 4) >> 2) + level1 != ((slope2 - 1 & 8) >> 3) + level2)
            {
               return false;
            }
            break;
      }
      return true;
   }
   static function checkView(mapHandler, cell1, cell2)
   {
      var oTargetCell_o = mapHandler.getCellData(cell2);
      if(!oTargetCell_o.lineOfSight || !oTargetCell_o.active)
      {
         return false;
      }
      var aCellsBetween_a = ank.battlefield.utils.Pathfinding.getCellsIdBetween(mapHandler,cell1,cell2);
      var nIdx_n = 0;
      while(nIdx_n < aCellsBetween_a.length - 1)
      {
         var nBetweenCell_n = aCellsBetween_a[nIdx_n];
         if(!ank.battlefield.utils.Pathfinding.isCellFreeForLOS(mapHandler,nBetweenCell_n,cell1,cell2))
         {
            return false;
         }
         nIdx_n = nIdx_n + 1;
      }
      return true;
   }
   static function getCellsIdBetween(mapHandler, from, to)
   {
      if(from == to)
      {
         return [];
      }
      var oFrom_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,from);
      var oTo_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,to);
      var nX1_n = oFrom_o.x;
      var nY1_n = oFrom_o.y;
      var nX2_n = oTo_o.x;
      var nY2_n = oTo_o.y;
      var nDx_n = nX2_n - nX1_n;
      var nDy_n = nY2_n - nY1_n;
      var nDist_n = Math.sqrt(nDx_n * nDx_n + nDy_n * nDy_n);
      var nDirX_n = nDx_n / nDist_n;
      var nDirY_n = nDy_n / nDist_n;
      var nAbsX_n = Math.abs(1 / nDirX_n);
      var nAbsY_n = Math.abs(1 / nDirY_n);
      var nSignX_n = nDirX_n >= 0 ? 1 : -1;
      var nSignY_n = nDirY_n >= 0 ? 1 : -1;
      var nTx_n = 0.5 * nAbsX_n;
      var nTy_n = 0.5 * nAbsY_n;
      var aResult_a = [];
      while(nX1_n != nX2_n || nY1_n != nY2_n)
      {
         if(Math.abs(nTx_n - nTy_n) < 1e-10)
         {
            nTx_n += nAbsX_n;
            nTy_n += nAbsY_n;
            nX1_n += nSignX_n;
            nY1_n += nSignY_n;
         }
         else if(nTx_n < nTy_n)
         {
            nTx_n += nAbsX_n;
            nX1_n += nSignX_n;
         }
         else
         {
            nTy_n += nAbsY_n;
            nY1_n += nSignY_n;
         }
         var nCell_n = ank.battlefield.utils.Pathfinding.getCaseNum(mapHandler,nX1_n,nY1_n);
         aResult_a.push(nCell_n);
      }
      return aResult_a;
   }
   static function isCellFreeForLOS(mapHandler, cellNum)
   {
      var oCell_o = mapHandler.getCellData(cellNum);
      if(!oCell_o.lineOfSight || !oCell_o.active)
      {
         return false;
      }
      var nSpriteId_n = oCell_o.spriteOnID;
      var oApi_o = _global.API;
      var oSprite_o = nSpriteId_n == undefined ? undefined : oApi_o.gfx.spriteHandler.getSprite(nSpriteId_n);
      var bSpriteVisible_b = oSprite_o != undefined && !oSprite_o.isInvisibleInFight;
      if(bSpriteVisible_b)
      {
         return false;
      }
      return true;
   }
   static function getCaseNum(mapHandler, x, y)
   {
      var nWidth_n = mapHandler.getWidth();
      return x * nWidth_n + y * (nWidth_n - 1);
   }
   static function checkAlign(mapHandler, cell1, cell2)
   {
      var oCoords1_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,cell1);
      var oCoords2_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,cell2);
      if(oCoords1_o.x == oCoords2_o.x)
      {
         return true;
      }
      if(oCoords1_o.y == oCoords2_o.y)
      {
         return true;
      }
      return false;
   }
   static function checkRange(mapHandler, nCell1, nCell2, bLineOnly, nRangeMin, nRangeMax, nRangeModerator)
   {
      nRangeMin = Number(nRangeMin);
      nRangeMax = Number(nRangeMax);
      nRangeModerator = Number(nRangeModerator);
      if(nRangeMax != 0)
      {
         nRangeMax += nRangeModerator;
         nRangeMax = Math.max(nRangeMin,nRangeMax);
      }
      if(bLineOnly)
      {
         if(!ank.battlefield.utils.Pathfinding.checkAlign(mapHandler,nCell1,nCell2))
         {
            return false;
         }
      }
      if(ank.battlefield.utils.Pathfinding.goalDistance(mapHandler,nCell1,nCell2) > nRangeMax || ank.battlefield.utils.Pathfinding.goalDistance(mapHandler,nCell1,nCell2) < nRangeMin)
      {
         return false;
      }
      return true;
   }
}
