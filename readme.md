# Shuffle module for AttractMode front end

by [Keil Miller Jr](http://keilmillerjr.com)

![mvscomplete](mvscomplete.gif)
![retrorama2](retrorama2.gif)

## DESCRIPTION:

Shuffle module is for the [AttractMode](http://attractmode.org) front end. It will aid in the use of slots (objects) used as a navigable list.

This module is meant to be simple. It does not handle presentation of object, nor does it handle object animation as a moving list. If you are looking for an animated list, please look at the conveyor module included with AttractMode.

## Paths

You may need to change file paths as necessary as each platform (windows, mac, linux) has a slightly different directory structure.

## Install Files

Shuffle currently has no dependancies.

1. Copy module files to `$HOME/.attract/modules/shuffle/`.

## Usage

From within your layout, you will load the Shuffle module. Shuffle keeps presentation and logic separate. It is up to you to create your objects and apply properties to them. You will then create an instance of the class.

```squirrel
// Load the Shuffle module
fe.load_module("shuffle");

// Create your objects
local list = [];
	list.push(fe.add_text("Title", -1, -1, 1, 1));
	list.push(fe.add_text("Title", -1, -1, 1, 1));
	list.push(fe.add_text("Title", -1, -1, 1, 1));

// Create an instance of the Shuffle class
// Shuffle({arg=val})
// Options:
// 	reset=bool - defaulting argument
// 	save=string - optional argument
// 	slots=[] - required argument

local list = Shuffle({ reset=false, save="mytheme", slots=list });
```

###### Supported objects

* artwork
* image
* text
* preserveImage
* preserveArt

#### Extending the class

###### public variables

* VERSION

###### public methods

* getSelected()
* getSlots()
* getVersion()
* setSelected()

###### private methods

* _refresh()
* _refreshDeselected()
* _refreshSelected
* _signals(signal\_str)
* _transitions(ttype, var, ttime)
* _updateIndexes()

This example will extend the Shuffle class and make a selected slot bold and deselected slots regular.

```squirrel
// Load the Shuffle module
fe.load_module("shuffle");

// Create your objects
local list = [];
	list.push(fe.add_text("Title", -1, -1, 1, 1));
	list.push(fe.add_text("Title", -1, -1, 1, 1));
	list.push(fe.add_text("Title", -1, -1, 1, 1));

class ShuffleList extends Shuffle {
	// If necessary, you can extend the refresh function
	// Useful to applying effects while looping through the slots array
	function refresh() {
		base._refresh();
	}

	// Overwrite the _refreshSelected function
	function _refreshSelected(slot) {
		slot.style = Style.Bold;
	}

	// Overwrite the _refreshDeselected function
	function _refreshDeselected(slot) {
		slot.style = Style.Regular;
	}
}

// Create an instance of the ShuffleList class
local list = ShuffleList({ slots=list });
```

## Notes

More functionality is expected as it meets my needs. If you have an idea of something to add that might benefit a wide range of layout developers, please join the [AttractMode forum](http://forum.attractmode.org) and send [me](http://forum.attractmode.org/index.php?action=profile;u=32) a message.
