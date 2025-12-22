class dofus.graphics.gapi.controls.SpriteHealthBar extends dofus.graphics.gapi.core.DofusAdvancedComponent
{
   var _nCurrentValue;
   var _nMinValue;
   var _nMaxValue;
   var _nWidth;
   var _mcBar;
   var _mcBarHighlight;
   var _txtValue;
   var _nPreviousWidth;
   var _nCurrentWidth;
   var _mcBorder;
   var _mcBackground;
   var _nUpdateTimeout;
   static var CLASS_NAME = "SpriteHealthBar";
   function SpriteHealthBar()
   {
      super();
   }
   function set lifeCurrentValue(nValue)
   {
      this._nCurrentValue = nValue;
   }
   function get lifeCurrentValue()
   {
      return this._nCurrentValue;
   }
   function set lifeMinValue(nValue)
   {
      this._nMinValue = nValue;
   }
   function get lifeMinValue()
   {
      return this._nMinValue;
   }
   function set lifeMaxValue(nValue)
   {
      this._nMaxValue = nValue;
   }
   function get lifeMaxValue()
   {
      return this._nMaxValue;
   }
   function set realWidth(nValue)
   {
      this._nWidth = nValue;
   }
   function init()
   {
      super.init(false,dofus.graphics.gapi.controls.SpriteHealthBar.CLASS_NAME);
   }
   function createChildren()
   {
      this.setWholeBarWidth();
      this.initTextField();
      this._mcBar._width = this._mcBarHighlight._width = this.getHealthBarWidth();
      this.addToQueue({object:this,method:this.addListeners});
   }
   function addListeners()
   {
      this._parent._oSprite.addEventListener("lpChanged",this);
      this._parent._oSprite.addEventListener("lpMaxChanged",this);
   }
   function initTextField()
   {
      this.createTextField("_txtValue",101,0,-1,this._nWidth,this._height);
      this._txtValue.embedFonts = true;
      this._txtValue.text = String(this._nCurrentValue);
      this._txtValue.setTextFormat(new TextFormat("Font2",10,16777215,false,false,false,null,null,"center"));
   }
   function getHealthBarWidth()
   {
      this._nPreviousWidth = this._nCurrentWidth;
      var _loc2_ = this._nCurrentValue - this._nMinValue;
      var _loc3_ = this._nMaxValue - this._nMinValue;
      var _loc4_ = Math.round(_loc2_ / _loc3_ * this._nWidth);
      if(_loc4_ > this._nWidth)
      {
         _loc4_ = this._nWidth;
      }
      this._nCurrentWidth = _loc4_;
      return _loc4_;
   }
   function animHealthBar(mc, nCurrentValue, nNewValue)
   {
      ank.utils.TweenAnimation.width(mc,mx.transitions.easing.Strong.easeIn,nCurrentValue,nNewValue,0.5,true);
   }
   function setWholeBarWidth()
   {
      this._mcBar._width = this._mcBarHighlight._width = this._mcBorder._width = this._mcBackground._width = this._nWidth;
   }
   function updateData()
   {
      this.initTextField();
      this._mcBar._width = this._mcBarHighlight._width = this.getHealthBarWidth();
      if(this.api.kernel.OptionsManager.getOption("AnimateHPBar"))
      {
         var _loc2_ = this._nPreviousWidth - this._nCurrentWidth;
         if(_loc2_ > 0)
         {
            var _loc3_ = new flash.geom.ColorTransform(1,1,0,1,1,150,0,0);
            var _loc4_ = new flash.geom.Transform(this._mcBarHighlight);
            _loc4_.colorTransform = _loc3_;
            this.animHealthBar(this._mcBarHighlight,this._nPreviousWidth,this._nCurrentWidth);
         }
         else
         {
            var _loc5_ = new flash.geom.ColorTransform(0,1,1,1,1,150,0,0);
            var _loc6_ = new flash.geom.Transform(this._mcBarHighlight);
            _loc6_.colorTransform = _loc5_;
            this.animHealthBar(this._mcBar,this._nPreviousWidth,this._nCurrentWidth);
         }
      }
   }
   function lpChanged(oEvent)
   {
      if(this._nUpdateTimeout != undefined)
      {
         _global.clearTimeout(this._nUpdateTimeout);
      }
      var _loc3_ = _global.setTimeout(this,"updateData",50);
      this._nUpdateTimeout = _loc3_;
      this._nCurrentValue = oEvent.value;
   }
   function lpMaxChanged(oEvent)
   {
      this._nMaxValue = oEvent.value;
   }
}
