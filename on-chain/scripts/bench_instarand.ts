import Web3 from 'web3';
import contractABI from '../contracts/artifacts/InstaRand.json';
import { deploy } from './web3-lib';
import { keccak, ddh_proof_fixed_gamma, flexirand_blinding_proof, get_random_bytes, get_random_uint256_2, get_random_uint256_4,get_random_uint256}from './input_factory';


const RUNS = 10;

console.log(`running bench_instarand with ${RUNS} repeitions`)
// Define contract address (replace with your contract's address)
const contractAddress = '0x5e0F1D0cBd09202bEBc6f535ed4656902d2BAAf4';

// Set up Web3 provider (for Remix JavaScript VM)
//const web3 = new Web3((window as any).web3.currentProvider);
const web3 = new Web3(web3Provider);
const eventName = 'GasMeasurementInstaRand';

let execution_gas_list = [[],[],[]];
let transaction_gas_list = [[],[],[]];
let execution_gas_sums = [0,0,0];
let transaction_gas_sums = [0,0,0];

//const promises = []

(async () => {
    try {
        const contract = new web3.eth.Contract(contractABI.abi, contractAddress);
        const accounts = await web3.eth.getAccounts()

        await contract.methods.set_pk(get_random_uint256_4()).send({ from: accounts[0] }) 
            .on('receipt', (_receipt) => { 
                
            })
            .on('error', (error) => {
                console.error("failed to set public key", error); // Error callback
            })
            

        for (let i = 0; i < RUNS; i++) {
            await bench(contract, accounts[0], i)
        }

        
        console.log(`total transaction gas over ${RUNS} key_reg transactions ${transaction_gas_sums[0]}`);
        console.log(`total transaction gas over ${RUNS} pre_ver transactions ${transaction_gas_sums[1]}`);
        console.log(`total transaction gas over ${RUNS} instant_ver transactions ${transaction_gas_sums[2]}`);

        console.log(`average transaction gas over ${RUNS} key_reg transactions ${transaction_gas_sums[0] / RUNS}`);
        console.log(`average transaction gas over ${RUNS} pre_ver transactions ${transaction_gas_sums[1] / RUNS}`);
        console.log(`average transaction gas over ${RUNS} instant_ver transactions ${transaction_gas_sums[2] / RUNS}`);
        
        console.log(`total execution gas over ${RUNS} key_reg transactions ${execution_gas_sums[0]}`);
        console.log(`total execution gas over ${RUNS} pre_ver transactions ${execution_gas_sums[1]}`);
        console.log(`total execution gas over ${RUNS} instant_ver transactions ${execution_gas_sums[2]}`);

        console.log(`average execution gas over ${RUNS} key_reg transactions ${execution_gas_sums[0] / RUNS}`);
        console.log(`average execution gas over ${RUNS} pre_ver transactions ${execution_gas_sums[1] / RUNS}`);
        console.log(`average execution gas over ${RUNS} instant_ver transactions ${execution_gas_sums[2] / RUNS}`);
        
        console.log('transaction gas raw data', execution_gas_list)
        console.log('execution gas raw data', transaction_gas_list)
    } catch (e) {    
        console.error("failed to execute bench_dvrf", e); // Error callback
    }
})()


async function bench(contract, account, i) {
    let pk_c = get_random_uint256_2();
    let e = get_random_bytes(32);
    let x = [pk_c, e]

    await contract.methods.register_client_key(x).send({ from: account }) 
        .then(receipt => {
            const events = receipt.events;
            if (Object.hasOwnProperty.call(events, eventName)) {
                const event = events[eventName];
                
                let ex_gas = Number(event.returnValues['gas'])
                let tx_gas = Number(receipt.gasUsed)

                execution_gas_list[0].push(ex_gas)
                execution_gas_sums[0] += ex_gas

                transaction_gas_list[0].push(tx_gas)
                transaction_gas_sums[0] += tx_gas

                return Number(event.returnValues['reqid']);

            }
        })
        .catch(error => {
            console.error("Failed in gen_req", error); // Error callback
        })


        let sig = get_random_uint256_2()
        await contract.methods.pre_ver(x, sig).send({ from: account })
            .then(receipt => {
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    
                    let ex_gas = Number(event.returnValues['gas'])
                    let tx_gas = Number(receipt.gasUsed)

                    execution_gas_list[1].push(ex_gas)
                    execution_gas_sums[1] += ex_gas

                    transaction_gas_list[1].push(tx_gas)
                    transaction_gas_sums[1] += tx_gas
                }
            })
            .catch(error => {
                console.log("ERR")
                console.error("failed isntarand prever", error); // Error callback
            })

        

    //function fulfill(ClientInput memory x, uint256 i, bytes32 w_i, DDH.Proof memory pi_i) public {
        
    let gamma = get_random_uint256_2();
    let pi_i = ddh_proof_fixed_gamma(gamma)  
    
    let w_i = await contract.methods._hash_gamma_to_y(gamma).call()


        await contract.methods.fulfill(x, i, w_i, pi_i).send({ from: account })
            .then(receipt => {
                            const events = receipt.events;
            if (Object.hasOwnProperty.call(events, eventName)) {
                const event = events[eventName];
                
                let ex_gas = Number(event.returnValues['gas'])
                let tx_gas = Number(receipt.gasUsed)

                execution_gas_list[2].push(ex_gas)
                execution_gas_sums[2] += ex_gas

                transaction_gas_list[2].push(tx_gas)
                transaction_gas_sums[2] += tx_gas
            }
        })
        .catch(error => {
            console.error("failed to call fulfill", error); // Error callback
        })
                /*
                const events = receipt.events;
                if (Object.hasOwnProperty.call(events, eventName)) {
                    const event = events[eventName];
                    
                    let ex_gas = Number(event.returnValues['gas'])
                    let tx_gas = Number(receipt.gasUsed)

                    execution_gas_list[2].push(ex_gas)
                    execution_gas_sums[2] += ex_gas

                    transaction_gas_list[2].push(tx_gas)
                    transaction_gas_sums[2] += tx_gas
                }
            })
            .catch(error => {
                console.log("ERR")
                console.error("failed isntarand fulfillment", error); // Error callback
            })*/

}






