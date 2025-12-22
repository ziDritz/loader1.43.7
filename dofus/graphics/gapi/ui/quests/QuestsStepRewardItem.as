class dofus.graphics.gapi.ui.quests.QuestsStepRewardItem extends ank.gapi.core.UIBasicComponent
{
   var _mcList;
   var _oItem;
   var _lblName;
   var _ldrIcon;
   function QuestsStepRewardItem()
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
         this._lblName.text = oItem.label;
         this._ldrIcon.forceReload = true;
         this._ldrIcon.contentParams = oItem.params;
         this._ldrIcon.contentPath = oItem.iconFile;
      }
      else if(this._lblName.text != undefined)
      {
         this._lblName.text = "";
         this._ldrIcon.contentPath = "";
      }
   }
}
