
# POSIT Project in BSc

## Code compilation

To compile a verilog file use the command
`iverilog -o [name of the output file] [.v files]`

## Running simulation

The vvp simulation programs take 'vvp' files and runs them:
`vvp [vvp file]`

## Presentation compilation

to compile the presentation use 

- install pandoc markdown compiler
`sudo apt-get install pandoc`

- compile it
`pandoc -s -t beamer -o pres.pdf pres.md`
