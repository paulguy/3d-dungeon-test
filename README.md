3D Dungeon Test
===============

Description
-----------
This is a visual test/demonstration/mockup of those 4 directional 3D
perspective dungeon crawler style games, except this does actually use 3D
because that's just easier and more efficient on modern computers.  It also
supports tinting surfaces and blending between the top and bottom of wall
textures, as well as variable height ceilings and floors.

Screenshots
-----------
![Screenshot 1](screen1.png)
![Screenshot 2](screen2.png)
![Screenshot 3](screen3.png)
![Screenshot 4](screen4.png)
![Screenshot 5](screen5.png)

Controls
--------
### General
W, S, A, D - move forward/back, strafe left/right
Q, E - turn counter clockwise/clockwise
F6 - Toggle play/edit mode

### Play
no additional controls

### Editor
```
Shift - fast modify value, alternate function
Ctrl - slow modify value
Z, X - Raise and lower view height, normally 1/10 of a block.  Holding shift
       will raise or lower by a whole block and control will raise or lower by
       1/100th.
C - Toggle between attaching to ceiling or floor.  When moving, the distance
    will remain constant with the selected face in whatever cell is moved to.
U - cycle between "ceiling" and "floor" mesh
    for bias or hue, this affects the face that's shown in the default
    arrangement of the ceiling mesh being above the floor mesh
        ceiling - changes bottoms of both
        floor - changes tops of both
I - cycle between wall (vertical) or horizontal faces
O - cycle between top or bottom face or the top or bottom part of the wall
    this affects height and texture offset
P - cycle between parameters
    height - Y position of the selected face
    hue - hue from 0.0 and 1.0
          0.0 is white, then red yellow green cyan blue purple
    bias - 1.0 no change in brightness
           < 1.0 darken by multiplying
           > 1.0 brighten by addition (desaturate)
    offset - texture offset in texture strip.  each 1.0x is 1 width unit going
             down
    fog color r
    fog color g
    fog color b - color of distance fog
    fog power - power the fog intensity is raised to
J, K - decrease/increase parameter.  Parameters will be increased or decreased
       by default at some "sensible" rate, usually 0.1, except offset which is
       by 1/8 by default.  Holding shift will change all values by 1.0 and
       control will change values by some slower sensible rate, typically
       except offset which is 1/64.
M - Capture value of currently selected attribute.  Hold shift to apply a
    captured value.
L - Enter/change the captured value which would be used directly.
Y - Capture ceiling wall hues, biases and offset values.  Hold shift to apply
    the captured values.
H - Capture selected horizontal face (ceiling or floor) hue, bias and offset
    value.  Hold shift to apply.
N - Capture floor wall hues, biases and offset values.  Hold shift to apply.
B - Capture height values of ceiling and floor mesh tops and bottoms.  Hold
    shift to apply.

    All modified values will be relative to the horizontal faces in the
    neighboring cell which is in the direction being looked at and walls which
    are on the side directly on that neighboring cell facing the view.

F5 - Save map data to file.  A prompt for a name will come up.  It will be
     saved to this game's user storage location.
F8 - Load map data from file.  A prompt for a name will come up.  It loads
     from this game's user storage location.
```
