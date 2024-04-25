// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../chainlink/chainlink_modified.sol";

contract BenchmarkChainlink {
    function compute_overhead(bool pred) public view returns (uint256) {
        return compute_negated_preds(!pred) - compute_normal_preds(pred);
    }
    function compute_normal_preds(bool pred) public view returns (uint256) {
        uint256 a = gasleft();
        // 4x is_on_curve
        require(pred);
        require(pred);
        require(pred);
        require(pred);
        // verify LC with gen
        require(pred);
        // linear combination
        require(pred);
        require(pred);
        require(pred);
        // require_eq
        require(pred);
        uint256 b = gasleft();
        return a - b;
    }
    function compute_negated_preds(bool pred) public view returns (uint256) {
        uint256 a = gasleft();
        // 4x is_on_curve
        require(!pred);
        require(!pred);
        require(!pred);
        require(!pred);
        // verify LC with gen
        require(!pred);
        // linear combination
        require(!pred);
        require(!pred);
        require(!pred);
        // require_eq
        require(!pred);
        uint256 b = gasleft();
        return a - b;
    }
    function benchmark_modified_chainlink(
        uint256[2] memory pk,
        uint256[2] memory gamma,
        uint256 c,
        uint256 s,
        uint256 seed,
        address uWitness,
        uint256[2] memory cGammaWitness,
        uint256[2] memory sHashWitness,
        uint256 zInv
    ) public returns (uint256) {
        GoldbergVrf goldberg = new GoldbergVrf();

        uint256 a = gasleft();
        goldberg._verifyVRFProof(
            pk,
            gamma,
            c,
            s,
            seed,
            uWitness,
            cGammaWitness,
            sHashWitness,
            zInv
        );

        uint256 b = gasleft();
        return a - b;
    }
}
