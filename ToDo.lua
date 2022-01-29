--[[

   ElvUI ItemCount
---------------------


			 To Do 1.5
			---------------------
	
		  √* Select the ItemCount tab/page in the ElvUI config window when datatext is clicked

		  √* Include 3 quick-switch item Patterns - e.g. lumber x100/fur x70/ore x240
		  √* Show item count in datatext tooltip

		  √* Confirm replacement of Patterns
		  √* Allow user choice to disable non-warning notifications, like "all patterns frozen"

		  √* Allow freezing of individual Item Pattern slots (to disallow replacing them)
		   
		  √* Save pattern profiles

		  √* Localization support
		   
		  √* Display item and count in combat text
		  
		   * Disallow alt-RightClick while elvui config is open; or find another solution to 
		     the behavior that counted items in the config interface aren't updated

		   * Translations for all localizations (low priority)

		   * Major Revision: 
		     Different sounds for each counted item (which also means we have to 
		     iterate each item within the OnEvent function, instead of just the
		     curitem.Item - also, each item should have a sound on/off toggle)


			 Current Issues
			---------------------
			
			

]]--
