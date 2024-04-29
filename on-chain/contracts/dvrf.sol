// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./BLS.sol";
/**
 * @title Dvrf
 * @dev TODO
 * @custom:dev-run-script ../scripts/deploy_and_bench_dvrf.ts
 */
contract Dvrf {
    uint256[4] pk;
    bytes32 domain;
    
    // hard-code value of precompile_gas_cost since library can only have constant values
    uint256 private constant PRECOMPILE_GAS_COST =  79133;
    uint256 internal reqid = 0;
    
    mapping(uint256 => bool) internal nonceUsed;

    event ReqGen(uint256 reqid, bytes x);
    event ReqFulf(uint256 reqid, bytes32 y);
    event GasMeasurementDvrf(uint256 gas, uint256 reqid);

    struct FormattedInput {
        bytes x;
        uint256 reqid;
    }

    constructor() {
        domain = bytes32(uint256(uint160(address(this))));        
    }

    function set_pk(uint256[4] memory _pk) public {
        pk = _pk;
    }

    // 1. generate dvrf request 
    function req(bytes memory x) public returns (uint256) {
        uint256 startGas = gasleft();

        reqid = reqid + 1;
        emit ReqGen(reqid, x);

        uint256 endGas = gasleft();
        emit GasMeasurementDvrf(startGas - endGas, reqid);

        // the cost to return a uint256 is low and is covered by "total cost" table column
        // this can be verified TODO
        return reqid;
    }

    // 2. fulfill dvrf request
    function fulf(
        FormattedInput memory inp,
        bytes32 y,
        uint256[2] calldata proof
    ) public {
        uint256 startGas = gasleft();

        uint256 _reqid = inp.reqid;

        require(!nonceUsed[_reqid]);

        verify_glow_dvrf(y, abi.encodePacked(inp.x, inp.reqid), proof);

        nonceUsed[_reqid] = true;
        emit ReqFulf(_reqid, y);

        uint256 endGas = gasleft();
        emit GasMeasurementDvrf(startGas - endGas, _reqid);
    }

    function verify_glow_dvrf(bytes32 y, bytes memory inp, uint256[2] memory proof) internal view {
        
        require(y == keccak256(abi.encodePacked(proof)));

        bool callSuccess;
        bool checkSuccess;

        (checkSuccess, callSuccess) = BLS.verifySingle(
            proof,
            pk,
            BLS.hashToPoint(domain, inp),
            PRECOMPILE_GAS_COST
        );

        require(
            callSuccess,
            "Verify : Incorrect Public key or Signature Points"
        );
        require(checkSuccess, "Verify : Incorrect Input Message");
    }

    function _hash_proof(uint256[2] memory proof) public pure returns (bytes32) {
         return keccak256(abi.encodePacked(proof));
    }

}
