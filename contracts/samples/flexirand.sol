// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

//import "./inp_ver.sol";
import "./dvrf.sol";

contract FlexiRand {
    uint256[4] pk;

    Dvrf dvrf;

    uint256 internal reqid = 0;
    mapping(uint256 => bool) internal nonceUsed;
    mapping(uint256 => bytes32) private requests;
    mapping(uint256 => uint256[2]) private inputs;
    mapping(uint256 => uint256[2]) private outputs;

    event ReqGen(uint256 reqid, bytes e);
    event BlindedInputSubmitted(
        uint256 reqid,
        uint256[2] x_blind,
        ZkpKdl proof
    );
    event Prever(uint256 reqid, uint256[2] y_blind);
    event Ver(uint256 reqid, bytes32 y);

    struct FormattedInput {
        bytes e;
        uint256 reqid;
    }

    struct ZkpKdl {
        uint256 s;
        uint256 c;
    }

    function init() public {
        dvrf = new Dvrf();
        //inp_verifier = new InpVer();
    }

    function set_pk(uint256[4] memory _pk) public {
        pk = _pk;
    }

    function gen_req(bytes memory e) public {
        reqid += 1;
        requests[reqid] = keccak256(abi.encodePacked(e));
        // requests[reqid] = keccak256(abi.encodePacked(e, msg.sender, block.number));
        emit ReqGen(reqid, e);
    }

    // reverts on fail
    function submit_blinding(
        FormattedInput memory x,
        uint256[2] memory x_blind,
        ZkpKdl memory proof
    ) public {
        require(requests[x.reqid] == keccak256(abi.encodePacked(x.e)));
        require(inputs[x.reqid][0] == 0 && inputs[x.reqid][1] == 0);

        //inp_verifier.inp_ver(x, proof, x_blind);

        inputs[x.reqid] = x_blind;

        emit BlindedInputSubmitted(x.reqid, x_blind, proof);
    }

    function pre_ver(
        FormattedInput memory x,
        uint256[2] memory y_blind
    ) public {
        require(requests[x.reqid] == keccak256(abi.encodePacked(x.e)));
        require(outputs[x.reqid][0] == 0 && inputs[x.reqid][1] == 0);

        uint256[2] memory x_blind = inputs[x.reqid];
        require(x_blind[0] != 0 && x_blind[1] != 0);

        dvrf.bls_ver(x_blind, pk, y_blind);

        outputs[x.reqid] = y_blind;

        emit Prever(x.reqid, y_blind);
    }

    function verify(
        FormattedInput memory x,
        bytes32 y,
        uint256[2] memory pi
    ) public {
        require(requests[x.reqid] == keccak256(abi.encodePacked(x.e)));
        require(!nonceUsed[x.reqid]);
        uint256[2] memory x_blind = inputs[x.reqid];
        uint256[2] memory y_blind = outputs[x.reqid];

        require(x_blind[0] != 0 && x_blind[1] != 0);
        require(y_blind[0] != 0 && y_blind[1] != 0);

        dvrf.dvrf_ver(abi.encode(x), pk, y, pi);

        nonceUsed[x.reqid] = true;
        emit Ver(x.reqid, y);
    }
}
