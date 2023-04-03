const DLVToken = artifacts.require("DLVToken");
const dlv_network_contract = artifacts.require("DLV_Network");
const Web3 = require('web3');
        
module.exports = function (deployer,network,accounts) {
  deployer.deploy(DLVToken,"DLVToken","DLV",accounts[1],
  200000000,{from: accounts[0]}).
  then(()=> {return deployer.deploy(dlv_network_contract,DLVToken.address,
    {from:accounts[1]})}).then(async ()=>{
      if(network == "development"){
          token = await DLVToken.deployed();
          main =  await dlv_network_contract.deployed();
          //instantiate two drivers and two merchants
          merchant1= accounts[2];
          merchant2= accounts[3];
          driver1= accounts[4];
          driver2= accounts[5];
          const year = 31536000 //year in seconds
          const web3 = new Web3('http://localhost:7545'); 
          const latestBlock = await web3.eth.getBlock('latest');
          const timestamp = latestBlock.timestamp;
  
      
        contractAddress=  dlv_network_contract.address;
        await token.addAllowList(contractAddress);
        await token.addAdmin(contractAddress);
        await token.addAllowList(merchant1);
        await token.addAllowList(merchant2);
        await token.addAllowList(driver2);
        await token.addAllowList(driver1);
        await token.approve(contractAddress,400,{from:accounts[2]});
        await token.approve(contractAddress,400,{from:accounts[3]});
        await token.approve(contractAddress,400,{from:accounts[4]});
        await token.approve(contractAddress,400,{from:accounts[5]});
        await main.buyToken(200,{from:accounts[2],value: 4000000000000});
        await main.buyToken(200,{from:accounts[3],value: 4000000000000});
        await main.buyToken(200,{from:accounts[4],value: 4000000000000});
        await main.buyToken(200,{from:accounts[5],value: 4000000000000});
       
        await main.register(1,{from:accounts[2]});
        await main.register(1,{from:accounts[3]});
        await main.register(2,{from:accounts[4]});
        await main.register(2,{from:accounts[5]});
       
      }
    }
    );  
};