class dofus.datacenter.DofusMap extends ank.battlefield.datacenter.Map
{
   var id;
   var eaMountParks;
   function DofusMap(nID)
   {
      super(nID);
   }
   function get coordinates()
   {
      var oMapText = _global.API.lang.getMapText(this.id);
      return _global.API.lang.getText("COORDINATES") + " : " + oMapText.x + ", " + oMapText.y;
   }
   function get x()
   {
      return _global.API.lang.getMapText(this.id).x;
   }
   function get y()
   {
      return _global.API.lang.getMapText(this.id).y;
   }
   function get superarea()
   {
      var oLang = _global.API.lang;
      return oLang.getMapAreaInfos(this.subarea).superareaID;
   }
   function get area()
   {
      var oLang = _global.API.lang;
      return oLang.getMapAreaInfos(this.subarea).areaID;
   }
   function get subarea()
   {
      var oLang = _global.API.lang;
      return oLang.getMapText(this.id).sa;
   }
   function get musics()
   {
      var oLang = _global.API.lang;
      return oLang.getMapSubAreaText(this.subarea).m;
   }
   function get dungeonID()
   {
      return Number(_global.API.lang.getMapText(this.id).d);
   }
   function get dungeon()
   {
      return _global.API.lang.getDungeonText(this.dungeonID);
   }
   function get dungeonName()
   {
      return this.dungeon.n;
   }
   function get dungeonFloorName()
   {
      return this.dungeonCurrentMap.n;
   }
   function get dungeonCurrentMap()
   {
      return this.dungeon.m[this.id];
   }
   function get isDungeon()
   {
      return !_global.isNaN(this.dungeonID);
   }
   static function isJail(nMapId)
   {
      switch(nMapId)
      {
         case 10240:
         case 8726:
         case 666:
            return true;
         default:
            return false;
      }
   }
   static function isTournament(nMapId)
   {
      switch(nMapId)
      {
         case 12224:
         case 12229:
         case 12225:
         case 12223:
         case 12228:
         case 12226:
         case 12227:
         case 7285:
         case 7286:
         case 7280:
         case 7283:
         case 7281:
         case 10368:
         case 7282:
            return true;
         default:
            return false;
      }
   }
   function get firstMountPark()
   {
      return this.eaMountParks[0];
   }
   function getMountPark(instance)
   {
      var i = 0;
      while(i < this.eaMountParks.length)
      {
         var oPark = this.eaMountParks[i];
         if(oPark.instanceId == instance)
         {
            return oPark;
         }
         i = i + 1;
      }
      return undefined;
   }
   function get mountParks()
   {
      return this.eaMountParks;
   }
   function resetMountPark()
   {
      this.eaMountParks = new ank.utils.ExtendedArray();
   }
   function addMountPark(oPark)
   {
      this.eaMountParks.push(oPark);
   }
}
