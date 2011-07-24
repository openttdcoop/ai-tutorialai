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

class TutorialAI extends AIInfo {
	function GetAuthor()      { return "Zuu"; }
	function GetName()        { return "TutorialAI"; }
	function GetShortName()            { return "TTAI"; }
	function GetDescription() { return "The AI will talk to you through signs that are placed in the middle of the map (starting location of new games). Don't forget to set a short start delay for the AI unless you want to wait a year for it."; }
	function GetAPIVersion()  { return "1.0"; }
	function GetVersion()     { return 4; }
	function MinVersionToLoad() { return 1; }
	function GetDate()        { return "2011-06-24"; }
	function GetUrl()         { return "http://junctioneer.net/o-ai/TTAI"; }
	function UseAsRandomAI()  { return false; }
	function CreateInstance() { return "TutorialAI"; }


	function GetSettings() {
		AddSetting({name = "log_level", description = "Log level (higher = print more)", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, flags = AICONFIG_INGAME, min_value = 1, max_value = 3});
		AddSetting({name = "debug_signs", description = "Build debug signs", easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = AICONFIG_BOOLEAN | AICONFIG_INGAME});
	}
}

/* Tell the core we are an AI */
RegisterAI(TutorialAI());
