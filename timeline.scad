///////////////////////////////////////////////
// Time Line of James Bond Movies
//
// A 3D-Printable Data Visualization Experiment
//
// Andreas Schuderer, created 6 August 2018
// Last modified 15 September 2018
//
// Thanks to Kay Schröder for the data
// and to Birgit Stolte for many things,
// particularly getting me up to speed on
// the topic of laser cutting.
///////////////////////////////////////////////

// Get the tjw-scad library here: https://github.com/teejaydub/tjw-scad
use <tjw-scad/spline.scad>

//////////// How To Use ///////////////////////

/*

This file can be used to create a time/sequence-based visualization
that is 3D-printable. The visualisation itself is called "data part"
in the code.

This file can also be used to create a base/display stand for
the data part, including axes. This base can either be 3D printed
as well, or, cut from materials such as acrylic (recommended).

The functionality depends on teejaydub's splines implementation
for smoothing between the data points:
https://github.com/teejaydub/tjw-scad
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
2.1 Set generateDataPart=true, generateBase=false
2.2 Set holesForLabels=0
2.3 Render (takes ±30min) & save stl in same folder as this file
2.4 Change the file name in module dataPartCached() to your STL file name

3. Create the real data part (skip and use previous STL if you don't want label holes)
3.1 Set generateDataPart=true, generateBase=false
3.2 Set holesForLabels=0.75 (or whatever RADIUS you would like)
3.3 Render (takes ±30min) & save stl
3.4 For printing, I recommend orienting it so most arcs are as vertical as
    possible. For  support here and there, and some conventional supports
    at the bottomsupports, I use tree supports from Meshmixer, adding
    a little extra for extra stability.

4. Create the base (set generateDataPart=false)
4A. Option A: Laser-cut base (or similar, recommended)
4A.1 Set generateBase=true,  svgEngrave=true,  svgCut=true
4A.2 Tweak parameters given to cradleSlots2D() (needs same params everywhere!)
4A.3 Set generateBase=true,  svgEngrave=true,  svgCut=false
4A.4 Render & export svg file for engraving/marking
4A.5 Set generateBase=true,  svgEngrave=false,  svgCut=true
4A.6 Render & export svg file for engraving/marking
4A.7 Optionally post-process in Ideamaker (arrange, keep/remove fill color, etc)
4B. Option B: 3D-printed base
4B.1 Set generateBase=true,  svgEngrave=false,  svgCut=false
4B.2 Tweak parameters given to cradleSlots2D() (needs same params everywhere!)
4B.3 Render (takes ±30min) & save stl
4B.4 Prints well without supports, though pillars might be a bit flimsy

*/
//////////// Parameters ///////////////////////

// False is quicker to work with. True means high quality.
// Set this to true before rendering!
highQuality = true;

// What parts to create
generateDataPart = true;
generateBase = false; // Only either render (or print) the data part or the base, not both at the same time
svgEngrave = false; // Base only: generate engraving pattern instead of 3d printable base
svgCut = false; // Base only: generate cutting pattern instead of 3d printable base

// Text
font = "Liberation Sans:style=Bold"; //"Stencil:style=Regular";
xLabel = "VIOLENCE";
yLabel = "SEX";
zLabel = "RECEPTION";
fontSize=8;

// Data source
include <bonddata.scad> // provides "data" variable with vector of vectors.

// To create this format in Excel, simply concatenate the
// columns using Excel formulas, for example like this:
//     A    B    C   D   E <- this column contains the formula
//   ----------------------
// 1| your data below   data = [ 
// 2| 0.9    7  0.5     ="[" & A2 & "," & B2 & "," & C2 & "],"
//    ...  ...  ...        ...
//98| 0.1   15  0.4     ="[" & A98 & "," & B98 & "," & B98 & "]"
//99|                   ];
// In this example, you would copy the contents of column E into your
// exampledata.scad file.

// Data mappings
// Which physical property to use for which column
// (if your data has less than 4 dimensions, you need to create one 
//  column with dummy data, e.g. the number 1 in each row)
xColumn = 0; // use 0th data column for x position
yColumn = 1;
zColumn = 3;
radiusColumn = 2;

// mapping of data ranges to edges of board (no automatic deletion of data beyond that)
xMin = 0; // value or "auto" (= minimum value found in data)
yMin = 1;
zMin = 0.25;
xMax = "auto"; // value or "auto" (= minimum value found in data)
yMax = "auto";
zMax = 1.1;

// Physical dimensions

// data part specific/general
compensateForScaling = 1.0; // planned re-scaling after export - will compensate cutout measurements that depend on material thickness and label hole diameter
holesForLabels = 0.75; // put vertical holes in data part, radius in mm (0 = no holes)

// base specific (also used for scaling the x, y and z axes)
boardWidth=160; // along x axis
boardDepth=120; // along y axis
zAxisHeight = 90; // only relevant for svg base
zAxisWidth = fontSize*4; // only relevant for svg base
radiusScale = 1/7500000; // a value of 1 times this factor will be represented as one square millimeter of cross-sectional area, because A = r^2 * pi
materialThickness = 4; // thickness of svg-cut material
slotLength = 6; // length of assembly slots in svg-cut material (if something stops working, this number might be too high with respect to the other dimensions)

// distance to keep from base edges
paddingLeft = 10;
paddingRight = 10;
paddingFront = 25;
paddingBack = 10;
paddingBottom = 10;
paddingTop = 5;

boardHeight=4; // thickness, only relevant for 3D printable base
embossHeight=0.5; // only relevant for 3D printable base

// In order to create the base, you need to export the data part as STL file
// and then change this file name accordingly. This speeds up things a lot.
module dataPartCached() import("timeline3.3_no_label_holes.stl");

//////////// Derived Parameters ///////////////////////

subdivisions = highQuality ? 4 : 2;

// todo: get only mapped data (and so that we don't do a lookup inside the lookup later)
smoothedData = smooth(getCols(data, [0,1,2,3]), subdivisions, false);

material = materialThickness/compensateForScaling;
filletR = material;
holes = holesForLabels/compensateForScaling;

dataT = transpose(data);
_xMin = xMin == "auto" ? min(dataT[xColumn]) : xMin;
_yMin = yMin == "auto" ? min(dataT[yColumn]) : yMin;
_zMin = zMin == "auto" ? min(dataT[zColumn]) : zMin;
_xMax = xMax == "auto" ? max(dataT[xColumn]) : xMax;
_yMax = yMax == "auto" ? max(dataT[yColumn]) : yMax;
_zMax = zMax == "auto" ? max(dataT[zColumn]) : zMax;
echo("Mins:", _xMin, _yMin, _zMin, "Maxs:", _xMax, _yMax,_zMax);

xRange = (_xMax - _xMin);
yRange = (_yMax - _yMin);
zRange = (_zMax - _zMin);
xScale = (boardWidth-paddingLeft-paddingRight)  / xRange;
yScale = (boardDepth-paddingFront-paddingBack)  / yRange;
zScale = (zAxisHeight-paddingBottom-paddingTop) / zRange;
echo("Spans:",xRange, yRange, zRange);
echo("Scales:",xScale, yScale, zScale);

function coords(d) = [
    paddingLeft   + (d[xColumn]-_xMin)*xScale,
    paddingFront  + (d[yColumn]-_yMin)*yScale,
    paddingBottom + (d[zColumn]-_zMin)*zScale
];
function radius(p) = sqrt(p[radiusColumn]*radiusScale)/PI; // as A = r^2 * pi
/*function lerp(a, b, fraction) = a + fraction * (b-a);
function map(x, minA, maxA, minB, maxB) =  
    minB + (maxB - minB)/(maxA - minA) * (x - minA);
*/

//////////// Rendering ////////////////////////////////
                        
//module dataPartCached() import("timeline3.3grob.stl");
//projection(cut=true) translate([-20,-100,-50]) dataPartCached();

//echo(smoothedData);
/*translate(coords(smoothedData[0])) sphere(3);
translate(coords(smoothedData[1])) sphere(3);
translate(coords(smoothedData[2])) sphere(3);
translate(coords(smoothedData[3])) sphere(3);
translate(coords(smoothedData[4])) sphere(3);
translate(coords(smoothedData[5])) sphere(3);
translate(coords(smoothedData[6])) sphere(3);
translate(coords(smoothedData[7])) sphere(3);
translate(coords(smoothedData[8])) sphere(3);
translate(coords(smoothedData[9])) sphere(3);*/
/*for (i=[0:1:len(smoothedData)-1]) {
    p = coords(smoothedData[i]);
    if (i%2==0)
        translate(p) sphere(3);
    else
        color([0,0,1]) translate(p) sphere(3, $fn=10);
}*/ // works when re-imported as stl in lo-q
//dataPoints(data, smoothedData); // works when re-imported as stl in lo-q
//dataSausage(smoothedData); // works when re-imported as stl in lo-q
//dataPart(data, smoothedData); // DOES NOT WORK when re-imported as stl in lo-q



// Base/Scaffolding -- print/cut this separately from the data part further below
if (generateBase) {
    if (svgCut) {
        // Create base with slots
        difference() {
            base2D(boardWidth=boardWidth, boardDepth=boardDepth);
            cradleSlots2D(data, minDistance=20, step=2, piecesToExclude=[]);
            translate([boardWidth-zAxisWidth-material, boardDepth-material*2, 0]) 
                difference() {
                    square(size=[zAxisWidth, material]);
                    zAxis2DSlots();
                }
        }
        // Create vertical axis
        xOffset = boardWidth+material;
        translate([xOffset, 0, 0]) zAxis2D();
        
        // Create cradle pieces
        cradles2D(data, minDistance=20, step=2, arrangeDistance=35, tolerance=0.5, piecesToExclude=[]);
    }
    if (svgEngrave) {
        color([0,0,1.0]) baseText2D(boardWidth=boardWidth, boardDepth=boardDepth, fontSize=fontSize, zAxisHeight=zAxisHeight, zAxisWidth=zAxisWidth);
        // in this mode only creates numbering of pieces:
        if (!svgCut) {
            cradles2D(data, minDistance=20, step=2, arrangeDistance=35, tolerance=0.5, piecesToExclude=[]);
             cradleSlots2D(data, minDistance=20, step=2, piecesToExclude=[]);    }
    }
    if (!svgCut && !svgEngrave) {
        base(boardWidth=boardWidth, boardDepth=boardDepth, boardHeight=boardHeight, embossHeight=embossHeight, fontSize=fontSize);
        scaffolding(data, smoothedData, thickness=2.5, minDistance=20, step=2);
    }
    else {
        // frame to help align engraving & cut pattern later
        translate([-2, boardDepth+1]) square(size=[10,1], center=false);
        translate([-2, boardDepth-10+1]) square(size=[1,10], center=false);
    }
}

// Data part. Print this separately from the base.
if (generateDataPart) {
    dataPart(data, smoothedData);
}






module zAxis2D() { // todo: round off with params etc.
    difference() {
        offset(r = filletR) offset(delta = -filletR)
            square(size=[zAxisWidth, zAxisHeight+material]);
        // connection to base:
        zAxis2DSlots();
    }
}

module zAxis2DSlots() {
    spacing = (zAxisWidth-2*slotLength)/3;
    translate([0, 0]) square(size=[spacing, material]);
    translate([spacing+slotLength, 0]) square(size=[spacing, material]);
    translate([2*(spacing+slotLength), 0]) square(size=[spacing, material]);
}



//////////// Functions & Modules /////////////

function dist(a,b) = sqrt(pow(a[0]-b[0],2)+pow(a[1]-b[1],2)+pow(a[2]-b[2],2));
function debug(s) = search(s,[]);
function transpose(m) =
  [ for(j=[0:len(m[0])-1]) [ for(i=[0:len(m)-1]) m[i][j] ] ];

function nextSmoothed(origIdx, smoothedData, step=1) =
    let(newIdx = origIdx * pow(2,subdivisions) + step)
    newIdx <= len(smoothedData)-1 ? smoothedData[newIdx] : smoothedData[len(smoothedData)-1];

//https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#rotate
function rotation(p1, p2) =
    let(x=p2[0]-p1[0], y=p2[1]-p1[1], z=p2[2]-p1[2],
        length = norm([x, y, z]),
        b = acos(z/length),
        c = atan2(y, x))
    [0, b, c];

function getCols(matrix, indices) =
    [for (row=matrix)
        [for (i=indices) row[i]]
     ];

function findPointsBelow(pointIndex, inPoints, tolerance=1, ignoreNeighbors=true) =
    let(p = inPoints[pointIndex])
    [for (i=[0:1:len(inPoints)-1])
        let(p2=inPoints[i])
        if (!(ignoreNeighbors && i>=pointIndex-1 && i<=pointIndex+1) &&
            p2[0] <= p[0]+tolerance && p2[0] >= p[0]-tolerance &&
            p2[1] <= p[1]+tolerance && p2[1] >= p[1]-tolerance &&
            p2[2] <  p[2]) p2
     ];

// plot one single point in the (smoothed) path
module point(p)
    sphere(radius(p), $fn=highQuality?20:10);

// plot one "real" data point (a non-smoothed point), have it point in the direction of the next (smoothed) point. If you only use non-smoothed data, provide the same array for data and smoothedData.
module dataPoint(i, data, smoothedData) {
    p = data[i];
    pos = coords(p);
    r = radius(p);
    rot = (i == len(data)-1) ?
        rotation(coords(nextSmoothed(i, smoothedData, step=-1)), pos) :
        rotation(pos,coords(nextSmoothed(i, smoothedData)));
    translate(pos)
        rotate(rot) {
            // object as such
            cylHeight = r*2.5;
            baseRad = r*1.6;
            tipRad = r*1.5;
            totalHeight = cylHeight + tipRad;
            translate([0,0,cylHeight/2-totalHeight/2]) { // center whole thing
                cylinder(h=cylHeight, r1=baseRad, r2=tipRad, center=true, $fn=highQuality?20:10);
                translate([0,0,cylHeight/2]) // move tip up
                    sphere(tipRad, center=true, $fn=highQuality?20:10);
            }
        }
}

// Plot the (smoothed) path for "data"
module dataSausage(data) {
    positions = [for (d=data) coords(d)];
    for (i=[0:1:len(data)-2]) {
        col = i/(len(data)-1)/2+0.5;
        this = data[i];
        next = data[i+1];
        thisPos = positions[i]; //coords(this);
        nextPos = positions[i+1]; //coords(next);
        color([col, col, col]) hull() {
            translate(thisPos) point(this);
            translate(nextPos) point(next);
        }
    }
}

// Plot all (real, non-smoothed) data points in "data"
module dataPoints(data, smoothedData) {
    for (i=[0:1:len(data)-1]) {
        dataPoint(i, data, smoothedData);
    }
}

// Plot both sausage + data points
module dataPart(data, smoothedData) {
    difference() {
        union() {
            dataSausage(smoothedData);
            dataPoints(data, smoothedData);
        }
        if (holes>0)
            for (d=data)  {
                p = coords(d);
                r = radius(d);
                translate(p)
                    cylinder(h=2*r*3, r=holes, center=true, $fn=highQuality?16:8);
            }
    }
}



// Plot support walls
module placeWalls(data, width=2, steps=5, arc=3) {
    function level(i, steps=10) = 
        let(realSteps=steps+1)
        max(0, 
            floor(i/realSteps)%2==0 ? 
                (i%realSteps)-1 : 
                realSteps-((i%realSteps)+1));
    positions = [for (d=data) coords(d)];
    for (i=[0:1:len(positions)-2]) {
        p1 = positions[i];
        p2 = positions[i+1];
        //pointsBelow = findPointsBelow(i, positions, tolerance=3);
        //if (len(pointsBelow) == 0) {
        currHeight = (1-pow(1.0-level(i, steps)/steps, arc)) * 0.9 * p1[2];
        nextHeight = (1-pow(1.0-level(i+1, steps)/steps, arc)) * 0.9 * p2[2];
        supportSlab(p1, p2, width, height1=currHeight, height2=nextHeight);
        //}
    }
}
module supportSlab(p1, p2, thickness, height1=0, height2=0) {
    x = p2[0] - p1[0];
    y = p2[1] - p1[1];
    z1 = p1[2];
    z2 = p2[2];
    length = norm([x, y])+0.5; // 0.5 to create some overlap between slabs
    zAngle = atan2(y, x);
    translate([p1[0], p1[1]])
        rotate([90,0,zAngle])
            translate([0, 0, -thickness/2])
                linear_extrude(thickness)
                    polygon(points= [
                                    [0, height1], // bottom left corner
                                    [length, height2], // bottom right corner
                                    [length, z2], // top right corner
                                    [0, z1] // top left corner
                            ]);
}

// Plot support pillars
module placePillars(data, width=2, minDistance=6) {
    positions = [for (d=data) coords(d)];
    for (i=[0:1:len(positions)-1]) {
        thisPos = positions[i];
        pointsBelow = findPointsBelow(i, positions, tolerance=minDistance);
        if (len(pointsBelow) == 0) {
            translate([thisPos[0], thisPos[1], thisPos[2]/2]) cube(size=[width,width,thisPos[2]], center=true);
        }
    }
}

// Find suitable positions for support.
//    positions = vector of 3d-points of which a selection will be returned
//    minDistance = only consider points where no other below point is not nearer than this (in x/y direction)
//    step = one means consider every point, two means every other point, etc.
//    pointsToExclude = vector of indices (0, 1, etc.) of points to throw out of list
function cradleIndices(positions, minDistance=20, step=1, pointsToExclude=[]) =
    let(rawIndices = [for (i=[0:step:len(positions)-1])
         let(pointsBelow = findPointsBelow(i, positions, tolerance=minDistance))
         if (len(pointsBelow) == 0)
         i])
     [for (i=[0:1:len(rawIndices)-1])
         if (len(search(i, pointsToExclude)) == 0)
         rawIndices[i]];

// Plot holders for the dataPart (dataPart still has to be subtracted from them) 
module placeCradles(data, smoothedData, thickness=2.5, minDistance=20, step=1) {
    positions = [for (d=data) coords(d)];
    indices = cradleIndices(positions, minDistance=minDistance, step=step); 
    for (i=indices) {
        thisPos = positions[i];
        columnHeight = thisPos[2]-thickness;
        r = radius(data[i]);
        columnWidth = max(thickness, r*2/3);
        translate([thisPos[0], thisPos[1], -thickness])
            union() {
                translate([0,0, columnHeight/2+thickness]) 
                        cylinder(h=columnHeight,r=columnWidth, center=true);
                translate([0,0, columnHeight])
                    scale(2)
                    difference() {
                        sphere(r, $fn=8);
                        translate([0,0,r]) cube(size=[r*2,r*2, r*2], center=true);
                    }
            }
    }
}

// Finish scaffolding (substract dataPart from cradles)
module scaffolding(data, smoothedData, thickness=2.5, minDistance=20, step=2) {
    difference() {
        placeCradles(data, smoothedData, thickness=thickness, minDistance=minDistance, step=step);
        //dataPart(data, smoothedData);
        dataPartCached();
    }
}

module base(boardWidth, boardDepth, boardHeight, embossHeight, fontSize = 15) {
    difference() {
        linear_extrude(boardHeight)
            base2D(boardWidth, boardDepth);
        translate([0,0,boardHeight-embossHeight])
            linear_extrude(embossHeight)
                baseText2D(boardWidth, boardDepth, fontSize);
    }
}

module base2D(boardWidth, boardDepth) {
    r = material;
    offset(r = filletR) offset(delta = -filletR) // create fillet
        //translate([r,r,0])
            square(size=[boardWidth, boardDepth]);
}

module baseText2D(boardWidth, boardDepth, fontSize = 15, zAxisHeight = 0, zAxisWidth = 0) {
    sizeFactor = fontSize / 15;
    axisFontSize = fontSize;
    valueFontSize = 10 * sizeFactor;
    tickMarkWidth = 2 * sizeFactor;
    majorTickMarkLength = 18 * sizeFactor;
    minorTickMarkLength = 10 * sizeFactor;
    
    for (axis = [0, 1, 2]) { // 0 = x, 1 = y, 2 = z
        // Determine which data belongs to this axis
        range = axis == 0 ? xRange :
                axis == 1 ? yRange :
                axis == 2 ? zRange : undef;
        _min  = axis == 0 ? _xMin :
                axis == 1 ? _yMin :
                axis == 2 ? _zMin : undef;
        _max  = axis == 0 ? _xMax :
                axis == 1 ? _yMax :
                axis == 2 ? _zMax : undef;
        label = axis == 0 ? xLabel :
                axis == 1 ? yLabel :
                axis == 2 ? zLabel : undef;
        boardDim = axis == 0 ? boardWidth :
                   axis == 1 ? boardDepth :
                   axis == 2 ? zAxisHeight : undef;
        echo("input: ",range, boardDim, _min, _max);
        
        // Guess a good tick interval (tick size)
        noTicks = 0.3 * sqrt(boardDim);
        delta = range/noTicks;
        dec = -floor(log(delta) / log(10));
        magn = pow(10, -dec);
        _norm = delta/magn; // between 1.0 and 10.0
        
        echo(noTicks, delta, dec, magn, _norm);
        
        tickSize = magn * (
               _norm < 1.5  ?   1 :
               _norm < 2.25 ?   2 :
               _norm < 3    ?   2.5 :
               _norm < 7.5  ?   5 : 10);
        tickDecimalsFactor = pow(10, max(0, dec));
        
        echo(tickSize, tickDecimalsFactor);
        
        // Draw the axis
        numDataCols = len(data[0]);
        direction =   axis == 0 ? 1 : -1;
        rotation =    axis == 0 ? [0,0,0] : [0,0,-90];
        translation = axis == 2 ? [boardWidth+material,material,0] : [0,0,0];
        translate(translation) rotate(rotation) {
            for (major=[_min:tickSize:_max+0.0001]) {
                c = coords([for(i=[1:1:numDataCols]) major])[axis];
                translate([direction*(c-tickMarkWidth/2),0,0])
                    square(size=[tickMarkWidth, majorTickMarkLength], center=false);
                translate([direction*c,majorTickMarkLength*1.2,0])
                    text(str(major), size=valueFontSize, font=font, halign="center");
                minorTickSize = tickSize/5;
                for (minor=[max(_min+minorTickSize,major-tickSize+minorTickSize):minorTickSize:major-minorTickSize+0.0001]) {
                    c = coords([for(i=[1:1:numDataCols]) minor])[axis];
                    translate([direction*(c-tickMarkWidth/2),0,0])
                        square(size=[tickMarkWidth, minorTickMarkLength], center=false);
                }
            }
            translate([direction*(boardDim-axisFontSize),(majorTickMarkLength+valueFontSize)*1.5,0])
                text(label, size=axisFontSize, font=font, halign=direction==1?"right":"left");
        }
    }
}


// slots for 2d supports
module cradleSlots2D(data, minDistance=20, step=2, piecesToExclude=[]) {
    p = [for (d=data) coords(d)];
    indices = cradleIndices(p, minDistance=minDistance, step=step, pointsToExclude=piecesToExclude);
    for (i=[0:1:len(indices)-1]) {
        thisIndex = indices[i];
        thisPos = p[thisIndex];
        if (svgCut)
            translate([thisPos[0], thisPos[1], 0])
                square(size=[material, slotLength], center=true);
        // help find matching cradles and slots
        #if (svgEngrave) translate([thisPos[0], thisPos[1]+4, 0]) text(str(i), size=4, font=font, halign="center");
    }
}

/// 2d supports for laser cutting
// piecesToExclude = []; // which pieces (0th, 1st, 2nd, ...) to exclude
// arrangeDistance = 45; // distance between parts
// tolerance = 0.5; // make cradles this much larger, in mm. Without tolerance, the concave/open cradle shapes will push the dataPart up
module cradles2D(data, minDistance=20, step=2, arrangeDistance=45, tolerance=0.5, piecesToExclude=[]) {
    p = [for (d=data) coords(d)];
    indices = cradleIndices(p, minDistance=minDistance, step=step, pointsToExclude=piecesToExclude);
    for (i=[0:1:len(indices)-1]) {
        thisIndex = indices[i];
        thisPos = p[thisIndex];
        r = radius(data[thisIndex]);
        h = thisPos[2];
        
        // Columns
        translate([(i+0.5)*arrangeDistance,-50,0]) { // arrange the pieces
            if (svgCut) difference() {
                offset(r = filletR/2) offset(delta = -filletR/2) // fillets
                offset(r = -filletR*2) offset(delta = filletR*2)
                polygon(points=[
                    [0, 0], // top center (will be intersected with data part)
                    [-max(6,r*4), 0], // top left corner
                    [-6, -max(10,r*4+6)], // top left end of diagonal
                    [-6, -h+12+material], // bottom left start of diagonal
                    [-12, -h], // bottom left corner
                    [ 12, -h], // bottom right corner
                    [ 6, -h+12+material], // bottom right end of diagonal
                    [ 6, -max(10,r*4+6)], // top right start of diagonal
                    [ max(6,r*4), 0], // top right corner
                ], convexity=5);
                // cut out slits for assembly
                translate([-material/2,-r*4,0]) square(size=[material,r*4], center=false);
                translate([-12,-h-1]) square(size=[12-slotLength/2,material+1]);
                translate([slotLength/2,-h-1]) square(size=[12-slotLength/2,material+1]);
                projection(cut=false) // cut out dataPart at this point
                    scale((r+tolerance)/r) // create tolerances
                        intersection() {
                            rotate([-90,-90,0]) translate(-thisPos) dataPartCached();
                            cube(size=[1000,1000,material], center=true);
                        }
            }
            // help find matching cradles and slots
            #translate([0,-h+1,0]) text(str(i), size=4, font=font, halign="center");
        }
        
        echo("cutting out piece",i);
        
        // 90 degrees cradle top pieces
        translate([(i+0.5)*arrangeDistance,-material,0]) // arrange the pieces
            if (svgCut) difference() {
               offset(r = filletR/2) offset(delta = -filletR/2) // fillets
               offset(r = -filletR*2) offset(delta = filletR*2)
               polygon(points=[
                    [0, 0], // top center
                    [-max(6,r*4), 0], // top left corner
                    [-material,-max(18,r*5+6)], // bottom left corner
                    [ material,-max(18,r*5+6)], // bottom right corner
                    [ max(6,r*4), 0], // top right corner
                ], convexity=5);
                projection(cut=false) // cut out dataPart at this point
                    scale((r+tolerance)/r) // create tolerances
                        intersection() {
                            rotate([-90,0,0]) translate(-thisPos) dataPartCached();
                            cube(size=[1000,1000,material], center=true);
                        }
                // cut out slit for assembly
                translate([-material/2,-max(18,r*5+6)-1,0]) square(size=[material,max(18,r*5+6)-r*4+1], center=false);
            }
    }
}
