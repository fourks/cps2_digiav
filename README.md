CPS2 digital AV interface (Rev 2 - CPS3 branch)
==============

Features (current)
--------------------------
* framelocked 1080p@59.60Hz output with max. 40 scanline latency
* 24bit/48kHz audio output
* supports CPS3 standard and widescreen modes

TODO
--------------------------
* OSD/UI
* resolution select
* more scanline options
* settings store / profiles

Installation
--------------------------
The add-on board can be installed on top of CPS3 board, preferably close to JAMMA connector. The following additional parts are required:
* 2pcs 0603 10k SMD resistors and TL2243 switch (or 2 external buttons connecting "vol+" and "vol-" pads to GND when pressed)
* ribbon cable (~15cm, at least 5x4=20 conductors)
* coaxial cable (~50cm total)
* kynar wire (~50cm total)

Signal hookup points are listed in pcb/doc/cps3_hookup_points.txt and instructions are in pcb/doc/install.md .

Usage
--------------------------
Board is controlled via TL2243 (or via 2 external buttons depending on installation):
* Upper button (VOL-): change vertical offset (0-8, default=4)
* Lower button (VOL+): enable/disable scanlines

More info and discussion
--------------------------
* [Forum topic](http://shmups.system11.org/viewtopic.php?f=6&t=59479&p=1266977)
