use ark_ff::{
    biginteger::BigInteger/*BIGINT_SIZE*/ as BigInteger,
    fields::*
};
/*
    Supported BigInteger sizes:
    256, 320, 384, 448, 768, 832
 */

pub type /*F_TYPE*/ = Fp/*BIGINT_SIZE*/</*F_TYPE*/Parameters>;

pub struct /*F_TYPE*/Parameters;

impl Fp/*BIGINT_SIZE*/Parameters for /*F_TYPE*/Parameters {}

impl FftParameters for /*F_TYPE*/Parameters {
    type BigInt = BigInteger;

    const TWO_ADICITY: u32 = /*TWO_ADICITY*/;

    const TWO_ADIC_ROOT_OF_UNITY: Self::BigInt = BigInteger([
        /*TWO_ADIC_ROOT_OF_UNITY*/
    ]);
}

impl FpParameters for /*F_TYPE*/Parameters {
    #[rustfmt::skip]
    const MODULUS: BigInteger = BigInteger([
        /*MODULUS*/
    ]);

    const MODULUS_BITS: u32 = /*MODULUS_BITS*/;

    const CAPACITY: u32 = Self::MODULUS_BITS - 1;

    /// The number of bits that must be shaved from the beginning of
    /// the representation when randomly sampling.
    const REPR_SHAVE_BITS: u32 = /*REPR_SHAVE_BITS*/;

    /// Let `M` be the power of 2^64 nearest to `Self::MODULUS_BITS`. Then
    /// `R = M % Self::MODULUS`.
    /// R = M % MODULUS
    #[rustfmt::skip]
    const R: BigInteger = BigInteger([
        /*R*/
    ]);

    /// R2 = R * R % MODULUS
    #[rustfmt::skip]
    const R2: BigInteger = BigInteger([
        /*R2*/
    ]);

    /// INV = -MODULUS^{-1} mod 2^64
    const INV: u64 = /*INV*/;

    /// A multiplicative generator of the field, in Montgomery form (g * R % modulus).
    /// `Self::GENERATOR` is an element having multiplicative order
    /// `Self::MODULUS - 1`. In other words, the generator is the lowest value such that
    /// MultiplicativeOrder(generator, p) = p - 1 where p is the modulus.
    #[rustfmt::skip]
    const GENERATOR: BigInteger = BigInteger([
        /*GENERATOR*/
    ]);

    #[rustfmt::skip]
    const MODULUS_MINUS_ONE_DIV_TWO: BigInteger = BigInteger([
        /*MODULUS_MINUS_ONE_DIV_TWO*/
    ]);

    #[rustfmt::skip]
    const T: BigInteger = BigInteger([
        /*T*/
    ]);

    #[rustfmt::skip]
    const T_MINUS_ONE_DIV_TWO: BigInteger = BigInteger([
        /*T_MINUS_ONE_DIV_TWO*/
    ]);
}
