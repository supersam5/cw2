import Web3 from 'web3'
import MdxLibrary from '../mdxtoken/build/MdxLibrary.json'
import MdxToken from '../mdxtoken/build/MdxToken.json'
export const loadWeb3 = async () => {
  if (window.ethereum) {
    await window.ethereum.enable()
    const web3 = new Web3(window.ethereum)
    const accounts = await web3.eth.getAccounts()

    const networkId = await web3.eth.net.getId()
    const libraryContractData = MdxLibrary.networks[networkId]
    const libraryContract = new web3.eth.Contract(
      MdxLibrary.abi,
      libraryContractData.address
    )

    // const tokenWeb3 = new Web3(Web3.givenProvider || 'http://localhost:7545')
    const tokenContractData = MdxToken.networks[networkId]
    if (!tokenContractData) throw new Error('Contract not deployed')
    const tokenContract = new web3.eth.Contract(
      MdxToken.abi,
      tokenContractData.address
    )

    const initdata = {
      account: accounts[0],
      libraryContract,
      tokenContract
    }
    console.log({ initdata })
    return initdata
  }
}
