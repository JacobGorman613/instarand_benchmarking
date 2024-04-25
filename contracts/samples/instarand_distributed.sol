// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./vrf.sol";
import "./dvrf.sol";
import "./instarand_centralized.sol";
import "../chainlink/chainlink_modified.sol";

// distributed instarand
contract InstaRandDistributed {
    uint256[4] pk_server;

    mapping(bytes32 => bytes32) internal server_outputs;
    mapping(bytes32 => bool) internal nonceUsed;
    Vrf internal gb;
    Dvrf internal glow;

    event KeyRegistered(InstaRand.ClientInput x);
    event Prever(InstaRand.ClientInput x, bytes32 y);
    event Ver(InstaRand.FormattedInput inp, bytes32 w_i, bytes32 z_i);

    function init() public {
        gb = new Vrf();
        glow = new Dvrf();
    }

    // set server public key
    function set_pk(uint256[4] memory pk) public {
        pk_server = pk;
    }
    function register_client_key(InstaRand.ClientInput memory x) public {
        emit KeyRegistered(x);
        //client_inputs[client_id] = keccak256(abi.encodePacked(x.pk, x.e));
    }

    function pre_ver(
        InstaRand.ClientInput memory x,
        bytes32 y,
        uint256[2] memory pi
    ) public {
        require(server_outputs[keccak256(abi.encode(x))] == 0);
        glow.dvrf_ver(abi.encode(x), pk_server, y, pi);

        server_outputs[keccak256(abi.encode(x))] = y;

        emit Prever(x, y);
    }

    function verify(
        InstaRand.FormattedInput memory inp,
        bytes32 w_i,
        GoldbergVrf.Proof memory pi_i
    ) public {
        bytes32 inp_as_key = keccak256(abi.encode(inp.pre_inp));
        require(!nonceUsed[inp_as_key]);

        require(server_outputs[inp_as_key] == inp.y);
        require(inp.y != 0);

        uint256[2] memory pk_client = inp.pre_inp.pk;

        gb.vrf_ver(abi.encode(inp), pk_client, w_i, pi_i);

        bytes32 z_i = keccak256(abi.encode(inp, w_i));

        nonceUsed[inp_as_key] = true;

        emit Ver(inp, w_i, z_i);
    }
}
