/*
 * This file is part of TutorialAI, which is an AI for OpenTTD
 * Copyright (C) 2011  Leif Linse
 *
 * TutorialAI is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * TutorialAI is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with TutorialAI; If not, see <http://www.gnu.org/licenses/> or
 * write to the Free Software Foundation, Inc., 51 Franklin Street, 
 * Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

class ChapterBus {

	constructor() {
	}

	function Start();

	function FindTownsToConnect();
	static function PopulationValuator(town);
	static function TownDistValuator(town1, town2, target_dist);

	function Error(error);
}

function ChapterBus::Start()
{
	AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

	g_menu_viewer.Open("Bus service\n\n" +
			"In this chapter a first transport service will be setup using buses to transport passengers between two towns.", 
			["continue"])
	g_menu_viewer.WaitUntilClose();


	// Find two towns
	//Helper.SetSign(g_menu_viewer.location, "preparing tutorial ...", true);
	g_menu_viewer.Open("Preparing tutorial...\n(Hold TAB-key to speed up)", []);
	local towns = this.FindTownsToConnect();
	if(towns[0] == null || towns[1] == null)
	{
		g_menu_viewer.Close();
		this.Error("failed to find two towns to connect");
		return;
	}
	local town_tiles = [AITown.GetLocation(towns[0]), AITown.GetLocation(towns[1])];
	
	local road_builder = RoadBuilder();
	road_builder.Init(town_tiles[0], town_tiles[1]);
	if(!road_builder.DoPathfinding())
	{
		// failed to find path between towns
		g_menu_viewer.Close();
		this.Error("The bus tutorial failed on this map. Try to create a new game and try again.");
		return;
	}

	g_menu_viewer.Close();

	// Tell user about found towns A + B
	Helper.SetSign(AITown.GetLocation(towns[0]), "TOWN A", true);
	Helper.SetSign(AITown.GetLocation(towns[1]), "TOWN B", true);
	g_menu_viewer.Open("The first step is to find two suitable towns. In this tutorial the towns marked with TOWN A and TOWN B signs will be connected.",
			["continue"]);
	g_menu_viewer.WaitUntilClose();


	// Build bus stops
	g_menu_viewer.Open("A bus service needs bus stops where passengers will wait and the buses will stop and pick up the passengers. When you click on continue, a bus stop will be placed in Town A.",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	local station_tiles = [null, null];
	station_tiles[0] = BuildInCityStationCloseTo(town_tiles[0], towns[0], false);

	g_menu_viewer.Open("When you click continue, a bus stop will be placed in Town B",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	station_tiles[1] = BuildInCityStationCloseTo(town_tiles[1], towns[1], false);

	// Build road
	g_menu_viewer.Open("Now both towns have a bus stop to collect passengers. Next a road has to be built to connect the two towns.\n\nWhen you click on continue a road will be built between the towns. This may take some time.",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	{
		road_builder.EnableSlowBuilding();
		local ret = road_builder.ConnectTiles();

		if(ret != RoadBuilder.CONNECT_SUCCEEDED)
		{
			this.Error("failed to build road");
			return;
		}
	}

	// Build depot
	g_menu_viewer.Open("Now there is both bus stops and a road. Next thing we want is a bus. But in order to buy a bus, a depot is needed.\n\nWhen you click on continue, a depot will be placed in town A",
			["continue"]);
	g_menu_viewer.WaitUntilClose();
	local depot_tile = BuildInCityStationCloseTo(town_tiles[0], towns[0], true);

	// Build bus
	g_menu_viewer.Open("Now all infrastructure is done. The following steps are now to buy a bus, give it orders and release it from the depot.",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	g_menu_viewer.Open("If you click on the depot you will open a window that shows the contents inside the depot. (now empty, but a bus will soon be built)",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	local engine = Engine.GetEngine_PAXLink(20, AIVehicle.VT_ROAD);
	if(!AIEngine.IsValidEngine(engine))
	{
		this.Error("couldn't find a suitable bus to buy");
		return;
	}
	
	local vehicle = AIVehicle.BuildVehicle(depot_tile, engine);
	if(!AIVehicle.IsValidVehicle(vehicle))
	{
		this.Error("couldn't buy bus");
		return;
	}
	AIVehicle.RefitVehicle(vehicle, Helper.GetPAXCargo()); // since GetEngine_PAXLink can return engines that by default don't carry PAX (but can be refitted to PAX), we need to refit bough vehicles to PAX.

	g_menu_viewer.Open("A bus has been built and is now located in the bus depot. Next step is to assign orders to it to visit the two bus stations.\n\nIf you click on the bus and then on the fourth button from the top on the right, you can see the order list.",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	// Add orders
	local order_list = OrderList();
	order_list.AddStop(AIStation.GetStationID(station_tiles[0]), AIOrder.AIOF_NONE);
	order_list.AddStop(AIStation.GetStationID(station_tiles[1]), AIOrder.AIOF_NONE);
	order_list.ApplyToVehicle(vehicle);

	g_menu_viewer.Open("Now everything is ready except for starting the bus. This is done by clicking at the bottom of the vehicle window.",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	// Start Bus
	AIVehicle.StartStopVehicle(vehicle);

	// Done
	g_menu_viewer.Open("Summary\n\nThe bus chapter has now came to an end and you have seen how to build a bus service between two towns.",
			["continue"]);
	g_menu_viewer.WaitUntilClose();

	// Remove Town A/B etc. signs
	Helper.ClearAllSigns();
}

function ChapterBus::Error(error)
{
	g_menu_viewer.Open("Tutorial Error: " + error, 
			["continue"])
	g_menu_viewer.WaitUntilClose();
}

/* static */ function ChapterBus::PopulationValuator(town)
{
	return Helper.Abs(AITown.GetPopulation(town) - 400);
}

/* static */ function ChapterBus::MapCenterValuator(town)
{
	local town_loc = AITown.GetLocation(town);
	local town_x = AIMap.GetTileX(town_loc);
	local town_y = AIMap.GetTileY(town_loc);

	return Helper.Abs( 
			Helper.Abs(AIMap.GetMapSizeX() / 2 - town_x) + Helper.Abs(AIMap.GetMapSizeY() / 2 - town_y) // Gives center of map lowest result
			- 10 // gives towns 10 Manhattan tiles away from center the highest score (so the menu don't cover the town)
		);
}

/* static */ function ChapterBus::TownDistValuator(town_a, town_b, target_dist)
{
	return Helper.Abs(AIMap.DistanceSquare(AITown.GetLocation(town_a), AITown.GetLocation(town_b)) - target_dist);
}

function ChapterBus::FindTownsToConnect()
{
	local towns = AITownList();
	towns.Valuate(ChapterBus.MapCenterValuator)
	towns.KeepBottom(1);

	local town1 = towns.Begin();

	AILog.Info("Town 1 : " + town1 + " " + AITown.GetName(town1));

	towns = AITownList();
	towns.RemoveItem(town1); // don't connect town1 with town1
	towns.Valuate(ChapterBus.TownDistValuator, town1, 60);
	towns.Sort(AIList.SORT_BY_VALUE, AIList.SORT_ASCENDING);

	if(towns.GetValue(towns.Begin()) < 20*20) // If at least one town is within +/- 20 tiles from the target distance of 60 tiles
	{
		towns.KeepBelowValue(20*20);
	}
	else
	{
		towns.KeepTop(1); // Keep the best town range-wise
	}

	// Out of the towns that fulfill the range-selection, pick the one with best population
	towns.Valuate(ChapterBus.PopulationValuator);
	towns.KeepBottom(1);

	local town2 = towns.Begin();

	return [town1, town2];
}

// From PAXLink
function ChapterBus::CanConnectToRoad(road_tile, adjacent_tile_to_connect)
{
	// If road_tile don't have road type "road" (ie it is only a tram track), then we can't connect to it
	if(!AIRoad.HasRoadType(road_tile, AIRoad.ROADTYPE_ROAD))
		return false;

	local neighbours = Tile.GetNeighbours4MainDir(road_tile);
	
	neighbours.RemoveItem(adjacent_tile_to_connect);

	// This function requires that road_tile is connected with at least one other road tile.
	neighbours.Valuate(AIRoad.IsRoadTile);
	if(Helper.ListValueSum(neighbours) < 1)
		return false;
	
	for(local neighbour_tile_id = neighbours.Begin(); neighbours.HasNext(); neighbour_tile_id = neighbours.Next())
	{
		if(AIRoad.IsRoadTile(neighbour_tile_id))
		{
			local ret = AIRoad.CanBuildConnectedRoadPartsHere(road_tile, neighbour_tile_id, adjacent_tile_to_connect);
			if(ret == 0 || ret == -1)
				return false;
		}
	}

	return true;
}
// From PAXLink
function ChapterBus::BuildRoadStation(tile_id, depot)
{
	if(AITile.IsWaterTile(tile_id))
		return false;

	// Don't even try if the tile has a steep slope
	local slope = AITile.GetSlope(tile_id);
	if(slope != 0 && AITile.IsSteepSlope(slope))
		return false;

	local neighbours = Tile.GetNeighbours4MainDir(tile_id);
	neighbours.Valuate(AIRoad.IsRoadTile);
	neighbours.KeepValue(1);
	neighbours.Valuate(AIRoad.HasRoadType, AIRoad.ROADTYPE_ROAD);
	neighbours.KeepValue(1);

	/*Helper.ClearAllSigns();
	for(local tile = neighbours.Begin(); neighbours.HasNext(); tile = neighbours.Next())
	{
		//Helper.SetSign(tile, "n");
		AISign.BuildSign(tile, "n");
	}*/

	//MyValuate(neighbours, CanConnectToRoad, tile_id);
	neighbours.Valuate(ChapterBus.CanConnectToRoad, tile_id);
	neighbours.KeepValue(1);

	neighbours.Valuate(AITile.GetMaxHeight);
	neighbours.KeepValue(AITile.GetMaxHeight(tile_id));

	// Return false if none of the neighbours has road
	if(neighbours.Count() == 0)
		return false;

	local front = neighbours.Begin();

	
	if(!ChapterBus.CanConnectToRoad(front, tile_id))
		return false;

	if(!AITile.IsBuildable(tile_id) && !AIRoad.IsRoadTile(tile_id) && !AICompany.IsMine(AITile.GetOwner(tile_id)))
	{
		AITile.DemolishTile(tile_id);
	}

	// Build road
	// Keep trying until we get another error than vehicle in the way
	while(!AIRoad.BuildRoad(tile_id, front) && AIError.GetLastError() == AIError.ERR_VEHICLE_IN_THE_WAY);

	if(!AIRoad.AreRoadTilesConnected(tile_id, front))
		return false;

	//Helper.SetSign(tile_id, "tile");
	//Helper.SetSign(front, "front");

	// Build station/depot
	// Keep trying until we get another error than vehicle in the way
	local ret = false; // for some strange reason this variable declaration can't be inside the loop
	do
	{
		if(depot)
			ret = AIRoad.BuildRoadDepot(tile_id, front);
		else
			ret = AIRoad.BuildRoadStation(tile_id, front, AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
	}
	while(!ret && AIError.GetLastError() == AIError.ERR_VEHICLE_IN_THE_WAY);

	return ret;
}

// From PAXLink
function ChapterBus::IsTileOnTownRoadGrid(tile_id)
{
	local n = AIGameSettings.GetValue("economy.town_layout").tointeger();
	local dx = abs(tile_id % AIMap.GetMapSizeY());
	local dy = abs(tile_id / AIMap.GetMapSizeY());
	local on_road_grid = (n == 2 || n == 3) &&     // Town has 2x2 or 3x3 road grid layout
		(dx % (n+1) == 0 || dy % (n+1) == 0);      // and tile is on the road grid

	return on_road_grid;
}

// From PAXLink
function ChapterBus::GridTileNeighbourScoreValuator(neighbour_tile_id, grid_tile_id)
{
	local score = 0;

	if(AITile.IsBuildable(neighbour_tile_id))
		score += 100;

	if(AIRoad.GetNeighbourRoadCount(neighbour_tile_id) != 0)
		score += 200000;

	local diff_x = AIMap.GetTileX(grid_tile_id) - AIMap.GetTileX(neighbour_tile_id);
	local diff_y = AIMap.GetTileY(grid_tile_id) - AIMap.GetTileY(neighbour_tile_id);
	local opposite_tile_id = grid_tile_id + AIMap.GetTileIndex(diff_x, diff_y);

	// don't give bonus to end of road.
	if(AIRoad.IsRoadTile(opposite_tile_id) && AIRoad.AreRoadTilesConnected(opposite_tile_id, grid_tile_id))
		score -= 200;

	// prefer tiles close to grid_tile_id
	score -= AIMap.DistanceManhattan(grid_tile_id, neighbour_tile_id) * 10

	// Give a big penalty to tiles that is on the town grid
	if(AIController.GetSetting("avoid_town_road_grid") == 1 && IsTileOnTownRoadGrid(neighbour_tile_id))
		score -= 400;

	score += AIBase.RandRange(1000);

	return score;
}

// From PAXLink
function ChapterBus::BuildInCityStationCloseTo(tile_id, town_id, depot)
{
	//if(AITile.IsBuildable(tile_id))
	if(ChapterBus.BuildRoadStation(tile_id, depot))
	{
		return tile_id;
	}
	else
	{
		Log.Info("BulidRoadStation error: " + AIError.GetLastErrorString(), Log.LVL_DEBUG);
		if(AIError.GetLastError() == AIError.ERR_LOCAL_AUTHORITY_REFUSES)
			return AIMap.GetTileIndex(-1, -1);

		local neighbours = Tile.GetNeighbours8(tile_id);

		// only accept neighbours that are in the town
		neighbours.Valuate(AITile.GetClosestTown);
		neighbours.KeepValue(town_id);

		neighbours.Valuate(ChapterBus.GridTileNeighbourScoreValuator, tile_id);
		neighbours.Sort(AIAbstractList.SORT_BY_VALUE, false);

		if(neighbours.Count() > 0)
		{
			// Try with first neighbour, but if that fails, take next one and try.
			foreach(build_at, _ in neighbours)
			{
				if(ChapterBus.BuildRoadStation(build_at, depot))
				{
					if(depot)
						Log.Info("Built road depot.", Log.LVL_DEBUG);
					else
						Log.Info("Built road station.", Log.LVL_DEBUG);
					return build_at;
				}
				else if(AIError.GetLastError() == AIError.ERR_LOCAL_AUTHORITY_REFUSES)
				{
					// Don't retry if the reason for failure was that the local authority refused building
					return AIMap.GetTileIndex(-1, -1);
				}
			}
		}
	}

	//Log.Info("Returning tile -1, -1", Log.LVL_DEBUG);
	return AIMap.GetTileIndex(-1, -1);
}
