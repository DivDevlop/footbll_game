extends Node

var game_mode := "5v5"
var difficulty := "Normal"

var last_match_time : float = 0.0
var last_match_winner : String = ""


var team_scores := {
	"LEFT TEAM": 0,
	"RIGHT TEAM": 0
}
