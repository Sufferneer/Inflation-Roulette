# Character JSON Documentation
This document will be split into two parts; one for gameplay variables, and one for sprite variables.
## Gameplay Variables
Gameplay variables are used for determining the Max Pressure, Skills, and other stats used for actual gameplay. Every character's gameplay variables are stored in `data/characters/<CHARATCER ID>.json`.
### "name"
#### String
The displayed name of the character. Used in Character Cards in the Character Selection menu.
### description
#### String
A short description of the character. Usually includes one sentence of their backstory, and one sentence hinting the character's skill. Used in Character Cards in the Character Selection menu.
### maxPressure
#### Integer
The maximum pressure the character can take before being eliminated. Suggested range to be 1 - 9. Untested on values higher than 10, and may affect animations. Value cannot be 0.
### maxConfidence
#### Integer
The maximum confidence the character can be.
### modifiers
#### (UNSUPPORTED) Key-Value Pairs
Alters the intensity of stat changes. Modifiers can be added via this format:
```json
	"modifiers": {
		"liveShotConfidenceChange": -2
	}
```
Adds modifier that changes the decrease in confidence by  `(1 + (-2)) = `**`-1`** when shooting a live shot.
### skills
#### Array of Objects
Skills can be added via this format:
```json
	"skills": [
		{
			"skill": "reload",
			"cost": 2
		},
		{
			"skill": "sabotage",
			"cost": 3
		}
	]
```
Adds Reload (cost: 2 Confidence) and Sabotage (cost: 3 Confidence).
## Sprite Variables
Sprite variables stores all animation data, and some cosmetic variables. They are stored in<br>`data/characters/sprites/<CHARATCER ID>.json`.
### "spriteSheets"
#### Array of Strings
File name of sprite sheets to be used in the `images/game/characters/<CHARATCER ID>` folder.
### "animations"
#### Array of Objects
Stores animation data for all animations that is used in the game. For a detailed explanation, see [Character Animation Documentation · JSON Animation Format](CHARACTER_ANIMATION_DOCUMENTATION.md#json-animation-format)
### "antialiasing"
#### Boolean
Whether the character's sprites are rendered smoothly.
Set this to `false` for pixelated characters.
### "belchThreshold"
#### (CURRENTLY UNUSED) Integer
At which Pressure value will the character play their belching animation.
### "gurgleThreshold"
#### Integer
At which Pressure value will the character starts playing belly gurgle sounds. Set to -1 to forcefully disable this.
### "creakThreshold"
#### Integer
At which Pressure value will the character starts playing balloon stretching sounds. Set to -1 to forcefully disable this.
### "poppingVelocityMultiplier"
#### Array of Floats
Determines how far and up would the character be launched when the character bursts.
The first value is the X velocity while the second value is the Y velocity.
### "poppingGravityMultiplier"
#### Float
The gravity of the character when the character bursts.
### "originPosition"
#### Array of Integers
The bottom center position of the player relative to the top left corner of the idle sprite.
The first value is the X position while the second value is the Y position.
### "cameraOffset"
#### Array of Integers
How much should the camera be offset when focusing on the character.
The first value is the X position offset while the second value is the Y position offset.
For X, negative values move the camera right; positive values move the camera left.
For Y, negative values move the camera up; positive values move the camera down.
### "poppedCameraOffset"
#### Array of Integers
When popped, how much should the camera be offset when focusing on the character.
The first value is the X position offset while the second value is the Y position offset.
### "pointerOffset"
#### (UNUSED) Array of Integers
# [Back To Main Page](MAIN_PAGE.md)