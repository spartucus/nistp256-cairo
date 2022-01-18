# nistp256-cairo
A cairo implementation of NIST P-256.

## implementation notes
### Montgomery Reduction
Montgomery reduction is a technique which allows efficient implementation of modular
multiplication.

For short, montgomery reduction $REDC(x)=xR^{-1}\mod{P}$ where  $R=2^{256}\mod{P}$  and $0\le{x}<{RP}$.

In fact, montgomery reduction is so fast that we will transfer a field element  $x$ to  $xR\mod{P}$, by $REDC(xR^2)$ , denote is as $\widetilde{x}$.

so we can fast computing $\widetilde{xy}=REDC(\widetilde{x}\widetilde{y})$.  

If we need translate a field element out of the montgomery domain, we have $x=REDC(\widetilde{x})$.

### Affine Point & Projective Point

Always, we used affine coordinates to express a point on curve like this $(x,y)$. Affine point has unique  coordinates.

However, we also use the projective coordinates to express a point as $(X,Y,Z)$. Projective Point has no unique coordinates.

we have that
$$
(x,y) => (x,y,1) \\
(X/Z,y/Z) <= (X,Y,Z)
$$
In affine coordinates, every addition/double on elliptic curve need a division, but no division in projective coordinates. so we always use projective coordinates to calculate the multiplication, and use affine coordinates to express a point.

In addition, we have Jacobi projective coordinates $(X,Y,Z)$:
$$
(x,y) => (x,y,1) \\
(X/Z^2,Y/Z^3) <= (X,Y,Z)
$$
