#!/usr/bin/env sage

def to_bytes_hex_string(parameter):
    hex_representation = str(hex(parameter)).split('x')[-1]
    padded = hex_representation.rjust(64, '0')
    output = '0x{}, 0x{}, 0x{}, 0x{},'.format(padded[48:64], padded[32:48], padded[16:32], padded[0:16])
    return output

def square_mult_reduce(base, power, modulo):
    power_string = str(bin(power)).split('b')[-1]
    number_of_rounds = len(power_string)
    result = base
    for i in range(1, number_of_rounds):
        result = result ** 2 % modulo
        if power_string[i] == '1':
            result = result * base % modulo
            
    return result

def compute_t_s(modulus):
    T = modulus - 1
    S = 0
    while T%2==0:
        S = S+1
        T = T/2 
    return int(T), int(S)

def compute_fp_parameters(modulus, closest_two_power_64=256):
    parameters = {'MODULUS': modulus}
    parameters['MODULUS_BITS'] = len(str(bin(modulus)).split('b')[-1])
    R = int(2**closest_two_power_64 % modulus)
    parameters['R'] = R
    parameters['R2'] = \
        int(
            ((2**closest_two_power_64) ** 2) % modulus
        )
    parameters['MODULUS_MINUS_ONE_DIV_TWO'] = int((modulus - 1)/2)
    T, S = compute_t_s(modulus)
    parameters['T'] = T
    parameters['T_MINUS_ONE_DIV_TWO'] = int((T - 1)/2)

    field = GF(modulus)
    generator = field.multiplicative_generator()
    parameters['GENERATOR'] = generator*R % modulus
    parameters['INV'] = -(1 / modulus) % (2 ** 64)
    parameters['TWO_ADICITY'] = S
    parameters['TWO_ADIC_ROOT_OF_UNITY'] = int(square_mult_reduce(generator, T, modulus)*R % modulus)
    
    return parameters

if __name__ == "__main__":
    # Fr
    print('Fr parameters')
    modulus = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
    base_field_parameters = compute_fp_parameters(modulus, 320)
    for key, val in base_field_parameters.items():
        print(key, '\n', val, '\n', to_bytes_hex_string(val))
    print()

    # Fp
    print('Fq parameters')
    ec_group_order = int('0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f', 16)
    scalar_field_parameters = compute_fp_parameters(ec_group_order, 320);
    for key, val in scalar_field_parameters.items():
        print(key, '\n', val, '\n', to_bytes_hex_string(val))

    ## Starknet
    # base_field_parameters = compute_fp_parameters(2**251 + 17 * 2**192 + 1, 3)
    # EC_GROUP_ORDER = 3618502788666131213697322783095070105526743751716087489154079457884512865583 #EC group order, see StarkNet doc
    # scalar_field_parameters = compute_fp_parameters(EC_GROUP_ORDER, 3);

    # for key, val in scalar_field_parameters.items():
        # print(key, '\t',, val)
