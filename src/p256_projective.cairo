%builtins range_check

from bigint import BASE, BigInt4, MODULUS, CURVE_EQUATION_B, bigint_zero, bigint_one
from utils import adc, sbb, mac
from starkware.cairo.common.bitwise import bitwise_and
from p256_field import mul as field_mul
from p256_field import add as field_add
from p256_field import sub as field_sub
from p256_field import double as field_double
from p256_field import square as field_square

#ec point in projective. for affine point, z=1
struct EcPoint:
    member x: BigInt4
    member y: BigInt4
    member z: BigInt4
end

# Identity of the group: the point at infinity.
func IDENTITY() -> (EcPoint):
    let (ZERO) = bigint_zero()
    let (ONE) = bigint_one()
    let res = EcPoint(
        x=ZERO,
        y=ONE,
        z=ZERO
    )
    return (res)
end

# Base point of P-256.
func GENERATOR() -> (EcPoint):
    let (ONE) = bigint_one()
    let x = BigInt4(
        d0=0xf4a13945d898c296,
        d1=0x77037d812deb33a0,
        d2=0xf8bce6e563a440f2,
        d3=0x6b17d1f2e12c4247
    )
    let y = BigInt4(
        d0=0xcbb6406837bf51f5,
        d1=0x2bce33576b315ece,
        d2=0x8ee7eb4a7c0f9e16,
        d3=0x4fe342e2fe1a7f9b
    )
    let res = EcPoint(
        x=x,
        y=y,
        z=ONE
    )

    return (res)
end

# Returns `self + other`.
# we ignore add_mix function, which is designed for (projective point + affine point)
func add(lhs: EcPoint, rhs: EcPoint) -> (EcPoint):
    let (xx) = field_mul(lhs.x, rhs.x)
    let (yy) = field_mul(lhs.y, rhs.y)
    let (zz) = field_mul(lhs.z, rhs.z)

    let (l_xy) = field_add(lhs.x, lhs.y)
    let (r_xy) = field_add(rhs.x, rhs.y)
    let (xx_yy) = field_add(xx, yy)
    let (lr_xy) = field_mul(l_xy, r_xy)
    let (xy_pairs) = field_sub(lr_xy, xx_yy)

    let (l_yz) = field_add(lhs.y, lhs.z)
    let (r_yz) = field_add(rhs.y, rhs.z)
    let (yy_zz) = field_add(yy, zz)
    let (lr_yz) = field_mul(l_yz, r_yz)
    let (yz_pairs) = field_sub(lr_yz, yy_zz)

    let (l_xz) = field_add(lhs.x, lhs.z)
    let (r_yz) = field_add(rhs.x, rhs.z)
    let (xx_zz) = field_add(xx, zz)
    let (lr_xz) = field_mul(l_xz, r_xz)
    let (xz_pairs) = field_sub(lr_xz, xx_zz)

    let (CURVE_EQUATION_B) = CURVE_EQUATION_B()
    let (b_zz) = field_mul(CURVE_EQUATION_B, zz)
    let (bzz_part) = field_sub(xz_pairs, b_zz)
    let (bzz2_part) = field_double(bzz_part)
    let (bzz3_part) = field_add(bzz2_part, bzz_part)

    let (yy_m_bzz3) = field_sub(yy, bzz3_part)
    let (yy_p_bzz3) = field_add(yy, bzz3_part)

    let (zz2) = field_double(zz)
    let (zz3) = field_add(zz2, zz)
    let (b_xz_part) = field_mul(CURVE_EQUATION_B, xz_pairs)
    let (zz3_xx) = field_add(zz3, xx)
    let (bxz_part) = field_sub(b_xz_part, zz3_xx)
    let (bxz2_part) = field_double(bxz_part)
    let (bxz3_part) = field_add(bxz2_part, bxz_part)
    let (xx2) = field_double(xx)
    let (xx3) = field_add(xx2, xx)
    let (xx3_m_zz3) = field_sub(xx3, zz3)

    let (yy_p_bzz3_m_xy_pairs) = field_mul(yy_p_bzz3, xy_pairs)
    let (yz_pairs_m_bxz3_part) = field_mul(yz_pairs, bxz3_part)
    let (x) = field_sub(yy_p_bzz3_m_xy_pairs, yz_pairs_m_bxz3_part)

    let (yy_p_bzz3_m_yy_m_bzz3) = field_mul(yy_p_bzz3, yy_m_bzz3)
    let (xx3_m_zz3_m_bxz3_part) = field_mul(xx3_m_zz3, bxz3_part)
    let (y) = field_add(yy_p_bzz3_m_yy_m_bzz3, xx3_m_zz3_m_bxz3_part)

    let (yy_m_bzz3_m_yz_pairs) = field_mul(yy_m_bzz3, yz_pairs)
    let (xy_pairs_m_xx3_m_zz3) = field_add(xy_pairs, xx3_m_zz3)
    let (z) = field_add(yy_m_bzz3_m_yz_pairs, xy_pairs_m_xx3_m_zz3)

    return EcPoint(
        x=x,
        y=y,
        z=z
    )
end

# Doubles this point.
func double(a: EcPoint) -> (EcPoint):
    let (xx) = field_square(a.x)
    let (yy) = field_square(a.y)
    let (zz) = field_square(a.z)
    let (xy) = field_mul(a.x, a.y)
    let (xz) = field_mul(a.x, a.z)
    let (xy2) = field_double(xy)
    let (xz2) = field_double(xz)

    let (CURVE_EQUATION_B) = CURVE_EQUATION_B()
    let (b_zz) = field_mul(CURVE_EQUATION_B, zz)
    let (bzz_part) = field_sub(b_zz, xz2)
    let (bzz2_part) = field_double(bzz_part)
    let (bzz3_part) = field_add(bzz2_part, bzz_part)

    let (yy_m_bzz3) = field_sub(yy, bzz3_part)
    let (yy_p_bzz3) = field_add(yy, bzz3_part)
    let (y_frag) = field_mul(yy_p_bzz3, yy_m_bzz3)
    let (x_frag) = field_mul(yy_m_bzz3, xy2)

    let (zz2) = field_double(zz)
    let (zz3) = field_add(zz2, zz)
    let (b_xz2) = field_mul(CURVE_EQUATION_B, xz2)
    let (zz3_xx) = field_add(zz3, xx)
    let (bxz2_part) = field_sub(b_xz2, zz3_xx)
    let (bxz4_part) = field_double(bxz2_part)
    let (bxz6_part) = field_add(bxz4_part, bxz2_part)
    let (xx2) = field_double(xx)
    let (xx3) = field_add(xx2, xx)
    let (xx3_m_zz3) = field_sub(xx3, zz3)

    let (xx3_m_zz3_m_bxz6_part) = field_mul(xx3_m_zz3, bxz6_part)
    let (y) = field_add(y_frag, xx3_m_zz3_m_bxz6_part)
    let (yz) = field_mul(a.y, a.z)
    let (yz2) = field_double(yz)
    let (bxz6_part_m_yz2) = field_mul(bxz6_part, yz2)
    let (x) = field_sub(x_frag, bxz6_part_m_yz2)
    let (yz2_m_yy) = field_mul(yz2, yy)
    let (yz2_m_yy2) = field_double(yz2_m_yy)
    let (z) = field_double(yz2_m_yy2)

    return EcPoint(
        x=x,
        y=y,
        z=z
    )
end

# Returns `[k] a`.
func mul(a:EcPoint, k: BigInt4) -> (res: EcPoint):
    let (IDENTITY) = IDENTITY()
end