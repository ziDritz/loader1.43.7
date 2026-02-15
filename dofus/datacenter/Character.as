class dofus.datacenter.Character extends dofus.datacenter.PlayableCharacter
{
   // Field: String - Display title/rank name shown above character
   var _title;
   // Field: Boolean - Indicates whether character completed TTG (Treasure Trial Game) collection
   var _bHasTtgCollection;
   // Field: Number - Guild identifier for character's guild membership
   var _nGuild;
   // Field: Number - Character gender/sex identifier
   var _nSex;
   // Field: Number - Character aura visual indicator
   var _nAura;
   // Field: Object - Alignment information containing faction and rank data
   var _oAlignment;
   // Field: Boolean - Indicates whether character is active as a merchant
   var _bMerchant;
   // Field: Number - Game server identifier where character resides
   var _nServerID;
   // Field: Boolean - Current death state of the character
   var _bDied;
   // Field: Object - Rank/prestige information for character progression
   var _oRank;
   // Field: Array - List of craft job skill identifiers mastered by character
   var _aMultiCraftSkillsID;
   // Field: String - Display name of character's guild
   var _sGuildName;
   // Field: Object - Guild emblem visual representation data
   var _oEmblem;
   // Field: Number - Bitmap flags encoding character restrictions (attack, exchange, walk, etc.)
   var _nRestrictions;
   // Field: Function - Event dispatcher for character state changes
   var dispatchEvent;
   // Field: Array - Base resistance values for 7 elements (Neutral, Earth, Fire, Water, Air, DodgePA, DodgePM)
   var _aResistances;
   // Field: Object - Manager instance for character stat modifiers and characteristics
   var CharacteristicsManager;
   // Static Constant: Number - Maximum neutral element resistance modifier (capped at 50%)
   static var MAX_NEUTRAL_RESISTANCE_MIXED = 50;
   // Static Constant: Number - Maximum earth element resistance modifier (capped at 50%)
   static var MAX_EARTH_RESISTANCE_MIXED = 50;
   // Static Constant: Number - Maximum water element resistance modifier (capped at 50%)
   static var MAX_WATER_RESISTANCE_MIXED = 50;
   // Static Constant: Number - Maximum fire element resistance modifier (capped at 50%)
   static var MAX_FIRE_RESISTANCE_MIXED = 50;
   // Static Constant: Number - Maximum air element resistance modifier (capped at 50%)
   static var MAX_AIR_RESISTANCE_MIXED = 50;
   // Field: Object - Configuration flags for top-layer animation clipping behavior
   var xtraClipTopAnimations = {staticF:true};
   // Purpose: Initialize character with transformation data and parent class properties
   // Parameters:
   //   sID - Unique identifier for the character
   //   clipClass - Visual clip/sprite class for rendering
   //   sGfxFile - Graphics file path for character artwork
   //   cellNum - Grid cell position identifier
   //   dir - Direction/orientation (0-7)
   //   gfxID - Graphics asset identifier
   //   title - Display title/rank string
   // Data flow: sID, clipClass, sGfxFile, cellNum, dir, gfxID -> parent class initialization; title -> _title property
   function Character(sID, clipClass, sGfxFile, cellNum, dir, gfxID, title)
   {
      // 1. Call parent PlayableCharacter constructor
      super();
      // 2. Store character title/rank
      this._title = title;
      // 3. Initialize parent class graphics and positioning
      this.initialize(sID,clipClass,sGfxFile,cellNum,dir,gfxID);
   }
   // Purpose: Calculate effective speed modifier based on character status effects
   // Data flow: _nSpeedModerator (base) -> conditional modifiers -> modified speed value returned
   // Steps: Read base speed -> Apply slow reduction or sonic speed boost -> Return result
   function get speedModerator()
   {
      // 1. Read base speed modifier from parent class
      var _loc2_ = this._nSpeedModerator;
      // 2. Check if character has slow status, reduce speed by half
      if(this.isSlow)
      {
         _loc2_ /= 2;
      }
      // 3. Otherwise check for admin sonic speed, multiply by 5x
      else if(this.isAdminSonicSpeed)
      {
         _loc2_ *= 5;
      }
      // 4. Return calculated speed modifier
      return _loc2_;
   }
   // Purpose: Retrieve whether character completed TTG collection achievement
   // Data flow: _bHasTtgCollection -> boolean returned
   function get hasTtgCollection()
   {
      return this._bHasTtgCollection;
   }
   // Purpose: Set TTG collection status for character
   // Parameters: bHasTtgCollection - Boolean flag for TTG completion
   // Data flow: bHasTtgCollection -> _bHasTtgCollection property
   function set hasTtgCollection(bHasTtgCollection)
   {
      this._bHasTtgCollection = bHasTtgCollection;
   }
   // Purpose: Retrieve character's guild identifier
   // Data flow: _nGuild -> number returned
   function get Guild()
   {
      return this._nGuild;
   }
   // Purpose: Set character's guild membership identifier
   // Parameters: value - Numeric guild ID
   // Data flow: value (coerced to Number) -> _nGuild property
   function set Guild(value)
   {
      this._nGuild = Number(value);
   }
   // Purpose: Retrieve character gender/sex identifier
   // Data flow: _nSex -> number returned
   function get Sex()
   {
      return this._nSex;
   }
   // Purpose: Set character gender/sex identifier
   // Parameters: value - Numeric sex code
   // Data flow: value (coerced to Number) -> _nSex property
   function set Sex(value)
   {
      this._nSex = Number(value);
   }
   // Purpose: Retrieve character aura visual indicator
   // Data flow: _nAura -> number returned
   function get Aura()
   {
      return this._nAura;
   }
   // Purpose: Set character aura visual indicator
   // Parameters: value - Numeric aura identifier
   // Data flow: value (coerced to Number) -> _nAura property
   function set Aura(value)
   {
      this._nAura = Number(value);
   }
   // Purpose: Retrieve character alignment information (faction and rank)
   // Data flow: _oAlignment -> object returned
   function get alignment()
   {
      return this._oAlignment;
   }
   // Purpose: Set character alignment information
   // Parameters: value - Alignment object containing faction and rank data
   // Data flow: value -> _oAlignment property
   function set alignment(value)
   {
      this._oAlignment = value;
   }
   // Purpose: Retrieve merchant status of character
   // Data flow: _bMerchant -> boolean returned
   function get Merchant()
   {
      return this._bMerchant;
   }
   // Purpose: Set merchant status for character
   // Parameters: value - Boolean indicating merchant activity
   // Data flow: value -> _bMerchant property
   function set Merchant(value)
   {
      this._bMerchant = value;
   }
   // Purpose: Retrieve server identifier for character
   // Data flow: _nServerID -> number returned
   function get serverID()
   {
      return this._nServerID;
   }
   // Purpose: Set server location identifier
   // Parameters: value - Server ID number
   // Data flow: value -> _nServerID property
   function set serverID(value)
   {
      this._nServerID = value;
   }
   // Purpose: Retrieve death state of character
   // Data flow: _bDied -> boolean returned
   function get Died()
   {
      return this._bDied;
   }
   // Purpose: Set character death state
   // Parameters: value - Boolean death indicator
   // Data flow: value -> _bDied property
   function set Died(value)
   {
      this._bDied = value;
   }
   // Purpose: Retrieve character rank/prestige information
   // Data flow: _oRank -> object returned
   function get rank()
   {
      return this._oRank;
   }
   // Purpose: Set character rank/prestige level
   // Parameters: value - Rank object with prestige data
   // Data flow: value -> _oRank property
   function set rank(value)
   {
      this._oRank = value;
   }
   // Purpose: Retrieve list of optimized craft job skill identifiers
   // Data flow: _aMultiCraftSkillsID -> array returned
   function get multiCraftSkillsID()
   {
      return this._aMultiCraftSkillsID;
   }
   // Purpose: Set list of character's multi-craft skill identifiers
   // Parameters: value - Array of craft job IDs
   // Data flow: value -> _aMultiCraftSkillsID property
   function set multiCraftSkillsID(value)
   {
      this._aMultiCraftSkillsID = value;
   }
   // Purpose: Set character's guild name display string
   // Parameters: sGuildName - String name of guild
   // Data flow: sGuildName -> _sGuildName property
   function set guildName(sGuildName)
   {
      this._sGuildName = sGuildName;
   }
   // Purpose: Retrieve guild name display for character
   // Data flow: _sGuildName -> string returned
   function get guildName()
   {
      return this._sGuildName;
   }
   // Purpose: Retrieve display title/rank shown above character
   // Data flow: _title -> string returned
   function get title()
   {
      return this._title;
   }
   // Purpose: Set guild emblem visual representation data
   // Parameters: oEmblem - Emblem object with artwork and rendering info
   // Data flow: oEmblem -> _oEmblem property
   function set emblem(oEmblem)
   {
      this._oEmblem = oEmblem;
   }
   // Purpose: Retrieve guild emblem visual data
   // Data flow: _oEmblem -> object returned
   function get emblem()
   {
      return this._oEmblem;
   }
   // Purpose: Apply restriction flags that control character action permissions
   // Parameters: nRestrictions - Numeric bitmap encoding all restriction flags
   // Data flow: nRestrictions (coerced to Number) -> _nRestrictions flags
   function set restrictions(nRestrictions)
   {
      // 1. Convert input to numeric bitmap
      this._nRestrictions = Number(nRestrictions);
   }
   // Purpose: Check if character can be assaulted/attacked
   // Data flow: _nRestrictions bit 0 -> boolean returned
   // Steps: Perform bitwise AND with flag 1 -> Invert result (0=allowed)
   function get canBeAssault()
   {
      // 1. Check bit 0 of restrictions
      // 2. Return true if assault restriction is NOT set
      return (this._nRestrictions & 1) != 1;
   }
   // Purpose: Check if character can be challenged in PvP
   // Data flow: _nRestrictions bit 1 -> boolean returned
   // Steps: Perform bitwise AND with flag 2 -> Invert result (0=allowed)
   function get canBeChallenge()
   {
      // 1. Check bit 1 of restrictions
      // 2. Return true if challenge restriction is NOT set
      return (this._nRestrictions & 2) != 2;
   }
   // Purpose: Check if character can participate in item exchanges
   // Data flow: _nRestrictions bit 2 -> boolean returned
   // Steps: Perform bitwise AND with flag 4 -> Invert result (0=allowed)
   function get canExchange()
   {
      // 1. Check bit 2 of restrictions
      // 2. Return true if exchange restriction is NOT set
      return (this._nRestrictions & 4) != 4;
   }
   // Purpose: Check if character can be directly attacked
   // Data flow: _nRestrictions bit 3 -> boolean returned
   // Steps: Perform bitwise AND with flag 8 -> Invert result (0=allowed)
   function get canBeAttack()
   {
      // 1. Check bit 3 of restrictions
      // 2. Return true if attack restriction is NOT set
      return (this._nRestrictions & 8) != 8;
   }
   // Purpose: Check if character is forced to walk (no running/teleporting)
   // Data flow: _nRestrictions bit 4 -> boolean returned
   // Steps: Perform bitwise AND with flag 0x10 -> Check if equals 16 (1=active)
   function get forceWalk()
   {
      // 1. Check bit 4 of restrictions
      // 2. Return true if force walk restriction IS set
      return (this._nRestrictions & 0x10) == 16;
   }
   // Purpose: Check if character has slow status effect active
   // Data flow: _nRestrictions bit 5 -> boolean returned
   // Steps: Perform bitwise AND with flag 0x20 -> Check if equals 32 (1=active)
   function get isSlow()
   {
      // 1. Check bit 5 of restrictions
      // 2. Return true if slow status IS set
      return (this._nRestrictions & 0x20) == 32;
   }
   // Purpose: Check if character can switch between normal and creature mode
   // Data flow: _nRestrictions bit 6 -> boolean returned
   // Steps: Perform bitwise AND with flag 0x40 -> Invert result (0=allowed)
   function get canSwitchInCreaturesMode()
   {
      // 1. Check bit 6 of restrictions
      // 2. Return true if creature mode restriction is NOT set
      return (this._nRestrictions & 0x40) != 64;
   }
   // Purpose: Check if character is in tomb/ghost state
   // Data flow: _nRestrictions bit 7 -> boolean returned
   // Steps: Perform bitwise AND with flag 0x80 -> Check if equals 128 (1=active)
   function get isTomb()
   {
      // 1. Check bit 7 of restrictions
      // 2. Return true if tomb state IS set
      return (this._nRestrictions & 0x80) == 128;
   }
   // Purpose: Check if character has admin sonic speed boost enabled
   // Data flow: _nRestrictions bit 8 -> boolean returned
   // Steps: Perform bitwise AND with flag 0x0100 -> Check if equals 256 (1=active)
   function get isAdminSonicSpeed()
   {
      // 1. Check bit 8 of restrictions
      // 2. Return true if admin sonic speed IS set
      return (this._nRestrictions & 0x0100) == 256;
   }
   // Purpose: Dispatch event notification when character resistances are updated
   // Data flow: Internal event object -> event system
   // Steps: Create event object -> Send to display framework listeners
   function onResistancesUpdated()
   {
      // 1. Create resistance change event
      // 2. Dispatch to all registered event listeners
      this.dispatchEvent({type:"resistancesChanged"});
   }
   // Purpose: Store character base resistance values before modifiers
   // Parameters: aResistances - Array of 7 resistance values
   // Data flow: aResistances -> _aResistances property
   function set resistances(aResistances)
   {
      // 1. Store base resistances array
      this._aResistances = aResistances;
   }
   // Purpose: Calculate final character resistances by applying stat modifiers
   // Data flow: _aResistances (base) -> CharacteristicsManager (modifiers) -> capped values returned
   // Parameters: None (uses instance resistances and manager)
   // Steps: Copy base resistances -> Apply element modifiers -> Apply dodge modifiers -> Cap at max -> Return array
   function get resistances()
   {
      // 1. Create copy of base resistances array
      var _loc2_ = [];
      var _loc3_ = 0;
      while(_loc3_ < this._aResistances.length)
      {
         _loc2_[_loc3_] = this._aResistances[_loc3_];
         _loc3_ = _loc3_ + 1;
      }
      // 2. Apply neutral element resistance modifier
      _loc2_[0] += this.CharacteristicsManager.getModeratorValue(dofus.managers.CharacteristicsManager.NEUTRAL_ELEMENT_PERCENT);
      // 3. Apply earth element resistance modifier
      _loc2_[1] += this.CharacteristicsManager.getModeratorValue(dofus.managers.CharacteristicsManager.EARTH_ELEMENT_PERCENT);
      // 4. Apply fire element resistance modifier
      _loc2_[2] += this.CharacteristicsManager.getModeratorValue(dofus.managers.CharacteristicsManager.FIRE_ELEMENT_PERCENT);
      // 5. Apply water element resistance modifier
      _loc2_[3] += this.CharacteristicsManager.getModeratorValue(dofus.managers.CharacteristicsManager.WATER_ELEMENT_PERCENT);
      // 6. Apply air element resistance modifier
      _loc2_[4] += this.CharacteristicsManager.getModeratorValue(dofus.managers.CharacteristicsManager.AIR_ELEMENT_PERCENT);
      // 7. Apply dodge PA probability modifier
      _loc2_[5] += this.CharacteristicsManager.getModeratorValue(dofus.managers.CharacteristicsManager.DODGE_PA_LOST_PROBABILITY);
      // 8. Apply dodge PM probability modifier
      _loc2_[6] += this.CharacteristicsManager.getModeratorValue(dofus.managers.CharacteristicsManager.DODGE_PM_LOST_PROBABILITY);
      // 9. Cap neutral resistance at max value (50%)
      _loc2_[0] = Math.min(_loc2_[0],dofus.datacenter.Character.MAX_NEUTRAL_RESISTANCE_MIXED);
      // 10. Cap earth resistance at max value (50%)
      _loc2_[1] = Math.min(_loc2_[1],dofus.datacenter.Character.MAX_EARTH_RESISTANCE_MIXED);
      // 11. Cap fire resistance at max value (50%)
      _loc2_[2] = Math.min(_loc2_[2],dofus.datacenter.Character.MAX_FIRE_RESISTANCE_MIXED);
      // 12. Cap water resistance at max value (50%)
      _loc2_[3] = Math.min(_loc2_[3],dofus.datacenter.Character.MAX_WATER_RESISTANCE_MIXED);
      // 13. Cap air resistance at max value (50%)
      _loc2_[4] = Math.min(_loc2_[4],dofus.datacenter.Character.MAX_AIR_RESISTANCE_MIXED);
      // 14. Return final calculated resistance array
      return _loc2_;
   }
}
