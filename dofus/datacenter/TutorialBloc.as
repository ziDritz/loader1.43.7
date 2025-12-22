class dofus.datacenter.TutorialBloc extends Object
{
   var _sID;
   var _nType;
   static var TYPE_ACTION = 0;
   static var TYPE_WAITING = 1;
   static var TYPE_IF = 2;
   function TutorialBloc(sID, nType)
   {
      super();
      this._sID = sID;
      this._nType = nType;
   }
   function get id()
   {
      return this._sID;
   }
   function get type()
   {
      return this._nType;
   }
}
