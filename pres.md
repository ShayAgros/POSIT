% POSIT presentation
% Shay Agroskin & Shahaf Haller
% Instructor: Jose Yallouz
---
theme:
- Szeged
colortheme:
- beaver
mainfont: DejaVuSans.ttf
mainfontoptions:
- BoldFont=DejaVuSans-Bold.ttf
header-includes: |
  \usepackage{tikz}
---

# Packer and unpacker modules - unpacker

The unpacker diagram is used to transform the POSIT into three
separate numbers that represent the regime, exponent and significand
parts of the POSIT.

It implements the following:

- sign extend each field (regime/exponent/significand)
- transform regime field into regular representation
- add the hidden 1 into the fraction representation.

# Packer and unpacker modules - unpacker

<!--add unpacker diagram here-->

# Packer and unpacker modules - Packer

<!--add description later-->

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
regime bits representation increases), we take care of this case when we pack the three
fields together

# Fraction part multiplication

left to the dot is a hidden bit), and hence a multiplication of two fraction
We acknowledge that the range of the fraction bits is [0,2) (while the 1 digit
fields is in the range [0, 4).

To get a product that is larger than one, we add the "hidden 1" as the MSB
before multiplying.

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
