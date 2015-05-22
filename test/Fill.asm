// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

(LOOP)
    @SCREEN
    D=A
    @addr
    M=D         // addr = 16384 (base address of the Hack screen)
(KDBEVENT)
    @KBD
    D=M
    @SCR_BLACK
    D;JGT       // if any key is pressed (>0), jump to SCR_BLACK
    @SCR_WHITE
    D;JEQ       // else if no key pressed (=0) jump to SCR_WHITE
    @KDBEVENT
    0;JMP       // Goto KDBEVENT
(SCR_BLACK)
    @bgcolor    // index of screen position
    M=-1        // color: -1 (-1=11111111111111)
    @REPAINT
    0;JMP       // Goto REPAINT
(SCR_WHITE)
    @bgcolor    // SCREEN index
    M=0         // color: 0
    @REPAINT
    0;JMP       // Goto REPAINT
(REPAINT)
    @bgcolor    // index of screen position
    D=M         // load color (black or white)
    @addr
    A=M         // get address of SCREEN
    M=D         // fill with bgcolor
    @addr
    D=M+1       // addr = addr + 1
    @addr
    M=M+1       // addr = addr + 1
    @KBD
    D=A-D       // KBD index - SCREEN index = A
    @REPAINT
    D;JGT       // if A >= 0, keep drawing.
    @LOOP
    0;JMP       // INFINITE LOOP
