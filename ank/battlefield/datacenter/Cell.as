class ank.battlefield.datacenter.Cell extends Object
{
   var y;
   var allSpritesOn;
   var nPermanentLevel;
   var num;
   var active = true;
   var lineOfSight = true;
   var layerGroundRot = 0;
   var groundLevel = 7;
   var movement = 4;
   var layerGroundNum = 0;
   var groundSlope = 1;
   var layerGroundFlip = false;
   var layerObject1Num = 0;
   var layerObject1Rot = 0;
   var layerObject1Flip = false;
   var layerObject2Flip = false;
   var layerObject2Interactive = false;
   var layerObject2Num = 0;
   function Cell()
   {
      super();
   }
   function get rootY()
   {
      return this.y - (7 - this.groundLevel) * ank.battlefield.Constants.LEVEL_HEIGHT;
   }
   function get isTrigger()
   {
      var bIsTrigger_b = false;
      var nIdx_n = 0;
      while(nIdx_n < dofus.Constants.MAP_TRIGGER_LAYEROBJECTS.length)
      {
         var nTriggerId_n = dofus.Constants.MAP_TRIGGER_LAYEROBJECTS[nIdx_n];
         if(this.layerObject1Num == nTriggerId_n || this.layerObject2Num == nTriggerId_n)
         {
            bIsTrigger_b = true;
            break;
         }
         nIdx_n = nIdx_n + 1;
      }
      return bIsTrigger_b;
   }
   function get isUnwalkableLayerObject()
   {
      var bUnwalkable_b = false;
      var nIdx_n = 0;
      while(nIdx_n < dofus.Constants.MAP_UNWALKABLE_LAYEROBJECTS.length)
      {
         var nUnwalkableId_n = dofus.Constants.MAP_UNWALKABLE_LAYEROBJECTS[nIdx_n];
         if(this.layerObject1Num == nUnwalkableId_n || this.layerObject2Num == nUnwalkableId_n)
         {
            bUnwalkable_b = true;
            break;
         }
         nIdx_n = nIdx_n + 1;
      }
      return bUnwalkable_b;
   }
   function get isTargetable()
   {
      return this.movement != 0 && (this.movement != 1 && this.active);
   }
   function isTactic(map)
   {
      var bTactic_b = false;
      if(this.layerGroundNum == 0 && (this.groundSlope == 1 && (this.layerObject2Num == 0 || (this.layerObject2Num == dofus.Constants.getTacticLayerObject2(map.subarea) || (this.layerObject2Num == 25 || this.layerObject2Num == 1030)))))
      {
         if(!this.lineOfSight)
         {
            if(this.layerObject1Num == dofus.Constants.getTacticGfx(map.subarea,0))
            {
               bTactic_b = true;
            }
         }
         else if(this.movement == 0 || this.movement == 1)
         {
            if(this.layerObject1Num == 10002)
            {
               bTactic_b = true;
            }
         }
         else if(this.layerObject1Num == dofus.Constants.getTacticGfx(map.subarea,1) || this.layerObject1Num == dofus.Constants.getTacticGfx(map.subarea,3))
         {
            bTactic_b = true;
         }
      }
      return bTactic_b;
   }
   function addSpriteOnID(sID)
   {
      if(this.allSpritesOn == undefined)
      {
         this.allSpritesOn = {};
      }
      if(sID == undefined)
      {
         return undefined;
      }
      if(this.allSpritesOn[sID])
      {
         return undefined;
      }
      this.allSpritesOn[sID] = true;
      var api_o = _global.API;
      var aPath_o = api_o.datacenter.Basics.interactionsManager_path;
      if(aPath_o != undefined)
      {
         var oLastCell_o = api_o.gfx.mapHandler.getCellData(aPath_o[aPath_o.length - 1].num);
         if(oLastCell_o != undefined && oLastCell_o.mc.onRollOver)
         {
            oLastCell_o.mc.onRollOver();
         }
      }
   }
   function removeSpriteOnID(sID)
   {
      this.allSpritesOn[sID] = undefined;
      delete this.allSpritesOn[sID];
   }
   function removeAllSpritesOnID()
   {
      for(var k in this.allSpritesOn)
      {
         this.allSpritesOn[k] = undefined;
         delete this.allSpritesOn[k];
      }
      delete this.allSpritesOn;
   }
   function get spriteOnCount()
   {
      var nCount_n = 0;
      for(var sID_s in this.allSpritesOn)
      {
         nCount_n = nCount_n + 1;
      }
      return nCount_n;
   }
   function get spriteOnID()
   {
      if(this.allSpritesOn == undefined)
      {
         return undefined;
      }
      for(var sID_s in this.allSpritesOn)
      {
         if(this.allSpritesOn[sID_s])
         {
            return String(sID_s);
         }
      }
      return undefined;
   }
   function get carriedSpriteOnId()
   {
      if(this.allSpritesOn == undefined)
      {
         return false;
      }
      for(var sID_s in this.allSpritesOn)
      {
         if(this.allSpritesOn[sID_s].hasCarriedChild())
         {
            return true;
         }
      }
      return false;
   }
   function turnTactic(mapHandler, map)
   {
      var bWasTrigger_b = this.isTrigger;
      if(this.nPermanentLevel == 0)
      {
         this.nPermanentLevel = 1;
      }
      this.layerGroundNum = 0;
      this.groundSlope = 1;
      this.layerObject1Rot = 0;
      if(!this.lineOfSight)
      {
         this.layerObject1Num = dofus.Constants.getTacticGfx(map.subarea,0);
      }
      else if(this.movement == 0 || this.movement == 1)
      {
         this.layerObject1Num = 10002;
      }
      else
      {
         var oCoord_o = ank.battlefield.utils.Pathfinding.getCaseCoordonnee(mapHandler,this.num);
         var bParity_b = Math.abs(oCoord_o.x) % 2 == Math.abs(oCoord_o.y) % 2;
         this.layerObject1Num = !bParity_b ? dofus.Constants.getTacticGfx(map.subarea,3) : dofus.Constants.getTacticGfx(map.subarea,1);
      }
      if(this.layerObject2Num != 25)
      {
         if(!this.lineOfSight)
         {
            this.layerObject2Num = dofus.Constants.getTacticLayerObject2(map.subarea);
         }
         else if(bWasTrigger_b)
         {
            this.layerObject2Num = 1030;
         }
         else
         {
            this.layerObject2Num = 0;
         }
      }
   }
}
