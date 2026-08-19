class_name SeasonTheme
extends RefCounted

## Placeholder run tints (P15). Same mood family as Home Stage.


static func bg_modulate(season_id: String) -> Color:
	match season_id:
		"country_bloom":
			return Color(1.0, 1.0, 1.0, 1.0)
		"frost_orchard":
			return Color(0.82, 0.90, 1.05, 1.0)
		"lantern_meadow":
			return Color(0.92, 0.84, 1.06, 1.0)
		"moonlit_warren":
			return Color(0.72, 0.74, 1.08, 1.0)
		"coral_tide":
			return Color(1.06, 0.88, 0.84, 1.0)
		_:
			return Color.WHITE


static func obstacle_modulate(season_id: String) -> Color:
	match season_id:
		"country_bloom":
			return Color(1.0, 1.0, 1.0, 1.0)
		"frost_orchard":
			return Color(0.75, 0.88, 1.12, 1.0)
		"lantern_meadow":
			return Color(0.95, 0.78, 1.1, 1.0)
		"moonlit_warren":
			return Color(0.65, 0.7, 1.15, 1.0)
		"coral_tide":
			return Color(1.12, 0.82, 0.78, 1.0)
		_:
			return Color.WHITE
