# Shuffle module for AttractMode front end

by [Keil Miller Jr](http://keilmillerjr.com)

![mvscomplete](mvscomplete.gif)
![retrorama2](retrorama2.gif)

## DESCRIPTION:

Shuffle module is for the [AttractMode](http://attractmode.org) front end. It will aid in the use of slots (objects) used as a navigatable list.

This module is meant to be simple. It does not handle presentation of object, nor does it handle object animation as a moving list. If you are looking for an animated list, please look at the conveyor module included with AttractMode.

## Paths

You may need to change file paths as necessary as each platform (windows, mac, linux) has a slightly different directory structure.

## Install Files

1. Copy module files to `$HOME/.attract/modules/shuffle/`.

## Usage

From within your layout, you can load the module and initiate the Shuffle class. The shuffle class will create the quantity of objects specified in an array called *slots*. The objects will be of type specified, and have the parameter specified passed to them. All objects will have thier index_offset updated appropriately during front end signals.

Shuffle likes to keep presentation seperate from logic. You must set the position of your objects after the class is initiated.

```squirrel
// Load the Shuffle module
fe.load_module("shuffle");

// Create an instance of the class
// Shuffle(quantity=5, type="text", param="[Title]", reset=true, parent=::fe)
local list = Shuffle(5, "text", "[Title]");
	// Set the position of the created slots
	list.slots[0].set_pos(x, y, w, h);
	list.slots[1].set_pos(x, y, w, h);
	list.slots[2].set_pos(x, y, w, h);
	list.slots[3].set_pos(x, y, w, h);
	list.slots[4].set_pos(x, y, w, h);
```

You may also extend the class and use the *select* and *deselect* functions. These functions are run after every signal, and can change your presentation.

This example will extend the Shuffle class and make a selected slot bold and deselected slots regular.

```squirrel
fe.load_module("shuffle");

// Extend the Shuffle class
class ShuffleList extends Shuffle {
	// Overwrite the select function
	function select(slot) {
		slot.style = Style.Bold;
	}
	
	// Overwrite the deselect function
	function deselect(slot) {
		slot.style = Style.Regular;
	}
}

// Create an instance of the extended class
local list = ShuffleList(5, "text", "[Title]");
	list.slots[0].set_pos(x, y, w, h);
	list.slots[1].set_pos(x, y, w, h);
	list.slots[2].set_pos(x, y, w, h);
	list.slots[3].set_pos(x, y, w, h);
	list.slots[4].set_pos(x, y, w, h);
```

Shuffle accepts the following types of objects:

* artwork
* image
* surface
* text

## Notes

More functionality is expected as it meets my needs. If you have an idea of something to add that might benefit a wide range of layout developers, please join the [AttractMode forum](http://forum.attractmode.org) and send [me](http://forum.attractmode.org/index.php?action=profile;u=32) a message.