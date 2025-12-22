class dofus.graphics.gapi.controls.conqueststatsviewer.ConquestStatsViewerItem extends ank.gapi.core.UIBasicComponent
{
   var _mcList;
   var _oItem;
   var _lblType;
   var _lblBonus;
   var _lblMalus;
   function ConquestStatsViewerItem()
   {
      super();
   }
   function set list(mcList)
   {
      this._mcList = mcList;
   }
   function setValue(bUsed, sSuggested, oItem)
   {
      if(bUsed)
      {
         this._oItem = oItem;
         this._lblType.text = this._oItem.type;
         this._lblBonus.text = this._oItem.bonus;
         this._lblMalus.text = this._oItem.malus;
      }
      else if(this._lblType.text != undefined)
      {
         this._lblType.text = "";
         this._lblBonus.text = "";
         this._lblMalus.text = "";
      }
   }
}
