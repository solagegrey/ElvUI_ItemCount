### v2.1.0 July 23 2023
* code cleanup
* reworked saving profile to use ElvUI SavedVariables instead of separate one for this addon
* removed support for multiple "pattern sets" -- nice idea, too much work for an already busy boy
* updated Ace Libs
* changed some variable initialization

### v2.0.40 May 31 2023
* new feature squelch info to chat
* bump 10.1.5

### v2.0.39 May 05 2023
* set TOC for 10.1.0
* updated readme.md for project description

### v2.0.37 Mar 21 2023
* bump TOC 10.0.7

### v2.0.36 Feb 18 2023
* added Wago.io listing & project ID

### v2.0.35 Jan 24 2023
* fixed some localization errors - even though localization for this addon is, so far, redundant and superfluous (not to mention incompetent and immaterial)

### v2.0.34 Jan 24 2023
* bump toc for 10.0.5

### v2.0.33 Jan 19 2023
* made local what could be made local, to avoid polluting global namespace - per recommendation of Azilroka

### v2.0.32 Jan 18 2023
* removed hard dependency for Ace3; the libs are included - may be able to remove* fixed SetFormattedText arguments

### v2.0.31 Nov 22 2022
* turn off debugging so users don't get schmegged in chat frame* alt-click for adding a counted item from bags is STILL disabled. Bliz changed the API and it's too complicated for my puny intellect* including Ace3 libs now, because ElvUI apparently doesn't carry one that's needed here? I don't remember which one.

### v2.0.3 Nov 16 2022
* bump 10.0.2* alt-click feature is disabled for debugging. To set counted items, use the main config interface* fixed various features that were broken by changes to called procedures, e.g. chiming when not supposed to (bag update without increase in count for counted item), and combat-text not appearing on reaching goal

### v2.0.2 Oct 26 2022
* bump 10.0.0* fixed wrong string in config display* removed extraneous file

### v2.0.01 Aug 20 2022
* bump toc for 9.2.7

### v2.0 Jul 04 2022
* each of the 5 counted items can have its own alert sound, and each may be configured to chime on collection or not* one of the 5 counted items can be "watched" by displaying in the datatext; all others will be displayed in the tooltip

### v1.5.1 Jan 29 2022
* Fixed some spelling

### v1.5.0 Nov 10 2021
* Bump TOC for 9.1.5* Moved repository to GitHub* Fixed issue where certain circumstances will cause a collection chime on login* Fixed issue where some interface sounds were still being addressed using string instead of ID* Added a bunch of new Goal sounds

### v1.4.3 Jun 28 2021
* Bump TOC for 9.1.0* Reinstated the /ic shortcut to open config* Reorganized the Options Panel

### v1.4.2 Jun 20 2021
* Bump TOC for 9.0.5* Fixed bug where left-click on datatext would not open config* Added counted item to floating combat text* Now relies on ElvUI for updated Ace libraries and LibElvUIPlugin library

### v1.4.1 Nov 25 2020
* Update for 9.x: RegisterDatatext function requires additional argument; change in how internal sound files are played

### v1.3.3.3 Nov 30 2018
* Bump TOC for 8.0

### v1.3.3.2 Nov 6 2016
* Bump TOC for 7.1

### v1.3.3.1 Aug 15 2016
* Corrected error with new Legion combat text setting. Your setting for "Combat Text Scrolling for Self" (on the Interface =&gt; Combat panel) will control whether ItemCount displays an alert using combat text.

### v1.3.3 Aug 4 2016
* Added two more count slots, for a total of 5 counted items* Updated Ace Libs* Corrected reference to ElvUI config lib

### v1.3.2 Jul 19 2016
* Bump TOC for 7.0 (may need to check Ace libs for updates...)

### v1.3.1.1 Sep 29 2015
* Bump TOC for 6.2

### v1.3.1 Feb 25 2015
* Bump TOC for 6.1* Attempted bug fix for not updating qty on hand when logging into an alt counting same item as previous login

### v1.3 Dec 17 2014
* Save and copy Pattern Sets, similar to config profiles* A little cleanup on localizations; still need translations...

### v1.2 Dec 7 2014
* Finally, left-click on datatext goes directly to the ItemCount config panel* Added 3 quick-switch item Patterns* Various changes to the tooltip content* Some code cleanup (please report any behavioral anomalies)* A little more work done on localizations (still need translations)

### v1.1.7 Nov 29 2014
* Added option for bell chime when quantity increases for watched item* Fixed and updated the datatext right-click dropdown config menu* Fixed the formatting of the changelog file ;)

### v1.1.6 Oct 16 2014
* Corrected TOC for pre-patch 6.0 (changed "60002" to "60000", harrumph)* Corrected problem loading AceConfig-3.0 and AceGUI-3.0

### v1.1.5 Oct 13 2014
* Bump TOC for pre-patch 6.0

### v1.1.4 Sep 21 2013
* Bug Fix (#2): now using AceHook-3.0 for capturing alt-rightclick event

### v1.1.3 Sep 20 2013
* Bug Fix (#1): when ItemCount was not assigned to a datatext display location, opening config would throw an error.* Updated Ace libraries

### v1.1.2 Sep 10 2013
* Bump TOC for 50400

### v1.1 Jul 8 2013
* New Feature: Right-Click menu for selecting alert sound* Simplified the tooltip just a bit* Began work on support for localization

### v1.0 May 21 2013
* New Feature: on left-click, opens config panel (still working on having the Item Count page appear automatically)* New Feature: Alt-Right-Click on an item in your bags to set the counted item

### v0.2 Apr 20 2013
* Initial Version (release)
