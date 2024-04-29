// Import Web3.js library
import Web3 from 'web3';
import contractABI from '../contracts/artifacts/Operations.json';
import { deploy } from './web3-lib';
import { keccak, ddh_proof_fixed_gamma, flexirand_blinding_proof, get_random_bytes, get_random_uint256_2, get_random_uint256_4,get_random_uint256}from './input_factory';



const RUNS = 10;

console.log(`running bench_operations with ${RUNS} repeitions`)
// Define contract address (replace with your contract's address)
const contractAddress = '0xAd1bDa6313b804DE8D86AC052BfE20a305cF29f4';
// Set up Web3 provider (for Remix JavaScript VM)
//const web3 = new Web3((window as any).web3.currentProvider);
const web3 = new Web3(web3Provider);
const eventName = 'GasMeasuredOperations';

let gasUsed = [[],[],[],[],[],[],[],[]];
let sums = [0,0,0,0,0,0,0,0];
(async () => {
    try {
        const contract = new web3.eth.Contract(contractABI.abi, contractAddress);
        const accounts = await web3.eth.getAccounts()
        
        await Promise.all([
            bench1(contract, accounts[0]),
            bench2(contract, accounts[1]),
            bench3(contract, accounts[2]),
            bench4(contract, accounts[3]),
            bench5(contract, accounts[4]),
            bench6(contract, accounts[5]),
            bench7(contract, accounts[6]),
            bench8(contract, accounts[7])
        ])
        
        console.log(`total gas used over ${RUNS} runs`, sums);
        for (let i = 0; i < 8; i++) {
            sums[i] = (1.0 * sums[i]) / RUNS
        }
        console.log(`average gas used over ${RUNS} runs`, sums);

        console.log("raw data")

        for (let i = 0; i < 8; i++) {
            console.log(`output ${i}`, gasUsed[i]);
        }
    } catch (e) {
        console.log(e.message)
    }
})()


async function bench1(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let pk = get_random_uint256_2();
        let y = get_random_uint256();
        await contract.methods.bench_secp256k1_hash_to_curve(pk, y).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[0].push(gas)
                    sums[0] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench 1", error); // Error callback
            })
    }
}
async function bench2(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let pk = get_random_uint256_2();
        let gamma = get_random_uint256_2();
        let proof = ddh_proof_fixed_gamma(gamma)
        let y = await contract.methods._hash_gamma_to_y(gamma).call()
        await contract.methods.bench_ddh_vrf_ver_ecp(y, pk, proof).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[1].push(gas)
                    sums[1] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench 2", error); // Error callback
            })
    }
}

async function bench3(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let inp = get_random_bytes(32);
        let pk = get_random_uint256_2();
        let gamma = get_random_uint256_2();
        let proof = ddh_proof_fixed_gamma(gamma)
        let y = await contract.methods._hash_gamma_to_y(gamma).call()
        await contract.methods.bench_ddh_vrf_ver_str(inp, y, pk, proof).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[2].push(gas)
                    sums[2] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench 3", error); // Error callback
            })
    }
}

async function bench4(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let domain = get_random_bytes(32);
        let msg = get_random_bytes(32);
        await contract.methods.bench_bn254_hash_to_curve(domain, msg).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[3].push(gas)
                    sums[3] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench 4", error); // Error callback
            })
        }
    }

    async function bench5(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let sig = get_random_uint256_2()
        let y = await contract.methods._hash_gamma_to_y(sig).call()
        let inp = get_random_uint256_2();
        let pk = get_random_uint256_4();
        await contract.methods.bench_bls_vrf_ver_ecp(y, inp, pk, sig).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[4].push(gas)
                    sums[4] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench", error); // Error callback
            })
    }
}


async function bench6(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let sig = get_random_uint256_2()
        let y = await contract.methods._hash_gamma_to_y(sig).call()
        let domain = get_random_bytes(32);
        let inp = get_random_bytes(32);
        let pk = get_random_uint256_4();
        await contract.methods.bench_bls_vrf_ver_str(y, domain, inp, pk, sig).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[5].push(gas)
                    sums[5] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench", error); // Error callback
            })
    }
}


async function bench7(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let inp = get_random_uint256_2();
        let pk = get_random_uint256_4();
        let sig = get_random_uint256_2();
        await contract.methods.bench_bls_sig_ver_ecp(inp, pk, sig).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[6].push(gas)
                    sums[6] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench", error); // Error callback
            })
    }
}



async function bench8(contract, account) {
    for (let i = 0; i < RUNS; i++) {
        let inp = get_random_bytes(32);
        let domain = get_random_bytes(32);
        let pk = get_random_uint256_4();
        let sig = get_random_uint256_2();
        await contract.methods.bench_bls_sig_ver_str(domain, inp, pk, sig).send({ from: account }) 
            .on('receipt', (receipt) => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    let gas = Number(event.returnValues['gas'])
                    gasUsed[7].push(gas)
                    sums[7] += gas
                } else {
                    console.error()
                }
            })
            .on('error', (error) => {
                console.error("failed to call bench", error); // Error callback
            })
    }
}
