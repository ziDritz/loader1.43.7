class dofus.datacenter.PlayableCharacter extends ank.battlefield.datacenter.Sprite
{
   /**
    * Type: Global API reference
    * Purpose: Provides access to game APIs and managers
    */
   var api;
   
   /**
    * Type: Number
    * Purpose: Graphics/Sprite ID for visual representation
    */
   var _gfxID;
   
   /**
    * Type: dofus.managers.GameActionsManager
    * Purpose: Manages character actions during combat and gameplay
    */
   var GameActionsManager;
   
   /**
    * Type: dofus.managers.CharacteristicsManager
    * Purpose: Manages and calculates character statistics and bonuses
    */
   var CharacteristicsManager;
   
   /**
    * Type: dofus.managers.EffectsManager
    * Purpose: Manages active effects, buffs, and debuffs on the character
    */
   var EffectsManager;
   
   /**
    * Type: Number
    * Purpose: Current Action Points (AP) available for character actions
    */
   var _ap;
   
   /**
    * Type: Number
    * Purpose: Current Movement Points (MP) available for character movement
    */
   var _mp;
   
   /**
    * Type: Number
    * Purpose: Unique character identifier
    */
   var id;
   
   /**
    * Type: MovieClip
    * Purpose: The visual representation of the character on battlefield
    */
   var mc;
   
   /**
    * Type: String
    * Purpose: Character name for display purposes
    */
   var _name;
   
   /**
    * Type: Number
    * Purpose: Character experience level
    */
   var _level;
   
   /**
    * Type: Function
    * Purpose: Broadcasts messages to listeners (AsBroadcaster pattern)
    */
   var broadcastMessage;
   
   /**
    * Type: Number
    * Purpose: Experience points accumulated by character
    */
   var _xp;
   
   /**
    * Type: Number
    * Purpose: Current Life Points (health) of the character
    */
   var _lp;
   
   /**
    * Type: Function
    * Purpose: Dispatches events to listeners (EventDispatcher pattern)
    */
   var dispatchEvent;
   
   /**
    * Type: Number
    * Purpose: Maximum Life Points the character can have
    */
   var _lpmax;
   
   /**
    * Type: Number
    * Purpose: Initial Action Points at turn start (before modifiers)
    */
   var _apinit;
   
   /**
    * Type: Number
    * Purpose: Initial Movement Points at turn start (before modifiers)
    */
   var _mpinit;
   
   /**
    * Type: Number
    * Purpose: Currency (gold) amount
    */
   var _kama;
   
   /**
    * Type: Number
    * Purpose: Team allegiance (0=neutral, 1=team1, 2=team2, etc)
    */
   var _team;
   
   /**
    * Type: Array
    * Purpose: Array of equipped accessories and weapons
    */
   var _aAccessories;
   
   /**
    * Type: Number
    * Purpose: PvP reward gain from defeating this character
    */
   var _nPvpGain;
   
   /**
    * Type: Boolean
    * Purpose: Indicates if character is a summon (not player-controlled)
    */
   var _summoned = false;
   /**
    * Purpose: Constructor for creating a new playable character instance
    * Parameters:
    *   - sID: (String) Unique character identifier
    *   - clipClass: (Object) MovieClip class for visual representation
    *   - sGfxFile: (String) Graphics file to load for character sprite
    *   - cellNum: (Number) Starting cell position on battlefield
    *   - dir: (Number) Starting direction/facing (0-7)
    *   - gfxID: (Number) Graphics identifier for the character model
    * Data Flow: Creates sprite instance and initializes with provided parameters
    */
   function PlayableCharacter(sID, clipClass, sGfxFile, cellNum, dir, gfxID)
   {
      super();
      if(this.__proto__ == dofus.datacenter.PlayableCharacter.prototype)
      {
         this.initialize(sID,clipClass,sGfxFile,cellNum,dir,gfxID);
      }
   }
   /**
    * Purpose: Initializes character with sprite, managers, and event systems
    * Parameters:
    *   - sID: (String) Character ID
    *   - clipClass: (Object) Visual clip class
    *   - sGfxFile: (String) Graphics file path
    *   - cellNum: (Number) Starting cell position
    *   - dir: (Number) Starting direction
    *   - gfxID: (Number) Graphics model ID
    * Data Flow: Sets up parent sprite, API reference, managers (actions, characteristics, effects), loads player AP/MP if player character, enables messaging systems
    * Steps:
    *   1. Initialize parent sprite with basic parameters
    *   2. Store API reference from global scope
    *   3. Store graphics identifier
    *   4. Create and assign GameActionsManager
    *   5. Create and assign CharacteristicsManager
    *   6. Create and assign EffectsManager
    *   7. Load player AP/MP if this is the player character
    *   8. Initialize AsBroadcaster for message broadcasting
    *   9. Initialize EventDispatcher for event system
    */
   function initialize(sID, clipClass, sGfxFile, cellNum, dir, gfxID)
   {
      // 1. Initialize parent sprite with basic parameters
      super.initialize(sID,clipClass,sGfxFile,cellNum,dir);
      
      // 2. Store API reference from global scope
      this.api = _global.API;
      
      // 3. Store graphics identifier
      this._gfxID = gfxID;
      
      // 4. Create and assign GameActionsManager
      this.GameActionsManager = new dofus.managers.GameActionsManager(this,this.api);
      
      // 5. Create and assign CharacteristicsManager
      this.CharacteristicsManager = new dofus.managers.CharacteristicsManager(this,this.api);
      
      // 6. Create and assign EffectsManager
      this.EffectsManager = new dofus.managers.EffectsManager(this,this.api);
      
      // 7. Load player AP/MP if this is the player character
      if(sID == this.api.datacenter.Player.ID)
      {
         this._ap = this.api.datacenter.Player.AP;
         this._mp = this.api.datacenter.Player.MP;
      }
      
      // 8. Initialize AsBroadcaster for message broadcasting
      AsBroadcaster.initialize(this);
      
      // 9. Initialize EventDispatcher for event system
      mx.events.EventDispatcher.initialize(this);
   }
   /**
    * Purpose: Updates character's life points and triggers related UI/animation effects
    * Parameters:
    *   - dLP: (Number) Delta life points to add/subtract (negative for damage)
    * Data Flow: Modifies LP, applies permanent damage multiplier when damage taken, updates UI components, triggers animations
    * Steps:
    *   1. Apply LP delta change to current LP
    *   2. Check if damage taken (dLP < 0) and in fight
    *   3. Calculate permanent damage reduction to max LP
    *   4. If player character, sync max LP to player data
    *   5. Update UI Banner component with new max LP
    *   6. Update UI StatJob component with new max LP
    *   7. Update Timeline character list display
    *   8. Create floating life point animation
    *   9. If damage taken and animations enabled, play "Hit" animation
    */
   function updateLP(dLP)
   {
      // 1. Apply LP delta change to current LP
      this.LP += Number(dLP);
      
      // 2. Check if damage taken (dLP < 0) and in fight
      if(dLP < 0 && this.api.datacenter.Game.isFight)
      {
         // 3. Calculate permanent damage reduction to max LP
         this.LPmax -= Math.floor((- dLP) * this.api.lang.getConfigText("PERMANENT_DAMAGE"));
         
         // 4. If player character, sync max LP to player data
         if(this.api.datacenter.Player.ID == this.id)
         {
            // 5. Update UI Banner component with new max LP
            this.api.datacenter.Player.LPmax = this.LPmax;
            this.api.ui.getUIComponent("Banner").lpMaxChanged({value:this.LPmax});
            
            // 6. Update UI StatJob component with new max LP
            this.api.ui.getUIComponent("StatJob").lpMaxChanged({value:this.LPmax});
         }
         
         // 7. Update Timeline character list display
         this.api.ui.getUIComponent("Timeline").timelineControl.updateCharacters();
      }
      
      // 8. Create floating life point animation
      this.api.gfx.fightPointAnimManager.addLifePointAnim(this.id,dLP);
      
      // 9. If damage taken and animations enabled, play "Hit" animation
      if(dLP < 0 && (!this.api.datacenter.Player.isSkippingFightAnimations && this.api.electron.isWindowFocused))
      {
         this.mc.setAnim("Hit");
      }
   }
   /**
    * Purpose: Updates character's action points and creates visual feedback animation
    * Parameters:
    *   - dAP: (Number) Delta action points (positive gain, negative loss)
    *   - bUsed: (Boolean) Whether AP was consumed by an action (only validates for non-player characters)
    * Data Flow: Modifies current AP (clamped to minimum 0), creates floating point animation for UI feedback
    * Steps:
    *   1. Default bUsed to false if undefined
    *   2. Validate: prevent non-player characters from gaining AP when consumed
    *   3. Apply AP delta change
    *   4. Clamp AP to minimum of 0 (no negative AP)
    *   5. Create floating AP animation in UI
    */
   function updateAP(dAP, bUsed)
   {
      // 1. Default bUsed to false if undefined
      if(bUsed == undefined)
      {
         bUsed = false;
      }
      
      // 2. Validate: prevent non-player characters from gaining AP when consumed
      if(this.api.datacenter.Game.currentPlayerID != this.id && bUsed)
      {
         return undefined;
      }
      
      // 3. Apply AP delta change
      this.AP += Number(dAP);
      
      // 4. Clamp AP to minimum of 0 (no negative AP)
      this.AP = Math.max(0,this.AP);
      
      // 5. Create floating AP animation in UI
      this.api.gfx.fightPointAnimManager.addActionPointAnim(this.id,dAP);
   }
   /**
    * Purpose: Initializes AP at turn start, optionally applying characteristic bonuses
    * Parameters:
    *   - bWithModerator: (Boolean) Whether to apply stat bonuses to initial AP (default: true)
    * Data Flow: Sets AP to base value plus optional moderator bonus (AP stat modifiers)
    * Steps:
    *   1. Default bWithModerator to true if undefined
    *   2. If applying bonuses:
    *      a. Retrieve AP bonus from CharacteristicsManager (characteristic ID "1")
    *      b. Set AP to base APinit plus bonus
    *   3. Else set AP to base APinit without bonus
    */
   function initAP(bWithModerator)
   {
      // 1. Default bWithModerator to true if undefined
      if(bWithModerator == undefined)
      {
         bWithModerator = true;
      }
      
      // 2. If applying bonuses
      if(bWithModerator)
      {
         // a. Retrieve AP bonus from CharacteristicsManager (characteristic ID "1")
         var _loc3_ = this.CharacteristicsManager.getModeratorValue("1");
         
         // b. Set AP to base APinit plus bonus
         this.AP = Number(this.APinit) + Number(_loc3_);
      }
      // 3. Else set AP to base APinit without bonus
      else
      {
         this.AP = Number(this.APinit);
      }
   }
   /**
    * Purpose: Updates character's movement points and creates visual feedback animation
    * Parameters:
    *   - dMP: (Number) Delta movement points (positive gain, negative loss)
    *   - bUsed: (Boolean) Whether MP was consumed by movement (only validates for non-player characters)
    * Data Flow: Modifies current MP (clamped to minimum 0), creates floating point animation for UI feedback
    * Steps:
    *   1. Default bUsed to false if undefined
    *   2. Validate: prevent non-player characters from gaining MP when consumed
    *   3. Convert dMP to number and store as local variable
    *   4. Apply MP delta change
    *   5. Clamp MP to minimum of 0 (no negative MP)
    *   6. Create floating MP animation in UI
    */
   function updateMP(dMP, bUsed)
   {
      // 1. Default bUsed to false if undefined
      if(bUsed == undefined)
      {
         bUsed = false;
      }
      
      // 2. Validate: prevent non-player characters from gaining MP when consumed
      if(this.api.datacenter.Game.currentPlayerID != this.id && bUsed)
      {
         return undefined;
      }
      
      // 3. Convert dMP to number and store as local variable
      var _loc4_ = Number(dMP);
      
      // 4. Apply MP delta change
      this.MP += _loc4_;
      
      // 5. Clamp MP to minimum of 0 (no negative MP)
      this.MP = Math.max(0,this.MP);
      
      // 6. Create floating MP animation in UI
      this.api.gfx.fightPointAnimManager.addMovePointAnim(this.id,_loc4_);
   }
   /**
    * Purpose: Initializes MP at turn start, optionally applying characteristic bonuses
    * Parameters:
    *   - bWithModerator: (Boolean) Whether to apply stat bonuses to initial MP (default: true)
    * Data Flow: Sets MP to base value plus optional moderator bonus (movement stat modifiers)
    * Steps:
    *   1. Default bWithModerator to true if undefined
    *   2. If applying bonuses:
    *      a. Retrieve MP bonus from CharacteristicsManager (characteristic ID "23")
    *      b. Set MP to base MPinit plus bonus
    *   3. Else set MP to base MPinit without bonus
    */
   function initMP(bWithModerator)
   {
      // 1. Default bWithModerator to true if undefined
      if(bWithModerator == undefined)
      {
         bWithModerator = true;
      }
      
      // 2. If applying bonuses
      if(bWithModerator)
      {
         // a. Retrieve MP bonus from CharacteristicsManager (characteristic ID "23")
         var _loc3_ = this.CharacteristicsManager.getModeratorValue("23");
         
         // b. Set MP to base MPinit plus bonus
         this.MP = Number(this.MPinit) + Number(_loc3_);
      }
      // 3. Else set MP to base MPinit without bonus
      else
      {
         this.MP = Number(this.MPinit);
      }
   }
   /**
    * Purpose: Get the graphics/sprite ID
    * Data Flow: Returns stored graphics identifier
    */
   function get gfxID()
   {
      return this._gfxID;
   }
   
   /**
    * Purpose: Set the graphics/sprite ID
    * Parameters:
    *   - value: (Number) Graphics model identifier
    */
   function set gfxID(value)
   {
      this._gfxID = value;
   }
   /**
    * Purpose: Get the character name
    * Data Flow: Returns stored character name string
    */
   function get name()
   {
      return this._name;
   }
   
   /**
    * Purpose: Set the character name
    * Parameters:
    *   - value: (String) Character display name
    */
   function set name(value)
   {
      this._name = value;
   }
   /**
    * Purpose: Get the character experience level
    * Data Flow: Returns stored character level number
    */
   function get Level()
   {
      return this._level;
   }
   
   /**
    * Purpose: Set the character level and broadcast change notification
    * Parameters:
    *   - value: (Number) New character level
    * Data Flow: Stores numeric level value and notifies listeners via broadcast
    */
   function set Level(value)
   {
      this._level = Number(value);
      this.broadcastMessage("onSetLevel",value);
   }
   /**
    * Purpose: Get the character experience points
    * Data Flow: Returns stored experience points number
    */
   function get XP()
   {
      return this._xp;
   }
   
   /**
    * Purpose: Set the character XP and broadcast change notification
    * Parameters:
    *   - value: (Number) New experience points
    * Data Flow: Stores numeric XP value and notifies listeners via broadcast
    */
   function set XP(value)
   {
      this._xp = Number(value);
      this.broadcastMessage("onSetXP",value);
   }
   /**
    * Purpose: Get the character current life points
    * Data Flow: Returns stored LP (health) number
    */
   function get LP()
   {
      return this._lp;
   }
   
   /**
    * Purpose: Set the character LP and dispatch change event with broadcasts
    * Parameters:
    *   - value: (Number) New life points (clamped to minimum 0)
    * Data Flow: Stores LP value (minimum 0), dispatches event, broadcasts to listeners
    * Steps:
    *   1. Check if value equals current LP, exit early if no change
    *   2. Clamp LP to minimum of 0 (no negative health)
    *   3. Dispatch lpChanged event with value and character ID
    *   4. Broadcast onSetLP message with new and old LP values
    */
   function set LP(value)
   {
      // 1. Check if value equals current LP, exit early if no change
      if(this._lp == value)
      {
         return;
      }
      
      // 2. Clamp LP to minimum of 0 (no negative health)
      this._lp = Number(value) <= 0 ? 0 : Number(value);
      
      // 3. Dispatch lpChanged event with value and character ID
      this.dispatchEvent({type:"lpChanged",value:value,id:this.id});
      
      // 4. Broadcast onSetLP message with new and old LP values
      this.broadcastMessage("onSetLP",value,this.LP);
   }
   /**
    * Purpose: Get the character maximum life points
    * Data Flow: Returns stored maximum LP (health cap) number
    */
   function get LPmax()
   {
      return this._lpmax;
   }
   
   /**
    * Purpose: Set the maximum LP and dispatch change event with broadcasts
    * Parameters:
    *   - value: (Number) New maximum life points
    * Data Flow: Stores max LP value, dispatches event, broadcasts to listeners
    * Steps:
    *   1. Check if value equals current LPmax, exit early if no change
    *   2. Store numeric max LP value
    *   3. Dispatch lpMaxChanged event with new max LP value
    *   4. Broadcast onSetLPmax message with new max LP and original value
    */
   function set LPmax(value)
   {
      // 1. Check if value equals current LPmax, exit early if no change
      if(this._lpmax == value)
      {
         return;
      }
      
      // 2. Store numeric max LP value
      this._lpmax = Number(value);
      
      // 3. Dispatch lpMaxChanged event with new max LP value
      this.dispatchEvent({type:"lpMaxChanged",value:value});
      
      // 4. Broadcast onSetLPmax message with new max LP and original value
      this.broadcastMessage("onSetLPmax",this.LPmax,value);
   }
   /**
    * Purpose: Get the character current action points
    * Data Flow: Returns stored AP number
    */
   function get AP()
   {
      return this._ap;
   }
   
   /**
    * Purpose: Set the character AP and dispatch change event with broadcasts
    * Parameters:
    *   - value: (Number) New action points count
    * Data Flow: Stores AP value, dispatches event, broadcasts to listeners
    * Steps:
    *   1. Check if value equals current AP, exit early if no change
    *   2. Store numeric AP value
    *   3. Dispatch apChanged event with value and character ID
    *   4. Broadcast onSetAP message with new AP value
    */
   function set AP(value)
   {
      // 1. Check if value equals current AP, exit early if no change
      if(this._ap == value)
      {
         return;
      }
      
      // 2. Store numeric AP value
      this._ap = Number(value);
      
      // 3. Dispatch apChanged event with value and character ID
      this.dispatchEvent({type:"apChanged",value:value,id:this.id});
      
      // 4. Broadcast onSetAP message with new AP value
      this.broadcastMessage("onSetAP",value);
   }
   /**
    * Purpose: Get the base initial action points (before bonuses)
    * Data Flow: Returns stored initial AP number
    */
   function get APinit()
   {
      return this._apinit;
   }
   
   /**
    * Purpose: Set the base initial action points value
    * Parameters:
    *   - value: (Number) Base AP at turn start (before modifiers)
    */
   function set APinit(value)
   {
      this._apinit = Number(value);
   }
   /**
    * Purpose: Get the character current movement points
    * Data Flow: Returns stored MP number
    */
   function get MP()
   {
      return this._mp;
   }
   
   /**
    * Purpose: Set the character MP and dispatch change event with broadcasts
    * Parameters:
    *   - value: (Number) New movement points count
    * Data Flow: Stores MP value, dispatches event, broadcasts to listeners
    * Steps:
    *   1. Check if value equals current MP, exit early if no change
    *   2. Store numeric MP value
    *   3. Dispatch mpChanged event with value and character ID
    *   4. Broadcast onSetMP message with new MP value
    */
   function set MP(value)
   {
      // 1. Check if value equals current MP, exit early if no change
      if(this._mp == value)
      {
         return;
      }
      
      // 2. Store numeric MP value
      this._mp = Number(value);
      
      // 3. Dispatch mpChanged event with value and character ID
      this.dispatchEvent({type:"mpChanged",value:value,id:this.id});
      
      // 4. Broadcast onSetMP message with new MP value
      this.broadcastMessage("onSetMP",value);
   }
   /**
    * Purpose: Get the base initial movement points (before bonuses)
    * Data Flow: Returns stored initial MP number
    */
   function get MPinit()
   {
      return this._mpinit;
   }
   
   /**
    * Purpose: Set the base initial movement points value
    * Parameters:
    *   - value: (Number) Base MP at turn start (before modifiers)
    */
   function set MPinit(value)
   {
      this._mpinit = Number(value);
   }
   /**
    * Purpose: Get the character currency (gold) amount
    * Data Flow: Returns stored Kama number
    */
   function get Kama()
   {
      return this._kama;
   }
   
   /**
    * Purpose: Set the character currency and broadcast change
    * Parameters:
    *   - value: (Number) New Kama (gold) amount
    * Data Flow: Stores currency value and notifies listeners via broadcast
    */
   function set Kama(value)
   {
      this._kama = Number(value);
      this.broadcastMessage("onSetKama",value);
   }
   /**
    * Purpose: Get the character team allegiance
    * Data Flow: Returns stored team number (0=neutral, 1/2=team members, etc)
    */
   function get Team()
   {
      return this._team;
   }
   
   /**
    * Purpose: Set the character team allegiance
    * Parameters:
    *   - value: (Number) Team identifier (0=neutral, 1=team1, 2=team2, etc)
    */
   function set Team(value)
   {
      this._team = Number(value);
   }
   /**
    * Purpose: Get the character's equipped weapon
    * Data Flow: Returns the first item in accessories array (weapon slot)
    */
   function get Weapon()
   {
      return this._aAccessories[0];
   }
   /**
    * Purpose: Get the animation key for current weapon's action animation
    * Data Flow: Retrieves weapon animation property from item data, defaults based on game state
    * Steps:
    *   1. Get weapon's unicID (unique item identifier)
    *   2. Retrieve item text data from language API
    *   3. Check if animation property (an) exists in item data
    *   4. If no animation property:
    *      a. Return "anim0" if in fight (combat animation)
    *      b. Return "anim3" if not in fight (idle animation)
    *   5. If animation property exists, return "anim" concatenated with property value
    */
   function get ToolAnimation()
   {
      // 1. Get weapon's unicID (unique item identifier)
      var _loc2_ = this.Weapon.unicID;
      
      // 2. Retrieve item text data from language API
      var _loc3_ = this.api.lang.getItemUnicText(_loc2_);
      
      // 3. Check if animation property (an) exists in item data
      if(_loc3_.an == undefined)
      {
         // 4a. Return "anim0" if in fight (combat animation)
         if(this.api.datacenter.Game.isFight)
         {
            return "anim0";
         }
         
         // 4b. Return "anim3" if not in fight (idle animation)
         return "anim3";
      }
      
      // 5. If animation property exists, return "anim" concatenated with property value
      return "anim" + _loc3_.an;
   }
   /**
    * Purpose: Get the full path to the character's artwork SWF file
    * Data Flow: Constructs path from artwork directory constant, graphics filename, and .swf extension
    */
   function get artworkFile()
   {
      return dofus.Constants.ARTWORKS_BIG_PATH + this.gfxFileName + ".swf";
   }
   /**
    * Purpose: Set whether character is a summon (non-player-controlled)
    * Parameters:
    *   - bIsSummoned: (Boolean) True if character is a summon
    */
   function set isSummoned(bIsSummoned)
   {
      this._summoned = bIsSummoned;
   }
   
   /**
    * Purpose: Get whether character is a summon
    * Data Flow: Returns boolean indicating if character is summoned or player-controlled
    */
   function get isSummoned(bIsSummoned)
   {
      return this._summoned;
   }
   /**
    * Purpose: Set the PvP reward gain from defeating this character
    * Parameters:
    *   - nPvpGain: (Number) PvP reward points/rank gain value
    */
   function set pvpGain(nPvpGain)
   {
      this._nPvpGain = nPvpGain;
   }
   
   /**
    * Purpose: Get the PvP reward gain value
    * Data Flow: Returns PvP points earned from defeating this character
    */
   function get pvpGain()
   {
      return this._nPvpGain;
   }
}
