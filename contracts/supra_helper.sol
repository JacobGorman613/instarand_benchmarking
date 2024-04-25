// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./supra/BLS_modified.sol";

library SupraHelper {
    function dvrf_ver(
        bytes memory inp,
        uint256[4] memory _pk,
        bytes32 y,
        uint256[2] memory pi
    ) public view {
        bytes32 domain = bytes32(uint256(uint160(msg.sender)) << 96);
        bls_ver(BLS.hashToPoint(domain, inp), _pk, pi);

        require(y == keccak256(abi.encode(pi)));
    }

    function bls_ver(
        uint256[2] memory inp,
        uint256[4] memory _pk,
        uint256[2] memory sig
    ) public view {
        bool callSuccess;
        bool checkSuccess;

        (checkSuccess, callSuccess) = BLS.verifySingle(sig, _pk, inp);

        require(
            callSuccess,
            "Verify : Incorrect Public key or Signature Points"
        );
        require(checkSuccess, "Verify : Incorrect Input Message");
    }
    function _formatted_inp(
        bytes memory x,
        uint256 _reqid
    ) public view returns (bytes memory, uint256[2] memory) {
        bytes memory inp = abi.encode(x, _reqid);
        bytes32 domain = bytes32(uint256(uint160(msg.sender)) << 96);
        uint256[2] memory inp_pt = BLS.hashToPoint(domain, inp);
        return (inp, inp_pt);
    }
}
