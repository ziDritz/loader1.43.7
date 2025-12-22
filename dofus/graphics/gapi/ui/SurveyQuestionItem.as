class dofus.graphics.gapi.ui.SurveyQuestionItem extends ank.gapi.core.UIBasicComponent
{
   var _mcList;
   var _oItem;
   var _txtQuestion;
   var _cbAnswers;
   static var MAX_ROWS = 5;
   function SurveyQuestionItem()
   {
      super();
   }
   function set list(mcList)
   {
      this._mcList = mcList;
   }
   function get list()
   {
      return this._mcList;
   }
   function setValue(bUsed, sSuggested, oItem)
   {
      this._oItem = oItem;
      if(oItem != undefined)
      {
         this._txtQuestion.text = oItem.text;
         this._cbAnswers._visible = true;
         this._cbAnswers.addEventListener("itemSelected",this);
         var _loc5_ = new ank.utils.ExtendedArray();
         var _loc6_ = 0;
         while(_loc6_ < oItem.answers.length)
         {
            _loc5_.push({label:oItem.answers[_loc6_]});
            _loc6_ = _loc6_ + 1;
         }
         this._cbAnswers.rowCount = _loc5_.length <= dofus.graphics.gapi.ui.SurveyQuestionItem.MAX_ROWS ? _loc5_.length : dofus.graphics.gapi.ui.SurveyQuestionItem.MAX_ROWS;
         this._cbAnswers.dataProvider = _loc5_;
         this._cbAnswers.selectedIndex = oItem.answerSelected;
      }
      else
      {
         this._cbAnswers.closeList();
      }
   }
   function init()
   {
      super.init(false);
      this._cbAnswers.mcListParent = String(this._parent);
   }
   function itemSelected(oEvent)
   {
      var _loc0_ = null;
      if((_loc0_ = oEvent.target) === this._cbAnswers)
      {
         this._mcList.dispatchEvent({type:"itemSelected",target:this,item:oEvent.item,id:this._oItem.id,selectedIndex:this._cbAnswers.selectedIndex});
      }
   }
}
