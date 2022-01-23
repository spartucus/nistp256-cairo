# The base of the representation.
const BASE = 2 ** 64

# Represents an integer defined by
#   d0 + BASE * d1 + BASE**2 * d2 + BASE**3 * d3.
# Note that d0, d1, d2, d3 must be in the range [0, BASE).
# In most cases this is used to represent a secp256r1 field element.
struct BigInt4:
    # The first 64 bits of the value
    member d0: felt
    # The second 64 bits of the value
    member d1: felt
    # The third 64 bits of the value
    member d2: felt
    # The forth 64 bits of the value
    member d3: felt
end

func bigint_zero() -> (res: BigInt4):
    return (
        BigInt4(
        d0=0,
        d1=0,
        d2=0,
        d3=0,
        ))
end

func bigint_one() -> (res: BigInt4):
    return (
        BigInt4(
        d0=0x0000000000000001,
        d1=0xffffffff00000000,
        d2=0xffffffffffffffff,
        d3=0x00000000fffffffe,
        ))
end

# Computes `a + b + carry`, returning the result along with the new carry.
# Input and Output values must be in range of [0, BASE).
func adc{range_check_ptr}(a: felt, b: felt, carry: felt) -> (res, new_carry):
    alloc_locals
    local res
    local new_carry
    %{
        # Python treat a, b, c as bigint, which is bigger than 128 bits
        ids.res = ids.a + ids.b + ids.carry
        ids.new_carry = ids.res / BASE
    %}

    # Check that 0 <= a < 2**64
    [range_check_ptr] = a
    assert [range_check_ptr + 1] = BASE - 1 - a

    # Check that 0 <= b < 2**64
    [range_check_ptr + 2] = b
    assert [range_check_ptr + 3] = BASE - 1 - b

    # Check that 0 <= carry < 2**64
    [range_check_ptr + 4] = carry
    assert [range_check_ptr + 5] = BASE - 1 - carry

    # Check that 0 <= res < 2 **64
    [range_check_ptr + 6] = carry
    assert [range_check_ptr + 7] = BASE - 1 - carry

    # Check that 0 <= new_carry < 2 **64
    [range_check_ptr + 8] = new_carry
    assert [range_check_ptr + 9] = BASE - 1 - new_carry

    let range_check_ptr = range_check_ptr + 10
    return (res=res, new_carry=new_carry)
end