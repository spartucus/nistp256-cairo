%builtins  output range_check bitwise
from starkware.cairo.common.serialize import serialize_word
from bigint import BigInt4, bigint_zero, bigint_one, out_bigInt4
from p256_filed import add, to_canonical
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

func main{output_ptr,range_check_ptr,bitwise_ptr:BitwiseBuiltin*}():
    let (zero) = bigint_one()
    let (czero) = to_canonical(zero)
    out_bigInt4(czero)
    let (one) = bigint_one()
    let (res) = add(zero,one)
    let (cres) = to_canonical(res)
    out_bigInt4(cres)
    return ()
end