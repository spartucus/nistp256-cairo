%builtins output range_check 

from starkware.cairo.common.serialize import serialize_word
from bigint import BigInt4, bigint_zero, bigint_one

func main():
    let zero = bigint_zero()
    let one = bigint_one()
    serialize_word(zero)
    serialize_word(one)
end