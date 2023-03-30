//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./DLVToken.sol";


contract DLV_Network{
    mapping(address => bool) public membership;
    mapping(address => bool) public isMerchant;
    mapping(address => bool) public isDriver;
    mapping(address=> bool) public isPurchaser;
    mapping(address => uint) public membershipExpires;
    mapping(uint16 => uint128) public item_prices;
    uint64 constant  MEMBERSHIP_FEE_DRIVER =  1 ether;
    uint64 constant  MEMBERSHIP_FEE_MERCHANT =  2 ether;
    uint constant  YEAR = 31536000; //365 * 24 * 60 * 60;
    uint constant  DELIVERY_DEADLINE= 86400; //1 day in seconds
    address payable public  owner;
    address payable contractAccount;
    DLVToken token;
    uint128 price_per_token = 20000000000000000 wei;
    ItemForDelivery[10000]  items;
    address[50] drivers;

    
    
    bool reentrancyGuard=true;
    enum DeliveryStatus { Available, OrderPlaced,OrderReceived,Dispatched, Delayed, Delivered }
    struct ItemForDelivery{
        string name;
        DeliveryStatus status;
        address recipient;
        address merchant;
        address driver;
        uint256 dispatchTimestamp;

    }
    event display(address _to, address _from, uint amount, string fn);

    modifier ownerOnly { require(msg.sender == owner, "Insufficient privileges"); _; }
    modifier purchaserOnly { require(isPurchaser[msg.sender]== true, "Only customers can perform this action"); _;}
    modifier merchantOnly { require(isMerchant[msg.sender]== true, "Only merchants can perform this action"); _;}
    modifier driverOnly { require(isDriver[msg.sender]== true, "Only merchants can perform this action"); _;}
    modifier contractOnly {require(msg.sender == contractAccount); _;}

    constructor(DLVToken _token) payable  {
        owner = payable(msg.sender);
        contractAccount=payable(address(this));
        token = _token;
    }

    fallback() external payable { emit display(contractAccount, msg.sender, msg.value, "fb");}
    receive() external  payable { emit display(contractAccount, msg.sender, msg.value, "rc");}

    function init(address merchant1, address merchant2, address driver1, address driver2) public {
        
        address _dummmyAddress;
        DeliveryStatus _dummyStatus;

        //instantiate two drivers and two merchants
        membershipExpires[merchant1] = block.timestamp + YEAR;
        membershipExpires[merchant2] = block.timestamp + YEAR;
        isMerchant[merchant1] = true;
        membership[merchant1] = true; 
        isMerchant[merchant2] = true;
        membership[merchant1] = true; 

        membershipExpires[driver1] = block.timestamp + YEAR;
        membershipExpires[driver2] = block.timestamp + YEAR;
        isDriver[driver1] = true;
        membership[driver1] = true; 
        isDriver[driver2] = true;
        membership[driver2] = true; 
        
        //instantiate products for delivery
        items[0] = ItemForDelivery("item 1",_dummyStatus,_dummmyAddress,merchant1,_dummmyAddress,0);
        items[1] = ItemForDelivery("item 2",_dummyStatus,_dummmyAddress,merchant1,_dummmyAddress,0);
        items[2] = ItemForDelivery("item 3",_dummyStatus,_dummmyAddress,merchant1,_dummmyAddress,0);
        items[3] = ItemForDelivery("item 4",_dummyStatus,_dummmyAddress,merchant2,_dummmyAddress,0);
        items[4] = ItemForDelivery("item 5",_dummyStatus,_dummmyAddress,merchant2,_dummmyAddress,0);
        items[5] = ItemForDelivery("item 6",_dummyStatus,_dummmyAddress,merchant2,_dummmyAddress,0);
        


     
       
    }


    function blockTimestamp() public view returns(uint){
        return block.timestamp;
    }

/*
    sender transfers 1 ether (fee) to owner    
*/
    function payFees() public payable{
        address _member = msg.sender;
        require(!isPurchaser[_member],"Purchasers do not need to pay a membership fee");
        //check msg.value == membership fee
        uint MEMBERSHIP_FEE;
        if (isMerchant[_member]== true) {
            MEMBERSHIP_FEE = MEMBERSHIP_FEE_MERCHANT;
        } else if (isDriver[_member]== true) {
           MEMBERSHIP_FEE = MEMBERSHIP_FEE_DRIVER;
        }
              
        
      

    
        
        //check membership is invalid
        require(membershipExpires[_member] > block.timestamp, "Membership not expired");
        //check sufficient funds in account
        require(token.balanceOf(_member) > MEMBERSHIP_FEE, "Insufficient funds");
        //send the amount and update membership
        membership[_member]= token.transferFrom(_member,contractAccount, MEMBERSHIP_FEE );
        //check it has been paid
        require(membership[_member], "Membership: Transferred failed");
        //update new expiry time + 1 year
        membershipExpires[_member] = block.timestamp + YEAR;
    }
    function payFees(address _member) public payable{
        //check msg.value == membership fee
        uint MEMBERSHIP_FEE;
        if (isMerchant[_member]== true) {
            MEMBERSHIP_FEE = MEMBERSHIP_FEE_MERCHANT;
        } else if (isDriver[_member]== true) {
           MEMBERSHIP_FEE = MEMBERSHIP_FEE_DRIVER;
        }
        if(isPurchaser[_member]){
             membership[_member]= true;
        }else{
            //check membership is invalid
            require(membershipExpires[_member] > block.timestamp, "Membership not expired");
            //check sufficient funds in account
            require(token.balanceOf(_member)> MEMBERSHIP_FEE, "Insufficient funds");
            //send the amount and update membership
            membership[_member]= token.transferFrom(_member,contractAccount, MEMBERSHIP_FEE);
            //check it has been paid
            require(membership[_member], "Membership: Transferred failed");
            //update new expiry time + 1 year
            membershipExpires[_member] = block.timestamp + YEAR;
        }
    }


    function collect(uint _amount) public payable ownerOnly{
        require(reentrancyGuard);
        reentrancyGuard=false;
        (bool sent, ) = owner.call{value: _amount}("");
        reentrancyGuard=true;
        require(sent, "Not collected");
    }

    function register(uint8 memberType) public payable{
        address _newMemberAddress = msg.sender;
        require(!membership[_newMemberAddress],"You are already a member!");
        
        membershipExpires[_newMemberAddress] = block.timestamp;
        if (memberType==1) {
            isMerchant[_newMemberAddress]= true;
        } else if(memberType==2) {
            require(drivers.length<50,"There is no vacancy for drivers");
            isDriver[_newMemberAddress]= true;  
        } else if (memberType==3){
            isPurchaser[_newMemberAddress]= true;
        }
       payFees(_newMemberAddress);  
    } 

    function buyToken(uint32 quantity) public payable{
        address _member = msg.sender; 
        uint256 tranx_cost = quantity * price_per_token;
        require(_member.balance > msg.value,"Insufficent funds" );
        require(msg.value == tranx_cost, "Provide enough ether to complete the transaction. Check token price");
        (bool sent, )= contractAccount.call{value: msg.value}("");
        if(sent) token.mint(_member,quantity);
        //emit event
    }
    

    function orderItem(uint16 itemId, uint128 price) public payable purchaserOnly{
        ItemForDelivery memory selectedItem = items[itemId];
        address  _purchaser = msg.sender;
        require(membership[msg.sender],"Wallet not registered please register as a member");
        require(selectedItem.status == DeliveryStatus.Available, "Item is not available for delivery");
        require(token.balanceOf(msg.sender) > price,"Insufficient funds to make this purchase");
        item_prices[itemId]= price;
        bool paid=token.transferFrom(_purchaser,selectedItem.merchant, price);
        if(paid){
            selectedItem.recipient = msg.sender;
            selectedItem.status= DeliveryStatus.OrderPlaced;
            items[itemId] = selectedItem;

        }
        
    }
    function acceptOrder(uint16 itemId) public payable merchantOnly{
        ItemForDelivery memory selectedItem = items[itemId];
        require(selectedItem.merchant== msg.sender,"Orders can only be accepted by designated merchant");
        selectedItem.status = DeliveryStatus.OrderReceived;
        
    }
    function dispatchItem(uint16 itemId, address _driver) public payable merchantOnly{
        ItemForDelivery memory selectedItem = items[itemId];
        require(selectedItem.merchant== msg.sender,"Orders can only be accepted by designated merchant"); 
        require(selectedItem.status == DeliveryStatus.OrderReceived, "Item is not available for delivery");
        bool paid = payDeliveryfee(msg.sender, itemId);
        if(paid){
            selectedItem.status = DeliveryStatus.Dispatched;
            selectedItem.driver = _driver;
            selectedItem.dispatchTimestamp = block.timestamp;
        }
        
    }
    function reportDelivery(uint16 itemId) public payable driverOnly{
        ItemForDelivery memory selectedItem = items[itemId]; 
        require(selectedItem.driver== msg.sender,"Deliveries can only be confirmed by designated driver"); 
        require(selectedItem.status == DeliveryStatus.Dispatched, "Item is not recorded as in transit");
        verifyDelivery(block.timestamp, itemId);
        
    }
    function verifyDelivery(uint256 deliveryTimestamp, uint16 itemId) contractOnly public {
       //assumption of location and actual delivery of item
       ItemForDelivery memory selectedItem = items[itemId]; 
       uint256 deliveryTime = deliveryTimestamp - selectedItem.dispatchTimestamp;
       payDriver(selectedItem.driver, itemId, deliveryTime, DELIVERY_DEADLINE);
       selectedItem.status = DeliveryStatus.OrderReceived;

    }
    function payDeliveryfee(address _merchantAddress, uint16 itemId) internal returns (bool){
           uint128 delivery_fee = (item_prices[itemId]*5)/100;
           bool paid = token.transferFrom(_merchantAddress,contractAccount, delivery_fee);
           return paid;
    }
    function payDriver(address _driverAddress, uint16 itemId, uint256 deliveryTime,uint DEADLINE) public payable contractOnly{
         ItemForDelivery memory selectedItem = items[itemId]; 
         uint128 driver_stipend = (item_prices[itemId]*4)/100;
         require(selectedItem.status == DeliveryStatus.OrderReceived, "Item must have been delivered");
         if(deliveryTime <= DEADLINE){
            token.transfer(_driverAddress,driver_stipend);
         }else{
            token.transfer(_driverAddress,(driver_stipend*50)/100);
         }
    }
}

