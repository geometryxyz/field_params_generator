#!/usr/bin/env sage
import argparse
import sys
import os

# Converts a value to 16-character hexadecimal chunks.
# The minimum number of chunks is 4.
def hexify_to_chunks(value, num_chunks):
    assert(num_chunks >= 4)

    chunk_length = 16
    hex_repr = str(hex(value)).split('x')[-1]

    hex_length = num_chunks * chunk_length
    padded = hex_repr.rjust(hex_length, '0')

    output = str()
    for i in range(0, num_chunks):
        start = (num_chunks - i - 1) * chunk_length
        end = start + chunk_length
        output += "0x"
        output += padded[start:end]
        output += ","

        if i < num_chunks - 1:
            output += " "

    return output


def compute_t_s(modulus):
    t = modulus - 1
    s = 0

    while t % 2 == 0:
        s += 1
        t /= 2

    return int(t), int(s)


def square_mult_reduce(base, power, modulo):
    power_string = str(bin(power)).split('b')[-1]
    number_of_rounds = len(power_string)
    result = base
    for i in range(1, number_of_rounds):
        result = result ** 2 % modulo
        if power_string[i] == '1':
            result = result * base % modulo
            
    return result


def compute_mod_bits(modulus):
    return len(str(bin(modulus)).split('b')[-1])


def compute_params(modulus, generator=None):
    mod_bits = compute_mod_bits(modulus)

    capacity = mod_bits - 1
    repr_shave_bits = 256 - mod_bits
    if repr_shave_bits <= 0:
        repr_shave_bits = 64

    r_exp = int()

    if mod_bits < 256:
        r_exp = 256
    else:
        # Round up
        r_exp = int(1 + mod_bits / 64) * 64

    r = (2 ** r_exp) % modulus

    r2 = (r ** 2) % modulus
    inv = -(1 / modulus) % (2 ** 64)

    # Note that his takes a few seconds to compute
    if generator is None:
        field = GF(modulus)
        generator = field.multiplicative_generator()
    else:
        generator = int(generator)

    generator = generator * r % modulus

    modulus_minus_one_div_two = (modulus - 1) / 2
    t, s = compute_t_s(modulus)
    t_minus_one_div_two = int((t - 1)/2)
    two_acidity = s
    two_adic_root_of_unity = int(square_mult_reduce(generator, t, modulus) * r % modulus)

    return {
        'MODULUS': modulus,
        'MODULUS_BITS': mod_bits,
        'CAPACITY': capacity,
        'REPR_SHAVE_BITS': repr_shave_bits,
        'R': r,
        'R2': r2,
        'MODULUS_MINUS_ONE_DIV_TWO': modulus_minus_one_div_two,
        'GENERATOR': generator,
        'INV': inv,
        'T': t,
        'T_MINUS_ONE_DIV_TWO': t_minus_one_div_two,
        'TWO_ADICITY': two_acidity,
        'TWO_ADIC_ROOT_OF_UNITY': two_adic_root_of_unity
    }

KEYS_NOT_TO_HEXIFY = [
    'TWO_ADICITY',
    'INV',
    'MODULUS_BITS',
    'CAPACITY',
    'REPR_SHAVE_BITS'
]

def print_params(params):

    for key, val in params.items():
        if key in KEYS_NOT_TO_HEXIFY:
            print("{}: {}\n".format(key, val))
        else:
            print("{}: {}\n{}\n".format(key, val, hexify_to_chunks(val, num_chunks)))

def generate_rust_code(params, output_file, field_type, num_chunks, bigint_size):
    TEMPLATE = os.path.join(os.path.dirname(__file__), 'field_template.rs')
    template_content = open(TEMPLATE).read()

    template_content = template_content.replace('/*BIGINT_SIZE*/', str(bigint_size))
    template_content = template_content.replace('/*F_TYPE*/', str(field_type))

    for key, val in params.items():
        k = "/*{}*/".format(key)
        if key in KEYS_NOT_TO_HEXIFY:
            template_content = template_content.replace(k, str(val))
        else:
            template_content = template_content.replace(k, hexify_to_chunks(val, num_chunks))

    print(template_content)
    with open(output_file, 'w') as f:
        f.write(template_content)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate ark-ff code to specify a finite field.')
    parser.add_argument('-m', '--modulus', required=True, type=str, help='The modulus')
    parser.add_argument('-g', '--generator', required=False, type=int, help='The generator')
    parser.add_argument('-t', '--template-output', required=False, type=str, help='The Rust file to generate')
    parser.add_argument('-f', '--field-type', required=False, type=str, help='The name of the field type (e.g. Fr or Fq)')
    args = parser.parse_args()

    if args.template_output and args.field_type is None:
        print('Please specify a field type using -f (e.g. Fr or Fq)')
        sys.exit()

    modulus = None
    modulus_str = args.modulus
    if modulus_str.startswith('0x'):
        modulus = int(modulus_str, 16)
    else:
        modulus = int(modulus_str, 10)

    mod_bits = compute_mod_bits(modulus)

    # Calculate the BigInt size
    bigint_size = None
    if mod_bits < 256:
        bigint_size = 256
    elif mod_bits >= 256 and mod_bits < 320: 
        bigint_size = 320
    elif mod_bits >= 320 and mod_bits < 384: 
        bigint_size = 384
    elif mod_bits >= 384 and mod_bits < 448: 
        bigint_size = 448
    elif mod_bits >= 448 and mod_bits < 768: 
        bigint_size = 768
    elif mod_bits >= 768 and mod_bits < 832: 
        bigint_size = 832
    else:
        print("Unable to generate Rust code because the required BigInteger size is not available.")

    num_chunks = 4
    if mod_bits >= 256:
        b = (1 + int(mod_bits / 64)) * 64
        num_chunks = b / 64

    params = None
    if args.generator:
        params = compute_params(modulus, args.generator)
    else:
        params = compute_params(modulus)

    print_params(params)

    if args.template_output and args.field_type:
        generate_rust_code(
            params,
            args.template_output,
            args.field_type,
            num_chunks,
            bigint_size
        )
