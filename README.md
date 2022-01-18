# nistp256-cairo
A cairo implementation of NIST P-256.

## implementation notes
### Montgomery Reduction
Montgomery reduction is a technique which allows efficient implementation of modular
multiplication.

For short, montgomery reduction $REDC(x)=xR^{-1}\mod{P}$ where  $R=2^{256}\mod{P}$  and $0\le{x}<{RP}$.

In fact, montgomery reduction is so fast that we will transfer a field element  $x$ to  $xR\mod{P}$, by $REDC(xR^2)$ , denote is as $\widetilde{x}$.

so we can fast computing $\widetilde{xy}=REDC(\widetilde{x}\widetilde{y})$.  If we need translate a field element out of the montgomery domain, we have $x=REDC(\widetilde{x})$.

