extends RefCounted
class_name MetaHubPages

## UX-04 hub carousel — indeksi stranica (Main Menu = centar, indeks 2).

const SHOP := 0
const COLLECTION := 1
const MAIN := 2
const CAMP := 3
const ARENA := 4

const PAGE_COUNT := 5

const PAGE_LABELS: Array[String] = [
	"Shop",
	"Journal",
	"Home",
	"Camp",
	"Arena",
]

## Ikone tabova u res://assets/ui/chrome/ — "<ime>.svg" tamna (na peach), "<ime>_light.svg" svijetla.
const PAGE_ICONS: Array[String] = [
	"tab_shop",
	"tab_journal",
	"tab_home",
	"tab_camp",
	"tab_arena",
]

const PAGE_SCENES: Array[String] = [
	"res://scenes/ui/shop_screen.tscn",
	"res://scenes/ui/collection_journal.tscn",
	"res://scenes/main_menu.tscn",
	"res://scenes/camp/camp_scene.tscn",
	"res://scenes/camp/merge_arena.tscn",
]
