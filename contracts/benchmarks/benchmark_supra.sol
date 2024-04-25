// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../supra/BLS_modified.sol";
import "../supra/BNPairingPrecompileCostEstimator.sol";
import "../samples/dvrf.sol";


// does conditional execution add gas?
contract BenchmarkSupra {
    bytes32 domain;
    uint256[4] pk;
    uint256 precompile_gas_cost;
    Dvrf dvrf;

    function init(bytes32 _domain) public {
        domain = _domain;
        dvrf = new Dvrf();
    }

    function benchmark_ver(bytes memory inp, uint256[2] memory proof) public view returns (uint256) {
        //bytes memory inp = "0xabcdefabcdefabcdef";

        //uint256[2] memory proof = [0x6E0502CABD0515D15B8AEE1D56A8C34DF9AA19CED312484C9439AB2E8C8A35D2, 0x6E0502CABD0515D15B8AEE1D56A8C34DF9AA19CED312484C9439AB2E8C8A35D2];
        
        uint256 a = gasleft();
        dvrf.bls_ver(BLS.hashToPoint(domain, inp), pk, proof);
        uint256 b = gasleft();
        return a - b;
        
    }
}