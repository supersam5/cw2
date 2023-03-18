//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract members{
    mapping(address => bool) public membership;
    mapping(address => uint) public membershipExpires;
    uint constant  MEMBERSHIP_FEE = 1 ether;
    uint constant  YEAR = 31536000; //365 * 24 * 60 * 60;
    address payable public  owner;
    address payable contractAccount;
    bool reentrancyGuard=true;
    
    event display(address _to, address _from, uint amount, string fn);

    modifier ownerOnly { require(msg.sender == owner, "Insufficient privileges"); _; }
    
    constructor() payable  {
        owner = payable(msg.sender);
        contractAccount=payable(address(this));
    }

    fallback() external payable { emit display(contractAccount, msg.sender, msg.value, "fb");}
    receive() external  payable { emit display(contractAccount, msg.sender, msg.value, "rc");}

    function init() public {
        address[3] memory temp;
        temp[0] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        temp[1] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        temp[2] = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        membershipExpires[temp[0]] = block.timestamp + 3600;
        membershipExpires[temp[1]] = block.timestamp;
        membershipExpires[temp[2]] = block.timestamp - 3600;
        membership[temp[0]] = true;
        membership[temp[1]] = true;
        membership[temp[2]] = true; 
    }


    function blockTimestamp() public view returns(uint){
        return block.timestamp;
    }

/*
    sender transfers 1 ether (fee) to owner    
*/
    function payFees() public payable{
        //check msg.value == membership fee
        require(msg.value ==  ______________, "Incorrect membership fee: amount due ");
        address _member = msg.sender;
        //check membership is invalid
        require(_________________[_member] _ block.timestamp, "Membership not expired");
        //check sufficient funds in account
        require(_member._______ > ______________, "Insufficient funds");
        //send the amount and update membership
        (membership[_member], ) = contractAccount.____{value: msg._____}("");
        //check it has been paid
        require(__________[_member], "Membership: Transferred failed");
        //update new expiry time + 1 year
        _________________[_member] = block.timestamp + ____;
    }

    function collect(uint _amount) public payable _________{
        require(reentrancyGuard);
        reentrancyGuard=_____;
        (bool sent, ) = _____.call{_____: _______}("");
        reentrancyGuard=____;
        require(sent, "Not collected");
    }
}

