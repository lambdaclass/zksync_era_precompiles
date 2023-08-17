use lambdaworks_math::{field::{fields::montgomery_backed_prime_fields::{IsModulus, U256PrimeField}, element::FieldElement}, unsigned_integer::element::{U256, UnsignedInteger}};

#[derive(Clone, Debug)]
struct AltBn128Modulus;
impl IsModulus<U256> for AltBn128Modulus {
    const MODULUS: U256 = UnsignedInteger::from_hex_unchecked(
        "30644E72E131A029B85045B68181585D97816A916871CA8D3C208C16D87CFD47",
    );
}

type AltBn128PrimeField = U256PrimeField<AltBn128Modulus>; 
type AltBn128FieldElement = FieldElement<AltBn128PrimeField>;

fn main() {
    println!("{:?}", AltBn128FieldElement::from(3).value().to_string())
}
