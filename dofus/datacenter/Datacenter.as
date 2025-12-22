class dofus.datacenter.Datacenter extends Object
{
   var _oAPI;
   var Player;
   var Basics;
   var Challenges;
   var Sprites;
   var Houses;
   var Storages;
   var Game;
   var Conquest;
   var Subareas;
   var Map;
   var Temporary;
   var Survey;
   var Temporis;
   var Exchange;
   function Datacenter(oAPI)
   {
      super();
      this.initialize(oAPI);
   }
   function initialize(oAPI)
   {
      this._oAPI = oAPI;
      this.Player = new dofus.datacenter.LocalPlayer(oAPI);
      this.Basics = new dofus.datacenter.Basics();
      this.Challenges = new ank.utils.ExtendedObject();
      this.Sprites = new ank.utils.ExtendedObject();
      this.Houses = new ank.utils.ExtendedObject();
      this.Storages = new ank.utils.ExtendedObject();
      this.Game = new dofus.datacenter.Game();
      this.Conquest = new dofus.datacenter.Conquest();
      this.Subareas = new ank.utils.ExtendedObject();
      this.Map = new dofus.datacenter.DofusMap();
      this.Temporary = {};
      this.Survey = new dofus.datacenter.SurveyManager();
      this.Temporis = new dofus.datacenter.evenemential.TemporisData();
   }
   function clear()
   {
      this.Player = new dofus.datacenter.LocalPlayer(this._oAPI);
      this.Basics.initialize();
      this.Challenges = new ank.utils.ExtendedObject();
      this.Sprites = new ank.utils.ExtendedObject();
      this.Houses = new ank.utils.ExtendedObject();
      this.Storages = new ank.utils.ExtendedObject();
      this.Game = new dofus.datacenter.Game();
      this.Conquest = new dofus.datacenter.Conquest();
      this.Subareas = new ank.utils.ExtendedObject();
      this.Map = new dofus.datacenter.DofusMap();
      this.Temporary = {};
      this.Survey = new dofus.datacenter.SurveyManager();
      this.Temporis = new dofus.datacenter.evenemential.TemporisData();
      delete this.Exchange;
   }
   function clearGame()
   {
      this.Game = new dofus.datacenter.Game();
   }
}
