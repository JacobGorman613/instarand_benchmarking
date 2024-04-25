// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../supra/BLS_modified.sol";
import "../samples/dvrf.sol";

contract Operations {
    bytes32 private single_data;//bytes32 single_data = keccak256(abi.encodePacked("hello world"));
    uint256 private nonce = 0;//bytes32 single_data = keccak256(abi.encodePacked("hello world"));
    mapping(uint256 => bytes32) private mapping_data;
    mapping(uint256 => bool) private mapping_bool;

    function hash_ecp_to_bits(uint256[2] memory inp) public pure returns (bytes32) {
        return keccak256(abi.encode(inp));
    }

    function hash_to_bits(bytes memory inp) public view returns (uint256) {
        uint256 a = gasleft();

        keccak256(abi.encodePacked(inp));

        uint256 b = gasleft();
        return a-b;
    }

    function read_and_require_single(bytes32 inp) public view returns (uint256) {
        uint256 a = gasleft();

        require(single_data == inp);

        uint256 b = gasleft();
        return a-b;

    }

    function require_neq_zero() public view returns (uint256) {
        uint256 x = uint256(single_data);
        uint256 a = gasleft();

        require(x != 0);

        uint256 b = gasleft();
        return a-b;

    }

    function read_and_require_bool(uint256 key) public view returns (uint256) {
        uint256 a = gasleft();

        require(mapping_bool[key]);

        uint256 b = gasleft();
        return a-b;

    }

    function read_and_require_bool_false(uint256 key) public view returns (uint256) {
        uint256 a = gasleft();

        require(!mapping_bool[key]);

        uint256 b = gasleft();
        return a-b;

    }

    function read_and_require_mapping(uint256 key, bytes32 val) public view returns (uint256) {
        uint256 a = gasleft();

        require(mapping_data[key] == val);

        uint256 b = gasleft();
        return a-b;

    }

    
    function increment_nonce() public returns (uint256) {
        uint256 a = gasleft();
        nonce += 1;
        uint256 b = gasleft();
        return a-b;
    }
    
    function write_single(bytes32 inp) public returns (uint256) {
        uint256 a = gasleft();
        single_data = inp;
        uint256 b = gasleft();
        return a-b;
    }
    function write_mapping_bytes32(uint256 key, bytes32 val) public returns (uint256) {
        uint256 a = gasleft();
        mapping_data[key] = val;
        uint256 b = gasleft();
        return a-b;
    }
    function write_mapping_bool(uint256 key, bool val) public returns (uint256) {
        uint256 a = gasleft();
        mapping_bool[key] = val;
        uint256 b = gasleft();
        return a-b;
    }
    function hash_to_g1(bytes calldata inp) public view returns (uint256) {
        bytes32 domain = keccak256("hello");
        uint256 a = gasleft();
        BLS.hashToPoint(domain, inp);
        uint256 b = gasleft();
        return a-b;
    }

    function delete_mapping(uint256 key) public returns (bool, uint256) {
        uint256 a = gasleft();
        delete(mapping_data[key]);
        uint256 b = gasleft();
        bool is_bigger = a > b;
        if (is_bigger) {
            return (is_bigger, a-b);
        } else {
            return (is_bigger, b-a);
        }
    }
}