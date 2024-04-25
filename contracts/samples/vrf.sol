// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../chainlink/chainlink_modified.sol";

// does conditional execution add gas?
contract Vrf {
    uint256[2] pk;

    uint256 internal reqid = 0;

    GoldbergVrf internal gb;

    mapping(uint256 => bool) internal nonceUsed;
    mapping(uint256 => bytes32) private requests;

    event ReqGen(uint256 reqid, bytes x);
    event ReqFulf(uint256 reqid, bytes32 y);

    function init() public {
        gb = new GoldbergVrf();
    }

    function set_pk(uint256[2] memory _pk) public {
        pk = _pk;
    }

    function req(bytes memory x) public returns (uint256) {
        reqid = reqid + 1;
        requests[reqid] = keccak256(abi.encode(x));
        //requests[reqid] = keccak256(abi.encodePacked(x, msg.sender, block.number));
        emit ReqGen(reqid, x);
        return reqid;
    }

    function req_return_pt(bytes memory x) public returns (bytes32, uint256[2] memory)  {
        uint256 _reqid = req(x);
        bytes32 inp = keccak256(abi.encodePacked(x, _reqid));
        uint256[2] memory pt = gb._hashToCurve(pk, uint256(inp));
        emit ReqGen(reqid, x);
        return (inp, pt);
    }

    function fulf(bytes memory x, uint256 _reqid, bytes32 y, GoldbergVrf.Proof memory proof) public {
        require(!nonceUsed[_reqid]);
        require(requests[_reqid] == keccak256(abi.encode(x)));
        //bytes32 inp = abi.encodePacked(x, _reqid);
        vrf_ver(x, pk, y, proof);

        emit ReqFulf(_reqid, y);
        nonceUsed[_reqid] = true;
        
    }
    //function bytes32_to_uint256(bytes32 inp) public pure returns (uint256) {
    //    return uint256(inp);
    //}
    //function uint256_to_bytes32(uint256 inp) public pure returns (bytes32) {
    //    return bytes32(inp);
    //}

    // reverts on fail
    function vrf_ver(bytes memory inp, uint256[2] memory _pk, bytes32 y, GoldbergVrf.Proof memory proof) public view {

        gb._verifyVRFProof(
            _pk,
            proof.gamma,
            proof.c,
            proof.s,
            uint256(keccak256(abi.encodePacked(inp))),
            proof.uWitness,
            proof.cGammaWitness,
            proof.sHashWitness,
            proof.zInv
        );

        require(y == keccak256(abi.encode(proof.gamma)));
    }

}