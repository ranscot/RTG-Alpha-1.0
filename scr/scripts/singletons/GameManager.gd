extends Node

# This creates our custom vocabulary for the engine
enum GameState {
	TITLE,
	CUTSCENE,
	PLAYING,
	PAUSED
}

# The game always boots up on the Title Screen
var current_state: GameState = GameState.TITLE

# The universal function that everything in your game will use to switch states
func change_state(new_state: GameState):
	current_state = new_state
	
	# A helpful debug print so we can watch the states change in the console
	print("State changed to: ", GameState.keys()[current_state])
	
	# (We will add the actual scene-swapping logic here in a minute!)
