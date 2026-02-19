/**
 * Class Purpose
 * Handles incoming server messages and creates/updates sprites on the battlefield based on server data
 *
 * In Sprite Creation from Server Data process
 * - The sprite creation process is primarily driven by `onMovement` which handles all sprite types (characters, monsters, NPCs, etc.)
 * - Created sprites are stored in `api.datacenter.Sprites` before being added to the battlefield (GameIn.as:75)
 * - The `_aGameSpriteLeftHistory` field is only used for debugging disconnects when logging is enabled (GameIn.as:531-540)
 */

class dofus.aks.extend.GameIn extends dofus.aks.Handler
{
   var _aGameSpriteLeftHistory = [];
   function GameIn(oAKS, oAPI)
   {
      super.initialize(oAKS,oAPI);
   }


   /**
    * onMovement
    * 
    * Purpose:
    * Parses server movement data and creates/updates sprites based on their type.
    *
    * Parameters:
    *  - sExtraData: Pipe-separated string containing sprite data entries
    *  - bIsSummoned: Flag indicating if the sprite is summoned
    *
    * Data Flow:
    * Raw server string → Parsed sprite properties → Typed sprite data object
    * → Character/Monster/NPC instance → Battlefield sprite
    */
   function onMovement(sExtraData, bIsSummoned)
   {
      // 1. Split the input data by "|" to process each sprite entry
      var aMovementParts = sExtraData.split("|");

      var nIndex = aMovementParts.length - 1;
      for(; nIndex >= 0; nIndex = nIndex - 1)
      {
         var sPart = aMovementParts[nIndex];

         if(sPart.length != 0)
         {
            var bIsRemoving = false;
            var bHasMovement = false;
            var sFirstChar = sPart.charAt(0);

            // 2. Determine if entry is an addition ("+", "~") or removal ("-")
            if(sFirstChar == "+")
            {
               bHasMovement = true;
            }
            else if(sFirstChar == "~")
            {
               bHasMovement = true;
               bIsRemoving = true;
            }
            else if(sFirstChar != "-")
            {
               continue;
            }

            if(bHasMovement)
            {
               // 3. Extract sprite properties (ID, cell, direction, GFX, colors, etc.)
               var aData = sPart.substr(1).split(";");
               var sCell = aData[0];

               if(sCell == "-1")
               {
                  sCell = String(this.api.datacenter.Player.data.cellNum);
               }

               var sDirection = aData[1];
               var nBonus = Number(aData[2]);
               var sOtherData1 = aData[3];
               var sOtherData2 = aData[4];
               var sSpeedOrColor = aData[5];
               var sGfxData = aData[6];

               var bNoFlip = false;
               var bAllowGhost = true;

               if(sGfxData.charAt(sGfxData.length - 1) == "*")
               {
                  sGfxData = sGfxData.substr(0,sGfxData.length - 1);
                  bNoFlip = true;
               }

               if(sGfxData.charAt(0) == "*")
               {
                  bAllowGhost = false;
                  sGfxData = sGfxData.substr(1);
               }

               var aGfxParts = sGfxData.split("^");
               var sGfxID = aGfxParts.length != 2 ? sGfxData : aGfxParts[0];

               var aColorParts = sSpeedOrColor.split(",");
               var sSpriteType = aColorParts[0];
               var sColorData = aColorParts[1];

               var oTitle = undefined;
               if(sColorData.length)
               {
                  var aTitleParts = sColorData.split("*");
                  oTitle = new dofus.datacenter.Title(_global.parseInt(aTitleParts[0]),aTitleParts[1]);
               }

               var nScaleX = 100;
               var nScaleY = 100;

               if(aGfxParts.length == 2)
               {
                  var sScaleData = aGfxParts[1];
                  if(_global.isNaN(Number(sScaleData)))
                  {
                     var aScaleParts = sScaleData.split("x");
                     nScaleX = aScaleParts.length != 2 ? 100 : Number(aScaleParts[0]);
                     nScaleY = aScaleParts.length != 2 ? 100 : Number(aScaleParts[1]);
                  }
                  else
                  {
                     nScaleX = nScaleY = Number(sScaleData);
                  }
               }

               if(bIsRemoving)
               {
                  var oOldSprite = this.api.datacenter.Sprites.getItemAt(sOtherData1);
                  this.onSpriteMovement(false,oOldSprite);
               }

               var oSprite;

               // 4. Create sprite data object based on sprite type
               //    (-1 to -10 specific types, default case for player characters)
               switch(sSpriteType)
               {
                  case "-1":
                  case "-2":
                     var oCharData = {};
                     oCharData.spriteType = sSpriteType;
                     oCharData.gfxID = sGfxID;
                     oCharData.scaleX = nScaleX;
                     oCharData.scaleY = nScaleY;
                     oCharData.noFlip = bNoFlip;
                     oCharData.cell = sCell;
                     oCharData.dir = sDirection;
                     oCharData.powerLevel = aData[7];
                     oCharData.color1 = aData[8];
                     oCharData.color2 = aData[9];
                     oCharData.color3 = aData[10];
                     oCharData.accessories = aData[11];
                     if(this.api.datacenter.Game.isFight)
                     {
                        oCharData.LP = aData[12];
                        oCharData.AP = aData[13];
                        oCharData.MP = aData[14];
                        if(aData.length > 18)
                        {
                           oCharData.resistances = [Number(aData[15]),Number(aData[16]),Number(aData[17]),Number(aData[18]),Number(aData[19]),Number(aData[20]),Number(aData[21])];
                           oCharData.team = aData[22];
                           oCharData.LPmax = aData[23];
                        }
                        else
                        {
                           oCharData.team = aData[15];
                           oCharData.LPmax = aData[16];
                        }
                        oCharData.summoned = bIsSummoned;
                     }
                     if(sSpriteType == -1)
                     {
                        oSprite = this.api.kernel.CharactersManager.createCreature(sOtherData1,sOtherData2,oCharData);
                     }
                     else
                     {
                        oSprite = this.api.kernel.CharactersManager.createMonster(sOtherData1,sOtherData2,oCharData);
                     }
                     break;
                  case "-3":
                     var oMonsterData = {};
                     oMonsterData.spriteType = sSpriteType;
                     oMonsterData.level = aData[7];
                     oMonsterData.scaleX = nScaleX;
                     oMonsterData.scaleY = nScaleY;
                     oMonsterData.noFlip = bNoFlip;
                     oMonsterData.cell = Number(sCell);
                     oMonsterData.dir = sDirection;
                     var aColorData = aData[8].split(",");
                     oMonsterData.color1 = aColorData[0];
                     oMonsterData.color2 = aColorData[1];
                     oMonsterData.color3 = aColorData[2];
                     oMonsterData.accessories = aData[9];
                     oMonsterData.bonusValue = nBonus;
                     var oGfxInfo = this.sliptGfxData(sGfxData);
                     var aGfxList = oGfxInfo.gfx;
                     this.splitGfxForScale(aGfxList[0],oMonsterData);
                     oSprite = this.api.kernel.CharactersManager.createMonsterGroup(sOtherData1,sOtherData2,oMonsterData);
                     if(this.api.kernel.OptionsManager.getOption("ViewAllMonsterInGroup") == true)
                     {
                        var sMainMonsterID = sOtherData1;
                        var nGfxIdx = 1;
                        while(nGfxIdx < aGfxList.length)
                        {
                           if(aGfxList[nGfxIdx] != "")
                           {
                              this.splitGfxForScale(aGfxList[nGfxIdx],oMonsterData);
                              aColorData = aData[8 + 2 * nGfxIdx].split(",");
                              oMonsterData.color1 = aColorData[0];
                              oMonsterData.color2 = aColorData[1];
                              oMonsterData.color3 = aColorData[2];
                              oMonsterData.dir = random(4) * 2 + 1;
                              oMonsterData.accessories = aData[9 + 2 * nGfxIdx];
                              var sExtraMonsterID = sOtherData1 + "_" + nGfxIdx;
                              var oExtraMonster = this.api.kernel.CharactersManager.createMonsterGroup(sExtraMonsterID,undefined,oMonsterData);
                              var sParentID = sMainMonsterID;
                              if(random(3) != 0 && nGfxIdx != 1)
                              {
                                 sParentID = sOtherData1 + "_" + (random(nGfxIdx - 1) + 1);
                              }
                              var nLinkDir = random(8);
                              this.api.gfx.addLinkedSprite(sExtraMonsterID,sParentID,nLinkDir,oExtraMonster);
                              if(!_global.isNaN(oExtraMonster.scaleX))
                              {
                                 this.api.gfx.setSpriteScale(oExtraMonster.id,oExtraMonster.scaleX,oExtraMonster.scaleY);
                              }
                              switch(oGfxInfo.shape)
                              {
                                 case "circle":
                                    nLinkDir = nGfxIdx;
                                    break;
                                 case "line":
                                    sParentID = sExtraMonsterID;
                                    nLinkDir = 2;
                              }
                           }
                           nGfxIdx = nGfxIdx + 1;
                        }
                     }
                     break;
                  case "-4":
                     var oNPCData = {};
                     oNPCData.spriteType = sSpriteType;
                     oNPCData.gfxID = sGfxID;
                     oNPCData.scaleX = nScaleX;
                     oNPCData.scaleY = nScaleY;
                     oNPCData.cell = sCell;
                     oNPCData.dir = sDirection;
                     oNPCData.sex = aData[7];
                     oNPCData.color1 = aData[8];
                     oNPCData.color2 = aData[9];
                     oNPCData.color3 = aData[10];
                     oNPCData.accessories = aData[11];
                     oNPCData.extraClipID = !(aData[12] != undefined && !_global.isNaN(Number(aData[12]))) ? -1 : Number(aData[12]);
                     oNPCData.customArtwork = Number(aData[13]);
                     oSprite = this.api.kernel.CharactersManager.createNonPlayableCharacter(sOtherData1,Number(sOtherData2),oNPCData);
                     break;
                  case "-5":
                     var oOfflineCharData = {};
                     oOfflineCharData.spriteType = sSpriteType;
                     oOfflineCharData.gfxID = sGfxID;
                     oOfflineCharData.scaleX = nScaleX;
                     oOfflineCharData.scaleY = nScaleY;
                     oOfflineCharData.cell = sCell;
                     oOfflineCharData.dir = sDirection;
                     oOfflineCharData.color1 = aData[7];
                     oOfflineCharData.color2 = aData[8];
                     oOfflineCharData.color3 = aData[9];
                     oOfflineCharData.accessories = aData[10];
                     oOfflineCharData.guildName = aData[11];
                     oOfflineCharData.emblem = aData[12];
                     oOfflineCharData.offlineType = aData[13];
                     oOfflineCharData.characterID = aData[14];
                     oSprite = this.api.kernel.CharactersManager.createOfflineCharacter(sOtherData1,sOtherData2,oOfflineCharData);
                     break;
                  case "-6":
                     var oTaxCollectorData = {};
                     oTaxCollectorData.spriteType = sSpriteType;
                     oTaxCollectorData.gfxID = sGfxID;
                     oTaxCollectorData.scaleX = nScaleX;
                     oTaxCollectorData.scaleY = nScaleY;
                     oTaxCollectorData.cell = sCell;
                     oTaxCollectorData.dir = sDirection;
                     oTaxCollectorData.level = aData[7];
                     if(this.api.datacenter.Game.isFight)
                     {
                        oTaxCollectorData.LP = aData[8];
                        oTaxCollectorData.AP = aData[9];
                        oTaxCollectorData.MP = aData[10];
                        oTaxCollectorData.resistances = [Number(aData[11]),Number(aData[12]),Number(aData[13]),Number(aData[14]),Number(aData[15]),Number(aData[16]),Number(aData[17])];
                        oTaxCollectorData.team = aData[18];
                        oTaxCollectorData.LPmax = aData[19];
                     }
                     else
                     {
                        oTaxCollectorData.guildName = aData[8];
                        oTaxCollectorData.emblem = aData[9];
                        oTaxCollectorData.isMine = !!Number(aData[10]);
                     }
                     oSprite = this.api.kernel.CharactersManager.createTaxCollector(sOtherData1,sOtherData2,oTaxCollectorData);
                     break;
                  case "-7":
                  case "-8":
                     var oMutantData = {};
                     oMutantData.spriteType = sSpriteType;
                     oMutantData.gfxID = sGfxID;
                     oMutantData.scaleX = nScaleX;
                     oMutantData.scaleY = nScaleY;
                     oMutantData.cell = sCell;
                     oMutantData.dir = sDirection;
                     oMutantData.sex = aData[7];
                     oMutantData.powerLevel = aData[8];
                     oMutantData.accessories = aData[9];
                     if(this.api.datacenter.Game.isFight)
                     {
                        oMutantData.LP = aData[10];
                        oMutantData.AP = aData[11];
                        oMutantData.MP = aData[12];
                        oMutantData.team = aData[20];
                        oMutantData.LPmax = aData[21];
                     }
                     else
                     {
                        oMutantData.emote = aData[10];
                        oMutantData.emoteTimer = aData[11];
                        oMutantData.restrictions = Number(aData[12]);
                     }
                     if(sSpriteType == "-8")
                     {
                        oMutantData.showIsPlayer = true;
                        var aPlayerMonsterParts = sOtherData2.split("~");
                        oMutantData.monsterID = aPlayerMonsterParts[0];
                        oMutantData.playerName = aPlayerMonsterParts[1];
                        oMutantData.team = aData[13];
                     }
                     else
                     {
                        oMutantData.showIsPlayer = false;
                        oMutantData.monsterID = sOtherData2;
                     }
                     oSprite = this.api.kernel.CharactersManager.createMutant(sOtherData1,oMutantData);
                     break;
                  case "-9":
                     var oParkMountData = {};
                     oParkMountData.spriteType = sSpriteType;
                     oParkMountData.gfxID = sGfxID;
                     oParkMountData.scaleX = nScaleX;
                     oParkMountData.scaleY = nScaleY;
                     oParkMountData.cell = sCell;
                     oParkMountData.dir = sDirection;
                     oParkMountData.ownerName = aData[7];
                     oParkMountData.level = aData[8];
                     oParkMountData.modelID = aData[9];
                     oSprite = this.api.kernel.CharactersManager.createParkMount(sOtherData1,sOtherData2 == "" ? this.api.lang.getText("NO_NAME") : sOtherData2,oParkMountData);
                     break;
                  case "-10":
                     var oPrismData = {};
                     oPrismData.spriteType = sSpriteType;
                     oPrismData.gfxID = sGfxID;
                     oPrismData.scaleX = nScaleX;
                     oPrismData.scaleY = nScaleY;
                     oPrismData.cell = sCell;
                     oPrismData.dir = sDirection;
                     oPrismData.level = aData[7];
                     oPrismData.alignment = new dofus.datacenter.Alignment(Number(aData[9]),Number(aData[8]));
                     oSprite = this.api.kernel.CharactersManager.createPrism(sOtherData1,sOtherData2,oPrismData);
                     break;
                  default:
                     var oPlayerCharData = {};
                     oPlayerCharData.spriteType = sSpriteType;
                     oPlayerCharData.cell = sCell;
                     oPlayerCharData.scaleX = nScaleX;
                     oPlayerCharData.scaleY = nScaleY;
                     oPlayerCharData.dir = sDirection;
                     oPlayerCharData.sex = aData[7];
                     if(this.api.datacenter.Game.isFight)
                     {
                        oPlayerCharData.level = aData[8];
                        var sAlignmentData = aData[9];
                        oPlayerCharData.color1 = aData[10];
                        oPlayerCharData.color2 = aData[11];
                        oPlayerCharData.color3 = aData[12];
                        oPlayerCharData.accessories = aData[13];
                        oPlayerCharData.LP = aData[14];
                        oPlayerCharData.AP = aData[15];
                        oPlayerCharData.MP = aData[16];
                        oPlayerCharData.resistances = [Number(aData[17]),Number(aData[18]),Number(aData[19]),Number(aData[20]),Number(aData[21]),Number(aData[22]),Number(aData[23])];
                        oPlayerCharData.team = aData[24];
                        oPlayerCharData.hasCandy = aData[26];
                        oPlayerCharData.hasBuff = aData[27];
                        if(aData[25].indexOf(",") != -1)
                        {
                           var aMountParts = aData[25].split(",");
                           var nMountID = Number(aMountParts[0]);
                           var nMountColor1 = _global.parseInt(aMountParts[1],16);
                           var nMountColor2 = _global.parseInt(aMountParts[2],16);
                           var nMountColor3 = _global.parseInt(aMountParts[3],16);
                           if(nMountColor1 == -1 || _global.isNaN(nMountColor1))
                           {
                              nMountColor1 = this.api.datacenter.Player.color1;
                           }
                           if(nMountColor2 == -1 || _global.isNaN(nMountColor2))
                           {
                              nMountColor2 = this.api.datacenter.Player.color2;
                           }
                           if(nMountColor3 == -1 || _global.isNaN(nMountColor3))
                           {
                              nMountColor3 = this.api.datacenter.Player.color3;
                           }
                           if(!_global.isNaN(nMountID))
                           {
                              var oMount = new dofus.datacenter.Mount(nMountID,Number(sGfxID));
                              oMount.customColor1 = nMountColor1;
                              oMount.customColor2 = nMountColor2;
                              oMount.customColor3 = nMountColor3;
                              oPlayerCharData.mount = oMount;
                           }
                        }
                        else
                        {
                           var nSimpleMountID = Number(aData[25]);
                           if(!_global.isNaN(nSimpleMountID))
                           {
                              oPlayerCharData.mount = new dofus.datacenter.Mount(nSimpleMountID,Number(sGfxID));
                           }
                        }
                        oPlayerCharData.LPmax = aData[28];
                        if(this.api.datacenter.Player.ID == sOtherData1)
                        {
                           this.api.datacenter.Player.LPmax = oPlayerCharData.LPmax;
                           this.api.datacenter.Player.LP = oPlayerCharData.LP;
                        }
                     }
                     else
                     {
                        sAlignmentData = aData[8];
                        oPlayerCharData.color1 = aData[9];
                        oPlayerCharData.color2 = aData[10];
                        oPlayerCharData.color3 = aData[11];
                        oPlayerCharData.accessories = aData[12];
                        oPlayerCharData.aura = aData[13];
                        oPlayerCharData.emote = aData[14];
                        oPlayerCharData.emoteTimer = aData[15];
                        oPlayerCharData.guildName = aData[16];
                        oPlayerCharData.emblem = aData[17];
                        oPlayerCharData.restrictions = aData[18];
                        oPlayerCharData.hasTtgCollection = aData[21] == "1";
                        if(aData[19].indexOf(",") != -1)
                        {
                           var aMountDataParts = aData[19].split(",");
                           var nMountID2 = Number(aMountDataParts[0]);
                           var nMountColor1X = _global.parseInt(aMountDataParts[1],16);
                           var nMountColor2X = _global.parseInt(aMountDataParts[2],16);
                           var nMountColor3X = _global.parseInt(aMountDataParts[3],16);
                           if(nMountColor1X == -1 || _global.isNaN(nMountColor1X))
                           {
                              nMountColor1X = this.api.datacenter.Player.color1;
                           }
                           if(nMountColor2X == -1 || _global.isNaN(nMountColor2X))
                           {
                              nMountColor2X = this.api.datacenter.Player.color2;
                           }
                           if(nMountColor3X == -1 || _global.isNaN(nMountColor3X))
                           {
                              nMountColor3X = this.api.datacenter.Player.color3;
                           }
                           if(!_global.isNaN(nMountID2))
                           {
                              var oMountX = new dofus.datacenter.Mount(nMountID2,Number(sGfxID));
                              oMountX.customColor1 = nMountColor1X;
                              oMountX.customColor2 = nMountColor2X;
                              oMountX.customColor3 = nMountColor3X;
                              oPlayerCharData.mount = oMountX;
                           }
                        }
                        else
                        {
                           var nSimpleMountID2 = Number(aData[19]);
                           if(!_global.isNaN(nSimpleMountID2))
                           {
                              oPlayerCharData.mount = new dofus.datacenter.Mount(nSimpleMountID2,Number(sGfxID));
                           }
                        }
                     }
                     if(bIsRemoving)
                     {
                        var aTransitionEffect = [sOtherData1,this.createTransitionEffect(),sCell,10];
                     }
                     var aAlignmentParts = sAlignmentData.split(",");
                     oPlayerCharData.alignment = new dofus.datacenter.Alignment(Number(aAlignmentParts[0]),Number(aAlignmentParts[1]));
                     oPlayerCharData.rank = new dofus.datacenter.Rank(Number(aAlignmentParts[2]));
                     oPlayerCharData.alignment.fallenAngelDemon = aAlignmentParts[4] == 1;
                     if(aAlignmentParts.length > 3 && sOtherData1 != this.api.datacenter.Player.ID)
                     {
                        if(this.api.lang.getAlignmentCanViewPvpGain(this.api.datacenter.Player.alignment.index,Number(oPlayerCharData.alignment.index)))
                        {
                           var nPvpLevelDiff = Number(aAlignmentParts[3]) - _global.parseInt(sOtherData1);
                           var nMinorLimit = this.api.lang.getConfigText("PVP_VIEW_BONUS_MINOR_LIMIT");
                           var nMinorPercent = this.api.lang.getConfigText("PVP_VIEW_BONUS_MINOR_LIMIT_PRC");
                           var nMajorLimit = this.api.lang.getConfigText("PVP_VIEW_BONUS_MAJOR_LIMIT");
                           var nMajorPercent = this.api.lang.getConfigText("PVP_VIEW_BONUS_MAJOR_LIMIT_PRC");
                           var nPvpGain = 0;
                           if(this.api.datacenter.Player.Level * (1 - nMinorPercent / 100) > nPvpLevelDiff)
                           {
                              nPvpGain = -1;
                           }
                           if(this.api.datacenter.Player.Level - nPvpLevelDiff > nMinorLimit)
                           {
                              nPvpGain = -1;
                           }
                           if(this.api.datacenter.Player.Level * (1 + nMajorPercent / 100) < nPvpLevelDiff)
                           {
                              nPvpGain = 1;
                           }
                           if(this.api.datacenter.Player.Level - nPvpLevelDiff < nMajorLimit)
                           {
                              nPvpGain = 1;
                           }
                           oPlayerCharData.pvpGain = nPvpGain;
                        }
                     }
                     if(!this.api.datacenter.Game.isFight && (_global.parseInt(sOtherData1,10) != this.api.datacenter.Player.ID && ((this.api.datacenter.Player.alignment.index == 1 || this.api.datacenter.Player.alignment.index == 2) && ((oPlayerCharData.alignment.index == 1 || oPlayerCharData.alignment.index == 2) && (oPlayerCharData.alignment.index != this.api.datacenter.Player.alignment.index && (oPlayerCharData.rank.value && this.api.datacenter.Map.bCanAttack))))))
                     {
                        if(this.api.datacenter.Player.rank.value > oPlayerCharData.rank.value)
                        {
                           this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_NEW_ENEMY_WEAK);
                        }
                        if(this.api.datacenter.Player.rank.value < oPlayerCharData.rank.value)
                        {
                           this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_NEW_ENEMY_STRONG);
                        }
                     }
                     var oPlayerGfxInfo = this.sliptGfxData(sGfxData);
                     var aPlayerGfxList = oPlayerGfxInfo.gfx;
                     this.splitGfxForScale(aPlayerGfxList[0],oPlayerCharData);
                     oPlayerCharData.title = oTitle;
                     oSprite = this.api.kernel.CharactersManager.createCharacter(sOtherData1,sOtherData2,oPlayerCharData);
                     dofus.datacenter.Character(oSprite).isClear = false;
                     oSprite.allowGhostMode = bAllowGhost;
                     var sCurrentParentID = sOtherData1;
                     var nChildLinkDir = oPlayerGfxInfo.shape != "circle" ? 2 : 0;
                     var nGfxItemIdx = 1;
                     while(nGfxItemIdx < aPlayerGfxList.length)
                     {
                        if(aPlayerGfxList[nGfxItemIdx] != "")
                        {
                           var sChildSpriteID = sOtherData1 + "_" + nGfxItemIdx;
                           var oGfxScaleData = {};
                           this.splitGfxForScale(aPlayerGfxList[nGfxItemIdx],oGfxScaleData);
                           var oChildSprite = new ank.battlefield.datacenter.Sprite(sChildSpriteID,ank.battlefield.mc.Sprite,dofus.Constants.CLIPS_PERSOS_PATH + oGfxScaleData.gfxID + ".swf");
                           oChildSprite.allDirections = false;
                           this.api.gfx.addLinkedSprite(sChildSpriteID,sCurrentParentID,nChildLinkDir,oChildSprite);
                           if(!_global.isNaN(oGfxScaleData.scaleX))
                           {
                              this.api.gfx.setSpriteScale(oChildSprite.id,oGfxScaleData.scaleX,oGfxScaleData.scaleY);
                           }
                           switch(oPlayerGfxInfo.shape)
                           {
                              case "circle":
                                 nChildLinkDir = nGfxItemIdx;
                                 break;
                              case "line":
                                 sCurrentParentID = sChildSpriteID;
                                 nChildLinkDir = 2;
                           }
                        }
                        nGfxItemIdx = nGfxItemIdx + 1;
                     }
               }

               // 6. Trigger onSpriteMovement to add/update the sprite on the battlefield
               this.onSpriteMovement(bHasMovement,oSprite,aTransitionEffect);
            }
            else
            {
               var sSpriteIDToRemove = sPart.substr(1);
               var oSpriteToRemove = this.api.datacenter.Sprites.getItemAt(sSpriteIDToRemove);

               if(!this.api.datacenter.Game.isRunning && this.api.datacenter.Game.isLoggingMapDisconnections)
               {
                  var sSpriteName = oSpriteToRemove.name;
                  var nLastDisconnectTime = this._aGameSpriteLeftHistory[sSpriteIDToRemove];

                  if(!_global.isNaN(nLastDisconnectTime) && getTimer() - nLastDisconnectTime < 300)
                  {
                     this.api.kernel.showMessage(undefined,this.api.kernel.DebugManager.getTimestamp() + " (Map) " + this.api.kernel.ChatManager.getLinkName(sSpriteIDToRemove,sSpriteName) + " s\'est déconnecté (" + sSpriteIDToRemove + ")","ADMIN_CHAT");
                  }

                  this._aGameSpriteLeftHistory[sSpriteIDToRemove] = getTimer();
               }

               // 6. Trigger onSpriteMovement to remove the sprite from the battlefield
               this.onSpriteMovement(bHasMovement,oSpriteToRemove);
            }
         }
      }
   }
   function onCellData(sExtraData)
   {
      var aDataLines = sExtraData.split("|");
      var nLineIdx = 0;
      while(nLineIdx < aDataLines.length)
      {
         var aLineParts = aDataLines[nLineIdx].split(";");
         var nCellNum = Number(aLineParts[0]);
         var sCellLayerNum = aLineParts[1].substring(0,10);
         var sCellData = aLineParts[1].substr(10);
         var bIsWalkable = aLineParts[2] != "0" ? 1 : 0;
         this.api.gfx.updateCell(nCellNum,sCellLayerNum,sCellData,bIsWalkable);
         nLineIdx = nLineIdx + 1;
      }
   }
   function onZoneData(sExtraData)
   {
      var aZoneLines = sExtraData.split("|");
      var nZoneIdx = 0;
      while(nZoneIdx < aZoneLines.length)
      {
         var sZoneLine = aZoneLines[nZoneIdx];
         var bIsAdding = sZoneLine.charAt(0) != "+" ? false : true;
         var aZoneData = sZoneLine.substr(1).split(";");
         var nZoneID = Number(aZoneData[0]);
         var nUnknown = Number(aZoneData[1]);
         var sZoneType = aZoneData[2];
         var nZoneLevel = Number(aZoneData[3]);
         if(bIsAdding)
         {
            this.api.gfx.drawZone(nZoneID,0,nUnknown,sZoneType,dofus.Constants.ZONE_COLOR[sZoneType],nZoneLevel);
         }
         else
         {
            this.api.gfx.clearZone(nZoneID,nUnknown,sZoneType);
         }
         nZoneIdx = nZoneIdx + 1;
      }
   }
   function onCellObject(sExtraData)
   {
      var bIsAdding = sExtraData.charAt(0) == "+";
      var aObjectLines = sExtraData.substr(1).split("|");
      var nObjectIdx = 0;
      while(nObjectIdx < aObjectLines.length)
      {
         var aObjectData = aObjectLines[nObjectIdx].split(";");
         var nCellNum = Number(aObjectData[0]);
         var nItemID = _global.parseInt(aObjectData[1]);
         if(bIsAdding)
         {
            var oItem = new dofus.datacenter.Item(0,nItemID);
            var nObjectType = Number(aObjectData[2]);
            switch(nObjectType)
            {
               case 0:
                  this.api.gfx.updateCellObjectExternalWithExternalClip(nCellNum,oItem.iconFile,1,true,true,oItem);
                  break;
               case 1:
                  if(this.api.gfx.mapHandler.getCellData(nCellNum).layerObjectExternalData.unicID != nItemID)
                  {
                     this.api.gfx.updateCellObjectExternalWithExternalClip(nCellNum,oItem.iconFile,1,true,false,oItem);
                  }
                  else
                  {
                     oItem = this.api.gfx.mapHandler.getCellData(nCellNum).layerObjectExternalData;
                  }
                  oItem.rideItemDurability = Number(aObjectData[3]);
                  oItem.rideItemDurabilityMax = Number(aObjectData[4]);
            }
         }
         else
         {
            var oCellData = this.api.gfx.mapHandler.getCellData(nCellNum);
            if(oCellData != undefined && (oCellData.mcObjectExternal != undefined && oCellData.mcObjectExternal == this.api.gfx.rollOverMcObject))
            {
               this.api.gfx.onObjectRollOut(oCellData.mcObjectExternal);
            }
            this.api.gfx.initializeCell(nCellNum,1);
         }
         nObjectIdx = nObjectIdx + 1;
      }
   }
   function onFrameObject2(sExtraData)
   {
      var oPopupMenu = ank.gapi.controls.PopupMenu.currentPopupMenu;
      var aFrameLines = sExtraData.split("|");
      var nLineIdx = 0;
      while(nLineIdx < aFrameLines.length)
      {
         var aFrameData = aFrameLines[nLineIdx].split(";");
         var nCellNum = Number(aFrameData[0]);
         var sFrameNum = aFrameData[1];
         var bHasFrame = aFrameData[2] != undefined;
         var bIsInteractive = aFrameData[2] != "1" ? false : true;
         if(oPopupMenu != undefined && (oPopupMenu.gatherCellNum == nCellNum && (!bIsInteractive && sFrameNum == "3")))
         {
            oPopupMenu.removePopupMenu();
         }
         if(bHasFrame)
         {
            this.api.gfx.setObject2Interactive(nCellNum,bIsInteractive,2);
         }
         this.api.gfx.setObject2Frame(nCellNum,sFrameNum);
         nLineIdx = nLineIdx + 1;
      }
   }
   function onFrameObjectExternal(sExtraData)
   {
      var aFrameLines = sExtraData.split("|");
      var nLineIdx = 0;
      while(nLineIdx < aFrameLines.length)
      {
         var aFrameData = aFrameLines[nLineIdx].split(";");
         var nCellNum = Number(aFrameData[0]);
         var nFrameNum = Number(aFrameData[1]);
         this.api.gfx.setObjectExternalFrame(nCellNum,nFrameNum);
         nLineIdx = nLineIdx + 1;
      }
   }
   function onEffect(sExtraData)
   {
      var aEffectData = sExtraData.split(";");
      var nEffectID = aEffectData[0];
      var aTargetIDs = aEffectData[1].split(",");
      var nDelayMin = aEffectData[2];
      var nDelayMax = aEffectData[3];
      var nDuration = aEffectData[4];
      var sEffectParams = aEffectData[5];
      var nTurns = Number(aEffectData[6]);
      var nAbsorbPercent = aEffectData[7];
      var sEffectType = aEffectData[8];
      var bIsDamage = Number(aEffectData[9]) == 1;
      var nTargetIdx = 0;
      while(nTargetIdx < aTargetIDs.length)
      {
         var nTargetID = aTargetIDs[nTargetIdx];
         if(nTargetID == this.api.datacenter.Game.currentPlayerID && nTurns != -1)
         {
            nTurns = nTurns + 1;
         }
         var oEffect = new dofus.datacenter.Effect(sEffectType,Number(nEffectID),Number(nDelayMin),Number(nDelayMax),Number(nDuration),sEffectParams,Number(nTurns),Number(nAbsorbPercent),undefined,undefined,bIsDamage);
         var oTargetSprite = this.api.datacenter.Sprites.getItemAt(nTargetID);
         oTargetSprite.EffectsManager.addEffect(oEffect);
         nTargetIdx = nTargetIdx + 1;
      }
   }
   function onClearAllEffect(sExtraData)
   {
      var oAllSprites = this.api.datacenter.Sprites;
      for(var a in oAllSprites)
      {
         oAllSprites[a].EffectsManager.terminateAllEffects();
      }
   }
   function onChallenge(sExtraData)
   {
      var bIsAdding = sExtraData.charAt(0) == "+";
      var aChallengeLines = sExtraData.substr(1).split("|");
      var aFirstLineData = aChallengeLines.shift().split(";");
      var nChallengeID = Number(aFirstLineData[0]);
      var nChallengeLevel = Number(aFirstLineData[1]);
      var nChallengeColor = (Math.cos(nChallengeID) + 1) * 8388607;
      if(bIsAdding)
      {
         var oChallenge = new dofus.datacenter.Challenge(nChallengeID,nChallengeLevel);
         this.api.datacenter.Challenges.addItemAt(nChallengeID,oChallenge);
         var nTeamIdx = 0;
         while(nTeamIdx < aChallengeLines.length)
         {
            var aTeamData = aChallengeLines[nTeamIdx].split(";");
            var sTeamName = aTeamData[0];
            var nTeamLevel = Number(aTeamData[1]);
            var nTeamType = Number(aTeamData[2]);
            var nTeamAlignment = Number(aTeamData[3]);
            var sTeamFile = dofus.Constants.getTeamFileFromType(nTeamType,nTeamAlignment);
            var oTeam = new dofus.datacenter.Team(sTeamName,ank.battlefield.mc.Sprite,sTeamFile,nTeamLevel,nChallengeColor,nTeamType,nTeamAlignment);
            oChallenge.addTeam(oTeam);
            this.api.gfx.addSprite(oTeam.id,oTeam);
            nTeamIdx = nTeamIdx + 1;
         }
      }
      else
      {
         var oChallengeLookup = this.api.datacenter.Challenges.getItemAt(nChallengeID).teams;
         for(var k in oChallengeLookup)
         {
            var oTeamToRemove = oChallengeLookup[k];
            this.api.gfx.removeSprite(oTeamToRemove.id);
         }
         this.api.datacenter.Challenges.removeItemAt(nChallengeID);
      }
   }
   function onTeam(sExtraData)
   {
      var aTeamLines = sExtraData.split("|");
      var nTeamID = Number(aTeamLines.shift());
      var oTeam = dofus.datacenter.Team(this.api.datacenter.Sprites.getItemAt(nTeamID));
      var nMemberIdx = 0;
      while(nMemberIdx < aTeamLines.length)
      {
         var aPlayerData = aTeamLines[nMemberIdx].split(";");
         var bIsJoining = aPlayerData[0].charAt(0) == "+";
         var sPlayerID = aPlayerData[0].substr(1);
         var sPlayerName = aPlayerData[1];
         var nPlayerLevel = aPlayerData[2];
         var aNameParts = sPlayerName.split(",");
         var nMonsterID = Number(sPlayerName);
         if(aNameParts.length > 1)
         {
            sPlayerName = this.api.lang.getFullNameText(aNameParts);
         }
         else if(!_global.isNaN(nMonsterID))
         {
            sPlayerName = this.api.lang.getMonstersText(nMonsterID).n;
         }
         if(bIsJoining)
         {
            var oMember = {};
            oMember.id = sPlayerID;
            oMember.name = sPlayerName;
            oMember.level = nPlayerLevel;
            oTeam.addPlayer(oMember);
         }
         else
         {
            oTeam.removePlayer(sPlayerID);
         }
         nMemberIdx = nMemberIdx + 1;
      }
      oTeam.refreshSwordSprite();
   }
   function onFightOption(sExtraData)
   {
      var sTeamID = sExtraData.substr(2);
      var oTeamSprite = this.api.datacenter.Sprites.getItemAt(sTeamID);
      if(oTeamSprite != undefined)
      {
         var bOptionEnabled = sExtraData.charAt(0) == "+";
         var sOptionType = sExtraData.charAt(1);
         switch(sOptionType)
         {
            case "H":
               oTeamSprite.options[dofus.datacenter.Team.OPT_NEED_HELP] = bOptionEnabled;
               break;
            case "S":
               oTeamSprite.options[dofus.datacenter.Team.OPT_BLOCK_SPECTATOR] = bOptionEnabled;
               break;
            case "A":
               oTeamSprite.options[dofus.datacenter.Team.OPT_BLOCK_JOINER] = bOptionEnabled;
               break;
            case "P":
               oTeamSprite.options[dofus.datacenter.Team.OPT_BLOCK_JOINER_EXCEPT_PARTY_MEMBER] = bOptionEnabled;
         }
         this.api.gfx.addSpriteOverHeadItem(sTeamID,"FightOptions",dofus.graphics.battlefield.FightOptionsOverHead,[oTeamSprite],undefined);
      }
   }
   function onLeave()
   {
      this.api.datacenter.Game.currentPlayerID = undefined;
      this.api.ui.getUIComponent("Banner").hideRightPanel(true);
      this.api.ui.unloadUIComponent("Timeline");
      this.api.ui.unloadUIComponent("StringCourse");
      this.api.ui.unloadUIComponent("PlayerInfos");
      this.api.ui.unloadUIComponent("SpriteInfos");
      this.aks.GameActions.onActionsFinish(String(this.api.datacenter.Player.ID));
      this.api.datacenter.Player.reset();
      this.api.datacenter.Player.isDead = false;
      var oFightChallenge = dofus.graphics.gapi.ui.FightChallenge(dofus.graphics.gapi.ui.FightChallenge(this.api.ui.getUIComponent("FightChallenge")));
      oFightChallenge.cleanChallenge();
      this.aks.Game.create();
   }
   function onEnd(sExtraData)
   {
      if(this.api.kernel.MapsServersManager.isBuilding)
      {
         this.addToQueue({object:this,method:this.onEnd,params:[sExtraData]});
         return undefined;
      }
      this.aks.Game.isBusy = true;
      var oFightChallenge = dofus.graphics.gapi.ui.FightChallenge(dofus.graphics.gapi.ui.FightChallenge(this.api.ui.getUIComponent("FightChallenge")));
      this.api.kernel.StreamingDisplayManager.onFightEnd();
      var oFightResults = {winners:[],loosers:[],collectors:[],challenges:oFightChallenge.challenges.deepClone(),currentTableTurn:this.api.datacenter.Game.currentTableTurn,currentPlayerInfos:[],currentPlayerInfosWithChest:[]};
      this.api.datacenter.Game.results = oFightResults;
      if(!this.api.datacenter.Game.isSpectator)
      {
         this.api.datacenter.Basics.currentSessionFightCount = this.api.datacenter.Basics.currentSessionFightCount + 1;
         oFightResults.id = this.api.datacenter.Basics.currentSessionFightCount;
         this.api.datacenter.Game.storeFightResults(oFightResults);
      }
      oFightChallenge.cleanChallenge();
      var aResultLines = sExtraData.split("|");
      var nBonusEndFight = -1;
      if(!_global.isNaN(Number(aResultLines[0])))
      {
         oFightResults.duration = Number(aResultLines[0]);
      }
      else
      {
         var aDurationData = aResultLines[0].split(";");
         oFightResults.duration = Number(aDurationData[0]);
         nBonusEndFight = Number(aDurationData[1]);
      }
      this.api.datacenter.Basics.aks_game_end_bonus = nBonusEndFight;
      var nSenderID = Number(aResultLines[1]);
      var nFightType = Number(aResultLines[2]);
      oFightResults.fightType = nFightType;
      var eaFightDrop = new ank.utils.ExtendedArray();
      var nKamaDrop = 0;
      this.api.datacenter.Player.isDead = false;
      this.parsePlayerData(oFightResults,3,nSenderID,aResultLines,nFightType,nKamaDrop,eaFightDrop,false,false);
   }
   function parsePlayerData(oResults, nStartIndex, nSenderID, aTmp, nFightType, nKamaDrop, eaFightDrop, bAlreadyParsed, bIsChest)
   {
      var nCurrentIdx = nStartIndex;
      var aPlayerDataParts = aTmp[nCurrentIdx].split(";");
      var oPlayerInfo = {};
      if(Number(aPlayerDataParts[0]) != 6)
      {
         oPlayerInfo.id = Number(aPlayerDataParts[1]);
         if(oPlayerInfo.id == this.api.datacenter.Player.ID)
         {
            if(Number(aPlayerDataParts[0]) == 0)
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_FIGHT_LOST);
            }
            else
            {
               this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_FIGHT_WON);
            }
         }
         var oNameInfo = this.api.kernel.CharactersManager.getNameFromData(aPlayerDataParts[2]);
         oPlayerInfo.name = oNameInfo.name;
         oPlayerInfo.type = oNameInfo.type;
         oPlayerInfo.level = Number(aPlayerDataParts[3]);
         oPlayerInfo.bDead = aPlayerDataParts[5] != "1" ? false : true;
         oPlayerInfo.gfx = Number(aPlayerDataParts[4]);
         switch(nFightType)
         {
            case 0:
               oPlayerInfo.minxp = Number(aPlayerDataParts[6]);
               oPlayerInfo.xp = Number(aPlayerDataParts[7]);
               oPlayerInfo.maxxp = Number(aPlayerDataParts[8]);
               oPlayerInfo.winxp = Math.max(Number(aPlayerDataParts[9]),0);
               oPlayerInfo.guildxp = Number(aPlayerDataParts[10]);
               oPlayerInfo.mountxp = Number(aPlayerDataParts[11]);
               var aDropItems = aPlayerDataParts[12].split(",");
               if(oPlayerInfo.id == this.api.datacenter.Player.ID && aDropItems.length > 10)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_GREAT_DROP);
               }
               oPlayerInfo.kama = aPlayerDataParts[13];
               break;
            case 1:
               oPlayerInfo.minhonour = Number(aPlayerDataParts[6]);
               oPlayerInfo.honour = Number(aPlayerDataParts[7]);
               oPlayerInfo.maxhonour = Number(aPlayerDataParts[8]);
               oPlayerInfo.winhonour = Number(aPlayerDataParts[9]);
               oPlayerInfo.rank = Number(aPlayerDataParts[10]);
               oPlayerInfo.disgrace = Number(aPlayerDataParts[11]);
               oPlayerInfo.windisgrace = Number(aPlayerDataParts[12]);
               oPlayerInfo.maxdisgrace = this.api.lang.getMaxDisgracePoints();
               oPlayerInfo.mindisgrace = 0;
               oPlayerInfo.alignment = Number(aPlayerDataParts[13]);
               aDropItems = aPlayerDataParts[14].split(",");
               if(oPlayerInfo.id == this.api.datacenter.Player.ID && aDropItems.length > 10)
               {
                  this.api.kernel.SpeakingItemsManager.triggerEvent(dofus.managers.SpeakingItemsManager.SPEAK_TRIGGER_GREAT_DROP);
               }
               oPlayerInfo.kama = aPlayerDataParts[15];
               oPlayerInfo.minxp = Number(aPlayerDataParts[16]);
               oPlayerInfo.xp = Number(aPlayerDataParts[17]);
               oPlayerInfo.maxxp = Number(aPlayerDataParts[18]);
               oPlayerInfo.winxp = Number(aPlayerDataParts[19]);
         }
      }
      else
      {
         aDropItems = aPlayerDataParts[1].split(",");
         oPlayerInfo.kama = aPlayerDataParts[2];
         nKamaDrop += Number(oPlayerInfo.kama);
      }
      oPlayerInfo.items = [];
      oPlayerInfo.items = this.parseItems(aDropItems);
      switch(Number(aPlayerDataParts[0]))
      {
         case 0:
            oResults.loosers.push(oPlayerInfo);
            break;
         case 2:
            oResults.winners.push(oPlayerInfo);
            break;
         case 5:
            oResults.collectors.push(oPlayerInfo);
            break;
         case 6:
            eaFightDrop = eaFightDrop.concat(oPlayerInfo.items);
      }
      if(!bAlreadyParsed && (oPlayerInfo.id == this.api.datacenter.Player.ID || bIsChest))
      {
         if(bIsChest)
         {
            var oItemLookup = new ank.utils.ExtendedObject();
            var aMergedItems = [];
            var aBaseLootItems = oResults.currentPlayerInfos[0].items;
            var nBaseItemIdx = 0;
            while(nBaseItemIdx < aBaseLootItems.length)
            {
               var oBaseItem = aBaseLootItems[nBaseItemIdx];
               var oClonedItem = new dofus.datacenter.Item(undefined,oBaseItem.unicID,oBaseItem.Quantity);
               aMergedItems.push(oClonedItem);
               oItemLookup.addItemAt(oBaseItem.unicID,oClonedItem);
               nBaseItemIdx = nBaseItemIdx + 1;
            }
            var aChestItems = oPlayerInfo.items;
            var nChestItemIdx = 0;
            while(nChestItemIdx < aChestItems.length)
            {
               var oChestItem = aChestItems[nChestItemIdx];
               if(oItemLookup.getItemAt(oChestItem.unicID) != undefined)
               {
                  var oExistingItem = dofus.datacenter.Item(oItemLookup.getItemAt(oChestItem.unicID));
                  oExistingItem.Quantity += oChestItem.Quantity;
               }
               else
               {
                  aMergedItems.push(oChestItem);
               }
               nChestItemIdx = nChestItemIdx + 1;
            }
            this.api.datacenter.Basics.kamas_lastGained = Number(this.api.datacenter.Basics.kamas_lastGained) + Number(aPlayerDataParts[13]);
            var oMergedResult = {};
            oMergedResult.type = oResults.currentPlayerInfos[0].type;
            oMergedResult.winxp = this.api.datacenter.Basics.exp_lastGained;
            oMergedResult.guildxp = this.api.datacenter.Basics.guildExp_lastGained;
            oMergedResult.mountxp = this.api.datacenter.Basics.mountExp_lastGained;
            oMergedResult.kama = this.api.datacenter.Basics.kamas_lastGained;
            oMergedResult.items = aMergedItems;
            oResults.currentPlayerInfosWithChest.push(oMergedResult);
            bAlreadyParsed = true;
         }
         else
         {
            if(this.api.datacenter.Player.Guild == 3 && nFightType == 0)
            {
               if(aTmp[nCurrentIdx + 1].split(";")[2] == 285)
               {
                  bIsChest = true;
               }
               else
               {
                  bAlreadyParsed = true;
               }
            }
            else
            {
               bAlreadyParsed = true;
            }
            this.api.datacenter.Basics.exp_lastGained = oPlayerInfo.winxp;
            this.api.datacenter.Basics.kamas_lastGained = oPlayerInfo.kama;
            this.api.datacenter.Basics.guildExp_lastGained = oPlayerInfo.guildxp;
            this.api.datacenter.Basics.mountExp_lastGained = oPlayerInfo.mountxp;
            oResults.currentPlayerInfos.push(oPlayerInfo);
         }
      }
      nCurrentIdx = nCurrentIdx + 1;
      if(nCurrentIdx < aTmp.length)
      {
         this.addToQueue({object:this,method:this.parsePlayerData,params:[oResults,nCurrentIdx,nSenderID,aTmp,nFightType,nKamaDrop,eaFightDrop,bAlreadyParsed,bIsChest]});
      }
      else
      {
         this.onParseItemEnd(nSenderID,oResults,eaFightDrop,nKamaDrop);
      }
   }
   function parseItems(aItems)
   {
      var aResults = [];
      var nItemIdx = 0;
      while(nItemIdx < aItems.length)
      {
         var aItemParts = aItems[nItemIdx].split("~");
         var nItemID = Number(aItemParts[0]);
         var nItemQty = Number(aItemParts[1]);
         if(_global.isNaN(nItemID))
         {
            break;
         }
         if(nItemID != 0)
         {
            var oItem = new dofus.datacenter.Item(0,nItemID,nItemQty);
            aResults.push(oItem);
         }
         nItemIdx = nItemIdx + 1;
      }
      return aResults;
   }
   function onParseItemEnd(nSenderID, oResults, eaFightDrop, nKamaDrop)
   {
      if(eaFightDrop.length)
      {
         var nItemsPerWinner = Math.ceil(eaFightDrop.length / oResults.winners.length);
         var nWinnerIdx = 0;
         while(nWinnerIdx < oResults.winners.length)
         {
            var nTotalItems = eaFightDrop.length;
            oResults.winners[nWinnerIdx].kama = Math.ceil(nKamaDrop / nItemsPerWinner);
            if(nWinnerIdx == oResults.winners.length - 1)
            {
               nItemsPerWinner = nTotalItems;
            }
            var nStartIdx = nTotalItems - nItemsPerWinner;
            while(nStartIdx < nTotalItems)
            {
               oResults.winners[nWinnerIdx].items.push(eaFightDrop.pop());
               nStartIdx = nStartIdx + 1;
            }
            nWinnerIdx = nWinnerIdx + 1;
         }
      }
      if(nSenderID == this.api.datacenter.Player.ID)
      {
         this.aks.GameActions.onActionsFinish(String(nSenderID));
      }
      this.api.datacenter.Game.isRunning = false;
      var oSpriteSequencer = this.api.datacenter.Sprites.getItemAt(nSenderID).sequencer;
      this.aks.Game.isBusy = false;
      if(oSpriteSequencer != undefined)
      {
         oSpriteSequencer.addAction(26,false,this.api.kernel.GameManager,this.api.kernel.GameManager.terminateFight);
         oSpriteSequencer.execute(false);
      }
      else
      {
         ank.utils.Logger.err("[AKS.Game.onEnd] Impossible de trouver le sequencer");
         ank.utils.Timer.setTimer(this,"game",this.api.kernel.GameManager,this.api.kernel.GameManager.terminateFight,500);
      }
      this.api.kernel.TipsManager.showNewTip(dofus.managers.TipsManager.TIP_FIGHT_ENDFIGHT);
   }
   function onExtraClip(sExtraData)
   {
      var aDataParts = sExtraData.split("|");
      var sClipName = aDataParts[0];
      var aSpriteIDs = aDataParts[1].split(";");
      var sClipPath = dofus.Constants.EXTRA_PATH + sClipName + ".swf";
      var bIsRemoving = sClipName == "-";
      for(var k in aSpriteIDs)
      {
         var sSpriteID = aSpriteIDs[k];
         if(bIsRemoving)
         {
            this.api.gfx.removeSpriteExtraClip(sSpriteID,false);
         }
         else
         {
            this.api.gfx.addSpriteExtraClip(sSpriteID,sClipPath,undefined,false);
         }
      }
   }
   function onGameOver()
   {
      this.api.network.softDisconnect();
      this.api.ui.loadUIComponent("GameOver","GameOver",undefined,{bAlwaysOnTop:true});
   }


   /**
	 * onSpriteMovement
	 * 
    * Purpose:
    * Adds or removes sprites from the battlefield and applies visual effects.
    *
    * Parameters:
    * @param bAdd {Boolean} True to add sprite, false to remove
    * @param oSprite {Sprite} The sprite object to add/remove
    * @param aEffect {Array} Optional visual effects to apply
    *
    * Data flow:
    * Sprite instance → Visual effects/scale applied → Added to battlefield container → Optional extra clips attached
    */
   function onSpriteMovement(bAdd, oSprite, aEffect)
   {

      // Step 1: Update player count if sprite is a Character
      if(oSprite instanceof dofus.datacenter.Character)
      {
         this.api.datacenter.Game.playerCount += !bAdd ? -1 : 1;
      }

      var sSpriteID = oSprite.id;

      if(bAdd)
      {
         // Step 2: If adding, apply visual effects and add sprite to GFX layer
         if(aEffect != undefined)
         {
            this.api.gfx.spriteLaunchVisualEffect.apply(this.api.gfx,aEffect);
         }
         this.api.gfx.addSprite(sSpriteID);

         // Step 3: Set sprite scale if specified
         if(!_global.isNaN(oSprite.scaleX))
         {
            this.api.gfx.setSpriteScale(sSpriteID,oSprite.scaleX,oSprite.scaleY);
         }

         // Step 4: Add extra clips (offline indicators, NPC clips, team circles, auras)
         if(oSprite instanceof dofus.datacenter.OfflineCharacter)
         {
            oSprite.mc.addExtraClip(dofus.Constants.EXTRA_PATH + oSprite.offlineType + ".swf",undefined,true);
            return undefined;
         }

         if(oSprite instanceof dofus.datacenter.NonPlayableCharacter)
         {
            if(!_global.isNaN(oSprite.extraClipID))
            {
               this.api.gfx.addSpriteExtraClip(sSpriteID,dofus.Constants.EXTRA_PATH + oSprite.extraClipID + ".swf",undefined,false);
               return undefined;
            }
         }

         if(this.api.datacenter.Game.isRunning)
         {
            this.api.gfx.addSpriteExtraClip(sSpriteID,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oSprite.Team]);
         }
         else if(oSprite.Aura != 0 && (oSprite.Aura != undefined && this.api.kernel.OptionsManager.getOption("Aura")))
         {
            this.api.gfx.addSpriteExtraClip(sSpriteID,dofus.Constants.AURA_PATH + oSprite.Aura + ".swf",undefined,true);
         }

         // Step 5: Update local player data if this is the player's sprite
         if(sSpriteID == this.api.datacenter.Player.ID)
         {
            this.api.datacenter.Player.data = oSprite;
            this.api.ui.getUIComponent("Banner").updateLocalPlayer();
         }
         else if(this.api.gfx.spriteHandler.isPlayerSpritesHidden && (oSprite instanceof dofus.datacenter.Character || (oSprite instanceof dofus.datacenter.PlayerShop || oSprite instanceof dofus.datacenter.MonsterGroup)))
         {
            this.api.gfx.spriteHandler.hideSprite(sSpriteID,true);
         }
         else if(this.api.gfx.spriteHandler.isShowingMonstersTooltip && oSprite instanceof dofus.datacenter.MonsterGroup)
         {
            oSprite.mc._rollOver(true);
         }

      }
      else if(!this.api.datacenter.Game.isRunning)
      {
         // Step 6 (out of fight): Remove immediately if not in fight
         this.api.gfx.removeSprite(sSpriteID);
      }
      else
      {
         // Step 6 (in fight): Play death animation sequence before removal
         var oSequencer = oSprite.sequencer;
         var oMovieClip = oSprite.mc;

         oSequencer.addAction(27,false,this.api.kernel,this.api.kernel.showMessage,[undefined,this.api.lang.getText("LEAVE_GAME",[oSprite.name]),"INFO_CHAT"]);
         oSequencer.addAction(28,false,this.api.ui.getUIComponent("Timeline"),this.api.ui.getUIComponent("Timeline").hideItem,[sSpriteID]);
         oSequencer.addAction(29,true,oMovieClip,oMovieClip.setAnim,["Die"],1500,true);

         if(oSprite.hasCarriedChild())
         {
            this.api.gfx.uncarriedSprite(oSprite.carriedChild.id,oSprite.cellNum,false,oSequencer);
            oSequencer.addAction(30,false,this.api.gfx,this.api.gfx.addSpriteExtraClip,[oSprite.carriedChild.id,dofus.Constants.CIRCLE_FILE,dofus.Constants.TEAMS_COLOR[oSprite.carriedChild.Team]]);
         }

         oSequencer.addAction(31,false,oMovieClip,oMovieClip.clear);
         oSequencer.execute();

         if(this.api.datacenter.Game.currentPlayerID == sSpriteID)
         {
            this.api.ui.getUIComponent("Banner").stopTimer();
            this.api.ui.getUIComponent("Timeline").stopChrono();
         }
      }

      this.api.kernel.GameManager.applyCreatureMode();
   }

   /**
	 * sliptGfxData
    * 
	 * Purpose:
    * Parses graphics data string to determine shape and GFX IDs
    * for multi-sprite entities.
    *
    * Parameters:
    * - sGfx: Graphics data string containing comma or colon separators
    *
    * Data flow:
    * Graphics string → Parsed shape and GFX array → Used for multi-sprite positioning
    */
   function sliptGfxData(sGfx)
   {

      // Step 1: Check for commas to detect circular arrangement
      if(sGfx.indexOf(",") != -1)
      {
         var aCircleGfx = sGfx.split(",");
         return {shape:"circle",gfx:aCircleGfx};
      }

      // Step 2: Check for colons to detect linear arrangement
      if(sGfx.indexOf(":") != -1)
      {
         var aLineGfx = sGfx.split(":");
         return {shape:"line",gfx:aLineGfx};
      }

      // Step 3: Return object with shape ("circle", "line", or "none")
      // and array of GFX IDs
      return {shape:"none",gfx:[sGfx]};

   }

   /**
    * splitGfxForScale
	 *
	 * Purpose:
    * Parses graphics data string to determine shape and GFX IDs
    * for multi-sprite entities.
    *
    * Parameters:
    * - sGfx: Graphics data string containing comma or colon separators
    *
    * Data flow:
    * Graphics string → Parsed shape and GFX array → Used for multi-sprite positioning
    */
   function splitGfxForScale(sGfxInput, oData)
   {

      // Step 1: Check for commas to detect circular arrangement
      var aGfxParts = sGfxInput.split("^");

      var sGfxID = aGfxParts.length != 2 ? sGfxInput : aGfxParts[0];

      var nScaleX = 100;

      var nScaleY = 100;

      // Step 2: Check for colons to detect linear arrangement
      if(aGfxParts.length == 2)

      {

         var sScaleData = aGfxParts[1];

         if(_global.isNaN(Number(sScaleData)))

         {

            var aScaleParts = sScaleData.split("x");

            nScaleX = aScaleParts.length != 2 ? 100 : Number(aScaleParts[0]);

            nScaleY = aScaleParts.length != 2 ? 100 : Number(aScaleParts[1]);

         }

         else

         {

            nScaleX = nScaleY = Number(sScaleData);

         }

      }

      // Step 3: Return object with shape ("circle", "line", or "none")
      // and array of GFX IDs
      oData.gfxID = sGfxID;

      oData.scaleX = nScaleX;

      oData.scaleY = nScaleY;

   }
   function createTransitionEffect()
   {
      var oEffect = new ank.battlefield.datacenter.VisualEffect();
      oEffect.id = 5;
      oEffect.file = dofus.Constants.SPELLS_PATH + "transition.swf";
      oEffect.level = 5;
      oEffect.params = [];
      oEffect.bInFrontOfSprite = true;
      oEffect.bTryToBypassContainerColor = false;
      return oEffect;
   }
}
