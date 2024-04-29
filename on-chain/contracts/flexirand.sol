// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./BLS.sol";

/**
 * @title FlexiRand
 * @dev TODO
 * @custom:dev-run-script ../scripts/deploy_and_bench_flexirand.ts
 */
contract FlexiRand {
    uint256[4] pk;
    bytes32 domain;
    
    // hard-code value of precompile_gas_cost since library can only have constant values
    uint256 private constant PRECOMPILE_GAS_COST =  79133;
    uint256 internal reqid = 0;
    
    mapping(uint256 => bytes32) private requests;
    mapping(uint256 => uint256[2]) private inputs;
    mapping(uint256 => uint256[2]) private outputs;


    constructor() {
        domain = bytes32(uint256(uint160(address(this))));        
    }

    event ReqGen(uint256 reqid, bytes e);
    event BlindedInputSubmitted(
        uint256 reqid,
        uint256[2] x_blind,
        ZkpKdl proof
    );
    event Prever(uint256 reqid, uint256[2] y_blind);
    event Ver(uint256 reqid, bytes32 y);

    event GasMeasurementFlexiRand(uint256 gas, uint256 reqid);

    struct FormattedInput {
        bytes e;
        uint256 reqid;
    }

    struct ZkpKdl {
        uint256 s;
        uint256 c;
    }

    function set_pk(uint256[4] memory _pk) public {
        pk = _pk;
    }

    function gen_req(bytes memory e) public returns (uint256) {
        uint256 startGas = gasleft();

        reqid += 1;
        requests[reqid] = keccak256(abi.encodePacked(e));
        // requests[reqid] = keccak256(abi.encodePacked(e, msg.sender, block.number));
        emit ReqGen(reqid, e);

        uint256 endGas = gasleft();
        emit GasMeasurementFlexiRand(startGas - endGas, reqid);

        return reqid;
    }

    // reverts on fail
    function submit_blinding(
        FormattedInput memory x,
        uint256[2] memory x_blind,
        ZkpKdl memory proof
    ) public {
        uint256 startGas = gasleft();

        require(requests[x.reqid] == keccak256(abi.encodePacked(x.e)));
        require(inputs[x.reqid][0] == 0 && inputs[x.reqid][1] == 0);

        //inp_verifier.inp_ver(x, proof, x_blind);

        inputs[x.reqid] = x_blind;

        emit BlindedInputSubmitted(x.reqid, x_blind, proof);

        uint256 endGas = gasleft();
        emit GasMeasurementFlexiRand(startGas - endGas, 2);
    }

    function pre_ver(
        uint256 _reqid,
        uint256[2] memory y_blind
    ) public {
        uint256 startGas = gasleft();

        require(outputs[_reqid][0] == 0 && outputs[_reqid][1] == 0);

        uint256[2] memory x_blind = inputs[_reqid];
        require(!(x_blind[0] == 0 && x_blind[1] == 0));

        verify_bls_signature(x_blind, y_blind);

        outputs[_reqid] = y_blind;

        emit Prever(_reqid, y_blind);

        uint256 endGas = gasleft();
        emit GasMeasurementFlexiRand(startGas - endGas, 3);
    }


    function fulf(
        FormattedInput memory x,
        bytes32 y,
        uint256[2] memory pi
    ) public {
        uint256 startGas = gasleft();

        require(requests[x.reqid] == keccak256(abi.encodePacked(x.e)));

        uint256[2] memory x_blind = inputs[x.reqid];
        uint256[2] memory y_blind = outputs[x.reqid];

        require(!(x_blind[0] == 0 && x_blind[1] == 0));
        require(!(y_blind[0] == 0 && y_blind[1] == 0));

        verify_glow_dvrf(y, abi.encodePacked(x.e, x.reqid), pi);

        delete requests[x.reqid];
        emit Ver(x.reqid, y);

        uint256 endGas = gasleft();
        emit GasMeasurementFlexiRand(startGas - endGas, 4);
    }

    
    // validates that `proof` is a valid BLS signature on `inp` with respect to `pk` and that y == H(proof) 
    function verify_glow_dvrf(bytes32 y, bytes memory inp, uint256[2] memory proof) internal view {
        require(y == keccak256(abi.encodePacked(proof)));
        verify_bls_signature(BLS.hashToPoint(domain, inp), proof);
    }

    // validates that `proof` is a valid BLS signature on `inp` with respect to `pk`
    function verify_bls_signature(uint256[2] memory inp, uint256[2] memory proof) internal view {
        bool callSuccess;
        bool checkSuccess;

        (checkSuccess, callSuccess) = BLS.verifySingle(
            proof,
            pk,
            inp,
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
