.spc700

.include registers.inc
.include macros.inc

.org 0600
.base 0000

wait:
    bra @wait
