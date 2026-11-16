# Virtual Reality Modelling - Lab 3

This lab adds sound and particle effects to the first-person breakfast scene from Lab 2. Turn on the lamp, then pick up and place the nine objects in the order shown on screen. The interface shows the current task, inventory and progress.

## Running the project

Open `project.godot` in Godot 4.7 and press **F5**. You can also open `scenes/main.tscn` and press **F6**.

| Control | Action |
| --- | --- |
| WASD / mouse | Move / look around |
| E | Interact with the object under the crosshair |
| E while aiming at the radio | Switch the radio off or on |
| R while aiming at the playing radio | Restart the song |
| Esc | Release the mouse |

## Interaction feedback

All 19 steps have an audio cue. The lamp switch clicks, each pickup produces a short handling sound, and each placement plays a sound at the object's position on the table. For example, the teaspoon makes a metallic clink and the croissant lands with a soft tap. Placing the last item triggers a three-note completion cue.

## Ambient effects

- **At the window (4 effects).** Wind is audible from the start. The first thunderclap comes after six seconds. At ten seconds, raindrops begin falling outside the window and the sound of rain gradually gets louder.
- **Inside the room (3 effects).** The wall clock ticks as its second hand moves, the countertop radio plays music, and dust particles become visible when the player switches on the lamp.

## Credits and AI assistance

The first-person controller is by Jeh3no. Model and texture sources, controller credits and license notices are listed in [links.txt](links.txt).

I used ChatGPT to help implement and debug the guided interactions, inventory and on-screen instructions. For Lab 3, I also used it to build the radio and clock from Godot primitives, set up the particle effects and synthesize the audio clips in Python. I tested the scene in Godot and adjusted the sound levels by ear.
