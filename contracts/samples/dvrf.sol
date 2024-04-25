// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../supra/BLS_modified.sol";
import "../supra/BNPairingPrecompileCostEstimator.sol";
import "../supra_mod.sol";

// does conditional execution add gas?
contract Dvrf {
    uint256[4] pk;

    uint256 internal reqid = 0;
    mapping(uint256 => bool) internal nonceUsed;

    event ReqGen(uint256 reqid, bytes x);
    event ReqFulf(uint256 reqid, bytes32 y);

    function set_pk(uint256[4] memory _pk) public {
        pk = _pk;
    }

    function req(bytes memory x) public returns (uint256) {
        reqid = reqid + 1;

        emit ReqGen(reqid, x);

        return reqid;
    }

    function fulf(
        bytes memory x,
        uint256 _reqid,
        bytes32 y,
        uint256[2] calldata proof
    ) public {
        require(!nonceUsed[_reqid]);

        SupraHelper.dvrf_ver(abi.encode(x, _reqid), pk, y, proof);

        emit ReqFulf(_reqid, y);

        nonceUsed[_reqid] = true;
    }
}
