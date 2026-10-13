const solc=require("solc"),fs=require("fs");const sources={};for(const f of fs.readdirSync("contracts"))sources[f]={content:fs.readFileSync("contracts/"+f,"utf8")};sources["MockUSDC.sol"]={content:fs.readFileSync("test/MockUSDC.sol","utf8")};
const o=JSON.parse(solc.compile(JSON.stringify({language:"Solidity",sources,settings:{optimizer:{enabled:true,runs:200},evmVersion:"shanghai",outputSelection:{"*":{"*":["abi","evm.bytecode.object"]}}}})));
(o.errors||[]).forEach(e=>console.log(e.severity,e.message));fs.writeFileSync("build.json",JSON.stringify(o.contracts));
