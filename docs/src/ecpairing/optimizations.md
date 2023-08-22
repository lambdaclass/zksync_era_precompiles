# Optimizations

This document lists the optimizations relevant to an elliptic curve or pairing-based cryptography library and whether Constantine has them implemented.

The optimizations can be of algebraic, algorithmic or "implementation details" nature. Using non-constant time code is always possible, it is listed if the speedup is significant.

## Finite Fields & Modular Arithmetic

- Representation
  - [x] Montgomery Representation

- Addition/substraction
  - [] Addition-chain for small constants

- Montgomery Multiplication
  - [ ] Fused multiply + reduce
  - [ ] no-carry optimization for CIOS (Coarsely Integrated Operand Scanning)
  - [ ] FIPS (Finely Integrated Operand Scanning)

- Montgomery Squaring
  - [ ] Dedicated squaring functions
  - [ ] Fused multiply + reduce
  - [ ] no-carry optimization for CIOS (Coarsely Integrated Operand Scanning)

- Addition chains
  - [ ] unreduced squarings/multiplications in addition chains

- Exponentiation
  - [ ] variable-time exponentiation
  - [ ] fixed window optimization _(sliding windows are not constant-time)_
  - [ ] NAF recoding
  - [ ] windowed-NAF recoding
  - [ ] SIMD vectorized select in window algorithm
  - [ ] Montgomery Multiplication with no final substraction,
    - Bos and Montgomery, https://eprint.iacr.org/2017/1057.pdf
      - Colin D Walter, https://colinandmargaret.co.uk/Research/CDW_ELL_99.pdf
      - Hachez and Quisquater, https://link.springer.com/content/pdf/10.1007%2F3-540-44499-8_23.pdf
    - Gueron, https://eprint.iacr.org/2011/239.pdf
  - [ ] Pippenger multi-exponentiation (variable-time)
    - [ ] parallelized Pippenger

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
  - [x] Homogeneous projective coordinates
    - [ ] Projective complete formulae
    - [ ] Mixed addition
  - [ ] Jacobian projective coordinates
    - [ ] Jacobian complete formulae
    - [ ] Mixed addition
    - [ ] Conjugate Mixed Addition
    - [ ] Composites Double-Add 2P+Q, tripling, quadrupling, quintupling, octupling

- [x] Scalar multiplication
  - [ ] fixed window optimization
  - [ ] constant-time NAF recoding
  - [ ] constant-time windowed-NAF recoding
    - [ ] SIMD vectorized select in window algorithm
  - [ ] constant-time endomorphism acceleration
    - [ ] using NAF recoding
    - [ ] using GLV-SAC recoding
  - [ ] constant-time windowed-endomorphism acceleration
    - [ ] using wNAF recoding
    - [ ] using windowed GLV-SAC recoding
    - [ ] SIMD vectorized select in window algorithm
  - [ ] Fixed-base scalar mul

## Extension Fields

- [ ] Lazy reduction via double-precision base fields
- [ ] Sparse multiplication
- Fp2
  - [ ] complex multiplication
  - [ ] complex squaring
  - [ ] sqrt via the constant-time complex method (Adj et al)
  - [ ] sqrt using addition chain
  - [ ] fused complex method sqrt by rotating in complex plane
- Cubic extension fields
  - [ ] Toom-Cook polynomial multiplication (Chung-Hasan)

## Pairings

- Frobenius maps
  - [ ] Sparse Frobenius coefficients
  - [ ] Coalesced Frobenius in towered Fields
  - [ ] Coalesced Frobenius powers

- Line functions
  - [x] Homogeneous projective coordinates
    - [ ] D-Twist
      - [ ] Fused line add + elliptic curve add
      - [ ] Fused line double + elliptic curve double
    - [ ] M-Twist
      - [ ] Fused line add + elliptic curve add
      - [ ] Fused line double + elliptic curve double
    - [ ] 6-way sparse multiplication line * Gₜ element
  - [ ] Jacobian projective coordinates
    - [ ] D-Twist
      - [ ] Fused line add + elliptic curve add
      - [ ] Fused line double + elliptic curve double
    - [ ] M-Twist
      - [ ] Fused line add + elliptic curve add
      - [ ] Fused line double + elliptic curve double
    - [ ] 6-way sparse multiplication line * Gₜ element
  - [ ] Affine coordinates
    - [ ] 7-way sparse multiplication line * Gₜ element
    - [ ] Pseudo-8 sparse multiplication line * Gₜ element

- Miller Loop
  - [ ] NAF recoding
  - [ ] Quadruple-and-add and Octuple-and-add
  - [ ] addition chains

- Final exponentiation
  - [ ] Cyclotomic squaring
    - [ ] Karabina's compressed cyclotomic squarings
  - [ ] Addition-chain for exponentiation by curve parameter
  - [ ] BN curves: Fuentes-Castañeda
  - [ ] BN curves: Duquesne, Ghammam

- [ ] Multi-pairing
  - [ ] Line accumulation
  - [ ] Parallel Multi-Pairing
