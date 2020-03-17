#!/usr/bin/env python

from create_posit import create_vector

ES = 3

def add_numbers(seed1, exp1, frac1, seed2, exp2, frac2):
    cexp1 = seed1 * (2 ** ES) + exp1
    cexp2 = seed2 * (2 ** ES) + exp2

    if (cexp1 >= cexp2):
        bigger_cexp = cexp1
        smaller_cexp = cexp2
        bigger_frac = frac1
        smaller_frac = frac2

        bigger_seed = seed1
    else:
        bigger_cexp = cexp2
        smaller_cexp = cexp1
        bigger_frac = frac2
        smaller_frac = frac1

        bigger_seed = seed2
    
    exp_diff = bigger_cexp - smaller_cexp
    smaller_frac = smaller_frac * (2 ** (-exp_diff))

    frac = smaller_frac + bigger_frac
    exp  = bigger_cexp - (bigger_seed * 2**ES)
    seed = bigger_seed

    if frac >= 2:
        frac = frac / 2
        exp = exp +1
    if exp > 2 ** ES:
        exp = exp - 2**ES
        seed + 1

    print("sum output:")
    print("\tseed: {}".format(seed))
    print("\texponent: {}".format(exp))
    print("\tfraction: {}".format(frac))

    return create_vector(seed, exp, frac) 

def multiply_numbers(seed1, exp1, frac1, seed2, exp2, frac2):
    seed    = seed1 + seed2
    exp     = exp1 + exp2
    frac    = frac1 * frac2

    if (frac >= 2):
        exp = exp +1
        frac = frac / 2

    if (exp > 2 ** ES):
        seed = seed + 1
        exp = exp - 2 ** ES

    print("product output:")
    print("\tseed: {}".format(seed))
    print("\texponent: {}".format(exp))
    print("\tfraction: {}".format(frac))

    return create_vector(seed, exp, frac) 

seed1 = 5
exp1 = 3
frac1 = 2 + 1/2 + 1/8 + 1/16

posit1 = create_vector(seed1, exp1, frac1)

seed2 = 5
exp2 = 2
frac2 = 1 + 1/4 + 1/8 + 1/32

posit2 = create_vector(seed2, exp2, frac2)

print("Posit1: %s" % posit1)
print("Posit2: %s" % posit2)

product_posit = add_numbers(seed1, exp1, frac1, seed2, exp2, frac2)
print("\tposit: {}".format(product_posit))
