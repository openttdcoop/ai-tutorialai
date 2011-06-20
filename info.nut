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
	function GetDescription() { return "The AI will talk to you through signs that are placed in the middle of the map (starting location of new games)"; }
	function GetVersion()     { return 1; }
	function MinVersionToLoad() { return 1; }
	function GetDate()        { return "2011-06-20"; }
	function CreateInstance() { return "TutorialAI"; }


}

/* Tell the core we are an AI */
RegisterAI(TutorialAI());
