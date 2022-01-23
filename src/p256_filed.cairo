%builtins range_check

from bigint import BASE, BigInt4, MODULUS
from utils import adc, sbb, mac
from starkware.cairo.common.bitwise import bitwise_and

func sub_inner{range_check_ptr}(l0,l1,l2,l3,l4,r0,r1,r2,r3,r4) -> (BigInt4, borrow):
    let (w0, borrow) = sbb(l0, r0, 0)
    let (w1, borrow) = sbb(l1, r1, borrow)
    let (w2, borrow) = sbb(l2, r2, borrow)
    let (w3, borrow) = sbb(l3, r3, borrow)
    let (w4, borrow) = sbb(l4, r4, borrow)

    let (MODULUS) = MODULUS()
    let (ba0) = bitwise_and(MODULUS.0[0], borrow)
    let (ba1) = bitwise_and(MODULUS.0[1], borrow)
    let (ba2) = bitwise_and(MODULUS.0[2], borrow)
    let (ba3) = bitwise_and(MODULUS.0[3], borrow)
    let (w0, carry) = adc(w0, ba0, 0);
    let (w1, carry) = adc(w1, ba1, carry);
    let (w2, carry) = adc(w2, ba2, carry);
    let (w3, carry) = adc(w3, ba3, carry);

    return (
        BigInt4(
        d0=w0,
        d1=w1,
        d2=w2,
        d3=w3,
    ),
    borrow)
end