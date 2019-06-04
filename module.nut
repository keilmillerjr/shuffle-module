class Shuffle {
	ignoreNewSelection = null;
	resetSlot = null;
	selectedSlot = null;
	slotType = null;
	slots = null;

	constructor(s, t="text", r=true) {
		ignoreNewSelection = false;
		resetSlot = r;
		selectedSlot = 0;
		slotType = t;
		slots = s;

		fe.add_signal_handler(this, "signals");
		fe.add_transition_callback(this, "transitions");
	}

	function signals(signal_str) {
		switch(signal_str) {
			case "random_game":
			case "prev_letter":
			case "next_letter":
			case "prev_favourite":
			case "next_favorite":
				ignoreNewSelection = true;
				break;
		}
		return false;
	}

	function transitions(ttype, var, ttime) {
		switch(ttype) {
			case Transition.ToNewSelection:
				if (ignoreNewSelection != true) { var>0 ? next() : prev(); }
				else { ignoreNewSelection = false; }
				update();
				break;
			case Transition.ToNewList:
				if (resetSlot == true) selectedSlot = 0;
				update();
				break;
		}
	}

	function next() {
		if (selectedSlot < (slots.len() - 1)) selectedSlot++;
	}

	function prev() {
		if (selectedSlot > 0) selectedSlot--;
	}

	function update() {
		for (local i=0; i<slots.len(); i++) {
			switch (slotType) {
				case "artwork":
				case "image":
				case "text":
					slots[i].index_offset = -(selectedSlot - i);
					break;
				case "preserveImage":
				case "preserveArt":
					slots[i].art.index_offset = -(selectedSlot - i);
					break;
			}

			-(selectedSlot-i)==0 ? select(slots[i]) : deselect(slots[i]);
		}
	}

	function select(slot) {}

	function deselect(slot) {}
}
