// Deploys Aegis + AegisEscrow to Arc mainnet (chain 5042, gas paid in native USDC), then exercises the USDC flow once.
require('fs').readFileSync('../metropolis/.env','utf8').split('\n').forEach(l=>{const[k,...v]=l.split('=');if(k)process.env[k]=v.join('=')});
const {ethers}=require('ethers'),fs=require('fs');
const RPC='https://rpc.mainnet.arc.io',CHAIN=5042,USDC='0x3600000000000000000000000000000000000000';
const b=JSON.parse(fs.readFileSync('build.json'));const get=n=>b[n+'.sol'][n];
const p=new ethers.JsonRpcProvider(RPC,CHAIN);const w=new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY,p);
const erc=new ethers.Contract(USDC,['function approve(address,uint256) returns(bool)','function balanceOf(address) view returns(uint256)'],w);
(async()=>{
 const bal=await p.getBalance(w.address);console.log('native USDC (18dp)',ethers.formatEther(bal));if(bal===0n)throw new Error('fund '+w.address);
 const out={chainId:CHAIN,usdc:USDC,deployer:w.address,txs:{}};
 const dep=async(n,args)=>{const c=get(n);const k=await new ethers.ContractFactory(c.abi,c.evm.bytecode.object,w).deploy(...args);const r=await k.deploymentTransaction().wait();out[n]=await k.getAddress();out.txs['deploy'+n]=r.hash;console.log(n,out[n],r.hash);return k;};
 const reg=await dep('AegisRegistry',[]);
 const anc=await dep('AegisAnchor',[w.address]);
 const brk=await dep('AegisBreaker',[w.address,[w.address]]);
 const esc=await dep('AegisEscrow',[USDC,await brk.getAddress(),w.address,10000n]); // 0.01 USDC per attestation
 let t=await reg.register('momentum-alpha','aegis://dreamdesk/momentum-alpha',ethers.id('swap,rebalance'));out.txs.register=(await t.wait()).hash;
 t=await anc.anchor(ethers.id('aegis-ledger-batch-1'),64);out.txs.anchor=(await t.wait()).hash;
 t=await erc.approve(await esc.getAddress(),50000n);out.txs.approve=(await t.wait()).hash;
 t=await esc.deposit(50000n);out.txs.deposit=(await t.wait()).hash;
 t=await esc.requestAttestation(ethers.id('aegis-attestation-1'));out.txs.payAttestation=(await t.wait()).hash;
 fs.writeFileSync('deployment.json',JSON.stringify(out,null,2));console.log(out);
})().catch(e=>{console.error(e.message);process.exit(1)});
