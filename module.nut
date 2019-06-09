const SHUFFLE_VERSION = "2.0.0";
::SHUFFLE_VERSION <- SHUFFLE_VERSION;

class Shuffle {
	__fatalError = null;
	_ignoreNewSelection = null;
	_reset = null;
	_save = null;
	_selected = null;
	_slots = null;

	constructor(opts) {
		this.__fatalError = false;
		this._ignoreNewSelection = false;
		this._selected = 0;

		// reset validation - defaulting argument
		try { assert(__validateReset(opts.reset)); }
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
			-(this._selected-i)==0 ? _refreshSelected(this._slots[i]) : _refreshDeselected(this._slots[i]);
		}
	}

	function _refreshDeselected(slot) {}

	function _refreshSelected(slot) {}

	function _signals(signal_str) {
		switch(signal_str) {
			case "random_game":
			case "prev_letter":
			case "next_letter":
			case "prev_favourite":
			case "next_favorite":
				this._ignoreNewSelection = true;
				break;
		}
		return false;
	}

	function _transitions(ttype, var, ttime) {
		switch(ttype) {
			case Transition.StartLayout:
				if (this._save) {
					try {
						assert(__validatesSelected(fe.nv.shuffle[this._save]));
						this._selected = fe.nv.shuffle[this._save];
					}
					catch(e) { print("ERROR in an instance of Shuffle: save - improper save data\n"); }
				}
				break;
			case Transition.EndLayout:
				if (this._save) {
					if (!("shuffle" in fe.nv)) fe.nv.shuffle <- {};
					if ("save" in fe.nv.shuffle) fe.nv.shuffle[this._save] = this._selected;
					else fe.nv.shuffle[this._save] <- this._selected;
				}
				break;
			case Transition.ToNewList:
				if (this._reset == true) this._selected = 0;
				_updateIndexes();
				_refresh();
				break;
			case Transition.ToNewSelection:
				if (this._ignoreNewSelection != true) {
					__updateSelected(var);
					_updateIndexes();
					_refresh();
				}
				else { this._ignoreNewSelection = false; }
				break;
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
		switch (position>0) {
			# select next slot
			case true:
				if (this._selected<(this._slots.len()-1)) this._selected++;
				break;
			# select previous slot
			case false:
				if (this._selected>0) this._selected--;
				break;
		}
	}

	function __validatesSelected(selected) {
		try {
			assert(typeof(selected) == "integer");
			assert(selected>=0 && selected<this._slots.len());
		}
		catch(e) { return false; }
		return true;
	}

	function __validateReset(reset) {
		try { assert(typeof(reset) == "bool"); }
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
