// shuffle-module
// by Keil Miller Jr
// https://github.com/keilmillerjr/shuffle-module

const SHUFFLE_VERSION = "2.2.0";
::SHUFFLE_VERSION <- SHUFFLE_VERSION;

class Shuffle {
	__fatalError = null;
	_ignoreNewSelection = null;
	_hide = null;
	_loop = null;
	_reset = null;
	_save = null;
	_selected = null;
	_slots = null;

	constructor(opts) {
		this.__fatalError = false;
		this._ignoreNewSelection = false;
		this._selected = 0;

		// hide validation - defaulting argument
		try {
			assert(__validateBool(opts.hide));
			this._hide = opts.hide;
		}
		catch(e) {
			if ("hide" in opts) print("ERROR in an instance of Shuffle: constructor - improper hide argument, switching to default value\n");
			this._hide = false;
		}

		// loop validation - defaulting argument
		try {
			assert(__validateBool(opts.loop));
			this._loop = opts.loop;
		}
		catch(e) {
			if ("loop" in opts) print("ERROR in an instance of Shuffle: constructor - improper reset argument, switching to default value\n");
			this._loop = true;
		}

		// reset validation - defaulting argument
		try {
			assert(__validateBool(opts.reset));
			this._reset = opts.reset;
		}
		catch(e) {
			if ("reset" in opts) print("ERROR in an instance of Shuffle: constructor - improper reset argument, switching to default value\n");
			this._reset = true;
		}

		// save validation - optional argument
		if ("save" in opts) {
			try {
				assert(__validateSave(opts.save));
				this._save = opts.save;
			}
			catch(e) {
				print("ERROR in an instance of Shuffle: constructor - improper save argument\n");
				this._save = null;
			}
		}

		// slots validation - required argument
		try {
			assert(__validateSlots(opts.slots))
			this._slots = opts.slots;
		}
		catch(e) {
			print("ERROR in an instance of Shuffle: constructor - improper slots argument\n");
			this.__fatalError = true;
		}

		// callbacks and handlers
		if (!this.__fatalError) {
			fe.add_signal_handler(this, "_signals");
			fe.add_transition_callback(this, "_transitions");
		}
	}

	# public

	function getSelected() { return this._selected }

	function getSlots() { return this._slots }

	function getVersion() { return SHUFFLE_VERSION }

	function setSelected(slot) { this._selected = slot }

	# private

	function _refresh() {
		for (local i=0; i<this._slots.len(); i++) {
			// hide slots
			if (this._hide) {
				if (i > fe.list.size-1) this._slots[i].visible = false;
				else this._slots[i].visible = true;
			}

			// easy extendable functions
			_refreshAll(this._slots[i]);
			-(this._selected-i)==0 ? _refreshSelected(this._slots[i]) : _refreshDeselected(this._slots[i]);
		}
	}

	function _refreshAll(slot) {}

	function _refreshDeselected(slot) {}

	function _refreshSelected(slot) {}

	function _signals(signal_str) {
		switch(signal_str) {
			// ignore signals at start or end of list when looping is false
			case "prev_game":
				if (this._loop == false && fe.list.index == 0) return true;
				break;
			case "next_game":
				if (this._loop == false && fe.list.index == fe.list.size-1) return true;
				break;
			// do not update selection for these signals
			case "random_game":
			case "prev_letter":
			case "next_letter":
			case "add_favourite":
			case "prev_favourite":
			case "next_favorite":
				this._ignoreNewSelection = true;
				break;
		}

		return false;
	}

	function _transitions(ttype, var, ttime) {
		// from old selection
		if (ttype == Transition.FromOldSelection) {
			// do not update new selection
			if (this._ignoreNewSelection == true) this._ignoreNewSelection = false;
			// update selected
			else __updateSelected(var);
		}

		// to new list
		else if (ttype == Transition.ToNewList) {
			// do not update new selection
			if (this._ignoreNewSelection == true) this._ignoreNewSelection = false;
			else {
				// reset
				if (this._reset == true) {
					this._selected = 0;
					fe.list.index = 0;
				}
				// load selected from fe.nv
				else if (this._save != null) {
					try {
						assert(__validatesSelected(fe.nv.shuffle[this._save][fe.list.name]));
						this._selected = fe.nv.shuffle[this._save][fe.list.name];
					}
					catch(e) { print("ERROR in an instance of Shuffle: save - improper save data\n"); }
				}
			}
		}

		// save selected in fe.nv
		else if (ttype == Transition.EndNavigation && this._save) {
			if (!("shuffle" in fe.nv)) fe.nv.shuffle <- {};
			if (!(this._save in fe.nv.shuffle)) fe.nv.shuffle[this._save] <- {};
			if (!(fe.list.name in fe.nv.shuffle[this._save])) fe.nv.shuffle[this._save][fe.list.name] <- this._selected;
			else fe.nv.shuffle[this._save][fe.list.name] = this._selected;
		}

		// update index offsets and refresh
		if (ttype == Transition.ToNewList || ttype == Transition.FromOldSelection) {
			_updateIndexOffsets();
			_refresh();
		}

		return false;
	}

	function _updateIndexOffsets() {
		for (local i=0; i<this._slots.len(); i++) {
			try { this._slots[i].index_offset = -(this._selected-i) } catch(e) {}
			try { this._slots[i].art.index_offset = -(this._selected-i); } catch(e) {}
		}
	}

	# protected

	function __updateSelected(position) {
		if (position<0 && this._selected<(this._slots.len()-1)) this._selected++;
		if (position>0 && this._selected>0) this._selected--;
	}

	function __validateBool(var) {
		try { assert(typeof(var) == "bool"); }
		catch(e) { return false; }
		return true;
	}

	function __validateSave(save) {
		try {
			assert(typeof(save) == "string");
			assert(save.len()>0);
		}
		catch(e) { return false; }
		return true;
	}

	function __validatesSelected(selected) {
		try {
			assert(typeof(selected) == "integer");
			assert(selected>=0 && selected<this._slots.len());
		}
		catch(e) { return false; }
		return true;
	}

	function __validateSlots(slots) {
		if (typeof(slots) != "array") return false;
		if (slots.len()<1) return false;
		for (local i=0; i<slots.len(); i++) {
			try { assert(typeof(slots[i].index_offset) == "integer" || typeof(slots[i].art.index_offset) == "integer"); }
			catch(e) { return false; }
		}
		return true
	}
}
