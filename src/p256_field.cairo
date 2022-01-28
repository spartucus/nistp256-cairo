from bigint import BASE, BigInt3, UnreducedBigInt3, UnreducedBigInt5, nondet_bigint3,bigint_mul

#is val mod n =0?
func verify_urbigInt5_zero{range_check_ptr}(val : UnreducedBigInt5, n : BigInt3):
    
    alloc_locals
    local flag 
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack
        n = pack(ids.n, PRIME)
        v3 = ids.val.d3 if ids.val.d3 < PRIME//2 else ids.val.d3 - PRIME
        v4 = ids.val.d4 if ids.val.d4 < PRIME//2 else ids.val.d4 - PRIME
        v = pack(ids.val, PRIME) + v3*2**258 + v4*2**344
        q, r = divmod(v, n)
        
        assert r == 0, f"verify_zero: Invalid input {ids.val.d0, ids.val.d1, ids.val.d2}."
        value = q  if q > 0 else 0 - q
        ids.flag = 1 if q > 0 else 0
    %}
    let (k) = nondet_bigint3()
    let (k_n) = bigint_mul(k, n)
    
    #val mod n = 0, so val = k_n
    tempvar carry1 = (( 2*flag - 1 ) * k_n.d0 - val.d0) / BASE
    assert [range_check_ptr + 0] = carry1 + 2 ** 127

    tempvar carry2 = (( 2*flag - 1 ) * k_n.d1 - val.d1 + carry1) / BASE
    assert [range_check_ptr + 1] = carry2 + 2 ** 127

    tempvar carry3 = (( 2*flag - 1 ) * k_n.d2 - val.d2 + carry2) / BASE
    assert [range_check_ptr + 2] = carry3 + 2 ** 127

    tempvar carry4 = (( 2*flag - 1 ) * k_n.d3 - val.d3 + carry3) / BASE
    assert [range_check_ptr + 3] = carry4 + 2 ** 127

    assert ( 2*flag - 1 ) * k_n.d4 - val.d4 + carry4 = 0
    
    let range_check_ptr = range_check_ptr + 4
    
    return ()
end

func verify_urbigInt3_zero{range_check_ptr}(val : UnreducedBigInt3, n : BigInt3):
    verify_urbigInt5_zero(UnreducedBigInt5(d0=val.d0, d1=val.d1, d2=val.d2, 0, 0), n)
    return ()
end

#return 1 if x ==0 mod n
func is_urbigInt3_zero{range_check_ptr}(x : BigInt3, n : BigInt3) -> (res : felt):
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import  pack
        n = pack(ids.n, PRIME)
        x = pack(ids.x, PRIME) % n
    %}
    if nondet %{ x == 0 %} != 0:
        verify_urbigInt3_zero(UnreducedBigInt3(d0=x.d0, d1=x.d1, d2=x.d2), n)
        return (res=1)
    end
    
    %{
        from starkware.python.math_utils import div_mod
        value = x_inv = div_mod(1, x, n)
    %}
    let (x_inv) = nondet_bigint3()
    let (x_x_inv) = bigint_mul(x, x_inv)

    # Check that x * x_inv = 1 to verify that x != 0.
    verify_urbigInt5_zero(UnreducedBigInt5(
        d0=x_x_inv.d0 - 1,
        d1=x_x_inv.d1,
        d2=x_x_inv.d2,
        d3=x_x_inv.d3,
        d4=x_x_inv.d4), n)
    return (res=0)
end