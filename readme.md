This is a TAS/practice mod for the 2008 Nitrome Flash game Toxic 2.

# Basic practice features

If you just play the game normally it should act more or less like the base game, except that various transitions are shortened. Additionally, the `R` button restarts the level and `H` forces a hit.

By default you don't have infinite lives, which could be useful for practicing stuff like death-cancelling, but could also be annoying, especially if you want to use the `H` key to move up vertically. To change that, you can press `M` to bring up the "Main menu", click "Testing vars" and then turn on the "No death" option ("Invulnerability" makes you ignore damage entirely).

In general, you can drag all windows around by clicking and dragging on their title bars, minimize and close them by clicking the respective icons and click on options to select/toggle them. You can look around the various options I added, hopefully it should be clear enough what they do, and also suggest new ones if you want any. Besides the main menu, you can also toggle the visibility of the input string by pressing `I`, variable window by pressing `V` and timer by pressing `T`.

Another thing useful for general practicing is savestates, you can save a state by holding Shift and pressing any number 0-9 and load a state by simply pressing that number. Unfortunately, loading a state can be pretty slow because it plays back inputs from the very beginning each time. Loading a state can desync if the playback is influenced by RNG (to fix that, you can input `r#`, where `#` is any number, at the beginning of the input string, which sets the RNG seed to a specific value), the options at "Testing vars" are set to different values than they were when saving the state, or the playback depends on very specific laser-bomb interactions or other things that depend on the hitTest function (unfortunately not really fixable, it's basically the same thing as why spike glitch doesn't work on the Red Ball 1 TAS mod instant playback).

# TAS controls

## Base TAS controls

`I` toggles the visibility of the input string  

`/` freezes/unfreezes the game in edit mode  
`.` frame advances in edit mode  
`,` frame rewinds in edit mode  

`'` freezes/unfreezes the game in playback mode  
`;` frame advances in playback mode  
`L` frame rewinds in playback mode  

`K` jumps a second ahead in playback mode  
`J` jumps a second back in playback mode  

`R` jumps to the beginning of the string while keeping the current mode  

For most keys above, pressing them while holding Shift alters their behaviour, usually increasing their effect 5 times (like jumping back 5 seconds instead of 1). Holding Shift and pressing the edit mode unfreeze or frame advance buttons will make them do their action in "insert mode", where, if there are inputs behind the playhead in the input string, instead of truncating, the new inputs get inserted inbetween.

Some gameplay convenience keybinds:

`N` decreases the amount of bombs thrown at the start of the next frame  
`P` toggles pause  
`H` forces a hit  

## Other TAS controls

If you are focused on the input field:

`Enter` loads the inputs from the field  
`Esc` or `F1` do the same and unfocus from the input field  
`PgDn` sets the playhead roughly to the current caret position  
`PgUp` or `F12` do the same and unfocus from the input field  

If you're not focused on the input field:

`F2` exits the level to the map screen  
`\` makes the input field scroll to the playhead  
`Delete` truncates the input field after the playhead  
`Shift` + `Delete` splits a letter in half at the playhead  

# Frame offsets

You can press `O` to bring up the offset bars window and the offset string textbox right below the normal input string textbox, type in an offset string, press escape, and you should have the bars for the offset string.

I don't really like the frame offset string format in Red Ball (how they have completely different syntax from TAS strings and how you need to count the frames of the TAS string to get the offset numbers), so I did them a bit differently here: as offsets almost always come from a specific TAS string, the offset string is just a TAS string with marked frame-dependent input spots.

There are two ways to mark frame-dependent inputs:
- the first is to put a comma between an input change, which makes the mod automatically check what inputs in the string changed there and put up bars for them. There are 4 types of input changes for this mode - direction change, up press change, down press change and pause change - and if multiple of them change in the letters surrounding the comma, the mod puts up a bar for each of them(except if one of them is pause change): for example, for `a,e`, you get a bar both for the direction change and the up press change. The advantages of this method of marking is that the mod automatically figures out what inputs changed and the offset works regardless of what key presses or releases are used to do the movement changes in the string(for example, an `a,d` switch can be done by pressing right, pressing D, releasing left or releasing A).

- the second method is putting a dot and one "key letter" after that in the place where the input happens. A "key letter" is a letter that denotes the press or release of a specific gameplay key, and although there's some overlap with the TAS input letters, they're really a different thing(which might be a bit confusing, idk). The "wasd" letters correspond to the same keys, letters "lruv" correspond to the left, right, up and down arrow keys respectively and "b" corresponds to spacebar (throwing a bomb). Lowercase letters denote pressing the key and uppercase letters - releasing the key. Each dot (with letter) gets exactly one input bar, you can also put multiple dots (with letters) between a pair of inputs if you have multiple precise inputs on a frame. The advantages of this method is that in cases where there are a lot of inputs close together, you might get less clutter on the input bars and see the offsets perfectly well regardless of how the inputs made you move in-game(like seeing the inputs even if you got a 0-framer), as well as just being able to define the offset bars exactly as you want, even in ways that conflict with the underlying TAS string(which can be useful sometimes).

For both methods, if you either put the symbol multiple times in a row or put a number after a symbol, the offset bar will display it as a window of the specified size, which starts at the same frame as the frame-perfect position. This is pretty much just a visual change of the input bar, and it can also be used creatively to display things other than windows more intuitively.

## Basic pattern starts

There's one thing that makes frame-perfect setups more complicated in this game than in, say, Red Ball: there are quite a few setups where precise inputs happen not a certain amount of frames since the start, but more like a certain number of frames since reaching a specific, or sometimes not so specific, position. One tool you can use to deal with this is the "pattern start" symbol `>`. If you put one between input letters in the offset string, all frame-dependent markers from this point on until the next pattern start symbol will belong to this pattern(with some edge cases if the offsets are on the same frame as the start symbol). The pattern gets "activated" if you enter more or less the same state (see the next section for more info) as the state you would be in if you played back the TAS string and reached the position where the current start symbol is, and the offset timings are shown according to how many frames have passed since you (last) activated the pattern. Currently, only one pattern can be active at a time, and the offsets before any pattern start symbols are treated as belonging to a pattern that starts on the first frame you can move. Also, if the offset has pattern start symbols, the mod needs to play back the TAS string to find the states corresponding to the start symbols, so the offset string gets copied to the normal input string textbox and automatically played back.

## Advanced pattern starts

With the normal pattern start symbol `>` in offset strings, the pattern activates if you have the same `_x`, `_y`, `vx`, `vy` and `state` values as when the player is in the specified part of the offset string. In addition to that, you can also use the `<>` construct, where inbetween the angled brackets you can specify which of the aforementioned conditions are used and how lenient they are. Each specification starts with a player variable name, like `_x` or `wall_count`, ends with a semicolon `;`, and inbetween, if you:
- write nothing, then activating the pattern doesn't depend on that variable. For example, writing `<_x;>` means the pattern will start if the remaining four variables described earlier match, without caring about the `_x` value.
- write a colon and two numbers separated by a comma, then the condition for matching with that variable is loosened to include all values that are offset by the specified range. For example, writing `<vx:-1,0.5;>` means that instead of the `vx` variable having to match exactly with its value when in the specified position in the offset string, it can be from 1 unit smaller up to 0.5 units bigger.
- write a colon and only one number, then it's similar to the previous case, except that one end of the range is assumed to be 0. For example, typing `<_y:1;>` is the same as `<_y:0,1;>` and `<_x:-0.5;>` is the same as `<_x:-0.5,0;>`.

You can write multiple of those condition modifications in a row for them all to count. You can also write player variable names that aren't one of the predefined five, in which case those variables will also count for determining whether the pattern should be activated (for example, writing `<wall_count:0;>` means that the `wall_count` value also needs to match exactly for the pattern to start). Additionally, some player variables have aliases which you can use instead of their actual names; currently, those are `x` for `_x`, `y` for `_y`, `st` for `state`, `wc` for `wall_count` and `fc` for `fall_count`.

Additionally, you can put a number after the `>` symbol or `<>` construct to signify how many frames earlier the range of states from which the pattern can be activated begins. For example, writing `d20<vy;>6,e` means that the pattern can be activated from 7 different states, starting from the state you reach by `d14` and ending with the state reached by `d20`. This means that if you do `d16e`, the pattern will already be activated and you will see that you jumped 4 frames too early; on the other hand, if you reached the state reached by `d20` in a different way which didn't go through the previous states, the pattern will still start, although then you wouldn't see the offset if you jumped early. Putting a 0 is the same as the standard behavior when not putting anything, which means that only the specified state will start the pattern.
