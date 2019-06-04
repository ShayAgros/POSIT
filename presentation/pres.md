% POSIT presentation
% Shay Agroskin & Shahaf Haller
% Instructor: Jose Yallouz
---
theme:
- Pittsburgh
colortheme:
- dolphin
mainfont: DejaVuSans.ttf
mainfontoptions:
- BoldFont=DejaVuSans-Bold.ttf
header-includes: |
  \usepackage{tikz}
---

# Background

Similar to IEEE float representation, the POSIT representation consists of several different segments.
Unlike Float:

- Posit have three fields, namely Regime/Exponent/Significand.
- These fields can have variable length

# Background - Posit number example

An example of a POSIT number


\begin{figure}[h]
\includegraphics[width=0.80\textwidth,height=0.30\textheight]{./POSIT_nr_example.png}
\end{figure}

# Background - POSIT pros

The POSIT representation allows

- change number granularity - shift from large number with low accuracy
    to tiny number with maximum precision

- use a single representation for NaN ($\pm \infty$)

- perfect reciprocal for powers of 2

# Background - Posit numbers circle 

\begin{figure}[h]
\includegraphics[width=0.50\textwidth,height=0.70\textheight]{./POSIT_semi_circle.png}
\caption{POSIT number representation}
\end{figure}

# Packer and unpacker modules

As a result of such representation, the size of these three fields can change
after ALU operations.

To handle such changes we introduce the Packer and Unpacker modules.

# Packer and unpacker modules - unpacker

The unpacker module is used to transform the POSIT into three
separate numbers that represent the regime, exponent and significand
parts of the POSIT.

It implements the following:

- sign extend each field (regime/exponent/significand)
- transform regime field into regular representation
- add the hidden 1 into the fraction representation.

# Packer and unpacker modules - unpacker

\begin{figure}[h]
\includegraphics[width=0.9\textwidth,height=0.75\textheight]{./unpacker.eps}
\caption{a diagram of POSIT multiplication flow}
\end{figure}

# Packer and unpacker modules - Packer

The packer module does the opposite functionality. It takes three numbers representing
the three segments, and creates a POSIT number out of them.

# Multiplication

We divide our multiplication into three parts using
the unpacker module.

- Regime fields addition
- Exponent fields addition
- Fraction fields multiplication

# Diagram

\begin{figure}[h]
\includegraphics[width=0.9\textwidth,height=0.75\textheight]{Posit_Mult_Diag.eps}
\caption{a diagram of POSIT multiplication flow}
\end{figure}

# Dealing with negative numbers

If the sign bit is set in any of the POSITs (or both) we 2's complement
the numbers and do the multiplication as if the two numbers were positive.

The sign bits are passed to the result in order to 2's complement the result back
if needed.

# Exponent and regime addition

The exponent bits are summed, and their carry is added to the regime bits summation.

The addition of the regime bits (with the exponent carry) can "overflow" (the resulting
regime can take more bits than it had in the original numbers), we take care of this 
case when we pack the three fields together.

# Fraction part multiplication

Similar to IEEE, the POSIT fraction (significand) field represents a number in
the range of [1,2) but encodes only the fraction part (range [0,1)) . 

To get a product that is larger than one, the Unpacker module adds the "hidden 1"
as the MSB fraction before multiplying.

# Handling fraction addition overflow

If the multiplication is bigger than 2 (bit 2*(N-1) is set), than we increase the
exponent field by 1, and proceed to normalizing (rounding the solution to their
appropriate range).

# Addition/subtraction

As with multiplication, we first use the unpacker module to
extract the three fields.

# Addition/subtraction - fraction alignment

Similar to floats, we choose the dominant regime and its subsequent
exponent to be the destination's regime and exponent.

The difference between the two numbers regime and exponents values
are passed to the fraction alignment to right shift the fraction
corresponding to the smaller regime + exponent

# Addition/subtraction - fraction addition normalization

The addition is done using the 2's complement form of the fraction
bits in order to get a subtraction as well as summation.

The summation overflow/underflow bit goes into the 'normalize' module

# Normalize module

The 'normalize' module handles the addition/subtraction overflow/underflow.
It outputs the extra bit from the fraction 'adder' result and add it to the
exponent result.

# Addition/subtraction - exponent & regime fields

The exponent and regime are (possibly) summed with the overflow from the
fraction overflow, but otherwise stay the same.

All three fields are then passed to the packer module and converted to POSIT
representation.

# Reciprocal

The reciprocal consists of making a 2's complement of POSIT bits. Further tests
needed to check inaccuracy error when dealing with numbers that are not a multiply
of 2.

# Bibliography

1. \small “The End of Error: Unum Computing”
    \small by Dr. John L. Gustafson

2. \small “Beating Floating Point at its Own Game: Posit Arithmetic”[^ref1]
    \small by Dr. John L. Gustafson and Dr. Isaac Yonemoto
    
3. \small “Parameterized Posit Arithmetic Hardware Generator”[^ref2]
    \small by Dr. John L. Gustafson et ali

[^ref1]: http://www.johngustafson.net/pdfs/BeatingFloatingPoint.pdf
[^ref2]: https://posithub.org/docs/iccd_submission_v1.pdf
