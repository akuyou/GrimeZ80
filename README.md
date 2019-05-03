# GrimeZ80

Grime is an old DOS top-down shooter game, developed by Mark Elendt and
released in 1984.

[GrimeZ80](http://www.chibiakumas.com/z80/grimez80.php) is a re-creation for
8-bit computer systems based on the Z80 processor. It has been written to be
cross-platform, running on 11 different systems including the Amstrad CPC,
ZX Spectrum, MSX1, MSX2, Enterprise, Sam Coupe, TI-83 calculator, Gameboy,
Gameboy Color, Sega Master System, and Sega Game Gear!

It was developed in 2018 over 7-days as part of the ChibiAkumas Z80 programming
tutorials, and has been made available here in the hope that others can learn
from these techniques to develop their own cross-platform games.

Along with the code itself, there is also a series of videos featuring an
overview of the development for each of the 7 days. These can be found on
[YouTube](https://www.youtube.com/playlist?list=PLp_QNRIYljFqwHWKzqpOcYl4bq6RUrvu4).


## Grime: The Game

_A deadly, all-consuming mold has emerged from the polluted swamp, spawned from
toxic chemical waste, and engulfing everything in its path with venomous grime.
Go forth in your herbicide-spewing Herbmobile, and destroy the mold colonies
which are threatening the town of Spudville._

_The game is similar in style to Centipede and its variants, but distinct in
some gameplay mechanics. Your vehicle can move throughout the entire playing
field, shoot in four directions, and toggle an auto-fire mode. Battle the
expanding patches of grime, the mutated wildlife, and the spores that
continuously deposit new colonies of mold. [text source: MobyGames]_

**Keyboard controls:**

    W - Up
    A - Left
    S - Down
    D - Right

    B - Rotate Left
    N - Rotate Right

    P - Pause
    ENTER - resume from pause


## Compile and run

Compile the file `GrimeZ80.asm` with [`vasm`](http://sun.hasenbraten.de/vasm/)
or an equivalent assembler.

Using `vasm` _Old Style_ running on a Unix based OS, the game can be compiled
for the **ZX Spectrum** with the following process:

First, edit `GrimeZ80.asm` and uncomment line 7 (remove the `;`):

    BuildZXS equ 1 ; Build for ZX Spectrum

Then type the following commands in your terminal:

    $ cd GrimeZ80/Sources
    $ vasmz80_oldstyle GrimeZ80.asm -chklabels -nocase -Dvasm=1 -Fbin -o grime.z80 -L grime.txt


To run the game with the `FUSE` ZX Spectrum emulator:

  * Select menu: `File -> Import Binary Data` and load the data to address `32768`.
  * In the emulator type: `RANDOMIZE USR 32768`.


## Resources

There is a series of videos discussing this game on the YouTube channel:
https://www.youtube.com/playlist?list=PLp_QNRIYljFqwHWKzqpOcYl4bq6RUrvu4

and a summary of how the code works here:
https://youtu.be/xNUN43k6XMs

and a small website showing it playing:
http://www.chibiakumas.com/z80/grimez80.php


Copyright (c) 2018 Keith Sear
