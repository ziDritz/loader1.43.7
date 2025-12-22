class ank.battlefield.GlobalSpriteHandler
{
   var _oSprites;
   var _mclLoader;
   var _aFrameToGo;
   var _sAccessoriesPath;
   function GlobalSpriteHandler()
   {
      this.initialize();
   }
   function initialize()
   {
      this._oSprites = {};
      this._mclLoader = new MovieClipLoader();
      this._mclLoader.addListener(this);
      this._aFrameToGo = [];
   }
   function setAccessoriesRoot(path)
   {
      this._sAccessoriesPath = path;
   }
   function addSprite(mcSprite, oSpriteData)
   {
      this._oSprites[mcSprite._target] = {mc:mcSprite,data:oSpriteData};
      this.garbageCollector();
   }
   function setColors(mc, color1, color2, color3)
   {
      var _loc6_ = this._oSprites[mc._target].data;
      if(color1 != -1)
      {
         _loc6_.color1 = color1;
      }
      if(color2 != -1)
      {
         _loc6_.color2 = color2;
      }
      if(color3 != -1)
      {
         _loc6_.color3 = color3;
      }
   }
   function setAccessories(mc, aAccessories)
   {
      var _loc4_ = this._oSprites[mc._target].data;
      if(aAccessories != undefined)
      {
         _loc4_.accessories = aAccessories;
      }
   }
   function applyColor(mc, nZone, isMount)
   {
      var _loc5_ = this.getSpriteData(mc);
      if(_loc5_ != undefined)
      {
         var _loc6_ = !(isMount && _loc5_.mount != undefined) ? _loc5_["color" + nZone] : _loc5_.mount["color" + nZone];
         if(_loc6_ != undefined && _loc6_ != -1)
         {
            var _loc7_ = (_loc6_ & 0xFF0000) >> 16;
            var _loc8_ = (_loc6_ & 0xFF00) >> 8;
            var _loc9_ = _loc6_ & 0xFF;
            var _loc10_ = new Color(mc);
            var _loc11_ = {};
            _loc11_ = {ra:"0",rb:_loc7_,ga:"0",gb:_loc8_,ba:"0",bb:_loc9_,aa:"100",ab:"0"};
            _loc10_.setTransform(_loc11_);
         }
      }
   }
   function getColorIndex(sGfxFileName, nBaseColor)
   {
      switch(sGfxFileName)
      {
         case "10":
         case "11":
         case "9224":
         case "9225":
         case "9248":
         case "9249":
            switch(nBaseColor)
            {
               case 1:
                  var _loc4_ = 3;
                  break;
               case 2:
                  _loc4_ = 1;
                  break;
               case 3:
                  _loc4_ = 2;
            }
            break;
         case "20":
         case "21":
         case "9226":
         case "9227":
         case "9250":
         case "9251":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 2;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 1;
            }
            break;
         case "30":
         case "31":
         case "9228":
         case "9229":
         case "9252":
         case "9253":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 3;
                  break;
               case 2:
                  _loc4_ = 1;
                  break;
               case 3:
                  _loc4_ = 2;
            }
            break;
         case "40":
         case "41":
         case "9230":
         case "9231":
         case "9254":
         case "9255":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 2;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 1;
            }
            break;
         case "50":
         case "51":
         case "9232":
         case "9233":
         case "9256":
         case "9257":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 2;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 1;
            }
            break;
         case "60":
         case "9234":
         case "9258":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 2;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 1;
            }
            break;
         case "61":
         case "9235":
         case "9259":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 1;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 2;
            }
            break;
         case "70":
         case "71":
         case "80":
         case "81":
         case "9235":
         case "9236":
         case "9260":
         case "9261":
         case "9237":
         case "9238":
         case "9262":
         case "9263":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 2;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 1;
            }
            break;
         case "90":
         case "91":
         case "9239":
         case "9240":
         case "9264":
         case "9265":
            _loc4_ = nBaseColor;
            break;
         case "100":
         case "9241":
         case "9266":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 3;
                  break;
               case 2:
                  _loc4_ = 2;
                  break;
               case 3:
                  _loc4_ = 1;
            }
            break;
         case "101":
         case "9242":
         case "9267":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 1;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 2;
            }
            break;
         case "110":
         case "111":
         case "9243":
         case "9244":
         case "9268":
         case "9269":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 2;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 1;
            }
            break;
         case "120":
         case "121":
         case "8010":
         case "8011":
         case "1264":
         case "7030":
         case "7031":
         case "9245":
         case "9246":
         case "9247":
         case "9270":
         case "9271":
            switch(nBaseColor)
            {
               case 1:
                  _loc4_ = 1;
                  break;
               case 2:
                  _loc4_ = 3;
                  break;
               case 3:
                  _loc4_ = 2;
            }
      }
      if(!_loc4_)
      {
         _loc4_ = -1;
      }
      return _loc4_;
   }
   function applyBottomColor(mc)
   {
      var _loc3_ = this.getSpriteData(mc);
      if(_loc3_ == undefined)
      {
         return undefined;
      }
      var _loc4_ = this.getColorIndex(_loc3_.gfxFileName,3);
      if(_loc4_ == -1)
      {
         return undefined;
      }
      this.applyColor(mc,_loc4_);
   }
   function applyBodyColor(mc)
   {
      var _loc3_ = this.getSpriteData(mc);
      if(_loc3_ == undefined)
      {
         return undefined;
      }
      var _loc4_ = this.getColorIndex(_loc3_.gfxFileName,2);
      if(_loc4_ == -1)
      {
         return undefined;
      }
      this.applyColor(mc,_loc4_);
   }
   function applyHeadColor(mc)
   {
      var _loc3_ = this.getSpriteData(mc);
      if(_loc3_ == undefined)
      {
         return undefined;
      }
      var _loc4_ = this.getColorIndex(_loc3_.gfxFileName,1);
      if(_loc4_ == -1)
      {
         return undefined;
      }
      this.applyColor(mc,_loc4_);
   }
   function applyAccessory(mc, accessoryID, side, mcToHide, bFix)
   {
      if(bFix == undefined)
      {
         bFix = false;
      }
      var _loc7_ = this.getSpriteData(mc);
      if(_loc7_ != undefined)
      {
         var _loc8_ = _loc7_.accessories[accessoryID].gfx;
         mc.clip.removeMovieClip();
         if(bFix)
         {
            switch(_loc7_.direction)
            {
               case 3:
               case 4:
               case 7:
                  mc._x = - mc._x;
            }
         }
         if(_loc8_ != undefined)
         {
            if(mcToHide != undefined)
            {
               mcToHide.gotoAndStop(!(_loc8_.length == 0 || _loc8_ == "_") ? 2 : 1);
            }
            if(!ank.battlefield.Constants.USE_STREAMING_FILES || ank.battlefield.Constants.STREAMING_METHOD == "compact")
            {
               mc.attachMovie(_loc8_,"clip",10);
               if(_loc7_.accessories[accessoryID].frame != undefined)
               {
                  mc.clip.gotoAndStop(side + _loc7_.accessories[accessoryID].frame);
               }
               else
               {
                  mc.clip.gotoAndStop(side);
               }
            }
            else
            {
               var _loc9_ = _loc8_.split("_");
               if(_loc9_[0] == undefined || (_global.isNaN(Number(_loc9_[0])) || (_loc9_[1] == undefined || _global.isNaN(Number(_loc9_[1])))))
               {
                  return undefined;
               }
               var _loc10_ = mc.createEmptyMovieClip("clip",10);
               if(_loc7_.skin !== undefined)
               {
                  this._aFrameToGo[_loc10_] = side + _loc7_.skin;
               }
               else
               {
                  this._aFrameToGo[_loc10_] = side;
               }
               this._mclLoader.loadClip(this._sAccessoriesPath + _loc9_.join("/") + ".swf",_loc10_);
            }
         }
      }
   }
   function applyAnim(mc, sAnim)
   {
      var _loc4_ = this.getSpriteData(mc);
      if(_loc4_ != undefined)
      {
         if(_loc4_.bAnimLoop)
         {
            _loc4_.mc.saveLastAnimation(_loc4_.animation);
         }
         else
         {
            _loc4_.mc.setAnim(sAnim);
         }
      }
   }
   function applyEnd(mc)
   {
      var _loc3_ = this.getSpriteData(mc);
      if(_loc3_ != undefined)
      {
         if(!_loc3_.bAnimLoop)
         {
            _loc3_.sequencer.onActionEnd();
         }
      }
   }
   function applySprite(mc)
   {
      var _loc3_ = this.getSpriteData(mc);
      switch(_loc3_.direction)
      {
         case 0:
         case 4:
            mc.attachMovie(_loc3_.animation + "S","clip",1);
            break;
         case 1:
         case 3:
            mc.attachMovie(_loc3_.animation + "R","clip",1);
            break;
         case 2:
            mc.attachMovie(_loc3_.animation + "F","clip",1);
            break;
         case 5:
         case 7:
            mc.attachMovie(_loc3_.animation + "L","clip",1);
            break;
         case 6:
            mc.attachMovie(_loc3_.animation + "B","clip",1);
      }
   }
   function registerCarried(mc)
   {
      var _loc3_ = this.getSpriteData(mc);
      _loc3_.mc.mcCarried = mc;
   }
   function registerChevauchor(mc)
   {
      var _loc3_ = this.getSpriteData(mc);
      _loc3_.mc.mcChevauchorPos = mc;
      _loc3_.mc.updateChevauchorPosition();
   }
   function getSpriteData(mc)
   {
      var _loc3_ = mc._target;
      for(var name in this._oSprites)
      {
         if(_loc3_.substring(0,name.length) == name)
         {
            if(_loc3_.charAt(name.length) == "/")
            {
               if(this._oSprites[name] != undefined)
               {
                  return this._oSprites[name].data;
               }
            }
         }
      }
   }
   function garbageCollector(Void)
   {
      for(var o in this._oSprites)
      {
         if(this._oSprites[o].mc._target == undefined)
         {
            delete this._oSprites[o];
         }
      }
   }
   function recursiveGotoAndStop(mc, frame)
   {
      mc.stop();
      mc.gotoAndStop(frame);
      for(var i in mc)
      {
         if(mc[i] instanceof MovieClip)
         {
            this.recursiveGotoAndStop(mc[i],frame);
         }
      }
   }
   function onLoadInit(mc)
   {
      this.recursiveGotoAndStop(mc,this._aFrameToGo[mc]);
      delete this._aFrameToGo[mc];
   }
}
