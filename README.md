# InstaRand Benchmarking
Library benchmarking VRF, dVRF, FlexiRand, and InstaRand.
Artifact for submission as part of TODO.
## Implementations
- Goldberg VRF on Secp256k1 Curve
- GLOW dVRF on BN254 Curve
- FlexiRand on BN254 Curve
- InstaRand Client on Secp256k1 Curve
## Package / Version Details
- Cargo (Rust) version 1.75.0
- [k256](https://crates.io/crates/k256) version 0.13.3 used for Secp256k1 Curve
- [substrate-bn](https://crates.io/crates/substrate-bn) version 0.6.0 was used for BN254 Curve
- [criterion](https://crates.io/crates/criterion/0.5.1/dependencies) version 0.4.0 was used for benchmarking
  - each benchmark consisted of at least 20 repetitions
  - experiments can be run with `cargo bench`
  - all experiments have R<sup>2</sup> >= 0.999
  - [`cargo bench` CLI Output](./benches/cli_benchmark_output.pdf)
  - [Full Report](./benches/report.zip)
## Benchmarks Overview
- Goldberg VRF on Secp256k1 Curve
- GLOW dVRF on BN254 Curve
- FlexiRand on BN254 Curve
- InstaRand Client using Goldberg VRF on Secp2566k1 Curve
- InstaRand Centralized Server using BLS VRF on BN254 Curve
- InstaRand Decentralized Server using GLOW dVRF on BN254 Curve
## Machine Information
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