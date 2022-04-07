# nistp256-cairo
A cairo implementation of NIST P-256(AKA Secp256R1).

We use canonical ECC way to make this implementation.

## implementation notes
### Outsourcing computing
We use python to compute the complex field computing, and verify the correctness in cairo. Start from `src/p256_example.cairo`.

### ECDSA-Verify in Projective coordinates

For a signature  ![](http://latex.codecogs.com/gif.latex?(r,s)), pubkey ![](http://latex.codecogs.com/gif.latex?P), base point ![](http://latex.codecogs.com/gif.latex?G)  and msg hash ![](http://latex.codecogs.com/gif.latex?m), we have to verify that: ![](http://latex.codecogs.com/gif.latex?(x,y,z)=r^{-1}sG+r^{-1}mP) and if ![](http://latex.codecogs.com/gif.latex?r*z=x\mod{P}) or ![](http://latex.codecogs.com/gif.latex?(r+n)*z=x\mod{P})

In this form, we avoid division method.