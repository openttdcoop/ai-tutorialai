
MENU_OPEN <- "__open__";
MENU_CLOSED <- "__closed__";


class Menu {

	sign_list = null;
	button_list = null;

	location = null;

	constructor() {
		this.sign_list = [];
		this.button_list = [];

		this.location = AIMap.GetTileIndex(AIMap.GetMapSizeX() / 2, AIMap.GetMapSizeY() / 2);
	}

	function Close();
	function SetLocation(top_tile); // Note: only affects new menus opened using Open.
	function Open(text, buttons);

	// Returns:
	// - "__open__" if open (see also MENU_OPEN constant above)
	// - "__closed__" if closed (see also MENU_CLOSED constant above)
	// - button-text if button "clicked"
	function CheckInput();

	static function SplitIntoSigns(text)
	function GetWorkingMenuTop(num_lines);
}

function Menu::Close()
{
	foreach(sign in this.sign_list)
	{
		AISign.RemoveSign(sign);
	}

	foreach(btn in this.button_list)
	{
		AISign.RemoveSign(btn["sign"]);
	}

	this.sign_list = [];
	this.button_list = [];
}

/* static */ function Menu::SplitIntoSigns(text)
{
	local sign_len = 30;

	//text = text.strip();

	local str_list = [];
	while(text.len() > sign_len)
	{
		AILog.Info("s - text: " + text);
		local next_line = "";
		local copy_from = 0;
		for(local i = 0; i < text.len(); ++i)
		{
			AILog.Info("i = " + i + " - text: " + text);
			local curr_word_len = i - copy_from
			if(next_line.len() + 1 + curr_word_len > sign_len)
			{
				// There is not enough room to add more words to new_line
				if(next_line.len() == 0)
				{
					AILog.Info("'" + next_line + "' is empty");
					// Detected a word longer than sign_len
					// => force break the word

					if(copy_from != 0)
						Die("Unexpected behaviour");

					local next_word = text.slice(copy_from, i);
					next_line = next_word.slice(copy_from, sign_len - 1) + "-";
					text = text.slice(sign_len);
				}
				else
				{
					// next_line has been filled by one or more words
					text = text.slice(i); // correct? or i + 1?
				}

				break;
			}

			// A word break has been found, and there is room for it (see checks above)
			if(text[i] == ' ' || 
					i == text.len() - 1) // or last char
			{
				local next_word = text.slice(copy_from, i);
				print("Word found: '" + next_word + "'");
				next_line += " " + next_word;
				copy_from = i + 1;
				//text = text.slice(i + 1); // correct? i or i + 1?
			}
		} 

		str_list.append(next_line);

		if(str_list.len() > 1)
			AILog.Info("STOP");
	}

	return str_list;
}

function Menu::GetWorkingMenuTop(num_lines)
{
	local curr_loc_menu_capacity = Helper.Min(AIMap.GetMapSizeX() - AIMap.GetTileX(this.location), AIMap.GetMapSizeY() - AIMap.GetTileY(this.location));
	local menu_top = this.location;
	if(curr_loc_menu_capacity < num_lines)
	{
		local needed_cap = num_lines - curr_loc_menu_capacity;
		menu_top = Tile.GetTileRelative(menu_top, -needed_cap, -needed_cap);

		if(!AIMap.IsValidTile(menu_top))
		{
			if(Helper.Min(AIMap.GetMapSizeX(), AIMap.GetMapSizeY()) >= num_lines)
				menu_top = AIMap.GetTileIndex(0, 0); // Resort to 0,0 if moving menu upwards from current loc failed
			else
			{
				// Menu is too large for current map!!
				return null;
			}

		}
	}

	return menu_top;
}

function Menu::SetLocation(top_tile)
{
	if(!AIMap.IsValidTile(top_tile))
	{
		AILog.Error("Bad tile sent to Menu::SetLocation");
		return false;
	}

	this.location = top_tile;
	return true;
}

function Menu::Open(text, buttons)
{
	this.Close();

	local text_list = Menu.SplitIntoSigns(text);
	local menu_top = this.GetWorkingMenuTop(text_list.len() + buttons.len());

	if(menu_top == null)
	{
		// Map is too small to display menu
		Helper.SetSign(this.location, "Menu Failed - Too small map!");
		AILog.Info("The map was too small to display the following text as signs: ");
		foreach(text_str in text_list)
		{
			AILog.Info("   " + text_str);
		}

		foreach(button in buttons)
		{
			AILog.Info("   [" + button + "]");
		}
	}

	// Place text signs
	local curr_tile = menu_top;
	foreach(text_str in text_list)
	{
		local sign = AISign.BuildSign(curr_tile, text_str);
		this.sign_list.append(sign);

		curr_tile = Tile.GetTileRelative(curr_tile, 1, 1);
	}

	// Place button signs
	foreach(button in buttons)
	{
		local sign = AISign.BuildSign(curr_tile, "[" + button + "]");
		local btn = {
			name = button,
			sign = sign
		}
		this.button_list.append(btn);

		curr_tile = Tile.GetTileRelative(curr_tile, 1, 1);
	}
}

function Menu::CheckInput()
{
	if(this.sign_list.len() == 0)
		return MENU_CLOSED;

	local result = MENU_OPEN;
	foreach(btn in this.button_list)
	{
		if(!AISign.IsValidSign(btn.sign))
		{
			// Button "clicked"
			result = btn.name;
			break;
		}
	}

	if(result != MENU_OPEN)
	{
		// Close menu.
		this.Close();
	}

	return result;
}

