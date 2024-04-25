# Gas Cost Analysis
## Direct Gas Measurements
#### Individual Operations ([Transcript](./benchmark_operations.md))
- Costs used to estimate SC calls
- Gas Use:
  - `hash_to_bits(bytes memory inp)`
    - returns cost to hash string of bytes to 256 bits
      - tested `inp` with length of 32 bytes
    - Measured Gas Use: TODO gwei
  - `read_and_require_single(bytes32 inp)`
    - returns cost to execute `require(stored_bytes == inp)` for `bytes32 stored_bytes` stored on-chain
    - Measured Gas Use: TODO gwei
  - `require_neq_zero()`
    - returns cost to execute `require(stored_bytes != 0)` for `bytes32 stored_bytes` stored on-chain
    - Measured Gas Use: TODO gwei
  - `read_and_require_bool(uint256 key)`
    - returns cost to execute `require(bool_mapping[key])` for `mapping(uint256 => bool) bool_mapping` stored on-chain
    - Measured Gas Use: TODO gwei
  - `read_and_require_bool_false(uint256 key)`
    - returns cost to execute `require(!bool_mapping[key])` for `mapping(uint256 => bool) bool_mapping` stored on-chain
    - Measured Gas Use: TODO gwei
  - `read_and_require_mapping(uint256 key, bytes32 val)`
    - returns cost to execute `require(data_mapping[key] == val)` for `mapping(uint256 => bytes32) data_mapping` stored on-chain
    - Measured Gas Use: TODO gwei
  - `increment_nonce()`
    - returns cost to execute `nonce += 1` for `uint256 nonce` stored on-chain
    - Measured Gas Use: TODO gwei
  - `write_single(bytes32 inp)`
    - returns cost to execute `stored_bytes = inp` for `bytes32 stored_bytes` stored on-chain
    - Measured Gas Use: TODO gwei
  - `write_mapping_bytes32(uint256 key, bytes32 val)`
    - returns cost to execute `data_mapping[key] = val` for `mapping(uint256 => bytes32) data_mapping` stored on-chain
    - Measured Gas Use: TODO gwei
  - `write_mapping_bool(uint256 key, bool val)`
    - returns cost to execute `bool_mapping[key] = val` for `mapping(uint256 => bool) bool_mapping` stored on-chain
    - Measured Gas Use: TODO gwei
  - `delete_mapping(uint256 key)`
    - returns cost to execute `require(!bool_mapping[key])` for `mapping(uint256 => bool) bool_mapping` stored on-chain
    - Measured Gas Use: TODO gwei
#### Chainlink VRF Verification ([Transcript](./benchmark_chainlink.md))
- Direct measurement of methods in [`chainlink_modified.sol`](../contracts/chainlink/chainlink_modified.sol)
  - Note that the modifications to [`chainlink.sol`](../contracts/chainlink/chainlink.sol) add operations which cost additional gas.
    - specifically we perfrom 9 additional negations
  - We use `compute_overhead` to determine the additional cost incurred and use this to adjust our estimated cost for on-chain VRF verification
- Gas Use:
  - `compute_overhead(bool pred)`
    - returns the difference in cost between computing `require(pred)` 9 times and `require(!pred)` 9 times.
    TODO maybe better to do once and multiply by 9
    - note we always call with `pred = true` but we need `pred` to be an argument to prevent the compiler from optimizing for known constant value
    - this holds since VRF verification (and thus the transaction) only succeed when all `require(pred)` is true for all negated predicates.
    - Measured Gas Use: TODO gwei
  - `benchmark_modified_chainlink(uint256[2] memory pk, uint256[2] memory gamma, uint256 c, uint256 s, uint256 seed, address uWitness, uint256[2] memory cGammaWitness, uint256[2] memory sHashWitness, uint256 zInv)`
    - returns cost verify VRF output for Goldberg VRF on secp256k1 curve
      - default input size = uint256 (seed)
    - benchmarked using Supra's code
    - Measured Gas Use: TODO gwei
    - Adjusted Gas Use: TODO gwei
#### Supra dVRF ([Transcript](./benchmark_supra.md))
- Direct measurement of methods in [`BLS_modified.sol`](../contracts/supra/BLS_modified.sol)
  - Note the modifications to [`BLS.sol`](../contracts/supra/BLS.sol) are net zero gas since we change one occurrence of `require(!<FOO>)` to `require(<FOO>)` and one occurrence of `require(<BAR>)` to `require(!<BAR>)` (these calls always occur together).
  Since we have removed one negation operation and added another, the total gas cost stays the same
- Gas Use:
  - `ver(bytes memory inp, uint256[2] memory proof)`
    - returns cost verify dVRF output for GLOW dVRF on BN254 Curve
      - tested `inp` with length of 32 bytes
    - Measured Gas Use: TODO gwei
  - `hash_to_g1(bytes calldata inp)`
    - returns cost to hash string of bytes to G1 member of BN254 Curve
      - tested `inp` with length of 32 bytes
    - Measured Gas Use: TODO gwei
  - `hash_g1_to_bits(uint256[2] memory inp)`
    - returns cost to hash G1 member of BN254 curve to 256 bits
    - Measured Gas Use: TODO gwei
## Sample SC Execution
#### VRF ([Transcript](./vrf.md))
- Sample SC implementing VRF Service
- Gas Use:
  - `req(bytes memory x)`
      - tested `x` with length of 32 bytes
      - TODO gwei
  - `fulf(bytes memory x, uint256 _reqid, bytes32 y, GoldbergVrf.Proof memory proof)`
      - tested `x` with length of 32 bytes
      - TODO gwei
#### dVRF ([Transcript](./dvrf.md))
- Sample SC implementing DVRF Service
- Gas Use:
  - `req(bytes memory x)`
      - tested `x` with length of 32 bytes
      - TODO gwei
  - `function fulf(bytes memory x, uint256 _reqid, bytes32 y, uint256[2] calldata proof)`
      - tested `x` with length of 32 bytes
      - TODO gwei
#### FlexiRand ([Transcript](./flexirand.md))
- Sample SC implementing FlexiRand Service
  - Note we assume the VRF Server(s) validate client blinding off-chain
- Gas Use:
  - `gen_req(bytes memory e)`
      - tested `e` with length of 32 bytes
      - TODO gwei
  - `submit_blinding(FormattedInput memory x, uint256[2] memory x_blind, ZkpKdl memory proof)`
  - `pre_ver(FormattedInput memory x, uint256[2] memory y_blind)`
  - `function verify(FormattedInput memory x, bytes32 y, uint256[2] memory pi)`
#### InstaRand with Centralized Server ([Transcript](./instarand_centralized.md))
- Sample SC implementing InstaRand Service where VRF is computed by centralized server
- Gas Use:
  - `register_client_key(ClientInput memory x)`
      - `struct ClientInput = { uint256[2] pk, bytes e }` where `e` is 32 bytes
      - TODO gwei
  - `pre_ver(ClientInput memory x, bytes32 y, GoldbergVrf.Proof memory proof)`
  - `verify(FormattedInput memory inp, bytes32 w_i, GoldbergVrf.Proof memory pi_i)`
#### InstaRand with Decentralized Server ([Transcript](./instarand_decentralized.md))