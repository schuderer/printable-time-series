# printable-time-series

A 3D-Printable Data Visualization Experiment, currently showing how James Bond movies have changed over time.

timeline.scad can be used to create a time/sequence-based visualization
that is 3D-printable. The visualisation itself is called "data part"
in the code.

It can also be used to create a base/display stand for
the data part, including axes. This base can either be 3D printed
as well, or, cut from materials such as acrylic (recommended).

The functionality depends on Rudolf Huttary's splines library
(slightly modified) for smoothing between the data points:
https://www.thingiverse.com/thing:1208001
(If you prefer no smoothing, you can just provide the
original data everywhere where it uses "dataSmoothed" now)

You need to provide your data in scad format and
link it in the parameters section below.

The parameters section contains information on how
to create such a file from your data and what the
parameters mean.

Here are the steps to create all the parts:
1. Set highQuality to true

2. Create a cached data part:
    1. Set generateDataPart=true, generateBase=false
    2. Set holesForLabels=0
    3. Render (takes ±30min) & save stl in same folder as this file
    4. Change the file name in module dataPartCached() to your STL file name

3. Create the real data part (skip and use previous STL if you don't want label holes)
    1. Set generateDataPart=true, generateBase=false
    2. Set holesForLabels=0.75 (or whatever RADIUS you would like)
    3. Render (takes ±30min) & save stl
    4. For printing, I recommend orienting it so most arcs are as vertical as
       possible. For  support here and there, and some conventional supports
       at the bottomsupports, I use tree supports from Meshmixer, adding
       a little extra for extra stability.

4. Create the base (set generateDataPart=false)
    1. Option A: Laser-cut base (or similar, recommended)
        1. Set generateBase=true,  svgEngrave=true,  svgCut=true
        2. Tweak parameters given to cradleSlots2D() (needs same params everywhere!)
        3. Set generateBase=true,  svgEngrave=true,  svgCut=false
        4. Render & export svg file for engraving/marking
        5. Set generateBase=true,  svgEngrave=false,  svgCut=true
        6. Render & export svg file for engraving/marking
        7. Optionally post-process in Ideamaker (arrange, keep/remove fill color, etc)
    2. Option B: 3D-printed base
        1. Set generateBase=true,  svgEngrave=false,  svgCut=false
        2. Tweak parameters given to cradleSlots2D() (needs same params everywhere!)
        3. Render (takes ±30min) & save stl
        4. Prints well without supports, though pillars might be a bit flimsy


Thanks to Kay Schröder for the data and to Birgit Stolte for many things, particularly getting me up to speed on the topic of laser cutting.
