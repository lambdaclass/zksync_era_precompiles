use p256::{AffinePoint, NonZeroScalar, Scalar};
use p256::ecdsa::{VerifyingKey, SigningKey, Signature};
use p256::ecdsa::signature::{Signer, Verifier};
use sha2::{self, Sha256, Digest};

fn main() {
    let gen = AffinePoint::GENERATOR;

    let signing_key = SigningKey::from(NonZeroScalar::new(Scalar::ONE).unwrap());
    let message = b"ECDSA proves knowledge of a secret number in the context of a single message";
    let signature: Signature = signing_key.sign(message);

    let mut hasher = Sha256::new();
    hasher.update(signature.to_bytes());
    let hash = hex::encode(hasher.finalize());

    let r = signature.r();
    let s = signature.s();
    let v = VerifyingKey::from_affine(gen).unwrap();

    println!("hash: {hash:?}");
    println!("r: {r}");
    println!("s: {s}");
    println!("gen: {gen:?}");
    assert!(v.verify(message, &signature).is_ok())
}
