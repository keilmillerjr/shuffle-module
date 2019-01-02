class Shuffle {
	slots = null;
	type = null;
	reset = null;
	selected = null;

	constructor(s, t="text", r=true) {
		slots = s;
		type = t;
		reset = r;
		selected = 0;

		fe.add_transition_callback(this, "transitions");
	}

	function transitions(ttype, var, ttime) {
		switch(ttype) {
			case Transition.ToNewSelection:
				var > 0 ? next() : prev();
				update();
				break;
			case Transition.ToNewList:
				if (reset == true) selected = 0;
				update();
				break;
			default:
				update();
				break;
		}
	}

	function next() {
		if (selected < (slots.len() - 1)) selected++;
	}

	function prev() {
		if (selected > 0) selected--;
	}

	function update() {
		for (local i=0; i<slots.len(); i++) {
			switch (type) {
				case "artwork":
				case "image":
				case "text":
					slots[i].index_offset = -(selected - i);
					break;
				case "preserveImage":
				case "preserveArt":
					slots[i].art.index_offset = -(selected - i);
					break;
			}

			(-(selected - i) == 0) ? select(slots[i]) : deselect(slots[i]);
		}
	}

	function select(slot) {

	}

	function deselect(slot) {

	}
}
