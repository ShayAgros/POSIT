% POSIT presentation
% Shay Agroskin && Shahaf Haller
% Instructors: "The Jose"
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

# Multiplication

We divide our multiplication into three parts

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

We acknowledge that the range of the fraction bits is [0,2) (while the 1 digit
left to the dot is a hidden bit), and hence a multiplication of two fraction
fields is in the range [0, 4).

To get a product that is larger than one, we add the "hidden 1" as the MSB
before multiplying.

# Handling fraction addition overflow

If the multiplication is bigger than 2 (bit 2*(N-1) is set), than we increase the
exponent field by 1, and proceed to normalizing (rounding the solution to their
appropriate range).
