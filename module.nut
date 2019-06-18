// shuffle-module
// by Keil Miller Jr
// https://github.com/keilmillerjr/shuffle-module

const SHUFFLE_VERSION = "2.2.0";
::SHUFFLE_VERSION <- SHUFFLE_VERSION;

class Shuffle {
	__fatalError = null;
	_ignoreNewSelection = null;
	_loop = null;
	_reset = null;
	_save = null;
	_selected = null;
	_slots = null;

	constructor(opts) {
		this.__fatalError = false;
		this._ignoreNewSelection = false;
		this._selected = 0;

		// reset validation - defaulting argument
		try {
			assert(__validateBool(opts.reset));
			this._reset = opts.reset;
		}
		catch(e) {
			if ("reset" in opts) print("ERROR in an instance of Shuffle: constructor - improper reset argument, switching to default value\n");
			this._reset = true;
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
			// ignore new selection for these signals
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
		// load save from fe.nv
		if (ttype == Transition.StartLayout && this._save) {
			try {
				assert(__validatesSelected(fe.nv.shuffle[this._save]));
				this._selected = fe.nv.shuffle[this._save];
			}
			catch(e) { print("ERROR in an instance of Shuffle: save - improper save data\n"); }
		}

		// store save in fe.nv
		else if (ttype == Transition.EndLayout && this._save) {
			if (!("shuffle" in fe.nv)) fe.nv.shuffle <- {};
			if ("save" in fe.nv.shuffle) fe.nv.shuffle[this._save] = this._selected;
			else fe.nv.shuffle[this._save] <- this._selected;
		}

		// ToNewList
		else if (ttype == Transition.ToNewList) {
			if (this._ignoreNewSelection == true) this._ignoreNewSelection = false;
			else if (this._reset == true) this._selected = 0;
		}

		// ToNewSelection
		else if (ttype == Transition.FromOldSelection) {
			if (this._ignoreNewSelection == true) this._ignoreNewSelection = false;
			else __updateSelected(var);
		}

		// process
		if (ttype == Transition.ToNewList || ttype == Transition.FromOldSelection) {
			_updateIndexes();
			_refresh();
		}
	}

	function _updateIndexes() {
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
