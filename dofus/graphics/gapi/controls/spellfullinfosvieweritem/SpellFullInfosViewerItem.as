class dofus.graphics.gapi.controls.spellfullinfosvieweritem.SpellFullInfosViewerItem extends ank.gapi.core.UIBasicComponent
{
   var _ctrSpellArea;
   var _ctrConditionalOver;
   var _oItem;
   var _lbl;
   var _ctrElement;
   var _lblArea;
   var _sOverText;
   var _nOverTextLinesCount;
   var arrange;
   var _nLabelWidth = 262.95;
   function SpellFullInfosViewerItem()
   {
      super();
      this._ctrSpellArea._visible = false;
      this._ctrConditionalOver._visible = false;
   }
   function setValue(bUsed, sSuggested, oItem)
   {
      var _loc5_ = _global.API;
      if(bUsed)
      {
         this._oItem = oItem;
         if(oItem.fx.description == undefined && oItem.description == undefined)
         {
            this._lbl.text = sSuggested;
         }
         else
         {
            if(oItem.fx.description != undefined)
            {
               this._lbl.text = oItem.fx.description;
            }
            else if(oItem.description != undefined)
            {
               this._lbl.text = oItem.description;
            }
            var _loc6_ = undefined;
            if(oItem.fx.element != undefined)
            {
               _loc6_ = oItem.fx.element;
            }
            else if(oItem.element != undefined)
            {
               _loc6_ = oItem.element;
            }
            if(_loc6_ != undefined)
            {
               switch(_loc6_)
               {
                  case "N":
                     this._ctrElement.contentPath = "IconNeutralDommage";
                     break;
                  case "F":
                     this._ctrElement.contentPath = "IconFireDommage";
                     break;
                  case "A":
                     this._ctrElement.contentPath = "IconAirDommage";
                     break;
                  case "W":
                     this._ctrElement.contentPath = "IconWaterDommage";
                     break;
                  case "E":
                     this._ctrElement.contentPath = "IconEarthDommage";
                     break;
                  default:
                     this._ctrElement.contentPath = "";
               }
            }
            else if(oItem.fx.icon != undefined)
            {
               this._ctrElement.contentPath = oItem.fx.icon;
            }
            else if(oItem.icon != undefined)
            {
               this._ctrElement.contentPath = oItem.icon;
            }
            else
            {
               this._ctrElement.contentPath = "";
            }
         }
         this._ctrConditionalOver.addEventListener("over",this);
         this._ctrConditionalOver.addEventListener("out",this);
         if(oItem.ar > 0)
         {
            var _loc7_ = oItem.at.charCodeAt(0);
            this._ctrSpellArea.contentPath = dofus.Constants.EMBLEMS_SPELL_AREAS_PATH + _loc7_ + ".swf";
            this._ctrSpellArea._visible = true;
            this._ctrSpellArea.addEventListener("over",this);
            this._ctrSpellArea.addEventListener("out",this);
            this._lblArea.text = oItem.ar != 63 ? oItem.ar : _global.API.lang.getText("INFINIT_SHORT");
         }
         else
         {
            this._ctrSpellArea._visible = false;
            this._ctrSpellArea.removeEventListener("over",this);
            this._ctrSpellArea.removeEventListener("out",this);
            this._lblArea.text = "";
         }
         if(oItem.fx.conditions != undefined)
         {
            var _loc8_ = oItem.fx.conditions;
         }
         else if(oItem.conditions != undefined)
         {
            _loc8_ = oItem.conditions;
         }
         if(_loc8_ == undefined || _loc8_[0] == _loc5_.lang.getText("NO_CONDITIONS"))
         {
            this._ctrConditionalOver._visible = false;
            this._sOverText = undefined;
         }
         else
         {
            this._nOverTextLinesCount = _loc8_.length;
            this._sOverText = _loc8_.join("\n- ");
            var _loc9_ = "QuestionMark";
            if(_loc8_.length == 1)
            {
               var _loc10_ = oItem.fx.conditionalStateID;
               if(_loc10_ == undefined)
               {
                  _loc10_ = oItem.conditionalStateID;
               }
               if(_loc10_ != undefined)
               {
                  _loc9_ = dofus.Constants.STATESICON_FILE;
               }
               else
               {
                  var _loc11_ = oItem.fx.conditionalAlignmentID;
                  if(_loc11_ == undefined)
                  {
                     _loc11_ = oItem.conditionalAlignmentID;
                  }
                  if(_loc11_ != undefined)
                  {
                     _loc9_ = dofus.Constants.ALIGNMENTS_MINI_PATH + _loc11_ + ".swf";
                  }
               }
            }
            delete this._ctrConditionalOver.tempVars;
            if(_loc9_ == dofus.Constants.STATESICON_FILE)
            {
               this.setFightStateOnContainer(this._ctrConditionalOver,_loc10_);
            }
            this._ctrConditionalOver.addEventListener("onContentInitialized",this);
            this._ctrConditionalOver.contentPath = _loc9_;
            this._ctrConditionalOver._visible = true;
         }
         this.resizeLabel();
      }
      else if(this._lbl.text != undefined)
      {
         this._oItem = undefined;
         this._lbl.text = "";
         this._lblArea.text = "";
         this._ctrSpellArea._visible = false;
         this._ctrElement.contentPath = "";
         this._ctrConditionalOver._visible = false;
      }
      else
      {
         this._oItem = undefined;
      }
   }
   function init()
   {
      super.init(false);
   }
   function createChildren()
   {
      this.arrange();
   }
   function size()
   {
      super.size();
      this.addToQueue({object:this,method:this.arrange});
   }
   function resizeLabel()
   {
      this._lbl.width = this._nLabelWidth;
      if(!this._ctrSpellArea._visible)
      {
         this._lbl.width += 49;
      }
   }
   function onContentInitialized(oEvent)
   {
      var _loc3_ = oEvent.target;
      if(_loc3_.tempVars)
      {
         this.setFightStateOnContainer(_loc3_,_loc3_.tempVars.fightStateToPut);
      }
   }
   function setFightStateOnContainer(ctr, nState)
   {
      if(ctr.contentLoaded)
      {
         delete ctr.tempVars;
         var _loc4_ = "State_" + nState;
         ctr.content._mcState.removeMovieClip();
         var _loc5_ = ctr.content.attachMovie(_loc4_,"_mcState",ctr.content.getNextHighestDepth());
         ctr.sizeContent();
         _loc5_._xscale += 70;
         _loc5_._yscale += 70;
         _loc5_._x += 6;
         _loc5_._y += 6;
      }
      else
      {
         ctr.tempVars = {fightStateToPut:nState};
      }
   }
   function over(oEvent)
   {
      var _loc3_ = _global.API;
      switch(oEvent.target)
      {
         case this._ctrConditionalOver:
            if(this._sOverText == undefined)
            {
               break;
            }
            var _loc4_ = _loc3_.lang.getText("CONDITIONS") + "\n- " + this._sOverText;
            var _loc5_ = -20 - this._nOverTextLinesCount * 12;
            _loc3_.ui.showTooltip(_loc4_,oEvent.target,_loc5_);
            break;
         case this._ctrSpellArea:
            var _loc6_ = this._oItem.at.charCodeAt(0);
            var _loc7_ = _loc3_.lang.getText("EFFECT_SHAPE_TYPE_" + _loc6_,[this._oItem.ar != 63 ? this._oItem.ar : _loc3_.lang.getText("INFINIT")]);
            _loc3_.ui.showTooltip(_loc7_,oEvent.target,-20);
      }
   }
   function out(oEvent)
   {
      _global.API.ui.hideTooltip();
   }
}
