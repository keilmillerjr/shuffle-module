class Shuffle {
	quantity = null;
	type = null;
	param = null;
	reset = null;
	parent = null;
	
	slots = null;
	
	selected = null;
	
	constructor(q=5, t="text", pm="[Title]", r=true, pt=::fe) {
		quantity = q;
		type = t;
		param = pm;
		reset = r;
		parent = pt;
		
		slots = [];
		for (local i=0; i<quantity; i++) {
			switch (type) {
				case "artwork":
					slots.push(parent.add_artwork(param, -1, -1, 1, 1));
					break;
				case "image":
					slots.push(parent.add_image(param, -1, -1, 1, 1));
					break;
				case "surface":
					slots.push(parent.add_surface(1, 1));
					break;
				case "text":
					slots.push(parent.add_text(param, -1, -1, 1, 1));
					break;
			}
		}
		
		selected = 0;
		
		update();
		
		fe.add_signal_handler(this, "handler");
	}
	
	function handler(signal_str) {
		switch (signal_str) {
			case "prev_page":
			case "next_page":
			case "random_game":
			case "prev_letter":
			case "next_letter":
				update();
				break;
			case "next_game":
				next();
				update();
				break;
			case "prev_game":
				prev();
				update();
				break;
			case "prev_display":
			case "next_display":
			case "next_filter": 
			case "prev_filter":
				if (reset == true) selected = 0;
				update();
				break;
		}
	}
	
	function next() {		
		if (selected < (quantity - 1)) selected++;
	}
	
	function prev() {
		if (selected > 0) selected--;
	}
	
	function update() {
		for (local i=0; i<quantity; i++) {
			slots[i].index_offset = -(selected - i);
			
			if (-(selected - i) == 0) {
				select(slots[i]);
			}
			else {
				deselect(slots[i]);
			}
		}
	}
	
	function select(slot) {
	
	}
	
	function deselect(slot) {
	
	}
}
