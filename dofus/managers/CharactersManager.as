/**
 * CharactersManager
 * 
 * One-line purpose:
 * Manages creation and configuration of sprite entities from server-provided data.
 *
 * General description:
 * CharactersManager is a singleton class that extends ApiElement and
 * serves as a factory for creating various types of sprites (characters, monsters, NPCs, etc.)
 * from server data packets. It handles parsing of raw server strings, instantiation of appropriate
 * sprite classes, and configuration of sprite properties like appearance, accessories, and stats.
 * (Note: From reading the code, I think CharactersManagers also init other properties like AP and MP)
 * 
 * In Sprite Creation from Server Data process:
 * In the sprite creation workflow, CharactersManager receives
 * parsed server data objects from network handlers (like GameIn.as), transforms this data into
 * properly typed sprite instances, configures their visual and behavioral properties, and registers
 * them in the global Sprites collection. It acts as the bridge between network protocol data
 * and displayable game entities.
 * 
 * 
 */


class dofus.managers.CharactersManager extends dofus.utils.ApiElement
{
   // Singleton holder
   // Type: CharactersManager
   // Purpose: stores the sole instance of this manager for global access.
   static var _sSelf = null;


   /**
    * Purpose: Initialize the CharactersManager singleton and link API.
    * Parameters:
    *   oAPI - core API reference providing datacenter and utilities.
    * Data flow: accepts API from caller and passes it to parent initialize.
    */
   function CharactersManager(oAPI)
   {
      dofus.managers.CharactersManager._sSelf = this;
      super.initialize(oAPI);
   }


   /**
    * Purpose: Return the singleton instance of CharactersManager.
    * Parameters: none
    * Data flow: simply returns stored _sSelf reference.
    */
   static function getInstance()
   {
      return dofus.managers.CharactersManager._sSelf;
   }


   /**
    * Purpose: Populate the local Player datacenter object with initial data.
    * Parameters:
    *   nID   - numeric identifier for the player
    *   sName - display name string from server
    *   oData - raw data object containing guild, level, sex, colors, items, etc.
    * Data flow: translates raw properties into typed Player fields and creates Item
    *           instances for inventory data.
    */
   function setLocalPlayerData(nID, sName, oData)
   {
      // Step 1: clear existing player information
      var oPlayer = this.api.datacenter.Player;
      oPlayer.clean();
      oPlayer.ID = nID;
      oPlayer.Name = sName;
      oPlayer.Guild = oData.guild;
      oPlayer.Level = oData.level;
      oPlayer.Sex = oData.sex;
      oPlayer.color1 = oData.color1 != -1 ? Number("0x" + oData.color1) : oData.color1;
      oPlayer.color2 = oData.color2 != -1 ? Number("0x" + oData.color2) : oData.color2;
      oPlayer.color3 = oData.color3 != -1 ? Number("0x" + oData.color3) : oData.color3;
      var aItemsData = oData.items.split(";");
      var i = 0;
      while(i < aItemsData.length)
      {
         var sItemData = aItemsData[i];
         if(sItemData.length != 0)
         {
            var oItem = this.getItemObjectFromData(sItemData);
            if(oItem != undefined)
            {
               oPlayer.addItem(oItem);
            }
         }
         i = i + 1;
      }
      oPlayer.updateCloseCombat();
   }

   
   /**
    * Purpose: Sync datacenter Player fields with properties from a sprite representation.
    * Parameters:
    *   oSprite - source sprite whose name, colors and sex should be mirrored.
    * Data flow: compares sprite attributes to Player and applies changes, triggering UI/electron updates.
    */
   function updateLocalPlayerData(oSprite)
   {
      // Step 1: compare and update name
      var oPlayer = this.api.datacenter.Player;
      if(oPlayer.Name != oSprite.name)
      {
         oPlayer.Name = oSprite.name;
         this.api.electron.updateWindowTitle(oPlayer.Name);
         this.api.electron.setIngameDiscordActivity();
      }
      if(oPlayer.color1 != oSprite.color1 || (oPlayer.color2 != oSprite.color2 || oPlayer.color3 != oSprite.color3))
      {
         oPlayer.color1 = oSprite.color1;
         oPlayer.color2 = oSprite.color2;
         oPlayer.color3 = oSprite.color3;
         this.api.ui.getUIComponent("Banner").circleXtra.updateArtwork(true);
         this.api.ui.getUIComponent("Inventory").refreshSpriteViewer();
      }
      if(oPlayer.Sex != oSprite.Sex)
      {
         oPlayer.Sex = oSprite.Sex;
         this.api.ui.getUIComponent("Inventory").refreshSpriteViewer();
      }
   }


   /**
    * Purpose: Builds or updates a Character datacenter object from a server packet.
    * Parameters:
    *   sID   - unique server sprite id (string)
    *   sName - display name for the character
    *   oData - raw data object containing gfxID, colors, stats, accessories, and more
    * Data flow: takes the oData payload, possibly mutates gfxID for authorized player,
    *           looks up or creates the corresponding Character instance, populates its
    *           visual, stat, and meta fields then returns it.
    */
   function createCharacter(sID, sName, oData)
   {
      // Step 1: Check for authorized player and replace special gfxID if needed
      if(this.api.datacenter.Player.isAuthorized && oData.gfxID == ank.battlefield.datacenter.Sprite.ANGELS_OF_THE_WORLD_SPRITE_ID)
      {
         oData.gfxID = ank.battlefield.datacenter.Sprite.ANGELS_OF_THE_WORLD_REPLACEMENT_SPRITE_ID;
      }

      // Step 2: Retrieve existing sprite from Sprites collection or create new Character instance
      var oCharacter = this.api.datacenter.Sprites.getItemAt(sID);
      if(oCharacter == undefined)
      {
         oCharacter = new dofus.datacenter.Character(sID, ank.battlefield.mc.Sprite, dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf", oData.cell, oData.dir, oData.gfxID, oData.title);
         this.api.datacenter.Sprites.addItemAt(sID, oCharacter);
      }

      // Step 3: Initialize GameActionsManager and set basic properties (cell, scale, name)
      oCharacter.GameActionsManager.init();
      oCharacter.cellNum = Number(oData.cell);
      oCharacter.scaleX = oData.scaleX;
      oCharacter.scaleY = oData.scaleY;
      oCharacter.name = sName;

      // Step 4: Set appearance properties (colors, accessories, guild info)
      oCharacter.Guild = Number(oData.spriteType);
      oCharacter.Level = Number(oData.level);
      oCharacter.Sex = oData.sex == undefined ? 1 : oData.sex;
      oCharacter.color1 = oData.color1 != -1 ? Number("0x" + oData.color1) : oData.color1;
      oCharacter.color2 = oData.color2 != -1 ? Number("0x" + oData.color2) : oData.color2;
      oCharacter.color3 = oData.color3 != -1 ? Number("0x" + oData.color3) : oData.color3;
      oCharacter.Aura = oData.aura == undefined ? 0 : oData.aura;
      oCharacter.Merchant = oData.merchant != "1" ? false : true;
      oCharacter.serverID = Number(oData.serverID);
      oCharacter.alignment = oData.alignment;
      oCharacter.rank = oData.rank;
      oCharacter.mount = oData.mount;
      oCharacter.isDead = oData.isDead == 1;
      oCharacter.deathState = Number(oData.isDead);
      oCharacter.deathCount = Number(oData.deathCount);
      oCharacter.lvlMax = Number(oData.lvlMax);
      oCharacter.pvpGain = Number(oData.pvpGain);
      oCharacter.hasTtgCollection = oData.hasTtgCollection;
      oCharacter.hasCandy = oData.hasCandy;
      oCharacter.hasBuff = oData.hasBuff;
      this.setSpriteAccessories(oCharacter, oData.accessories);

      // Step 5: Configure combat stats if present (LP, AP, MP, resistances)
      if(oData.LP != undefined)
      {
         oCharacter.LP = oData.LP;
      }
      if(oData.LPmax != undefined)
      {
         oCharacter.LPmax = oData.LPmax;
      }
      if(oData.AP != undefined)
      {
         oCharacter.AP = oData.AP;
      }
      if(oData.AP != undefined)
      {
         oCharacter.APinit = oData.AP;
      }
      if(oData.MP != undefined)
      {
         oCharacter.MP = oData.MP;
      }
      if(oData.MP != undefined)
      {
         oCharacter.MPinit = oData.MP;
      }
      if(oData.resistances != undefined)
      {
         oCharacter.resistances = oData.resistances;
      }

      oCharacter.Team = oData.team != undefined ? oData.team : null;
      if(oData.emote != undefined && oData.emote.length != 0)
      {
         oCharacter.direction = ank.battlefield.utils.Pathfinding.convertHeightToFourDirection(oData.dir);
         if(oData.emoteTimer != undefined && oData.emote.length != 0)
         {
               oCharacter.startAnimationTimer = oData.emoteTimer;
         }
         oCharacter.startAnimation = "EmoteStatic" + oData.emote;
      }
      if(oData.guildName != undefined)
      {
         oCharacter.guildName = oData.guildName;
      }
      oCharacter.emblem = this.createGuildEmblem(oData.emblem);
      if(oData.restrictions != undefined)
      {
         oCharacter.restrictions = _global.parseInt(oData.restrictions, 36);
      }
      if(sID == this.api.datacenter.Player.ID)
      {
         this.updateLocalPlayerData(oCharacter);
         if(!this.api.datacenter.Player.haveFakeAlignment)
         {
               this.api.datacenter.Player.alignment = oCharacter.alignment.clone();
         }
      }
      return oCharacter;
   }

   /**
    * Purpose: Create or update a Creature sprite from server data.
    * Parameters:
    *   sID   - server sprite identifier
    *   sName - display name
    *   oData - object with gfxID, cell, dir, stats, etc.
    * Data flow: uses oData to instantiate or fetch a Creature instance, configures it and returns it.
    */
   function createCreature(sID, sName, oData)
   {
      // Step 1: retrieve existing creature or construct a new one
      var oCreature = this.api.datacenter.Sprites.getItemAt(sID);
      if(oCreature == undefined)
      {
         oCreature = new dofus.datacenter.Creature(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID);
         this.api.datacenter.Sprites.addItemAt(sID,oCreature);
      }
      oCreature.GameActionsManager.init();
      oCreature.cellNum = oData.cell;
      oCreature.name = sName;
      oCreature.powerLevel = oData.powerLevel;
      oCreature.scaleX = oData.scaleX;
      oCreature.scaleY = oData.scaleY;
      oCreature.noFlip = oData.noFlip;
      oCreature.color1 = oData.color1 != -1 ? Number("0x" + oData.color1) : oData.color1;
      oCreature.color2 = oData.color2 != -1 ? Number("0x" + oData.color2) : oData.color2;
      oCreature.color3 = oData.color3 != -1 ? Number("0x" + oData.color3) : oData.color3;
      this.setSpriteAccessories(oCreature,oData.accessories);
      if(oData.LP != undefined)
      {
         oCreature.LP = oData.LP;
      }
      if(oData.LPmax != undefined)
      {
         oCreature.LPmax = oData.LPmax;
      }
      if(oData.AP != undefined)
      {
         oCreature.AP = oData.AP;
      }
      if(oData.AP != undefined)
      {
         oCreature.APinit = oData.AP;
      }
      if(oData.MP != undefined)
      {
         oCreature.MP = oData.MP;
      }
      if(oData.MP != undefined)
      {
         oCreature.MPinit = oData.MP;
      }
      if(oData.resistances != undefined)
      {
         oCreature.resistances = oData.resistances;
      }
      if(oData.summoned != undefined)
      {
         oCreature.isSummoned = oData.summoned;
      }
      oCreature.Team = oData.team != undefined ? oData.team : null;
      return oCreature;
   }
   /**
    * Purpose: Create or update a Monster sprite based on server input.
    * Parameters:
    *   sID   - sprite identifier key
    *   sName - given name string
    *   oData - raw data with gfxID, stats, colors, etc.
    * Data flow: fetches or builds Monster datacenter object, applies visual and combat attributes.
    */
   function createMonster(sID, sName, oData)
   {
      // Step 1: fetch or instantiate monster sprite
      var oMonster = this.api.datacenter.Sprites.getItemAt(sID);
      if(oMonster == undefined)
      {
         oMonster = new dofus.datacenter.Monster(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID);
         this.api.datacenter.Sprites.addItemAt(sID,oMonster);
      }
      oMonster.GameActionsManager.init();
      oMonster.cellNum = oData.cell;
      oMonster.name = sName;
      oMonster.scaleX = oData.scaleX;
      oMonster.scaleY = oData.scaleY;
      oMonster.noFlip = oData.noFlip;
      oMonster.powerLevel = oData.powerLevel;
      oMonster.color1 = oData.color1 != -1 ? Number("0x" + oData.color1) : oData.color1;
      oMonster.color2 = oData.color2 != -1 ? Number("0x" + oData.color2) : oData.color2;
      oMonster.color3 = oData.color3 != -1 ? Number("0x" + oData.color3) : oData.color3;
      this.setSpriteAccessories(oMonster,oData.accessories);
      if(oData.LP != undefined)
      {
         oMonster.LP = oData.LP;
      }
      if(oData.LPmax != undefined)
      {
         oMonster.LPmax = oData.LPmax;
      }
      if(oData.AP != undefined)
      {
         oMonster.AP = oData.AP;
      }
      if(oData.AP != undefined)
      {
         oMonster.APinit = oData.AP;
      }
      if(oData.MP != undefined)
      {
         oMonster.MP = oData.MP;
      }
      if(oData.MP != undefined)
      {
         oMonster.MPinit = oData.MP;
      }
      if(oData.summoned != undefined)
      {
         oMonster.isSummoned = oData.summoned;
      }
      oMonster.Team = oData.team != undefined ? oData.team : null;
      return oMonster;
   }
   /**
    * Purpose: Construct or refresh a MonsterGroup entry from server packet.
    * Parameters:
    *   sID   - unique identifier
    *   sName - display name (often unused)
    *   oData - object with gfxID, level, colors, bonusValue, etc.
    * Data flow: creates/fetches MonsterGroup, sets properties and returns it.
    */
   function createMonsterGroup(sID, sName, oData)
   {
      // Step 1: get or create monster group
      var oMonsterGroup = this.api.datacenter.Sprites.getItemAt(sID);
      if(oMonsterGroup == undefined)
      {
         oMonsterGroup = new dofus.datacenter.MonsterGroup(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.bonusValue);
         this.api.datacenter.Sprites.addItemAt(sID,oMonsterGroup);
      }
      oMonsterGroup.GameActionsManager.init();
      oMonsterGroup.cellNum = oData.cell;
      oMonsterGroup.name = sName;
      oMonsterGroup.Level = oData.level;
      oMonsterGroup.scaleX = oData.scaleX;
      oMonsterGroup.scaleY = oData.scaleY;
      oMonsterGroup.noFlip = oData.noFlip;
      oMonsterGroup.color1 = oData.color1 != -1 ? Number("0x" + oData.color1) : oData.color1;
      oMonsterGroup.color2 = oData.color2 != -1 ? Number("0x" + oData.color2) : oData.color2;
      oMonsterGroup.color3 = oData.color3 != -1 ? Number("0x" + oData.color3) : oData.color3;
      this.setSpriteAccessories(oMonsterGroup,oData.accessories);
      return oMonsterGroup;
   }
   /**
    * Purpose: Create or update a NonPlayableCharacter sprite from server info.
    * Parameters:
    *   sID     - sprite identifier
    *   nUnicID - unique NPC instance id
    *   oData   - data with gfxID, cell, dir, colors, extraClipID, etc.
    * Data flow: fetches or builds NPC instance, assigns visual attributes and returns it.
    */
   function createNonPlayableCharacter(sID, nUnicID, oData)
   {
      // Step 1: locate or construct NPC object
      var oNPC = this.api.datacenter.Sprites.getItemAt(sID);
      if(oNPC == undefined)
      {
         oNPC = new dofus.datacenter.NonPlayableCharacter(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID,oData.customArtwork);
         this.api.datacenter.Sprites.addItemAt(sID,oNPC);
      }
      oNPC.GameActionsManager.init();
      oNPC.cellNum = oData.cell;
      oNPC.unicID = nUnicID;
      oNPC.scaleX = oData.scaleX;
      oNPC.scaleY = oData.scaleY;
      oNPC.color1 = oData.color1 != -1 ? Number("0x" + oData.color1) : oData.color1;
      oNPC.color2 = oData.color2 != -1 ? Number("0x" + oData.color2) : oData.color2;
      oNPC.color3 = oData.color3 != -1 ? Number("0x" + oData.color3) : oData.color3;
      this.setSpriteAccessories(oNPC,oData.accessories);
      if(oData.extraClipID >= 0)
      {
         oNPC.extraClipID = oData.extraClipID;
      }
      return oNPC;
   }
   /**
    * Purpose: Instantiate an OfflineCharacter sprite based on saved data.
    * Parameters:
    *   sID   - identifier for offline sprite
    *   sName - name string
    *   oData - data containing gfxID, cell, colors, guildName, etc.
    * Data flow: retrieves or creates offline sprite, sets properties and returns it.
    */
   function createOfflineCharacter(sID, sName, oData)
   {
      // Step 1: fetch or create offline character
      var oOfflineChar = this.api.datacenter.Sprites.getItemAt(sID);
      if(oOfflineChar == undefined)
      {
         oOfflineChar = new dofus.datacenter.OfflineCharacter(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID);
         this.api.datacenter.Sprites.addItemAt(sID,oOfflineChar);
      }
      oOfflineChar.GameActionsManager.init();
      oOfflineChar.cellNum = oData.cell;
      oOfflineChar.name = sName;
      oOfflineChar.scaleX = oData.scaleX;
      oOfflineChar.scaleY = oData.scaleY;
      oOfflineChar.color1 = oData.color1 != -1 ? Number("0x" + oData.color1) : oData.color1;
      oOfflineChar.color2 = oData.color2 != -1 ? Number("0x" + oData.color2) : oData.color2;
      oOfflineChar.color3 = oData.color3 != -1 ? Number("0x" + oData.color3) : oData.color3;
      this.setSpriteAccessories(oOfflineChar,oData.accessories);
      if(oData.guildName != undefined)
      {
         oOfflineChar.guildName = oData.guildName;
      }
      oOfflineChar.emblem = this.createGuildEmblem(oData.emblem);
      oOfflineChar.offlineType = oData.offlineType;
      oOfflineChar.characterID = oData.characterID;
      return oOfflineChar;
   }
   /**
    * Purpose: Build or refresh a TaxCollector entity from server data.
    * Parameters:
    *   sID   - sprite identifier
    *   sName - raw name string (comma-separated)
    *   oData - object with gfxID, cell, colors, stats, guildName, etc.
    * Data flow: obtains/creates TaxCollector sprite, applies stats and appearance attributes.
    */
   function createTaxCollector(sID, sName, oData)
   {
      // Step 1: find or instantiate tax collector sprite
      var oTaxCollector = this.api.datacenter.Sprites.getItemAt(sID);
      if(oTaxCollector == undefined)
      {
         oTaxCollector = new dofus.datacenter.TaxCollector(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID,oData.isMine);
         this.api.datacenter.Sprites.addItemAt(sID,oTaxCollector);
      }
      oTaxCollector.GameActionsManager.init();
      oTaxCollector.cellNum = oData.cell;
      oTaxCollector.scaleX = oData.scaleX;
      oTaxCollector.scaleY = oData.scaleY;
      oTaxCollector.name = this.api.lang.getFullNameText(sName.split(","));
      oTaxCollector.Level = oData.level;
      oTaxCollector.isMine = oData.isMine;
      if(oData.guildName != undefined)
      {
         oTaxCollector.guildName = oData.guildName;
      }
      oTaxCollector.emblem = this.createGuildEmblem(oData.emblem);
      if(oData.LP != undefined)
      {
         oTaxCollector.LP = oData.LP;
      }
      if(oData.LPmax != undefined)
      {
         oTaxCollector.LPmax = oData.LPmax;
      }
      if(oData.AP != undefined)
      {
         oTaxCollector.AP = oData.AP;
      }
      if(oData.AP != undefined)
      {
         oTaxCollector.APinit = oData.AP;
      }
      if(oData.MP != undefined)
      {
         oTaxCollector.MP = oData.MP;
      }
      if(oData.MP != undefined)
      {
         oTaxCollector.MPinit = oData.MP;
      }
      if(oData.resistances != undefined)
      {
         oTaxCollector.resistances = oData.resistances;
      }
      oTaxCollector.Team = oData.team != undefined ? oData.team : null;
      return oTaxCollector;
   }
   /**
    * Purpose: Create or update a Prism sprite for alignment wars.
    * Parameters:
    *   sID   - sprite key
    *   sName - linked monster id formatted as string
    *   oData - data containing gfxID, level, alignment, etc.
    * Data flow: fetches or creates Prism instance, configures link and returns it.
    */
   function createPrism(sID, sName, oData)
   {
      // Step 1: retrieve or build prism sprite
      var oPrism = this.api.datacenter.Sprites.getItemAt(sID);
      if(oPrism == undefined)
      {
         oPrism = new dofus.datacenter.PrismSprite(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID);
         this.api.datacenter.Sprites.addItemAt(sID,oPrism);
      }
      oPrism.GameActionsManager.init();
      oPrism.cellNum = oData.cell;
      oPrism.scaleX = oData.scaleX;
      oPrism.scaleY = oData.scaleY;
      oPrism.linkedMonster = Number(sName);
      oPrism.Level = oData.level;
      oPrism.alignment = oData.alignment;
      return oPrism;
   }
   /**
    * Purpose: Instantiate or update a ParkMount sprite from server feed.
    * Parameters:
    *   sID   - sprite identifier
    *   sName - mount name
    *   oData - contains gfxID, ownerName, level, modelID, etc.
    * Data flow: retrieves/creates ParkMount object, sets visual and owner attributes.
    */
   function createParkMount(sID, sName, oData)
   {
      // Step 1: fetch existing or create new park mount
      var oParkMount = this.api.datacenter.Sprites.getItemAt(sID);
      if(oParkMount == undefined)
      {
         oParkMount = new dofus.datacenter.ParkMount(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID,oData.modelID);
         this.api.datacenter.Sprites.addItemAt(sID,oParkMount);
      }
      oParkMount.GameActionsManager.init();
      oParkMount.cellNum = oData.cell;
      oParkMount.name = sName;
      oParkMount.scaleX = oData.scaleX;
      oParkMount.scaleY = oData.scaleY;
      oParkMount.ownerName = oData.ownerName;
      oParkMount.level = oData.level;
      return oParkMount;
   }
   /**
    * Purpose: Build or update a Mutant sprite using provided data.
    * Parameters:
    *   sID  - identifier for mutant sprite
    *   oData - contains gfxID, cell, colors, sex, monsterID, playerName, etc.
    * Data flow: obtains/creates Mutant instance, populates appearance, stats, emote info.
    */
   function createMutant(sID, oData)
   {
      // Step 1: obtain existing mutant or create a new one
      var oMutant = this.api.datacenter.Sprites.getItemAt(sID);
      if(oMutant == undefined)
      {
         oMutant = new dofus.datacenter.Mutant(sID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oData.gfxID + ".swf",oData.cell,oData.dir,oData.gfxID);
         this.api.datacenter.Sprites.addItemAt(sID,oMutant);
      }
      oMutant.GameActionsManager.init();
      oMutant.scaleX = oData.scaleX;
      oMutant.scaleY = oData.scaleY;
      oMutant.cellNum = Number(oData.cell);
      oMutant.Guild = Number(oData.spriteType);
      oMutant.powerLevel = Number(oData.powerLevel);
      oMutant.Sex = oData.sex == undefined ? 1 : oData.sex;
      oMutant.showIsPlayer = oData.showIsPlayer;
      oMutant.monsterID = oData.monsterID;
      oMutant.playerName = oData.playerName;
      this.setSpriteAccessories(oMutant,oData.accessories);
      if(oData.LP != undefined)
      {
         oMutant.LP = oData.LP;
      }
      if(oData.LPmax != undefined)
      {
         oMutant.LPmax = oData.LPmax;
      }
      if(oData.AP != undefined)
      {
         oMutant.AP = oData.AP;
      }
      if(oData.AP != undefined)
      {
         oMutant.APinit = oData.AP;
      }
      if(oData.MP != undefined)
      {
         oMutant.MP = oData.MP;
      }
      if(oData.MP != undefined)
      {
         oMutant.MPinit = oData.MP;
      }
      oMutant.Team = oData.team != undefined ? oData.team : null;
      if(oData.emote != undefined && oData.emote.length != 0)
      {
         oMutant.direction = ank.battlefield.utils.Pathfinding.convertHeightToFourDirection(oData.dir);
         if(oData.emoteTimer != undefined && oData.emote.length != 0)
         {
            oMutant.startAnimationTimer = oData.emoteTimer;
         }
         oMutant.startAnimation = "EmoteStatic" + oData.emote;
      }
      if(oData.restrictions != undefined)
      {
         oMutant.restrictions = _global.parseInt(oData.restrictions,36);
      }
      return oMutant;
   }
   /**
    * Purpose: Parse an encoded item string and return an Item datacenter object.
    * Parameters:
    *   sData - "~" separated hex-encoded values representing id, quantity, rarity, runID, effects
    * Data flow: splits sData, converts segments into numbers, constructs and returns Item.
    */
   function getItemObjectFromData(sData)
   {
      // Step 1: early exit if empty input
      if(sData.length == 0)
      {
         return null;
      }
      if(sData.length == 0)
      {
         return null;
      }
      var aItemData = sData.split("~");
      var nItemID = _global.parseInt(aItemData[0],16);
      var nQuantity = _global.parseInt(aItemData[1],16);
      var nRarity = _global.parseInt(aItemData[2],16);
      var nRunID = aItemData[3].length != 0 ? _global.parseInt(aItemData[3],16) : -1;
      var sEffects = aItemData[4];
      var oItem = new dofus.datacenter.Item(nItemID,nQuantity,nRarity,nRunID,sEffects);
      oItem.priceMultiplicator = this.api.lang.getConfigText("SELL_PRICE_MULTIPLICATOR");
      return oItem;
   }
   /**
    * Purpose: Create a Spell object from its serialized string form.
    * Parameters:
    *   sData - "~" separated values for spellID, level, effects
    * Data flow: splits string, casts values to Number, constructs Spell instance.
    */
   function getSpellObjectFromData(sData)
   {
      // Step 1: split incoming string into components
      var aSpellData = sData.split("~");
      var aSpellData = sData.split("~");
      var nSpellID = Number(aSpellData[0]);
      var nSpellLevel = Number(aSpellData[1]);
      var sSpellEffects = aSpellData[2];
      var oSpell = new dofus.datacenter.Spell(nSpellID,nSpellLevel,sSpellEffects);
      return oSpell;
   }


   /**
    * Purpose: Interpret a name field and determine entity type (taxcollector/player/monster).
    * Parameters:
    *   sData - server provided string that may be comma-separated or numeric.
    * Data flow: reads sData, splits or tests numeric to set oResult.name and oResult.type.
    * Steps:
    *   1. split on comma – if two parts treat as tax collector.
    *   2. if not numeric string treat as player name.
    *   3. otherwise look up monster name by id.
    */
   function getNameFromData(sData)
   {
      var oResult = {};

      // Step: Parses string to determine if it's a tax collector, player, or monster name
      var aNameParts = sData.split(",");
      if(aNameParts.length == 2)
      {
         oResult.name = this.api.lang.getFullNameText(aNameParts);
         oResult.type = "taxcollector";
      }
      else if(_global.isNaN(Number(sData)))
      {
         oResult.name = sData;
         oResult.type = "player";
      }
      else
      {
         oResult.name = this.api.lang.getMonstersText(Number(sData)).n;
         oResult.type = "monster";
      }
      return oResult;
   }

   /**
    * Purpose: Decode accessories string and assign Accessory objects to a sprite.
    * Parameters:
    *   oSprite      - datacenter sprite receiving accessories array
    *   sAccessories - comma-separated list of accessory descriptors
    * Data flow: tokens are parsed to numbers, Accessory instances are built and attached.
    */
   function setSpriteAccessories(oSprite, sAccessories)
   {
      // Step 1: only process if string is non-empty
      if(sAccessories.length != 0)
      {
      if(sAccessories.length != 0)
      {
         var aAccessories = [];
         var aAccessoriesParts = sAccessories.split(",");
         var i = 0;
         while(i < aAccessoriesParts.length)
         {
            if(aAccessoriesParts[i].indexOf("~") != -1)
            {
               var aAccessoryData = aAccessoriesParts[i].split("~");
               var nAccessoryID = _global.parseInt(aAccessoryData[0],16);
               var nAccessoryColor = _global.parseInt(aAccessoryData[1]);
               var nAccessorySlot = _global.parseInt(aAccessoryData[2]) - 1;
               if(nAccessorySlot < 0)
               {
                  nAccessorySlot = 0;
               }
            }
            else
            {
               nAccessoryID = _global.parseInt(aAccessoriesParts[i],16);
               nAccessoryColor = undefined;
               nAccessorySlot = undefined;
            }
            if(!_global.isNaN(nAccessoryID))
            {
               var oAccessory = new dofus.datacenter.Accessory(nAccessoryID,nAccessoryColor,nAccessorySlot);
               aAccessories[i] = oAccessory;
            }
            i = i + 1;
         }
         oSprite.accessories = aAccessories;
      }
   }
   /**
    * Purpose: Generate emblem object from compact string data.
    * Parameters:
    *   sEmblem - comma-separated emblem parameters (backID, backColor, upID, upColor)
    * Data flow: splits string, converts base36 values, clamps IDs, returns emblem object.
    */
   function createGuildEmblem(sEmblem)
   {
      if(sEmblem != undefined)
      {
         var aEmblemData = sEmblem.split(",");
         var nBackID = _global.parseInt(aEmblemData[0],36);
         var nUpID = _global.parseInt(aEmblemData[2],36);
         if(nBackID < 1 || nBackID > dofus.Constants.EMBLEM_BACKS_COUNT)
         {
            nBackID = 1;
         }
         if(nUpID < 1 && nUpID != -1 || nUpID > dofus.Constants.EMBLEM_UPS_COUNT)
         {
            nUpID = 1;
         }
         var oEmblem = {};
         oEmblem.backID = nBackID;
         oEmblem.backColor = _global.parseInt(aEmblemData[1],36);
         oEmblem.upID = nUpID;
         oEmblem.upColor = _global.parseInt(aEmblemData[3],36);
         return oEmblem;
      }
      return undefined;
   }
}
