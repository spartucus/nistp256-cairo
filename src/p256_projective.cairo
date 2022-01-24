%builtins range_check

from bigint import BASE, BigInt4, MODULUS, bigint_zero, bigint_one
from utils import adc, sbb, mac
from starkware.cairo.common.bitwise import bitwise_and

#ec point in projective. for affine point, z=1
struct EcPoint:
    member x: BigInt4
    member y: BigInt4
    member z: BigInt4
end