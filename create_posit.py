#!/usr/bin/env python

import sys
import math

ES=3

def usage():
    print("usage: create_posit.py seed exponent fraction")

def create_seed_seq(seed):
    is_positive = int(seed > 0)
    positive_seed = abs(seed)
    seed_sequence = ""
    for i in range(positive_seed):
        seed_sequence = "{}".format(is_positive) + seed_sequence
    seed_sequence = seed_sequence + "{}".format(int(not(is_positive)))

    if (seed > 0):
        seed_sequence = "1" + seed_sequence
    return seed_sequence

def create_exp_seq(exp):
    return "{0:03b}".format(exp)

def create_frac_seq(frac):
    frac = frac - 1
    divider = 0.5
    frac_seq = ""
    for i in range(16):
        tmp_frac = frac - divider
        if (tmp_frac >= 0):
            frac_seq = frac_seq + "1"
            frac = tmp_frac
        else:
            frac_seq = frac_seq + "0"
        divider = divider / 2
    return frac_seq

# if (len(sys.argv) < 3):
    # usage()
    # exit(1)

# seed = sys.argv[1]
# exponent = sys.argv[2]
# fraction = sys.argv[3]

def create_vector(seed, exponent, fraction):
    # seed = 4
    # exponent = 2
    # fraction = -1.75

    absolute_fraction = abs(fraction)

    if (exponent > 2**ES or exponent < 0):
        print("Exponent should be between 0 and {}".format(2**ES))
        exit(1)

    if (absolute_fraction >= 2 or absolute_fraction < 1):
        print("Fraction should be between 1 and 2")
        exit(1)

    seed_seq = create_seed_seq(seed)
    exp_seq  = create_exp_seq(exponent)
    fraction_seq = create_frac_seq(absolute_fraction)

    posit = "0" + seed_seq + exp_seq + fraction_seq
    posit = posit[0:16]

    # if (fraction < 0):
        # posit = "{0:16b}".format(~int(posit, 2))
    return posit
    # print(bin(int(posit)))
