/**
 * One-line class purpose
 * Top-level runtime state container that holds shared data objects.
 *
 * General description 
 * `Datacenter` initializes and exposes singleton-like data objects used across the client (Player, Game,
 * Map, etc.). It provides a central place to read and mutate shared state, and to reset subsets of that
 * state during session transitions.
 *
 * Sprite Creation from Server Data process
 * During sprite creation, network handlers (e.g., `GameIn`) construct sprite data objects from server
 * messages and store them in `Datacenter.Sprites`. The rendering system (`Battlefield`/`SpriteHandler`)
 * then reads these entries to create and manage visual `Sprite` MovieClips. `Datacenter` itself does not
 * create sprites; it holds the authoritative collection and provides reset methods (`clear`, `clearGame`)
 * that truncate the sprite registry when maps or sessions change.
 */

class dofus.datacenter.Datacenter extends Object
{
   var _oAPI;
   var Player;
   var Basics;
   var Challenges;
   /** Registry of all sprite data objects keyed by sprite ID; populated by network handlers and consumed
    * by the rendering system. */
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

   /**
    * clear
    *
    * Purpose:
    * Resets all top-level data objects, including the sprite registry, typically on map change or logout.
    */
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
