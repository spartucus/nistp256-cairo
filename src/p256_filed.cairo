%builtins range_check

from bigint import BASE, BigInt4, MODULUS, bigint_zero, bigint_one
from utils import adc, sbb, mac
from starkware.cairo.common.bitwise import bitwise_and

func sub_inner{range_check_ptr}(l0, l1, l2, l3, l4, r0, r1, r2, r3, r4) -> (res:BigInt4, borrow):
    let (w0, borrow) = sbb(l0, r0, 0)
    let (w1, borrow) = sbb(l1, r1, borrow)
    let (w2, borrow) = sbb(l2, r2, borrow)
    let (w3, borrow) = sbb(l3, r3, borrow)
    let (w4, borrow) = sbb(l4, r4, borrow)

    let (MODULUS) = MODULUS()
    let (ba0) = bitwise_and(MODULUS[0], borrow)
    let (ba1) = bitwise_and(MODULUS[1], borrow)
    let (ba2) = bitwise_and(MODULUS[2], borrow)
    let (ba3) = bitwise_and(MODULUS[3], borrow)
    let (w0, carry) = adc(w0, ba0, 0);
    let (w1, carry) = adc(w1, ba1, carry);
    let (w2, carry) = adc(w2, ba2, carry);
    let (w3, carry) = adc(w3, ba3, carry);

    return (
        res=BigInt4(
        d0=w0,
        d1=w1,
        d2=w2,
        d3=w3,
    ),
    borrow=borrow)
end

# Returns `fe^by`, where `by` is a little-endian integer exponent.
func pow_vartime(fe: BigInt4, by: felt*) -> (res: BigInt4):
    let (one) = bigint_one()
    
end

# Montgomery Reduction
# The general algorithm is:
    # ```text
    # A <- input (2n b-limbs)
    # for i in 0..n {
    #     k <- A[i] p' mod b
    #     A <- A + k p b^i
    # }
    # A <- A / b^n
    # if A >= p {
    #     A <- A - p
    # }
    # ```
    #
    # For secp256r1, we have the following simplifications:
    #
    # - `p'` is 1, so our multiplicand is simply the first limb of the intermediate A.
    #
    # - The first limb of p is 2^64 - 1; multiplications by this limb can be simplified
    #   to a shift and subtraction:
    #   ```text
    #       a_i * (2^64 - 1) = a_i * 2^64 - a_i = (a_i << 64) - a_i
    #   ```
    #   However, because `p' = 1`, the first limb of p is multiplied by limb i of the
    #   intermediate A and then immediately added to that same limb, so we simply
    #   initialize the carry to limb i of the intermediate.
    #
    # - The third limb of p is zero, so we can ignore any multiplications by it and just
    #   add the carry.
    #
    # References:
    # - Handbook of Applied Cryptography, Chapter 14
    #   Algorithm 14.32
    #   http://cacr.uwaterloo.ca/hac/about/chap14.pdf
    #
    # - Efficient and Secure Elliptic Curve Cryptography Implementation of Curve P-256
    #   Algorithm 7) Montgomery Word-by-Word Reduction
    #   https://csrc.nist.gov/csrc/media/events/workshop-on-elliptic-curve-cryptography-standards/documents/papers/session6-adalier-mehmet.pdf
func montgomery_reduce{range_check_ptr}(r0, r1, r2, r3, r4, r5, r6, r7) -> (res: BigInt4):
    let (MODULUS) = MODULUS()
    let (r1, carry) = mac(r1, r0, MODULUS[1], r0)
    let (r2, carry) = adc(r2, 0, carry)
    let (r3, carry) = mac(r3, r0, MODULUS[3], carry)
    let (r4, carry2) = adc(r4, 0, carry)

    let (r2, carry) = mac(r2, r1, MODULUS[1], r1)
    let (r3, carry) = adc(r3, 0, carry)
    let (r4, carry) = mac(r4, r1, MODULUS[3], carry)
    let (r5, carry2) = adc(r5, carry2, carry)

    let (r3, carry) = mac(r3, r2, MODULUS[1], r2)
    let (r4, carry) = adc(r4, 0, carry)
    let (r5, carry) = mac(r5, r2, MODULUS[3], carry)
    let (r6, carry2) = adc(r6, carry2, carry)

    let (r4, carry) = mac(r4, r3, MODULUS[1], r3)
    let (r5, carry) = adc(r5, 0, carry)
    let (r6, carry) = mac(r6, r3, MODULUS[3], carry)
    let (r7, r8) = adc(r7, carry2, carry)

    let (res, borrow) = sub_inner(r4, r5, r6, r7, r8, MODULUS[0], MODULUS[1], MODULUS[2], MODULUS[3], 0)
    return (res=res)
end

# Returns lhs + rhs mod p
func add{range_check_ptr}(lhs: BigInt4, rhs: BigInt4) -> (res: BigInt4):
    let (MODULUS) = MODULUS()
    # Bit 256 of p is set, so addition can result in five words.
    let (w0, carry) = adc(lhs.d0, rhs.d0, 0)
    let (w1, carry) = adc(lhs.d1, rhs,d1, carry)
    let (w2, carry) = adc(lhs.d2, rhs.d2, carry)
    let (w3, w4) = adc(lhs.d3, rhs.d3, carry)

    # Attempt to subtract the modulus, to ensure the result is in the field.
    let (res, borrow) = sub_inner(w0, w1, w2, w3, w4, MODULUS[0], MODULUS[1], MODULUS[2], MODULUS[3], 0)
    return (res=res)
end

# Returns lhs - rhs mod p
func sub{range_check_ptr}(lhs: BigInt4, rhs: BigInt4) -> (res: BigInt4):
    let (res, borrow) = sub_inner(lhs.d0, lhs.d1, lhs.d2, lhs.d3, 0, rhs.d0, rhs.d1, rhs.d2. rhs.d3, 0)
    return (res=res)
end

# Returns lhs * rhs mod p
func mul{range_check_ptr}(lhs: BigInt4, rhs: BigInt4) -> (res: BigInt4):
    # Schoolbook multiplication.
    let (w0, carry) = mac(0, lhs.d0, rhs.d0, 0)
    let (w1, carry) = mac(0, lhs.d0, rhs.d1, carry)
    let (w2, carry) = mac(0, lhs.d0, rhs.d2, carry)
    let (w3, w4) = mac(0, lhs.d0, rhs.d3, carry)

    let (w1, carry) = mac(w1, lhs.d1, rhs.d0, 0)
    let (w2, carry) = mac(w2, lhs.d1, rhs.d1, carry)
    let (w3, carry) = mac(w3, lhs.d1, rhs.d2, carry)
    let (w4, w5) = mac(w4, lhs.d1, rhs.d3, carry)

    let (w2, carry) = mac(w2, lhs.d2, rhs.d0, 0)
    let (w3, carry) = mac(w3, lhs.d2, rhs.d1, carry)
    let (w4, carry) = mac(w4, lhs.d2, rhs.d2, carry)
    let (w5, w6) = mac(w5, lhs.d2, rhs.d3, carry)

    let (w3, carry) = mac(w3, lhs.d3, rhs.d0, 0)
    let (w4, carry) = mac(w4, lhs.d3, rhs.d1, carry)
    let (w5, carry) = mac(w5, lhs.d3, rhs.d2, carry)
    let (w6, w7) = mac(w6, lhs.d3, rhs.d3, carry)

    let (res) = montgomery_reduce(w0, w1, w2, w3, w4, w5, w6, w7)
    return (res=res)
end

# Returns the multiplication of fe, if it is non-zero.
func invert{range_check_ptr}(fe: BigInt4) -> (res: BigInt4):
    # Make sure fe is non-zero
    let (zero) = bigint_zero()
    assert (fe != zero)


end