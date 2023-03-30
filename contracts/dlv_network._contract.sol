//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract DLV_Network{
    mapping(address => bool) public membership;
    mapping(address => bool) public isMerchant;
    mapping(address => bool) public isDriver;
    mapping(address => uint) public membershipExpires;
    uint constant  MEMBERSHIP_FEE_VEHICLE = 1 ether;
    uint constant  MEMBERSHIP_FEE_DRIVER = 50000000000 wei;
    uint constant  MEMBERSHIP_FEE_MERCHANT = 250000000 wei;
    uint constant  YEAR = 31536000; //365 * 24 * 60 * 60;
    uint constant  DELIVERY_DEADLINE= 86400; //1 day in seconds
    address payable public  owner;
    address payable contractAccount;
    
    bool reentrancyGuard=true;
    enum DeliveryStatus { OrderPlaced, InTransit, Delivered }
    
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
        require(msg.value == MEMBERSHIP_FEE, "Incorrect membership fee: amount due ");
        address _member = msg.sender;
        //check membership is invalid
        require(membershipExpires[_member] > block.timestamp, "Membership not expired");
        //check sufficient funds in account
        require(_member.balance > MEMBERSHIP_FEE, "Insufficient funds");
        //send the amount and update membership
        (membership[_member], ) = contractAccount.call{value: msg.value}("");
        //check it has been paid
        require(membership[_member], "Membership: Transferred failed");
        //update new expiry time + 1 year
        membershipExpires[_member] = block.timestamp + YEAR;
    }

    function collect(uint _amount) public payable ownerOnly{
        require(reentrancyGuard);
        reentrancyGuard=false;
        (bool sent, ) = owner.call{value: amount}("");
        reentrancyGuard=true;
        require(sent, "Not collected");
    }

    function register(address _memberAddress) public payable{

    } 

    function buyToken(address _memberAddress) public payable{

    }

    function orderItem(address _memberAddress,uint8 itemId) public payable purchaserOnly{

    }
    function acceptOrder(address _memberAddress,uint8 itemid) public payable merchantOnly{

    }
    function dispatchItem(address _memberAddress,uint8 itemid) public payable merchantOnly{

    }
    function reportDelivery(address _memberAddress,uint8 itemid) public payable driverOnly{

    }
    function verifyDelivery(uint8 deliveryTime) contractOnly public{

    }
    function payDeliveryfee(address _driverAddress, uint8 itemid) public payable contractOnly{
        
    }
}

