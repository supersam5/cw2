const DLVToken = artifacts.require("DLVToken");
const dlv_network_contract = artifacts.require("DLV_Network");
module.exports = function (deployer) {
  deployer.deploy(DLVToken,"DLVToken","DLV","0x8D152937F32029A75ebC4d7f8d75B9558DCe9950",
  200000000,{from: "0x887D97043A0f20ae6df7b9A322b39A951e8A3021"}).
  then(()=> {return deployer.deploy(dlv_network_contract,DLVToken.address,
    {from:"0xa4DC916FB0E163B1208805eD9cC08ea56192e5E5"})});  
};