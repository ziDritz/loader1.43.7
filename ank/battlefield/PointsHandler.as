/**
 * Handles the display and management of floating point/damage numbers on the battlefield.
 * These are typically damage numbers, heals, or other numeric indicators that appear
 * during combat and float/animate above characters or locations.
 */
class ank.battlefield.PointsHandler
{
   var battlefieldMovieClip;
   var containerMovieClip;
   var datacenterObject;
   var pointsList;
   var currentIndexCounter;
   static var MAX_INDEX = 200;

   /**
    * Constructor - initializes the handler with required references
    * @param battlefieldMc The main battlefield movie clip reference
    * @param containerMc The container where point movie clips will be created
    * @param datacenter The datacenter object for accessing game constants
    */
   function PointsHandler(battlefieldMc, containerMc, datacenter)
   {
      this.initialize(battlefieldMc, containerMc, datacenter);
   }

   /**
    * Initializes all member variables
    * @param battlefieldMc The main battlefield movie clip reference
    * @param containerMc The container where point movie clips will be created
    * @param datacenter The datacenter object for accessing game constants
    */
   function initialize(battlefieldMc, containerMc, datacenter)
   {
      this.battlefieldMovieClip = battlefieldMc;
      this.containerMovieClip = containerMc;
      this.datacenterObject = datacenter;
      this.pointsList = {};
      this.currentIndexCounter = 0;
   }

   /**
    * Clears all point movie clips from the container
    */
   function clear()
   {
      for(var key in this.containerMovieClip)
      {
         this.containerMovieClip[key].removeMovieClip();
      }
   }

   /**
    * Adds a new floating point indicator to the battlefield
    * @param characterID The unique identifier for the character
    * @param xPosition The x coordinate where the point should appear
    * @param yPosition The y coordinate where the point should appear
    * @param pointValue The numeric value to display (as string)
    * @param pointType The type of point (determines visual appearance via Constants.getPointClip)
    */
   function addPoints(characterID, xPosition, yPosition, pointValue, pointType)
   {
      var pointIndex = this.getNextIndex();
      var depth = this.containerMovieClip.getNextHighestDepth();

      // Create main container movie clip for this point
      this.containerMovieClip.createEmptyMovieClip("pt" + pointIndex, depth);
      var pointContainer = this.containerMovieClip["pt" + pointIndex];

      // Create inner clip that will hold the loaded asset
      var pointClip = pointContainer.createEmptyMovieClip("clip-pt" + pointIndex, depth);

      // Set position
      pointContainer._x = xPosition;
      pointContainer._y = yPosition;

      // Store references and metadata
      pointContainer.mc = pointClip;
      pointContainer.file = dofus.Constants.getPointClip(pointType);
      pointContainer.value = pointValue;
      pointContainer.characterID = characterID;
      pointContainer.thisPath = this;

      // Initialize points array for this character if it doesn't exist
      if(this.pointsList[characterID] == undefined)
      {
         this.pointsList[characterID] = [];
      }

      // Add the point to the queue for this character
      this.pointsList[characterID].push(pointContainer);

      // If this is the first point in the queue, start loading it
      if(this.pointsList[characterID].length == 1)
      {
         this.loadPointClip(pointContainer);
      }
   }

   /**
    * Gets the next index in a cycling sequence (0 to MAX_INDEX)
    * This prevents index overflow by resetting when the max is exceeded
    * @return The next index value
    */
   function getNextIndex()
   {
      this.currentIndexCounter = this.currentIndexCounter + 1;
      if(this.currentIndexCounter > ank.battlefield.PointsHandler.MAX_INDEX)
      {
         this.currentIndexCounter = 0;
      }
      return this.currentIndexCounter;
   }

   /**
    * Loads the actual visual asset for a point movie clip
    * @param pointContainer The point container object to load the clip into
    */
   function loadPointClip(pointContainer)
   {
      var loader = new MovieClipLoader();
      loader.loadClip(pointContainer.file, pointContainer.mc);
   }

   /**
    * Called when a point animation finishes, processes the next point in queue
    * @param characterID The character whose point animation finished
    */
   function onAnimateFinished(characterID)
   {
      var characterPoints = this.pointsList[characterID];

      // Remove the current (finished) point from the queue
      characterPoints.shift();

      // If there are more points in the queue, load the next one
      if(characterPoints.length != 0)
      {
         var nextPoint = characterPoints[0];
         this.loadPointClip(nextPoint);
      }
   }
}
