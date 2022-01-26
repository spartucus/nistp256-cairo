from starkware.cairo.common.math import assert_nn_le, assert_not_zero
from bigint import BASE, N0, N1, N2, N3

# Verifies that val is in the range [1, N).
func validate_signature_entry{range_check_ptr}(val : BigInt4):
    assert_nn_le(val.d3, N3)
    assert_nn_le(val.d2, BASE - 1)
    assert_nn_le(val.d1, BASE - 1)
    assert_nn_le(val.d0, BASE - 1)

    if val.d3 == N3:
        if val.d2 == N2:
            if val.d1 == N1:
                assert_nn_le(val.d0, N0 - 1)
                return ()
            end
            assert_nn_le(val.d1, N1 - 1)
            return ()
        end
        assert_nn_le(val.d2, N2 - 1)
        return ()
    end

    if val.d3 == 0:
        if val.d2 == 0:
            if val.d1 == 0:
                # Make sure val > 0.
                assert_not_zero(val.d0)
                return ()
            end
        end
    end
    return ()
end

func pack_div_mod(x : BigInt4, s : BigInt4) -> (res: BigInt4, k: BigInt4):
    alloc_locals
    local res : BigInt4
    local k : BigInt4
    %{
        from starkware.python.math_utils import div_mod
        from starkware.cairo.common.math_utils import as_int

        N = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
        limbs_x = ids.x.d0, ids.x.d1, ids.x.d2, ids.x.d3
        value_x = sum(as_int(limb, PRIME) * 2 ** (64 * i) for i, limb in enumerate(limbs_x)) % N

        limbs_s = ids.s.d0, ids.s.d1, ids.s.d2, ids.s.d3
        value_s = sum(as_int(limb, PRIME) * 2 ** (64 * i) for i, limb in enumerate(limbs_s)) % N

        value = div_mod(value_x, value_s, N)

        num, residue = divmod(value, BASE)
        ids.res.d3 = residue

        num, residue = divmod(num, BASE)
        ids.res.d2 = residue

        num, residue = divmod(num, BASE)
        ids.res.d1 = residue

        num, residue = divmod(num, BASE)
        ids.res.d0 = residue

        value = safe_div(value * value_s - value_x, N)

        num, residue = divmod(value, BASE)
        ids.k.d3 = residue

        num, residue = divmod(num, BASE)
        ids.k.d2 = residue

        num, residue = divmod(num, BASE)
        ids.k.d1 = residue

        num, residue = divmod(num, BASE)
        ids.k.d0 = residue
    %}

    return (res=res, k=k)
end

# Computes x * s^(-1) modulo the size of the elliptic curve (N).
func mul_s_inv{range_check_ptr}(x : BigInt4, s : BigInt4) -> (res : BigInt4):
    let (res, k) = pack_div_mod(x, s)
    return (res=res)
end