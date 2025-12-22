class dofus.graphics.gapi.ui.Waypoints extends dofus.graphics.gapi.core.DofusAdvancedComponent
{
   var _eaData;
   var _winBg;
   var _lblCoords;
   var _lblName;
   var _lblCost;
   var _lblArea;
   var _lblDescription;
   var _btnClose2;
   var _btnTeleport;
   var _btnClose;
   var _lstWaypoints;
   var _oSelectedRow;
   static var CLASS_NAME = "Waypoints";
   function Waypoints()
   {
      super();
   }
   function set data(eaData)
   {
      this.addToQueue({object:this,method:function(d)
      {
         this._eaData = d;
         if(this.initialized)
         {
            this.initData();
         }
      },params:[eaData]});
   }
   function init()
   {
      super.init(false,dofus.graphics.gapi.ui.Waypoints.CLASS_NAME);
   }
   function callClose()
   {
      this.api.network.Waypoints.leave();
      return true;
   }
   function createChildren()
   {
      this.addToQueue({object:this,method:this.initTexts});
      this.addToQueue({object:this,method:this.addListeners});
      this.addToQueue({object:this,method:this.initData});
   }
   function initTexts()
   {
      this._winBg.title = this.api.lang.getText("WAYPOINT_LIST");
      this._lblCoords.text = this.api.lang.getText("COORDINATES_SMALL");
      this._lblName.text = this.api.lang.getText("SUBAREA") + " (" + this.api.lang.getText("RESPAWN_SMALL") + ")";
      this._lblCost.text = this.api.lang.getText("COST");
      this._lblArea.text = this.api.lang.getText("AREA");
      this._lblDescription.text = this.api.lang.getText("CLICK_ON_WAYPOINT");
      this._btnClose2.label = this.api.lang.getText("CLOSE");
      this._btnTeleport.label = this.api.lang.getText("TELEPORT");
   }
   function addListeners()
   {
      this._btnClose.addEventListener("click",this);
      this._btnClose2.addEventListener("click",this);
      this._btnTeleport.addEventListener("click",this);
      this._lstWaypoints.addEventListener("itemdblClick",this);
      this._lstWaypoints.addEventListener("itemSelected",this);
   }
   function initData()
   {
      if(this._eaData != undefined)
      {
         this._eaData.sortOn("fieldToSort",Array.CASEINSENSITIVE);
         this._lstWaypoints.dataProvider = this._eaData;
      }
   }
   function teleport()
   {
      var _loc2_ = this._oSelectedRow;
      var _loc3_ = _loc2_.cost;
      if(this.api.datacenter.Player.Kama >= _loc3_)
      {
         this.api.network.Waypoints.use(_loc2_.id);
      }
      else
      {
         this.api.kernel.showMessage(undefined,this.api.lang.getText("NOT_ENOUGH_RICH"),"ERROR_CHAT");
      }
   }
   function click(oEvent)
   {
      switch(oEvent.target)
      {
         case this._btnClose:
         case this._btnClose2:
            this.callClose();
            break;
         case this._btnTeleport:
            this.teleport();
      }
   }
   function itemdblClick(oEvent)
   {
      this.teleport();
   }
   function itemSelected(oEvent)
   {
      this._oSelectedRow = oEvent.row.item;
      this._btnTeleport.enabled = true;
   }
}
