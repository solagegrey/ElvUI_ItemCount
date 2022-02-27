--[[

   ElvUI ItemCount
---------------------


			 To Do 2.0
			---------------------

		   * Major Revision: 
		     Different sounds for each counted item (which also means we have to 
		     iterate each item within the OnEvent function, instead of just the
		     curitem.Item - also, each item should have a sound on/off toggle)

			  . remove curitem object and references, apply features to all pattern[1-5] objects
			  . apply loop in OnEvent to iterate pattern collection

		   * Disallow alt-RightClick while elvui config is open; or find another solution to 
		     the behavior that counted items in the config interface aren't updated

		   * Translations for all localizations (low priority)


			 Current Issues
			---------------------
			
			

]]--
