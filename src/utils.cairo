# Computes `a + b + carry`, returning the result along with the new carry.
# Input and Output values must be in range of [0, BASE).
from bigint import BASE
func adc{range_check_ptr}(a: felt, b: felt, carry: felt) -> (res, new_carry):
    alloc_locals
    local move
    local res
    local new_carry
    %{
        # Python treat a, b, carry as bigint, which is bigger than 128 bits
        ids.move = ids.a + ids.b + ids.carry
        ids.new_carry = ids.move // (2**64)
        ids.res = ids.move - ids.new_carry * 2**64
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
    [range_check_ptr + 6] = res
    assert [range_check_ptr + 7] = BASE - 1 - res

    # Check that 0 <= new_carry < 2 **64
    [range_check_ptr + 8] = new_carry
    assert [range_check_ptr + 9] = BASE - 1 - new_carry

    let range_check_ptr = range_check_ptr + 10
    return (res=res, new_carry=new_carry)
end

# Computes `a - (b + borrow)`, returning the result along with the new borrow.
# Input and Output values must be in range of [0, BASE).
func sbb{range_check_ptr}(a: felt, b: felt, borrow: felt) -> (res, new_borrow):
    alloc_locals
    local move
    local res
    local new_borrow
    %{
        # Python treat a, b, borrow as bigint, which is bigger than 128 bits
        ids.move = (ids.a - (ids.b + ids.borrow//2**63)) % 2**128
        ids.new_borrow = ids.move // (2**64)
        ids.res = ids.move - ids.new_borrow * 2**64
    %}

    # Check that 0 <= a < 2**64
    [range_check_ptr] = a
    assert [range_check_ptr + 1] = BASE - 1 - a

    # Check that 0 <= b < 2**64
    [range_check_ptr + 2] = b
    assert [range_check_ptr + 3] = BASE - 1 - b

    # Check that 0 <= borrow < 2**64
    [range_check_ptr + 4] = borrow
    assert [range_check_ptr + 5] = BASE - 1 - borrow

    # Check that 0 <= res < 2 **64
    [range_check_ptr + 6] = res
    assert [range_check_ptr + 7] = BASE - 1 - res

    # Check that 0 <= new_borrow < 2 **64
    [range_check_ptr + 8] = new_borrow
    assert [range_check_ptr + 9] = BASE - 1 - new_borrow

    let range_check_ptr = range_check_ptr + 10
    return (res=res, new_borrow=new_borrow)
end

# Computes `a + (b * c) + carry`, returning the result along with the new carry.
# Input and Output values must be in range of [0, BASE).
func mac{range_check_ptr}(a: felt, b: felt, c: felt, carry: felt) -> (res, new_carry):
    alloc_locals
    local move
    local res
    local new_carry
    %{
        # Python treat a, b, c, carry as bigint, which is bigger than 128 bits
        ids.move = ids.a + ids.b * ids.c + ids.carry
        ids.new_carry = ids.move // (2**64)
        ids.res = ids.move - ids.new_carry * 2**64 
    %}

    # Check that 0 <= a < 2**64
    [range_check_ptr] = a
    assert [range_check_ptr + 1] = BASE - 1 - a

    # Check that 0 <= b < 2**64
    [range_check_ptr + 2] = b
    assert [range_check_ptr + 3] = BASE - 1 - b

    # Check that 0 <= c < 2**64
    [range_check_ptr + 4] = c
    assert [range_check_ptr + 5] = BASE - 1 - c

    # Check that 0 <= carry < 2**64
    [range_check_ptr + 6] = carry
    assert [range_check_ptr + 7] = BASE - 1 - carry

    # Check that 0 <= res < 2 **64
    [range_check_ptr + 8] = res
    assert [range_check_ptr + 9] = BASE - 1 - res

    # Check that 0 <= new_carry < 2 **64
    [range_check_ptr + 10] = new_carry
    assert [range_check_ptr + 11] = BASE - 1 - new_carry

    let range_check_ptr = range_check_ptr + 12
    return (res=res, new_carry=new_carry)
end