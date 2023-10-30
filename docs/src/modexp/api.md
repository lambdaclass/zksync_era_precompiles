# API Docs

## Big Unsigned Integers Arithmetic

### `bigUIntAdd`

### `bigUIntSubWithBorrow`

### `bigUIntMul`

### `bigUIntBitOr`

```
+------------+-----------------------+-------------------------------+-------------------------------+-------------------------------+-----------------+-----------------+--------------------------------------+
| Iteration  |       currentOffset   |           lhsCurrentPtr       |           rhsCurrentPtr       |           resCurrentPtr       | lhsCurrentValue | rhsCurrentValue |           resCurrentValue            |
+------------+-----------------------+-------------------------------+-------------------------------+-------------------------------+-----------------+-----------------+--------------------------------------+
| 0          | +0x00                 | lhsPtr + 0x00                 | rhsPtr + 0x00                 | resPtr + 0x00                 | lhs[0]          | rhs[0]          | or(lhs[0], rhs[0])                   |
| 1          | +0x20                 | lhsPtr + 0x20                 | rhsPtr + 0x20                 | resPtr + 0x20                 | lhs[1]          | rhs[1]          | or(lhs[1], rhs[1])                   |
| 2          | +0x40                 | lhsPtr + 0x40                 | rhsPtr + 0x40                 | resPtr + 0x40                 | lhs[2]          | rhs[2]          | or(lhs[2], rhs[2])                   |
|            |                       |                               |                               |                               |                 |                 |                                      |
| ...        | ...                   | ...                           | ...                           | ...                           | ...             | ...             | ...                                  |
|            |                       |                               |                               |                               |                 |                 |                                      |
| nLimbs - 1 | +(0x20 * (nLimbs - 1) | lhsPtr + (0x20 * (nLimbs - 1) | rhsPtr + (0x20 * (nLimbs - 1) | resPtr + (0x20 * (nLimbs - 1) | lhs[nLimbs - 1] | rhs[nLimbs - 1] | or(lhs[nLimbs - 1], rhs[nLimbs - 1]) |
+------------+-----------------------+-------------------------------+-------------------------------+-------------------------------+-----------------+-----------------+--------------------------------------+
```

### `bigUIntCondSelect`