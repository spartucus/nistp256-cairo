# nistp256-cairo
A cairo implementation of NIST P-256(AKA Secp256R1).

## implementation notes
### Outsourcing computing
We use python to compute the complex field computing, and verify the correctness in cairo. Start from `src/p256_example.cairo`.

### Montgomery Reduction
Montgomery reduction is a technique which allows efficient implementation of modular multiplication.

For short, montgomery reduction ![](http://latex.codecogs.com/gif.latex?REDC(x)=xR^{-1}\mod{P}) where  ![](http://latex.codecogs.com/gif.latex?R=2^{256}\mod{P}) and ![](https://latex.codecogs.com/gif.latex?0\leq{x}<RP).

In fact, montgomery reduction is so fast that we will transfer a field element ![](http://latex.codecogs.com/gif.latex?x) to ![](http://latex.codecogs.com/gif.latex?xR\mod{P}), by ![](http://latex.codecogs.com/gif.latex?REDC(xR^2)), denote is as ![](http://latex.codecogs.com/gif.latex?\widetilde{x}).

so we can fast computing ![](http://latex.codecogs.com/gif.latex?\widetilde{xy}=REDC(\widetilde{x}\widetilde{y})).  

If we need translate a field element out of the montgomery domain, we have ![](http://latex.codecogs.com/gif.latex?x=REDC(\widetilde{x})).

### Affine Point & Projective Point

Always, we used affine coordinates to express a point on curve like this ![](http://latex.codecogs.com/gif.latex?(x,y)). Affine point has unique  coordinates.

However, we also use the projective coordinates to express a point as ![](http://latex.codecogs.com/gif.latex?(X,Y,Z)). Projective Point has no unique coordinates.

we have that

![](http://latex.codecogs.com/gif.latex?(x,y)=>(x,y,1))

![](http://latex.codecogs.com/gif.latex?(X/Z,y/Z)<=(X,Y,Z))

In affine coordinates, every addition/double on elliptic curve need a division, but no division in projective coordinates. so we always use projective coordinates to calculate the multiplication, and use affine coordinates to express a point.

In addition, we have Jacobi projective coordinates ![](http://latex.codecogs.com/gif.latex?(X,Y,Z)):

![](http://latex.codecogs.com/gif.latex?(x,y)=>(x,y,1))

![](http://latex.codecogs.com/gif.latex?(X/Z^2,Y/Z^3)<=(X,Y,Z))

### ECDSA-Verify in Projective coordinates

For a signature  ![](http://latex.codecogs.com/gif.latex?(r,s)), pubkey ![](http://latex.codecogs.com/gif.latex?P), base point ![](http://latex.codecogs.com/gif.latex?G)  and msg hash ![](http://latex.codecogs.com/gif.latex?m), we have to verify that: ![](http://latex.codecogs.com/gif.latex?(x,y,z)=r^{-1}sG+r^{-1}mP) and if ![](http://latex.codecogs.com/gif.latex?r*z=x\mod{P}) or ![](http://latex.codecogs.com/gif.latex?(r+n)*z=x\mod{P})

In this form, we avoid division method.