class dofus.datacenter.MountableCreature
{
   var _sGfxFile;
   var _nGfxID;
   function MountableCreature(sGfxFile, nGfxID)
   {
      this.initialize(sGfxFile,nGfxID);
   }
   function get gfxFile()
   {
      return this._sGfxFile;
   }
   function initialize(sGfxFile, nGfxID)
   {
      this._sGfxFile = sGfxFile;
      this._nGfxID = nGfxID;
      mx.events.EventDispatcher.initialize(this);
   }
}
