# InstaRand Benchmarking
Library benchmarking VRF, dVRF, FlexiRand, and InstaRand.
Artifact for submission as part of TODO.
## Implementations Overview
- Goldberg VRF on Secp256k1 Curve
- GLOW dVRF on BN254 Curve
- FlexiRand on BN254 Curve
- InstaRand Client on Secp256k1 Curve
## Rust
#### Rust Benchmarks Overview
- Goldberg VRF on Secp256k1 Curve
- GLOW dVRF on BN254 Curve
- FlexiRand on BN254 Curve
- InstaRand Client using Goldberg VRF on Secp2566k1 Curve
- InstaRand Centralized Server using BLS VRF on BN254 Curve
- InstaRand Decentralized Server using GLOW dVRF on BN254 Curve
#### Rust Version / Package Details Details
- Cargo (Rust) version 1.75.0
- [k256](https://crates.io/crates/k256) version 0.13.3 used for Secp256k1 Curve
- [substrate-bn](https://crates.io/crates/substrate-bn) version 0.6.0 was used for BN254 Curve
- [criterion](https://crates.io/crates/criterion/0.5.1/dependencies) version 0.4.0 was used for benchmarking
  - each benchmark consisted of at least 20 repetitions
  - experiments can be run with `cargo bench`
  - all experiments have R<sup>2</sup> >= 0.999
  - [`cargo bench` CLI Output](./data/rust/cli_benchmark_output.pdf)
  - [Full Report](./data/rust/report.zip)
#### Machine Information
- Model: MacBook Pro 18.3
- Chip: Apple M1 Pro
- Cores: 8 (6 performance and 2 efficiency)
- Memory: 16 GB
- System Firmware Version: 8422.141.2
- OS Loader Version: 8422.141.2
- OS: macOS Ventura 13.5.1
- Additional Information:
  - Wi-Fi and Bluetooth disabled
  - All other processes closed
  - Screen reduced to minimum brightness
  - No external devices connected (mouse, monitor, etc.)
## Contracts
#### Smart Contracts Overview ([`./contracts/`](./contracts/))
- [`~/supra/`](./contracts/supra/) and [`~/chainlink/`](./contracts/chainlink/) contain implementations for verification of BLS Signatures on BN254 and Goldberg VRF on Secp256k1 respectively.
They contain code initially published publicly (TODO ensure copyright and add link to SC's).
Additionally, we created modified versions of the code ([`BLS_modified.sol`](./contracts/supra/BLS_modified.sol) and [`chainlink_modified.sol`](./contracts/chainlink/chainlink_modified.sol)) which negate several of the validity checks required by the program (`require(<FOO>) -> require(!<FOO>)`),
This allows us to accurately benchmark VRF/dVRF verification without access to a valid input.
We account for the added gas caused by these negations in our [analysis](./data/gas/analysis.md).
- [`~/benchmarks`](./contracts/benchmarks/) contains smart contracts which measure and return the gas consumed for individual operations.
These are used to estimate gas cost as a sum-of-parts.
- [`~/samples`](./contracts/samples/) contains sample smart contracts implementing VRF, dVRF, FlexiRand, and InstaRand (both with centralized and decentralized server).
These can be called to simulate normal SC execution to measure total gas consumed directly.
- TODO maybe notes about optimizations
#### Software Details
- Compiled using Solidity Compiler 0.8.19
- Deployed and run on Remix VM (Cancun) (TODO link)
- TODO explain what this means w.r.t. ethereum
- Note some of these contracts are too large to be deployed on ethereum main net
#### Gas Measurement
- `<FOO>.txt` in [`./data/gas/`](./data/gas/) contains transcripts of calls made to `<FOO>.sol` in either [`./contracts/benchmarks`](./contracts/benchmarks/) or [`./contracts/samples`](./contracts/samples/)
- [`./data/gas/analysis.md`](./data/gas/analysis.md) contains analysis of the data from the transcripts