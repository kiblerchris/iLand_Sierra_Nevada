/* Javascriptfile for iLand management. */

// global variables
var mgmt_list = {}
var mgmt_loaded = false;

/* Load the management descriptions from a CSV file.
   Each line consists of a location (x/y), a year and a number of trees that should remain after management.
   The data is stored as properties of an object (mgmt_list). */
function load()
{
	mgmt_list = {};  // clear array
    //var csvFile = new CSVFile; // (old Qt4 style)
	var csvFile = Factory.newCSVFile(Globals.path('scripts/management.csv'));
	
	var key, value;
   for (i=0;i<csvFile.rowCount;i++) {
        // create a combined key
        key = csvFile.value(i,0) + '_' + csvFile.value(i,1) ; // ruindex_year
	value = csvFile.value(i,2); // the remaining trees
	mgmt_list[key] = value;
	print (key); // just for debugging
   }	
}






// helping function to query the "database" of management operations
// returns <undefined> if no entry is inside the list
function queryMgmtList(ruindex, year)
{
	var key = ruindex + '_' + year;
	return mgmt_list[key];
}

 var stand_grid = Factory.newMap()
/* callback function called by iLand.
   executes management for each resource unit.*/

   
function manage(year)
{
   if (mgmt_loaded == false) {
      print("1st call - loading management...");
	  load();
	  mgmt_loaded = true;
	  print("loading management finished....");
   }
   print("executing management - year " + year);
   var remains;
   for (var i=0;i<Globals.resourceUnitCount;i++) {
		remains = queryMgmtList(i, year);
		if (remains!=undefined) {
			// do some management
			var tree_count = management.loadResourceUnit(i); // load all trees of resouce unit with index i
			print("do management for resource unit " + i + ". Trees on RU: " + tree_count +". Trees to remain:" + remains);
			// calculate how many trees are to be removed
			var to_remove = tree_count - remains;
			
			    // killPct(percentile_from, percentile_to, count)
				// killPct(0,100,x) -> kill x trees randomly 
				// you can apply some sorting:
				// management.sort('dbh'); // sort by dbh ascending
				// management.killPct(0,33,x); // -> remove x from lowest third
				management.disturbanceKill(stem_to_soil_fraction=0.2, stem_to_snag_fraction=0.3,branch_to_soil_fraction=0.2,branch_to_snag_fraction=0.3,agent='fire');
				print("killed " + to_remove+" trees from resource unit " + i + ".");
				management.killSaplingsResourceUnit(i);
				print("killed saplings from resource unit" + i + ".");
		}
	}

}

