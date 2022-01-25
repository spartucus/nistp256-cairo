%builtins  output range_check bitwise
from starkware.cairo.common.serialize import serialize_word
from bigint import BigInt4, bigint_zero, bigint_one, bigint_MODULUS, out_bigInt4
from p256_filed import add, to_canonical, mul, sub, out_canonical, to_montgomery,div_mod
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

func main{output_ptr,range_check_ptr,bitwise_ptr:BitwiseBuiltin*}():
    let (one) = bigint_one()
    let (two) = add(one,one)
    #out_canonical(two)
    let (four) = mul(two,two)
    #out_canonical(four)
    let (p) = bigint_MODULUS()
    
    let (mone) = sub(p,one)
    #out_canonical(mone)
    let (mtwo) = sub(p,two)
    #out_canonical(mtwo)
    let (mmtwo) = mul(mtwo,mtwo)
    #out_canonical(mmtwo)




    let cx = BigInt4(
        d0=0xf4a13945d898c296,
        d1=0x77037d812deb33a0,
        d2=0xf8bce6e563a440f2,
        d3=0x6b17d1f2e12c4247
    )
    let cy = BigInt4(
        d0=0xcbb6406837bf51f5,
        d1=0x2bce33576b315ece,
        d2=0x8ee7eb4a7c0f9e16,
        d3=0x4fe342e2fe1a7f9b
    )
    let ca = BigInt4(    #a = -3
        d0=0xfffffffffffffffc,
        d1=0x00000000ffffffff,
        d2=0x0000000000000000,
        d3=0xffffffff00000001,
    )
    let cb = BigInt4(
        d0=0x3BCE3C3E27D2604B,
        d1=0x651D06B0CC53B0F6,
        d2=0xB3EBBD55769886BC,
        d3=0x5AC635D8AA3A93E7,
    )
    let (x) = to_montgomery(cx)
    let (y) = to_montgomery(cy)
    let (a) = to_montgomery(ca)
    let (b) = to_montgomery(cb)
    let (yy) = mul(y,y)
    #out_canonical(yy)
    let (xx) = mul(x,x)
    let (xxx) = mul(xx,x)
    let (ax) = mul(a,x)
    let (res) = add(xxx,ax)
    let (res) = add(res,b)
    #out_canonical(res)
    #yy == res

    let (step1) = div_mod(yy,x,p)  # y^2/x
    let (step2) = div_mod(b,x,p)       # b/x
    let (step3) = add(xx,a)       # (x^2+a)R
    let (step4) = sub(step1,step2) # y^2/x-b/x
    out_bigInt4(step4)
    out_canonical(step3)
    # step4 == step3
    return ()
end