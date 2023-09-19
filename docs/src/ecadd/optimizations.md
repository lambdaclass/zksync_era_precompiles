# Optimizations

This document lists the optimizations relevant to an elliptic curve or pairing-based cryptography library and whether Constantine has them implemented.

The optimizations can be of algebraic, algorithmic or "implementation details" nature. Using non-constant time code is always possible, it is listed if the speedup is significant.

## Finite Fields & Modular Arithmetic

- Representation
  - [x] Montgomery Representation

- Addition/substraction
  - [ ] Addition-chain for small constants

- Addition chains
  - [ ] unreduced squarings/multiplications in addition chains

- Inversion (constant-time baseline, Little-Fermat inversion via a^(p-2))
  - [ ] Constant-time binary GCD algorithm by Möller, algorithm 5 in https://link.springer.com/content/pdf/10.1007%2F978-3-642-40588-4_10.pdf
  - [ ] Addition-chain for a^(p-2)
  - [x] Constant-time binary GCD algorithm by Bernstein-Yang, https://eprint.iacr.org/2019/266
  - [ ] Constant-time binary GCD algorithm by Pornin, https://eprint.iacr.org/2020/972
  - [ ] Constant-time binary GCD algorithm by BY with half-delta optimization by libsecp256k1, formally verified, https://eprint.iacr.org/2021/549
  - [ ] Simultaneous inversion

## Elliptic curve

- Weierstrass curves:
  - [x] Affine coordinates
  - Homogeneous projective coordinates & Jacobian projective coordinates are not worth it for just one addition or one doubling.
