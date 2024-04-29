// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./DDH.sol";

/**
 * @title Vrf
 * @dev TODO
 * @custom:dev-run-script ../scripts/deploy_and_bench_vrf.ts
 */
contract Vrf {
    
    uint256[2] pk;

    uint256 internal reqid = 0;

    //mapping(uint256 => bool) internal nonceUsed;
    mapping(uint256 => bytes32) private requests;

    event ReqGen(uint256 reqid, bytes x);
    event ReqFulf(uint256 reqid, bytes32 y);

    event GasMeasurementVrf(uint256 gas, uint256 reqid);

    function set_pk(uint256[2] memory _pk) public {
        pk = _pk;
    }

    function req(bytes memory x) public returns (uint256) {
        
        uint256 startGas = gasleft();

        reqid = reqid + 1;
        requests[reqid] = keccak256(abi.encodePacked(x));
        emit ReqGen(reqid, x);

        uint256 endGas = gasleft();

        emit GasMeasurementVrf(startGas - endGas, reqid);

        // the cost to return a uint256 is low and is covered by "total cost" table column
        // this can be verified TODO
        return reqid;
    }
    
    function fulf(
        uint256 x,
        uint256 _reqid,
        bytes32 y,
        DDH.Proof memory proof
    ) public {
        uint256 startGas = gasleft();
        
        require(requests[_reqid] == keccak256(abi.encodePacked(x)));
        verify_ddh_vrf(abi.encodePacked(x, _reqid), y, proof);

        emit ReqFulf(_reqid, y);

        //nonceUsed[_reqid] = true;
        delete requests[_reqid];

        uint256 endGas = gasleft();
        emit GasMeasurementVrf(startGas - endGas, reqid);
    }

    // reverts on fail
    function verify_ddh_vrf(
        bytes memory inp,
        bytes32 y,
        DDH.Proof memory proof
    ) internal view {
        DDH._verifyVRFProof(
            pk,
            proof.gamma,
            proof.c,
            proof.s,
            uint256(keccak256(abi.encodePacked(inp))),
            proof.uWitness,
            proof.cGammaWitness,
            proof.sHashWitness,
            proof.zInv
        );

        require(y == keccak256(abi.encodePacked(proof.gamma)));
    }


    function _hash_gamma_to_y(uint256[2] memory gamma) public pure returns (bytes32) {
         return keccak256(abi.encodePacked(gamma));
    }
}
