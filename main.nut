
import("util.superlib", "SuperLib", 8);

Helper <- SuperLib.Helper;
Direction <- SuperLib.Direction;
Tile <- SuperLib.Tile;
Money <- SuperLib.Tile;

require("menu.nut");


MENU_HELLO <- 0;
MENU_1 <- 1;
MENU_2 <- 2;
MENU_3 <- 3;


class TutorialAI extends AIController {

	menu_viewer = null;
	menu_id = null;
	constructor()
	{
		this.menu_viewer = Menu();
		this.menu_id = null;
	}

	function Start();

	function Save();
	function Load(version, data);

	function WaitForMenu();
}

function TutorialAI::SetCompanyName()
{
	if(!AICompany.SetName("TutorialAI"))
		return false;

	AICompany.SetPresidentName("Bob")
	return true;
}

function TutorialAI::WaitForMenu()
{
	local ret = this.menu_viewer.CheckInput();
	while(ret == MENU_OPEN)
	{
		this.Sleep(30);
		ret = this.menu_viewer.CheckInput();
	}

	return ret;
}

function TutorialAI::Start()
{
	this.Sleep(1);

	local center_x = AIMap.GetMapSizeX() / 2;
	local center_y = AIMap.GetMapSizeY() / 2;
	local center_tile = AIMap.GetTileIndex(center_x, center_y);

	if(!this.SetCompanyName())
	{
		// Put error messages above the center
		Helper.SetSign(Tile.GetTileRelative(center_tile, -5, -5), "Another Tutorial AI");
		Helper.SetSign(Tile.GetTileRelative(center_tile, -4, -4), "has already started");
		return;
	}

	AICompany.SetLoanAmount(AICompany.GetMaxLoanAmount());

	
	this.menu_viewer.Open("[*] Hello! Welcome to the in-game AI-based tutorial. " +
			"In this tutorial messages are shown on signs like these. At the bottom there are one or more \"button\"-signs. They look like this: [button]. To \"click\" on a button, click on the button and choose to delete it.", ["continue"]);
	this.WaitForMenu();


	this.menu_viewer.Open("[*] Chapters (select one)", ["1. Introduction", "2. Buses", "3. Trains", "4. Planes", "5. Conclusion"]);
	local chapter = this.WaitForMenu();



	while(true)
	{
		//SuperLib.SubWay.GiveMeFood();
	}
}

function TutorialAI::Save()
{
	local table = {};
	return table;
}

function TutorialAI::Load(version, data)
{
	AILog.Info("Previously saved with AI version " + version);
}

