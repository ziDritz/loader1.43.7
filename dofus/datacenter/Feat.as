class dofus.datacenter.Feat extends Object
{
   var api;
   var _nIndex;
   var _oFeatInfos;
   var _nLevel;
   var _aParams;
   function Feat(nIndex, nLevel, aParams)
   {
      super();
      this.api = _global.API;
      this.initialize(nIndex,nLevel,aParams);
   }
   function get index()
   {
      return this._nIndex;
   }
   function set index(nIndex)
   {
      this._nIndex = !(_global.isNaN(nIndex) || nIndex == undefined) ? nIndex : 0;
   }
   function get name()
   {
      return this._oFeatInfos.n;
   }
   function get level()
   {
      return this._nLevel;
   }
   function get effect()
   {
      return new dofus.datacenter.FeatEffect(this._oFeatInfos.e,this._aParams);
   }
   function get iconFile()
   {
      return dofus.Constants.FEATS_PATH + this._oFeatInfos.g + ".swf";
   }
   function initialize(nIndex, nLevel, aParams)
   {
      this._nIndex = nIndex;
      this._nLevel = nLevel;
      this._aParams = aParams;
      this._oFeatInfos = this.api.lang.getAlignmentFeat(nIndex);
   }
}
