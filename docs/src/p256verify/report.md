# Repo

https://github.com/lambdaclass/zksync_era_precompiles

# Benchmark Results

|  | Min Gas Used | Avg Gas Used | Max Gas Used |
| --- | --- | --- | --- |
| **MVP** | 2.681.270 | 2.718.008 | 2.742.770 |
| **Optimized** | 1.325.290 | 1.627.415 | 1.886.968 |
| **After the first audit** | - | - | - |

## Comparison between different implementations

The table below is a result of running the whole test suite over some implementations of the precompile.

You can see the benchmark setup [here](https://github.com/lambdaclass/zksync_era_precompiles/pull/180) and run it following the PR’s description.

| Implementation | Min Gas Used | Avg Gas Used | Max Gas Used |
| --- | --- | --- | --- |
| **[Daimos's Solidity P256 Verifier ](https://github.com/daimo-eth/p256-verifier)** | 1.592.916 | 1.976.707 | 2.193.456 |
| **[pcaversaccio's Vyper P256 Verifier](https://github.com/pcaversaccio/p256-verifier-vyper)** | 1.734.519 | 2.144.258 | 2.383.619 |
| **[LambdaClass's Yul P256 Verifier](https://github.com/lambdaclass/zksync_era_precompiles/blob/main/precompiles/P256VERIFY.yul)** | 1.325.290 | 1.627.415 | 1.886.968 |

## Comparison between our implementation and Huff’s

We’re aware that Huff’s implementation was not taken into account for the gas costs comparison because there’s no “zkHuff” compiler on zkSync Era today. Nevertheless below you’ll find an algorithm comparison table between our implementation and that one.

|  |  | **Implementation** |  |
| --- | --- | --- | --- |
| **Arithmetic** | **Operation** | [LambdaClass's Yul P256 Verifier](https://github.com/lambdaclass/zksync_era_precompiles/blob/main/precompiles/P256VERIFY.yul) | [AmadiMichael's Huff P256 Verifier](https://github.com/AmadiMichael/p256-verifier-huff) |
| **Prime Field Arithmetic** |  |  |  |
|  | **Addition** | Montgomery Modular Addition | Modular Addition |
|  | **Subtraction** | Montgomery Modular Subtraction | Modular Subtraction |
|  | **Multiplication** | Montgomery multiplication | Modular Multiplication |
|  | **Exponentiation** | - | - |
|  | **Inversion** | Modified Binary Extended GCD (adapted for Montgomery Form) | Fermat’s little theorem (using modexp precompile) |
| **Elliptic Curve Arithmetic** |  |  |  |
|  | **Addition** | Addition in Homogeneous Projective Form | madd-2008-s in XYZZ Coordinates |
|  | **Double** | Double in Homogeneous Projective Form | mdbl-2008-s in XYZZ Coordinates |
|  | **Scalar Multiplication** | - | - |
| **Other** | **Strauss-Shamir's trick** | ✅ | ✅ |

---

# Used Algorithms

Here you’ll find every algorithm and optimization that we’ve implemented in the precompile in question.

## Prime Field Arithmetic

| Addition | Subtraction | Multiplication | Exponentiation | Inversion |
| --- | --- | --- | --- | --- |
| Montgomery Modular Addition | Montgomery Modular Subtraction | Montgomery multiplication | — | Modified Binary Extended GCD (adapted for Montgomery Form) |

The secp256r1 (also known as P256) is an elliptic curve defined by the equation $y^2 = x^3 + ax +b$ with $a = 115792089210356248762697446949407573530086143415290314195533631308867097853948$ and $b = 41058363725152142129326129780047268409114441015993725554835256314039467401291$ over the finite field $\mathbb{F}_p$, being $p = 218882428718392752222464057452572750886963111572978236626890378946452262$08583. The modulus is 256 bits, which is why every element in the field is represented as a `uint256`.

The arithmetic is carried out with the field elements encoded in the Montgomery form. This is done not only because operating in the Montgomery form speeds up the computation but also because the native modular multiplication, which is carried out by Yul's `mulmod` opcode, is very inefficient.

Instructions set on zkSync and EVM are different, so the performance of the same Yul/Solidity code can be efficient on EVM, but not on zkEVM and opposite. We definitely want to optimize precompiles due to their low cost on EVM and potential huge usage on hyperscaling near future.

One such very inefficient command is `mulmod`. On EVM there is a native opcode that makes modulo multiplication and it costs only 8 gas, which compared to the other opcodes costs is only 2-3 times more expensive. On zkEVM we don’t have native `mulmod` opcode, instead, the compiler does full-with multiplication (e.g. it multiplies two `uint256`s and gets as a result an `uint512`). Then the compiler performs long division for reduction (but only the remainder is kept), in the generic form it is an expensive operation and costs around 50 opcode executions, which can’t be compared to the cost of one opcode execution. The worst thing is that `mulmod` is used a lot for the modulo inversion, so optimizing this one opcode gives a huge benefit to the precompiles.

### Multiplication

As said before, multiplication was carried out by implementing the Montgomery reduction, which works with general moduli and provides a significant speedup compared to the naïve approach.

The squaring operation is obtained by multiplying a number by itself. However, this operation can have an additional speedup by implementing the SOS Montgomery squaring.

### Inversion

Inversion was performed using the extended binary Euclidean algorithm (also known as extended binary greatest common divisor). This algorithm is a modification of Algorithm 3 `MontInvbEEA` from [Montgomery inversion](https://cetinkayakoc.net/docs/j82.pdf).

## Elliptic Curve Arithmetic

| Addition | Double | Scalar Multiplication |
| --- | --- | --- |
| Addition in Homogeneous Projective Form | Double in Homogeneous Projective Form | Double-and-add |

The points are represented in homogeneous projective coordinates, given by the coordinates $(x , y , z)$. Transformation into affine coordinates can be done by applying the following transformation:
$(x,y) = (X.Z^{-1} , Y.Z^{-1} )$ if the point is not the point at infinity.

The key idea of projective coordinates is that instead of performing every division immediately, we defer the divisions by multiplying them into a denominator. The denominator is represented by a new coordinate. Only at the very end, do we perform a single division to convert from projective coordinates back to affine coordinates.

In affine form, each elliptic curve point has 2 coordinates, like $(x,y)$. In the new projective form, each point will have 3 coordinates, like $(X,Y,Z)$, with the restriction that $Z$ is never zero. The forward mapping is given by $(x,y)→(xz,yz,z)$, for any non-zero $z$ (usually chosen to be 1 for convenience). The reverse mapping is given by $(X,Y,Z)→(X/Z,Y/Z)$, as long as $Z$ is non-zero.

### Point Doubling

The affine form case $y=0$ corresponds to the projective form case $Y/Z=0$. This is equivalent to $Y=0$, since $Z≠0$.

For the interesting case where $P=(X,Y,Z)$ and $Y≠0$, let’s convert the affine arithmetic to projective arithmetic.

After expanding and simplifying the equations ([demonstration here](https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates)), the following substitutions come out

$$
\begin{align*} T &= 3X^{2} + aZ^{2},\\ U &= 2YZ,\\ V &= 2UXY,\\ W &= T^{2} - 2V \end{align*}
$$

Using them, we can write

$$
\begin{align*} X_{r}  &= UW \\ Y_{r} &= T(V−W)−2(UY)^{2} \\ Z_{r} &= U^{3} \end{align*}
$$

As we can see, the complicated case involves approximately 18 multiplications, 4 additions/subtractions, and 0 divisions.

### Point Addition

The affine form case $x_{p} = x_{q}$ corresponds to the projective form case $X_{p}/Z_{p} = X_{q}/Z_{q}$. This is equivalent to $X_{p}Z_{q} = X_{q}Z_{p}$, via cross-multiplication.

For the interesting case where $P = (X_{p},\ Y_{p},\ Z_{p})$ , $Q = (X_{q},\ Y_{q},\ Z_{q})$, and $X_{p}Z_{q} ≠ X_{q}Z_{p}$, let’s convert the affine arithmetic to projective arithmetic.

After expanding and simplifying the equations ([demonstration here](https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates)), the following substitutions come out

$$
\begin{align*}
T_{0} &= Y_{p}Z_{q}\\
T_{1} &= Y_{q}Z_{p}\\
T &= T_{0} - T_{1}\\
U_{0} &= X_{p}Z_{q}\\
U_{1} &= X_{q}Z_{p}\\
U &= U_{0} - U_{1}\\
U_{2} &= U^{2}\\
V &= Z_{p}Z_{q}\\
W &= T^{2}V−U_{2}(U_{0}+U_{1}) \\
\end{align*}
$$

Using them, we can write

$$
\begin{align*} X_{r}  &= UW \\ Y_{r} &= T(U_{0}U_{2}−W)−T_{0}U^{3} \\ Z_{r} &= U^{3}V \end{align*}
$$

As we can see, the complicated case involves approximately 15 multiplications, 6 additions/subtractions, and 0 divisions.

## Other optimizations

Strauss Shamir’s algorithm (a.k.a. Shamir’s trick) is being used to perform the elliptic curve arithmetic part of the algorithm.

---

# Resources

- [EIP-7212](https://eips.ethereum.org/EIPS/eip-7212)
- [EIP-7212 Forum](https://ethereum-magicians.org/t/eip-7212-precompiled-for-secp256r1-curve-support/14789)
- [Shamir’s trick](https://crypto.stackexchange.com/questions/99975/strauss-shamir-trick-on-ec-multiplication-by-scalar).
- [Montgomery Form](https://en.wikipedia.org/wiki/Montgomery_modular_multiplication).
- [Homogeneous Projective Coordinates](https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates).
