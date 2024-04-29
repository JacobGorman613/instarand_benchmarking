// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./BLS.sol";
import "./DDH.sol";
/**
 * @title InstaRand
 * @dev TODO
 * @custom:dev-run-script ../scripts/deploy_and_bench_instarand.ts
 */
contract InstaRand {
    uint256[4] pk_server;
    bytes32 domain;

    mapping(bytes32 => uint256[2]) internal server_outputs;
    mapping(bytes32 => mapping(uint256 => bool)) internal nonceUsed;

    event KeyRegistered(ClientInput x);
    event Prever(ClientInput x, uint256[2] sig);
    event Ver(uint256[2] pk_c, uint256 i, bytes32 z_i);

    event GasMeasurementInstaRand(uint256 gas);
    
    // hard-code value of precompile_gas_cost since library can only have constant values
    uint256 private constant PRECOMPILE_GAS_COST =  79133;
    
    constructor() {
        domain = bytes32(uint256(uint160(address(this))));        
    }

    struct ClientInput {
        uint256[2] pk;
        bytes e;
    }

    // set server public key
    function set_pk(uint256[4] memory pk) public {
        pk_server = pk;
    }
    
    function register_client_key(ClientInput memory x) public {
        uint256 startGas = gasleft();

        emit KeyRegistered(x);

        uint256 endGas = gasleft();
        emit GasMeasurementInstaRand(startGas - endGas);
    }

    function pre_ver(ClientInput memory x, uint256[2] memory signature) public {
    //function pre_ver(ClientInput memory x, bytes32 y, uint256[2] memory pi) public {
        uint256 startGas = gasleft();

        bytes memory inp = abi.encodePacked(x.e, x.pk);


        require(server_outputs[keccak256(inp)][0] == 0 && server_outputs[keccak256(inp)][1] == 0);

        verify_bls_signature(inp, pk_server, signature);

        //verify_glow_dvrf(y, inp, signature);
        server_outputs[keccak256(abi.encodePacked(x.e, x.pk))] = signature;
        emit Prever(x, signature);

        uint256 endGas = gasleft();
        emit GasMeasurementInstaRand(startGas - endGas);

    }

    function fulfill(ClientInput memory x, uint256 i, bytes32 w_i, DDH.Proof memory pi_i) public {
        uint256 startGas = gasleft();

        bytes32 key = keccak256(abi.encodePacked(x.e, x.pk));
        
        uint256[2] memory y = server_outputs[key];

        require(y[0] != 0 || y[1] != 0);
        require(!nonceUsed[key][i]);

        bytes memory inp = abi.encode(x.e, x.pk, y, i);

        verify_ddh_vrf(inp, x.pk, w_i, pi_i);

        bytes32 z_i = keccak256(abi.encodePacked(inp, w_i));
        nonceUsed[key][i] = true;

        emit Ver(x.pk, i, z_i);

        uint256 endGas = gasleft();
        emit GasMeasurementInstaRand(startGas - endGas);
    }
    
/*
    function verify_glow_dvrf(bytes32 y, bytes memory inp, uint256[2] memory proof) internal view {
        require(y == keccak256(abi.encodePacked(proof)));

        bool callSuccess;
        bool checkSuccess;

        (checkSuccess, callSuccess) = BLS.verifySingle(
            proof,
            pk_server,
            BLS.hashToPoint(domain, inp),
            PRECOMPILE_GAS_COST
        );

        require(
            callSuccess,
            "Verify : Incorrect Public key or Signature Points"
        );
        require(checkSuccess, "Verify : Incorrect Input Message");
    }
*/

    
    // validates that `proof` is a valid BLS signature on `inp` with respect to `pk`
    function verify_bls_signature(bytes memory inp,  uint256[4] memory pk, uint256[2] memory proof) internal view {
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

    // reverts on fail
    function verify_ddh_vrf(
        bytes memory inp,
        uint256[2] memory _pk,
        bytes32 y,
        DDH.Proof memory proof
    ) internal view {
        DDH._verifyVRFProof(
            _pk,
            proof.gamma,
            proof.c,
            proof.s,
            uint256(keccak256(inp)),
            proof.uWitness,
            proof.cGammaWitness,
            proof.sHashWitness,
            proof.zInv
        );
        require(y == keccak256(abi.encodePacked(proof.gamma)));
    }
    
    // reverts on fail
    function verify_ddh_vrf_lite(
        bytes memory inp,
        uint256[2] memory _pk,
        DDH.Proof memory proof
    ) internal view {
        DDH._verifyVRFProof(
            _pk,
            proof.gamma,
            proof.c,
            proof.s,
            uint256(keccak256(inp)),
            proof.uWitness,
            proof.cGammaWitness,
            proof.sHashWitness,
            proof.zInv
        );
    }

    
    function _hash_gamma_to_y(uint256[2] memory gamma) public pure returns (bytes32) {
         return keccak256(abi.encodePacked(gamma));
    }

}
