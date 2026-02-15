class ank.battlefield.utils.Compressor extends ank.utils.Compressor
{
   function Compressor()
   {
      super();
   }

   // There is no map decompression, only cells are uncompressed
   static function uncompressMap(mapID, name, width, height, backgroundNum, sData, oMap, bForced)
   {
      if(oMap == undefined)
      {
         return undefined;
      }
      var aCells_o = [];
      var aValidCells_o = [];
      var nDataLen_n = sData.length;
      var nCellIndex_n = 0;
      var nCharIndex_n = 0;
      while(nCharIndex_n < nDataLen_n)
      {
         var oCell_o = ank.battlefield.utils.Compressor.uncompressCell(sData.substring(nCharIndex_n,nCharIndex_n + 10),bForced,0);
         oCell_o.num = nCellIndex_n;
         aCells_o.push(oCell_o);
         nCellIndex_n = nCellIndex_n + 1;
         if(oCell_o.isTargetable)
         {
            aValidCells_o.push(oCell_o);
         }
         nCharIndex_n += 10;
      }
      oMap.id = Number(mapID);
      oMap.name = name;
      oMap.width = Number(width);
      oMap.height = Number(height);
      oMap.backgroundNum = backgroundNum;
      oMap.data = aCells_o;
      oMap.validCells = aValidCells_o;
   }
   static function uncompressCell(sData, bForced, nPermanentLevel)
   {
      if(bForced == undefined)
      {
         bForced = false;
      }
      if(nPermanentLevel == undefined)
      {
         nPermanentLevel = 0;
      }
      else
      {
         nPermanentLevel = Number(nPermanentLevel);
      }
      var oCell = new ank.battlefield.datacenter.Cell();
      var aChars = sData.split("");
      var i = aChars.length - 1;
      var aCodes = [];
      while(i >= 0)
      {
         aCodes[i] = ank.utils.Compressor._self._hashCodes[aChars[i]];
         i = i - 1;
      }
      oCell.active = !((aCodes[0] & 0x20) >> 5) ? false : true;
      if(oCell.active || bForced)
      {
         oCell.nPermanentLevel = nPermanentLevel;
         oCell.lineOfSight = !(aCodes[0] & 1) ? false : true;
         oCell.layerGroundRot = (aCodes[1] & 0x30) >> 4;
         oCell.groundLevel = aCodes[1] & 0x0F;
         oCell.movement = (aCodes[2] & 0x38) >> 3;
         oCell.layerGroundNum = ((aCodes[0] & 0x18) << 6) + ((aCodes[2] & 7) << 6) + aCodes[3];
         oCell.groundSlope = (aCodes[4] & 0x3C) >> 2;
         oCell.layerGroundFlip = !((aCodes[4] & 2) >> 1) ? false : true;
         oCell.layerObject1Num = ((aCodes[0] & 4) << 11) + ((aCodes[4] & 1) << 12) + (aCodes[5] << 6) + aCodes[6];
         oCell.layerObject1Rot = (aCodes[7] & 0x30) >> 4;
         oCell.layerObject1Flip = !((aCodes[7] & 8) >> 3) ? false : true;
         oCell.layerObject2Flip = !((aCodes[7] & 4) >> 2) ? false : true;
         oCell.layerObject2Interactive = !((aCodes[7] & 2) >> 1) ? false : true;
         oCell.layerObject2Num = ((aCodes[0] & 2) << 12) + ((aCodes[7] & 1) << 12) + (aCodes[8] << 6) + aCodes[9];
         oCell.layerObjectExternal = "";
         oCell.layerObjectExternalInteractive = false;
      }
      return oCell;
   }
   static function compressMap(oMap)
   {
      if(oMap == undefined)
      {
         return undefined;
      }
      var aCompressedCells_s = [];
      var aCells_o = oMap.data;
      var nCellCount_n = aCells_o.length;
      var nIndex_n = 0;
      while(nIndex_n < nCellCount_n)
      {
         aCompressedCells_s.push(ank.battlefield.utils.Compressor.compressCell(aCells_o[nIndex_n]));
         nIndex_n = nIndex_n + 1;
      }
      return aCompressedCells_s.join("");
   }
   static function compressCell(oCell)
   {
      var aValues_n = [0,0,0,0,0,0,0,0,0,0];
      aValues_n[0] = (!oCell.active ? 0 : 1) << 5;
      aValues_n[0] |= !oCell.lineOfSight ? 0 : 1;
      aValues_n[0] |= (oCell.layerGroundNum & 0x0600) >> 6;
      aValues_n[0] |= (oCell.layerObject1Num & 0x2000) >> 11;
      aValues_n[0] |= (oCell.layerObject2Num & 0x2000) >> 12;
      aValues_n[1] = (oCell.layerGroundRot & 3) << 4;
      aValues_n[1] |= oCell.groundLevel & 0x0F;
      aValues_n[2] = (oCell.movement & 7) << 3;
      aValues_n[2] |= oCell.layerGroundNum >> 6 & 7;
      aValues_n[3] = oCell.layerGroundNum & 0x3F;
      aValues_n[4] = (oCell.groundSlope & 0x0F) << 2;
      aValues_n[4] |= (!oCell.layerGroundFlip ? 0 : 1) << 1;
      aValues_n[4] |= oCell.layerObject1Num >> 12 & 1;
      aValues_n[5] = oCell.layerObject1Num >> 6 & 0x3F;
      aValues_n[6] = oCell.layerObject1Num & 0x3F;
      aValues_n[7] = (oCell.layerObject1Rot & 3) << 4;
      aValues_n[7] |= (!oCell.layerObject1Flip ? 0 : 1) << 3;
      aValues_n[7] |= (!oCell.layerObject2Flip ? 0 : 1) << 2;
      aValues_n[7] |= (!oCell.layerObject2Interactive ? 0 : 1) << 1;
      aValues_n[7] |= oCell.layerObject2Num >> 12 & 1;
      aValues_n[8] = oCell.layerObject2Num >> 6 & 0x3F;
      aValues_n[9] = oCell.layerObject2Num & 0x3F;
      var nIdx_n = aValues_n.length - 1;
      while(nIdx_n >= 0)
      {
         aValues_n[nIdx_n] = ank.utils.Compressor.encode64(aValues_n[nIdx_n]);
         nIdx_n = nIdx_n - 1;
      }
      var sEncoded_s = aValues_n.join("");
      return sEncoded_s;
   }
   static function compressPath(aFullPathData, bWithFirst)
   {
      var sCompressed_s = new String();
      var aLightPath_o = ank.battlefield.utils.Compressor.makeLightPath(aFullPathData,bWithFirst);
      var nLen_n = aLightPath_o.length;
      var nIndex_n = 0;
      while(nIndex_n < nLen_n)
      {
         var oStep_o = aLightPath_o[nIndex_n];
         var nDir_n = oStep_o.dir & 7;
         var nHigh_n = (oStep_o.num & 0x0FC0) >> 6;
         var nLow_n = oStep_o.num & 0x3F;
         sCompressed_s += ank.utils.Compressor.encode64(nDir_n);
         sCompressed_s += ank.utils.Compressor.encode64(nHigh_n);
         sCompressed_s += ank.utils.Compressor.encode64(nLow_n);
         nIndex_n = nIndex_n + 1;
      }
      return sCompressed_s;
   }
   static function makeLightPath(aFullPath, bWithFirst)
   {
      if(aFullPath == undefined)
      {
         ank.utils.Logger.err("Le chemin est vide");
         return [];
      }
      var aLightPath_o = [];
      if(bWithFirst)
      {
         aLightPath_o.push(aFullPath[0]);
      }
      var nI_n = aFullPath.length - 1;
      var nPrevDir_n = undefined;
      while(nI_n >= 0)
      {
         if(aFullPath[nI_n].dir != nPrevDir_n)
         {
            aLightPath_o.splice(0,0,aFullPath[nI_n]);
            nPrevDir_n = aFullPath[nI_n].dir;
         }
         nI_n = nI_n - 1;
      }
      return aLightPath_o;
   }
   static function extractFullPath(mapHandler, compressedData)
   {
      var aLightPath_o = [];
      var aChars_a = compressedData.split("");
      var nLen_n = compressedData.length;
      var nCellCount_n = mapHandler.getCellCount();
      var nIndex_n = 0;
      while(nIndex_n < nLen_n)
      {
         aChars_a[nIndex_n] = ank.utils.Compressor.decode64(aChars_a[nIndex_n]);
         aChars_a[nIndex_n + 1] = ank.utils.Compressor.decode64(aChars_a[nIndex_n + 1]);
         aChars_a[nIndex_n + 2] = ank.utils.Compressor.decode64(aChars_a[nIndex_n + 2]);
         var nCellNum_n = (aChars_a[nIndex_n + 1] & 0x0F) << 6 | aChars_a[nIndex_n + 2];
         if(nCellNum_n < 0)
         {
            ank.utils.Logger.err("Case pas sur carte");
            return null;
         }
         if(nCellNum_n > nCellCount_n)
         {
            ank.utils.Logger.err("Case pas sur carte");
            return null;
         }
         aLightPath_o.push({num:nCellNum_n,dir:aChars_a[nIndex_n]});
         nIndex_n += 3;
      }
      return ank.battlefield.utils.Compressor.makeFullPath(mapHandler,aLightPath_o);
   }
   static function makeFullPath(mapHandler, aLightPath)
   {
      var aFullPath_o = [];
      var nIndex_n = 0;
      var nMapWidth_n = mapHandler.getWidth();
      var aDirOffsets_n = [1,nMapWidth_n,nMapWidth_n * 2 - 1,nMapWidth_n - 1,-1,- nMapWidth_n,- nMapWidth_n * 2 + 1,- (nMapWidth_n - 1)];
      var nCurrentNum_n = aLightPath[0].num;
      aFullPath_o[nIndex_n] = nCurrentNum_n;
      var nLightIndex_n = 1;
      while(nLightIndex_n < aLightPath.length)
      {
         var nTargetNum_n = aLightPath[nLightIndex_n].num;
         var nDir_n = aLightPath[nLightIndex_n].dir;
         var nSafety_n = 2 * nMapWidth_n + 1;
         while(aFullPath_o[nIndex_n] != nTargetNum_n)
         {
            nCurrentNum_n += aDirOffsets_n[nDir_n];
            aFullPath_o[nIndex_n = nIndex_n + 1] = nCurrentNum_n;
            if((nSafety_n = nSafety_n - 1) < 0)
            {
               ank.utils.Logger.err("Chemin impossible");
               return null;
            }
         }
         nCurrentNum_n = nTargetNum_n;
         nLightIndex_n = nLightIndex_n + 1;
      }
      return aFullPath_o;
   }
}
