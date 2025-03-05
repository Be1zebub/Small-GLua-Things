// GMod dark theme
// replace your garrysmod/resource/SourceScheme.res with this file
// preview: https://i.imgur.com/3O9VJ77.jpg
"Scheme"
{
	//////////////////////// COLORS ///////////////////////////
	// color details
	// this is a list of all the colors used by the scheme
	"Colors"
	{
		// base colors
		"White"											"255 255 255 255"
		"OffWhite"										"221 221 221 255"
		"DullWhite"										"190 190 190 255"
		"Orange"										"255 155 0 255"
		"TransparentBlack"								"0 0 0 128"
		"Black"											"0 0 0 255"

		"Blank"											"0 0 0 0"

		"SteamLightGreen"								"157 194 80 255"
		"AchievementsLightGrey"							"79 79 79 255"
		"AchievementsDarkGrey"							"55 55 55 255"
		"AchievementsInactiveFG"						"130 130 130 255"
	}

	///////////////////// BASE SETTINGS ////////////////////////
	//
	// default settings for all panels
	// controls use these to determine their settings
	"BaseSettings"
	{
		// vgui_controls color specifications
		Border.Bright									"17 17 17 255"							// the lit side of a control
		Border.Dark										"17 17 17 255"							// the dark/unlit side of a control
		Border.Selection								"54 54 54 255"							// the additional border color for displaying the default/selected button
		Border.DarkSolid								"17 17 17 255"
		Border.Subtle									"17 17 17 255"

		Button.TextColor								"240 240 240 255"
		Button.BgColor									"45 45 48 50"
		Button.ArmedTextColor							"0 122 204 255"
		Button.ArmedBgColor								"62 62 64 255"				[$WIN32]
		Button.ArmedBgColor								"62 62 64 255"				[$X360]
		Button.DepressedTextColor						"18 18 18 255"
		Button.DepressedBgColor							"0 122 204 255"
		Button.FocusBorderColor							"Blank"

		CheckButton.TextColor							"240 240 240 255"
		CheckButton.SelectedTextColor					"190 190 190 255"
		CheckButton.BgColor								"30 30 32 50"
		CheckButton.Border1								"Border.Subtle"							// the left checkbutton border
		CheckButton.Border2								"Border.Subtle"							// the right checkbutton border
		CheckButton.Check								"60 60 62 255"							// color of the check itself
		CheckButton.HighlightFgColor					"0 122 204 255"
		CheckButton.ArmedBgColor						"Blank"
		CheckButton.DepressedBgColor					"Blank"
		CheckButton.DisabledBgColor						"Black"

		ComboBoxButton.ArrowColor						"0 122 204 255"
		ComboBoxButton.ArmedArrowColor					"0 60 255 255"
		ComboBoxButton.BgColor							"Blank"
		ComboBoxButton.DisabledBgColor					"Blank"

		Frame.TitleTextInsetX							"16"
		Frame.ClientInsetX								"8"
		Frame.ClientInsetY								"6"
		Frame.BgColor									"50 50 50 250"				[$WIN32]
		Frame.BgColor									"50 50 50 250"				[$X360]
		Frame.OutOfFocusBgColor							"25 25 25 240"				[$WIN32]
		Frame.OutOfFocusBgColor							"25 25 25 192"				[$X360]
		Frame.FocusTransitionEffectTime					"0.3"									// time it takes for a window to fade in/out on focus/out of focus
		Frame.TransitionEffectTime						"0.3"						[$WIN32]	// time it takes for a window to fade in/out on open/close
		Frame.TransitionEffectTime						"0.2"						[$X360]		// time it takes for a window to fade in/out on open/close
		Frame.AutoSnapRange								"0"
		FrameGrip.Color1								"40 40 42 255"
		FrameGrip.Color2								"40 40 42 255"
		FrameTitleButton.FgColor						"255 0 0 204"
		FrameTitleButton.BgColor						"Blank"
		FrameTitleButton.DisabledFgColor				"197 64 74 91"
		FrameTitleButton.DisabledBgColor				"Blank"
		FrameSystemButton.FgColor						"Blank"
		FrameSystemButton.BgColor						"Blank"
		FrameSystemButton.Icon							""
		FrameSystemButton.DisabledIcon					""
		FrameTitleBar.Font								"UiBold"					[$WIN32]
		FrameTitleBar.Font								"DefaultLarge"				[$X360]
		FrameTitleBar.TextColor							"0 122 204 204"
		FrameTitleBar.BgColor							"Blank"
		FrameTitleBar.DisabledTextColor					"0 122 204 91"
		FrameTitleBar.DisabledBgColor					"Blank"

		GraphPanel.FgColor								"0 122 204 255"
		GraphPanel.BgColor								"17 17 17 150"

		Label.TextDullColor								"190 190 190 255"
		Label.TextColor									"190 190 190 255"
		Label.TextBrightColor							"240 240 240 255"
		Label.SelectedTextColor							"210 210 210 255"
		Label.BgColor									"Blank"
		Label.DisabledFgColor1							"90 90 90 255"
		Label.DisabledFgColor2							"85 85 85 245"

		ListPanel.TextColor								"240 240 240 255"
		ListPanel.TextBgColor							"Blank"
		ListPanel.BgColor								"12 12 12 50"
		ListPanel.SelectedTextColor						"0 122 204 255"
		ListPanel.SelectedBgColor						"50 50 50 204"
		ListPanel.OutOfFocusSelectedTextColor			"Black"
		ListPanel.SelectedOutOfFocusBgColor				"132 183 241 100"
		ListPanel.EmptyListInfoTextColor				"Black"

		Menu.TextColor									"240 240 240 255"
		Menu.BgColor									"25 25 28 50"
		Menu.ArmedTextColor								"0 122 204 255"
		Menu.ArmedBgColor								"40 40 42 255"
		Menu.TextInset									"6"

		Panel.FgColor									"Blank"
		Panel.BgColor									"Blank"

		ProgressBar.FgColor								"0 122 204 255"
		ProgressBar.BgColor								"12 12 12 50"

		PropertySheet.TextColor							"240 240 240 240"
		PropertySheet.SelectedTextColor					"White"
		PropertySheet.SelectedBgColor					"60 60 60 255"
		PropertySheet.TransitionEffectTime				"0.25"									// time to change from one tab to another
		PropertySheet.BgColor							"37 37 37 50"

		RadioButton.TextColor							"240 240 240 240"
		RadioButton.SelectedTextColor					"0 122 204 255"

		// Console
		RichText.TextColor								"210 210 210 255"
		RichText.BgColor								"12 12 12 150"
		RichText.SelectedTextColor						"0 122 204 255"
		RichText.SelectedBgColor						"20 20 20 150"

		ScrollBar.Wide									"15"

		ScrollBarButton.FgColor							"Button.FgColor"
		ScrollBarButton.BgColor							"Button.BgColor"
		ScrollBarButton.ArmedFgColor					"Button.ArmedFgColor"
		ScrollBarButton.ArmedBgColor					"Button.ArmedBgColor"
		ScrollBarButton.DepressedFgColor				"Button.DepressedFgColor"
		ScrollBarButton.DepressedBgColor				"Button.DepressedBgColor"

		ScrollBarSlider.FgColor							"46 46 48 255"							// nob color
		ScrollBarSlider.BgColor							"29 29 31 255"							// slider background color

		SectionedListPanel.HeaderTextColor				"0 122 204 255"
		SectionedListPanel.HeaderBgColor				"Blank"
		SectionedListPanel.DividerColor					"0 0 0 150"
		SectionedListPanel.TextColor					"Button.FgColor"
		SectionedListPanel.BrightTextColor				"White"
		SectionedListPanel.BgColor						"17 17 17 50"
		SectionedListPanel.SelectedTextColor			"18 18 18 255"
		SectionedListPanel.SelectedBgColor				"0 122 204 50"
		SectionedListPanel.OutOfFocusSelectedTextColor	"18 18 18 230"
		SectionedListPanel.OutOfFocusSelectedBgColor	"0 122 204 60"

		Slider.NobColor									"46 46 48 255"
		Slider.TextColor								"Label.TextColor"
		Slider.TrackColor								"50 50 50 200"
		Slider.DisabledTextColor1						"Label.DisabledFgColor1"
		Slider.DisabledTextColor2						"Label.DisabledFgColor2"

		TextEntry.TextColor								"Label.TextColor"
		TextEntry.BgColor								"33 33 33 50"
		TextEntry.CursorColor							"0 122 204 240"
		TextEntry.DisabledTextColor						"DullWhite"
		TextEntry.DisabledBgColor						"192 192 192 50"
		TextEntry.SelectedTextColor						"10 10 10 50"
		TextEntry.SelectedBgColor						"SectionedListPanel.SelectedBgColor"
		TextEntry.OutOfFocusSelectedBgColor				"SectionedListPanel.OutOfFocusSelectedBgColor"
		TextEntry.FocusEdgeColor						"TransparentBlack"

		ToggleButton.SelectedTextColor					"White"

		Tooltip.TextColor								"Menu.ArmedTextColor"
		Tooltip.BgColor									"Menu.ArmedBgColor"

		TreeView.BgColor								"TransparentBlack"

		WizardSubPanel.BgColor							"Blank"

		// scheme-specific colors
		MainMenu.TextColor								"White"						[$WIN32]
		MainMenu.TextColor								"200 200 200 255"			[$X360]
		MainMenu.ArmedTextColor							"200 200 200 255"			[$WIN32]
		MainMenu.ArmedTextColor							"White"						[$X360]
		MainMenu.DepressedTextColor						"192 186 80 255"
		MainMenu.MenuItemHeight							"30"						[$WIN32]
		MainMenu.MenuItemHeight							"22"						[$X360]
		MainMenu.MenuItemHeight_hidef					"32"						[$X360]
		MainMenu.Inset									"32"
		MainMenu.Backdrop								"0 0 0 156"

		Console.TextColor								"OffWhite"
		Console.DevTextColor							"White"

		NewGame.TextColor								"White"
		NewGame.FillColor								"0 0 0 255"
		NewGame.SelectionColor							"Orange"					[$WIN32]
		NewGame.SelectionColor							"0 0 0 255"					[$X360]
		NewGame.DisabledColor							"128 128 128 196"

		MessageDialog.MatchmakingBG						"46 43 42 255"				[$X360]
		MessageDialog.MatchmakingBGBlack				"22 22 22 255"				[$X360]

		MatchmakingMenuItemTitleColor					"200 184 151 255"			[$X360]
		MatchmakingMenuItemDescriptionColor				"200 184 151 255"			[$X360]

		"QuickListBGDeselected"							"AchievementsDarkGrey"
		"QuickListBGSelected"							"AchievementsLightGrey"
	}

	//////////////////////// BITMAP FONT FILES /////////////////////////////
	//
	// Bitmap Fonts are ****VERY*** expensive static memory resources so they are purposely sparse
	BitmapFontFiles
	{
		// UI buttons, custom font, (256x64)
		"Buttons"		"materials/vgui/fonts/buttons_32.vbf"
	}

	//////////////////////// FONTS /////////////////////////////
	//
	// describes all the fonts
	Fonts
	{
		// fonts are used in order that they are listed
		// fonts listed later in the order will only be used if they fulfill a range not already filled
		// if a font fails to load then the subsequent fonts will replace
		// fonts are used in order that they are listed
		"DebugFixed"
		{
			"1"
			{
				"name"		"Courier New"
				"tall"		"10"
				"weight"	"500"
				"antialias" "1"
			}
		}
		// fonts are used in order that they are listed
		"DebugFixedSmall"
		{
			"1"
			{
				"name"		"Courier New"
				"tall"		"7"
				"weight"	"500"
				"antialias" "1"
			}
		}
		"DefaultFixedOutline"
		{
			"1"
			{
				"name"		 "Lucida Console" [$WINDOWS]
				"name"		 "Lucida Console" [$X360]
				"name"		 "Lucida Console" [$OSX]
				"name"		 "Verdana" [$LINUX]
				"tall"		"14" [$LINUX]
				"tall"		 "10"
				"tall_lodef" "15"
				"tall_hidef" "20"
				"weight"	 "0"
				"outline"	 "1"
			}
		}
		"Default"
		{
			"1"
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana" [$LINUX]
				"tall"		"16"
				"weight"	"500"
			}
		}
		"DefaultBold"
		{
			"1"
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana Bold" [$LINUX]
				"tall"		"16"
				"weight"	"1000"
			}
		}
		"DefaultUnderline"
		{
			"1"
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana" [$LINUX]
				"tall"		"16"
				"weight"	"500"
				"underline" "1"
			}
		}
		"DefaultSmall"
		{
			"1"
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana" [$LINUX]
				"tall"		"12" [!$LINUX]
				"tall"		"16" [$LINUX]
				"weight"	"0"
			}
		}
		"DefaultSmallDropShadow"
		{
			"1"
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana" [$LINUX]
				"tall"		"13"
				"weight"	"0"
				"dropshadow" "1"
			}
		}
		"DefaultVerySmall"
		{
			"1"
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana" [$LINUX]
				"tall"		"12"
				"weight"	"0"
			}
		}

		"DefaultLarge"
		{
			"1"
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana" [$LINUX]
				"tall"		"18"
				"weight"	"0"
			}
		}
		"UiBold"
		{
			"1"	[$WIN32]
			{
				"name"		"Tahoma" [!$LINUX]
				"name"		"Verdana" [$LINUX]
				"tall"		"12"
				"weight"	"1000"
			}
			"1"	[$X360]
			{
				"name"		"Tahoma"
				"tall"		"24"
				"weight"	"2000"
				"outline"	"1"
			}
		}
		"ChapterTitle"	[$X360]
		{
			"1"
			{
				"name"			"Tahoma"
				"tall"			"20"
				"tall_hidef"	"28"
				"weight"		"2000"
				"outline"		"1"
			}
		}
		"ChapterTitleBlur"	[$X360]
		{
			"1"
			{
				"name"			"Tahoma"
				"tall"			"20"
				"tall_hidef"	"28"
				"weight"		"2000"
				"blur"			"3"
				"blur_hidef"	"5"
			}
		}
		"MenuLarge"
		{
			"1"	[$LINUX]
			{
				"name"		"Helvetica Bold"
				"tall"		"20"
				"antialias" "1"
			}
			"1"	[!$LINUX]
			{
				"name"		"Verdana"
				"tall"		"16"
				"weight"	"600"
				"antialias" "1"
			}
			"1"	[$X360]
			{
				"name"		"Verdana"
				"tall"			"14"
				"tall_hidef"	"20"
				"weight"	"1200"
				"antialias" "1"
				"outline" "1"
			}
		}
		"AchievementTitleFont"
		{
			"1"
			{
				"name"		"Verdana"
				"tall"		"20"
				"weight"	"1200"
				"antialias" "1"
				"outline" "1"
			}
		}

		"AchievementTitleFontSmaller"
		{
			"1"
			{
				"name"		"Verdana"
				"tall"		"18"
				"weight"	"1200"
				"antialias" "1"
				//"outline" "1"
			}
		}


		"AchievementDescriptionFont"
		{
			"1"
			{
				"name"		"Verdana"
				"tall"		"15"
				"weight"	"1200"
				"antialias" "1"
				"outline" "1"
				"yres"		"0 480"
			}
			"2"
			{
				"name"		"Verdana"
				"tall"		"20"
				"weight"	"1200"
				"antialias" "1"
				"outline" "1"
				"yres"	 "481 10000"
			}
		}

		GameUIButtons
		{
			"1"	[$X360]
			{
				"bitmap"	"1"
				"name"		"Buttons"
				"scalex"	"0.63"
				"scaley"	"0.63"
				"scalex_hidef"	"1.0"
				"scaley_hidef"	"1.0"
				"scalex_lodef"	"0.75"
				"scaley_lodef"	"0.75"
			}
		}
		"ConsoleText"
		{
			"1"
			{
				"name"		 "Arial" [$WINDOWS]
				"name"		 "Lucida Console" [$X360]
				"name"		 "Lucida Console" [$OSX]
				"name"		 "Roboto" [$LINUX]
				"tall"		"24" [$LINUX]
				"tall"		"24"
				"weight"	"535"
			}
		}

		// this is the symbol font
		"Marlett"
		{
			"1"
			{
				"name"		"Marlett"
				"tall"		"14"
				"weight"	"0"
				"symbol"	"1"
			}
		}

		"Trebuchet24"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"24"
				"weight"	"900"
			}
		}

		"Trebuchet20"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"20"
				"weight"	"900"
			}
		}

		"Trebuchet18"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"18"
				"weight"	"900"
			}
		}

		// HUD numbers
		// We use multiple fonts to 'pulse' them in the HUD, hence the need for many of near size
		"HUDNumber"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"40"
				"weight"	"900"
			}
		}
		"HUDNumber1"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"41"
				"weight"	"900"
			}
		}
		"HUDNumber2"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"42"
				"weight"	"900"
			}
		}
		"HUDNumber3"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"43"
				"weight"	"900"
			}
		}
		"HUDNumber4"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"44"
				"weight"	"900"
			}
		}
		"HUDNumber5"
		{
			"1"
			{
				"name"		"Trebuchet MS"
				"tall"		"45"
				"weight"	"900"
			}
		}
		"DefaultFixed"
		{
			"1"
			{
				"name"		 "Lucida Console" [$WINDOWS]
				"name"		 "Lucida Console" [$X360]
				"name"		 "Verdana" [$LINUX]
				"tall"		"11" [$LINUX]
				"tall"		"10"
				"weight"	"0"
			}
//			"1"
//			{
//				"name"		"FixedSys"
//				"tall"		"20"
//				"weight"	"0"
//			}
		}

		"DefaultFixedDropShadow"
		{
			"1"
			{
				"name"		 "Lucida Console" [$WINDOWS]
				"name"		 "Lucida Console" [$X360]
				"name"		 "Lucida Console" [$OSX]
				"name"		 "Courier" [$LINUX]
				"tall"		"14" [$LINUX]
				"tall"		"10"
				"weight"	"0"
				"dropshadow" "1"
			}
//			"1"
//			{
//				"name"		"FixedSys"
//				"tall"		"20"
//				"weight"	"0"
//			}
		}

		"CloseCaption_Normal"
		{
			"1"
			{
				"name"		"Tahoma" [!$POSIX]
				"name"		"Verdana" [$POSIX]
				"tall"		"16"
				"weight"	"500"
			}
		}
		"CloseCaption_Italic"
		{
			"1"
			{
				"name"		"Tahoma"
				"tall"		"16"
				"weight"	"500"
				"italic"	"1"
			}
		}
		"CloseCaption_Bold"
		{
			"1"
			{
				"name"		"Tahoma" [!$POSIX]
				"name"		"Verdana Bold" [$POSIX]
				"tall"		"16"
				"weight"	"900"
			}
		}
		"CloseCaption_BoldItalic"
		{
			"1"
			{
				"name"		"Tahoma" [!$POSIX]
				"name"		"Verdana Bold Italic" [$POSIX]
				"tall"		"16"
				"weight"	"900"
				"italic"	"1"
			}
		}

		TitleFont
		{
			"1"
			{
				"name"		"HalfLife2"
				"tall"		"72"
				"weight"	"400"
				"antialias"	"1"
				"custom"	"1"
			}
		}

		TitleFont2
		{
			"1"
			{
				"name"		"HalfLife2"
				"tall"		"120"
				"weight"	"400"
				"antialias"	"1"
				"custom"	"1"
			}
		}

		AppchooserGameTitleFont	[$X360]
		{
			"1"
			{
				"name"			"Trebuchet MS"
				"tall"			"16"
				"tall_hidef"	"24"
				"weight"		"900"
				"antialias"		"1"
			}
		}

		AppchooserGameTitleFontBlur	[$X360]
		{
			"1"
			{
				"name"			"Trebuchet MS"
				"tall"			"16"
				"tall_hidef"	"24"
				"weight"		"900"
				"blur"			"3"
				"blur_hidef"	"5"
				"antialias"		"1"
			}
		}

		StatsTitle	[$WIN32]
		{
			"1"
			{
				"name"		"Arial" [!$POSIX]
				"name"		"Verdana Bold" [$POSIX]
				"weight"		"2000"
				"tall"			"20"
				"antialias"		"1"
			}
		}

		StatsText	[$WIN32]
		{
			"1"
			{
				"name"		"Arial" [!$POSIX]
				"name"		"Verdana Bold" [$POSIX]
				"weight"		"2000"
				"tall"			"18"
				"antialias"		"1"
			}
		}

		AchievementItemTitle	[$WIN32]
		{
			"1"
			{
				"name"		"Arial" [!$POSIX]
				"name"		"Verdana Bold" [$POSIX]
				"weight"		"1500"
				"tall"			"16" [!$POSIX]
				"tall"			"18" [$POSIX]
				"antialias"		"1"
			}
		}

		AchievementItemDate	[$WIN32]
		{
			"1"
			{
				"name"		"Arial" [!$POSIX]
				"name"		"Verdana Bold" [$POSIX]
				"weight"		"1500"
				"tall"			"16"
				"antialias"		"1"
			}
		}


		StatsPageText
		{
			"1"
			{
				"name"		"Arial" [!$POSIX]
				"name"		"Verdana Bold" [$POSIX]
				"weight"		"1500"
				"tall"			"14" [!$POSIX]
				"tall"			"16" [$POSIX]
				"antialias"		"1"
			}
		}

		AchievementItemTitleLarge	[$WIN32]
		{
			"1"
			{
				"name"		"Arial" [!$POSIX]
				"name"		"Verdana Bold" [$POSIX]
				"weight"		"1500"
				"tall"			"18" [!$POSIX]
				"tall"			"19" [$POSIX]
				"antialias"		"1"
			}
		}

		AchievementItemDescription	[$WIN32]
		{
			"1"
			{
				"name"		"Arial" [!$POSIX]
				"name"		"Verdana" [$POSIX]
				"weight"		"1000"
				"tall"			"14" [!$POSIX]
				"tall"			"15" [$POSIX]
				"antialias"		"1"
			}
		}


		"ServerBrowserTitle"
		{
			"1"
			{
				"name"		"Tahoma" [!$POSIX]
				"name"		"Verdana" [$POSIX]
				"tall"		"35"
				"tall_lodef"	"40"
				"weight"	"500"
				"additive"	"0"
				"antialias" "1"
			}
		}

		"ServerBrowserSmall"
		{
			"1"
			{
				"name"		"Tahoma"
				"tall"		"16"
				"weight"	"0"
				"range"		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				"yres"	"480 599"
			}
			"2"
			{
				"name"		"Tahoma"
				"tall"		"16"
				"weight"	"0"
				"range"		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				"yres"	"600 767"
			}
			"3"
			{
				"name"		"Tahoma"
				"tall"		"16"
				"weight"	"0"
				"range"		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				"yres"	"768 1023"
				"antialias"	"1"
			}
			"4"
			{
				"name"		"Tahoma"
				"tall"		"19"
				"weight"	"0"
				"range"		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				"yres"	"1024 1199"
				"antialias"	"1"
			}
			"5"
			{
				"name"		"Tahoma"
				"tall"		"19"
				"weight"	"0"
				"range"		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				"yres"	"1200 6000"
				"antialias"	"1"
			}
		}

	}

	//
	//////////////////// BORDERS //////////////////////////////
	//
	// describes all the border types
	Borders
	{
		BaseBorder		SubtleBorder
		ButtonBorder	RaisedBorder
		ComboBoxBorder	DepressedBorder
		MenuBorder		SubtleBorder
		BrowserBorder	DepressedBorder
		PropertySheetBorder	RaisedBorder

		FrameBorder
		{
			// rounded corners for frames
			//"backgroundtype" "2"

			Left
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}
		}

		SubtleBorder
		{
			"inset" "0 0 0 0"
			Left
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}
		}

		DepressedBorder
		{
			"inset" "0 0 0 0"
			Left
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}
		}
		RaisedBorder
		{
			"inset" "0 0 0 0"
			Left
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}
		}

		TitleButtonBorder
		{
			"backgroundtype" "0"
		}

		TitleButtonDisabledBorder
		{
			"backgroundtype" "0"
		}

		TitleButtonDepressedBorder
		{
			"backgroundtype" "0"
		}

		ScrollBarButtonBorder
		{
			"inset" "0 0 0 0"
			Left
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}
		}

		ScrollBarButtonDepressedBorder
		{
			"inset" "0 0 0 0"
			Left
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}
		}

		TabBorder
		{
			"inset" "1 1 1 1"

			render
			{
				"0" "fill( x0, y0, x1, y1, Black )"
			}

			render_bg
			{
				"0" "fill( x0, y0, x1, y1, Orange )"
			}

		}

		TabActiveBorder
		{
			"inset" "1 1 1 1"
			Left
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.Subtle"
					"offset" "0 0"
				}
			}

		}


		ToolTipBorder
		{
			"inset" "0 0 1 0"
			Left
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}
		}

		// this is the border used for default buttons (the button that gets pressed when you hit enter)
		ButtonKeyFocusBorder
		{
			"inset" "0 0 0 0"
			Left
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
			}
			Top
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
			}
			Right
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
			}
			Bottom
			{
				"1"
				{
					"color" "Border.Selection"
					"offset" "0 0"
				}
			}
		}

		ButtonDepressedBorder
		{
			"inset" "0 0 0 0"
			Left
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 1"
				}
			}

			Right
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "1 0"
				}
			}

			Top
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}

			Bottom
			{
				"1"
				{
					"color" "Border.DarkSolid"
					"offset" "0 0"
				}
			}
		}
	}

	//////////////////////// CUSTOM FONT FILES /////////////////////////////
	//
	// specifies all the custom (non-system) font files that need to be loaded to service the above described fonts
	CustomFontFiles
	{
		"1"		"resource/HALFLIFE2.ttf"
		"2"		"resource/HL2EP2.ttf"
		"3"		"resource/marlett.ttf"
	}
}
