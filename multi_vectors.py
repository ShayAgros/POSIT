#!/usr/bin/env python3

from create_posit import create_vector

ES = 3

def multiply_numbers(seed1, exp1, frac1, seed2, exp2, frac2):
    seed    = seed1 + seed2
    exp     = exp1 + exp2
    frac    = frac1 * frac2

    if (frac >= 2):
        exp = exp +1
        frac = frac / 2

    if (exp >= 2 ** ES):
        seed = seed + 1
        exp = exp - 2 ** ES

    print("product output:")
    print("\tseed: {}".format(seed))
    print("\texponent: {}".format(exp))
    print("\tfraction: {}".format(frac))

    return create_vector(seed, exp, frac) 

seed1 = 3
exp1 = 3
frac1 = 1 + 1/2 + 1/8 + 1/16

posit1 = create_vector(seed1, exp1, frac1)

seed2 = 5
exp2 = 2
frac2 = 1 + 1/4 + 1/8 + 1/32

posit2 = create_vector(seed2, exp2, frac2)

print("Posit1: %s" % posit1)
print("Posit2: %s" % posit2)

product_posit = multiply_numbers(seed1, exp1, frac1, seed2, exp2, frac2)
print("\tposit: {}".format(product_posit))
