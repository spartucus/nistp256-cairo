%builtins range_check

from bigint import BigInt3
from p256 import verify_ecdsa
from p256_ec import EcPoint

func main{range_check_ptr}():
    let public_key_pt = EcPoint(
        BigInt3(0x3fb12f3c59ff46c271bf83,0x3e89236e3f334d5977a52e,0x1ccbe91c075fc7f4f033b),
        BigInt3(0x4e78dc7ccd5ca89a4ca9,0x2cb039844f81b6df2a4edd,0xce4014c68811f9a21a1fd))
    let r = BigInt3(0x155a7acabb5e6f79c8c2ac,0xf598a549fb4abf5ac7da9,0xf3ac8061b514795b8843e)
    let s = BigInt3(0x2f175a3ccdda2acc058903,0x1898afdcdc73be5ec863a5,0x8bf77819ca05a6b2786c7)
    let msg_hash = BigInt3(0x100377dbc4e7a6a133ec56,0x25c813f825413878bbec6a,0x44acf6b7e36c1342c2c58)
    verify_ecdsa(public_key_pt=public_key_pt, msg_hash=msg_hash, r=r, s=s)
    return ()
end
