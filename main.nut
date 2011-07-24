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

import("util.superlib", "SuperLib", 9);

Log <- SuperLib.Log;
Helper <- SuperLib.Helper;
Money <- SuperLib.Money;

Tile <- SuperLib.Tile;
Direction <- SuperLib.Direction;

Engine <- SuperLib.Engine;
Vehicle <- SuperLib.Vehicle;

Station <- SuperLib.Station;
Airport <- SuperLib.Airport;
Industry <- SuperLib.Industry;

Order <- SuperLib.Order;
OrderList <- SuperLib.OrderList;

RoadBuilder <- SuperLib.RoadBuilder;
RoadPathFinder <- SuperLib.RoadPathFinder;

require("menu.nut");
require("Chapters/Bus/chapter_main.nut");

g_menu_viewer <- null;

class TutorialAI extends AIController {

	loaded_from_savegame = null;
	constructor()
	{
		this.loaded_from_savegame = false;
		g_menu_viewer = Menu();
	}

	function Start();

	function Save();
	function Load(version, data);

	function WaitForMenu();

	function ChapterIntroduction();
	function ChapterTrains();
	function ChapterPlanes();
	function ChapterConclusion();

	function ChapterNotDoneYetMessage();
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
	local ret = g_menu_viewer.CheckInput();
	while(ret == MENU_OPEN)
	{
		this.Sleep(5);
		ret = g_menu_viewer.CheckInput();
	}

	return ret;
}

function TutorialAI::Start()
{
	this.Sleep(1);

	if(this.loaded_from_savegame)
	{
		AILog.Info("");
		AILog.Error("How to handle Save/Load for TutorialAI haven't been decided yet.");
		return;
	}

	if(!this.SetCompanyName())
	{
		AILog.Info("");
		AILog.Error("Another Tutorial AI has already started.");
		return;
	}

	local center_x = AIMap.GetMapSizeX() / 2;
	local center_y = AIMap.GetMapSizeY() / 2;
	local center_tile = AIMap.GetTileIndex(center_x, center_y);

	AICompany.SetLoanAmount(AICompany.GetMaxLoanAmount());

	g_menu_viewer.Open("Hello. Welcome to the in-game AI-based tutorial!\n\n" +
			"In this tutorial messages are shown on signs like these. At the bottom there are one or more \"button\"-signs. They look like this: [button]\n\nTo \"click\" on a button, left-click on the sign and choose to delete it.", ["continue"]);
	g_menu_viewer.WaitUntilClose();

	while(true)
	{
		g_menu_viewer.Open("Chapters (select one)", ["1. Introduction", "2. Bus service", "3. Train service (todo)", "4. Plane service (todo)", "5. Conclusion (todo)", "Quit"]);
		local chapter = g_menu_viewer.WaitUntilClose();
		local chapter_class = null;

		// Switch on first character in clicked button text
		switch(chapter[0])
		{
			case 'Q':
				while(true) { AIController.Sleep(74); } // Sleep forever
				break;
		
			case '1':
				this.ChapterIntroduction();
				break;

			case '2':
				chapter_class = ChapterBus();
				chapter_class.Start();
				break;

			case '3':
				this.ChapterTrains();
				break;

			case '4':
				this.ChapterPlanes();
				break;

			case '5':
				this.ChapterConclusion();
				break;
		}
	}
}

function TutorialAI::ChapterIntroduction()
{
	g_menu_viewer.Open("Hard to read?\n\n" +
			"If you find the signs hard to read, the menu can also be read through the AI debug window. You find it by pressing and holding the rightmost button in the toolbar (at the top). Go down and select the AI debug option.", 
			["continue"])
	g_menu_viewer.WaitUntilClose();

	g_menu_viewer.Open("Slow to close signs?\n\n" +
			"There is one slightly advanced way to make it easier to close the signs",
			["tell me how!", "skip"])
	if(g_menu_viewer.WaitUntilClose() == "tell me how!")
	{
		g_menu_viewer.Open("In this game you have at least two companies. Your own human controlled company and one or more AI controlled companies. Signs in OpenTTD are owned by the company who placed the signs. If you are the owner of a sign, you can click on them and hold the CTRL-button in order to quickly remove them. So in order to more quickly remove the tutorial button-signs, you need to somehow change into the AI company of the tutorial AI. Luckily there is a cheat for this, the switch company cheat.",
				["continue", "abort"]);
		if(g_menu_viewer.WaitUntilClose() == "continue")
		{
			g_menu_viewer.Open("Press CTRL + ALT + C (or if that doesn't work CTRL + ALT + Win + C) to open the cheat window. Change playing company until it says TutorialAI at the bottom of your screen\n\nNow you can CTRL+Click to remove the continue button below:",
					["continue"]);
			g_menu_viewer.WaitUntilClose();
		}
	}

	g_menu_viewer.Open("The sign list\n\n" +
			"In OpenTTD there exist a window that lists all signs in the game. You find in the fifth toolbar menu from the left. Remember to press and hold the left mouse button on the toolbar menu.\n\nAs you might have noticed, all menus in this tutorial begin with (*). The reason for this is to make it easier to find the menu start in the sign list. Click on a line in the sign list window to jump to that sign.", 
			["continue"])
	g_menu_viewer.WaitUntilClose();
}

function TutorialAI::ChapterTrains()
{
	this.ChapterNotDoneYetMessage();
}

function TutorialAI::ChapterPlanes()
{
	this.ChapterNotDoneYetMessage();
}

function TutorialAI::ChapterConclusion()
{
	this.ChapterNotDoneYetMessage();
}

function TutorialAI::ChapterNotDoneYetMessage()
{
	g_menu_viewer.Open("This chapter has not been written yet. Contributions to new chapters are welcome. See the TutorialAI forum thread: junctioneer.net/o-ai/TTAI", ["continue"]);
	g_menu_viewer.WaitUntilClose();
}

function TutorialAI::Save()
{
	local table = {};
	return table;
}

function TutorialAI::Load(version, data)
{
	AILog.Info("Previously saved with AI version " + version);
	this.loaded_from_savegame = true;
}

