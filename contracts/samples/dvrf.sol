// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../supra/BLS_modified.sol";
import "../supra/BNPairingPrecompileCostEstimator.sol";


// does conditional execution add gas?
contract Dvrf {
    bytes32 domain;
    uint256[4] pk;
    uint256 precompile_gas_cost;


    uint256 internal reqid = 0;
    mapping(uint256 => bool) internal nonceUsed;
    
    event ReqGen(uint256 reqid, bytes x);
    event ReqFulf(uint256 reqid, bytes32 y);

    function set_pk(uint256[4] memory _pk) public {
        pk = _pk;
    }
    function init(bytes32 _domain) public {
        domain = _domain;
        BNPairingPrecompileCostEstimator estimator = new BNPairingPrecompileCostEstimator();
        precompile_gas_cost = estimator.getGasCost(1);
    }

    function req(bytes memory x) public returns (uint256) {
        reqid = reqid + 1;
        
        emit ReqGen(reqid, x);

        return reqid;
    }

    function formatted_inp(bytes memory x, uint256 _reqid) public view returns (bytes memory, uint256[2] memory) {
        bytes memory inp = abi.encode(x, _reqid);
        uint256[2] memory inp_pt = BLS.hashToPoint(domain, inp);
        return (inp, inp_pt);
    }

    function fulf(bytes memory x, uint256 _reqid, bytes32 y, uint256[2] calldata proof) public {
        require(!nonceUsed[_reqid]);
       
        dvrf_ver(abi.encode(x, _reqid), pk, y, proof);

        emit ReqFulf(_reqid, y);
        
        nonceUsed[_reqid] = true;
        
    }
    
    function dvrf_ver(bytes memory inp, uint256[4] memory _pk, bytes32 y, uint256[2] memory pi) public view {
        bls_ver(BLS.hashToPoint(domain, inp), _pk, pi);

        require(y == keccak256(abi.encode(pi)));
    }

    function bls_ver(uint256[2] memory inp, uint256[4] memory _pk, uint256[2] memory sig) public view {
        
        bool callSuccess;
        bool checkSuccess;

        (checkSuccess, callSuccess) = BLS.verifySingle(
            sig,
            _pk,
            inp,
            precompile_gas_cost
        );

        require(
            callSuccess,
            "Verify : Incorrect Public key or Signature Points"
        );
        require(checkSuccess, "Verify : Incorrect Input Message");
    }
}