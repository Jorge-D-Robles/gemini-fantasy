## Static utilities for the defeat screen options.
## All methods are pure functions — testable without the scene tree.


## Returns available recovery options shown on the defeat screen.
## has_save: whether a save file exists for slot 0.
## Returns Array of {label: String, action: String} dicts.
## Actions: "load" (load last save), "quit" (return to title).
static func compute_defeat_options(has_save: bool = false) -> Array[Dictionary]:
	var opts: Array[Dictionary] = []
	if has_save:
		opts.append({"label": "Load Last Save", "action": "load"})
	opts.append({"label": "Return to Title", "action": "quit"})
	return opts
