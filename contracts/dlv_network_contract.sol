//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./DlvToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";



contract DLV_Network{
    using SafeMath for uint256;
    mapping(address => bool) public membership;
    mapping(address => bool) public isMerchant;
    mapping(address => bool) public isDriver;
    mapping(address=> bool) public isPurchaser;
    mapping(address => uint) public membershipExpires;
    mapping(uint16 => uint256) public item_prices;
    uint64 constant  MEMBERSHIP_FEE_DRIVER =  50;
    uint64 constant  MEMBERSHIP_FEE_MERCHANT =  100;
    uint constant  YEAR = 31536000; //365 * 24 * 60 * 60;
    uint constant  DELIVERY_DEADLINE= 86400; //1 day in seconds
    address payable public  owner;
    address payable contractAccount;
    DLVToken token;
    uint128 price_per_token = 20000000000 wei;
    ItemForDelivery[10000] public items;
    address[50] drivers;

    
    bool reentrancyGuard=true;
    enum DeliveryStatus  { Available, OrderPlaced,OrderReceived,Dispatched, Delayed, Delivered } 
    struct ItemForDelivery{
        string name;
        DeliveryStatus status;
        address recipient;
        address merchant;
        address driver;
        uint256 dispatchTimestamp;

    }
    function init(address merchant1, address merchant2) public {
        address _dummmyAddress;
       
        //instantiate products for delivery
        items[0] = ItemForDelivery("item 1",DeliveryStatus.Available,_dummmyAddress,merchant1,_dummmyAddress,0);
        items[1] = ItemForDelivery("item 2",DeliveryStatus.Available,_dummmyAddress,merchant1,_dummmyAddress,0);
       items[2] = ItemForDelivery("item 5",DeliveryStatus.Available,_dummmyAddress,merchant2,_dummmyAddress,0);
        items[3] = ItemForDelivery("item 6",DeliveryStatus.Available,_dummmyAddress,merchant2,_dummmyAddress,0);
        
    }

    
    event display(address _to, address _from, uint amount, string fn);
    event deliveryUpdate(uint16 _item_id,address _merchant,address _purchaser, string _newStatus);
    event driverUpdate(uint16 _item_id,address _merchant,address _driver,string _status);

    modifier ownerOnly { require(msg.sender == owner, "Insufficient privileges"); _; }
    modifier purchaserOnly { require(isPurchaser[msg.sender]== true, "Only customers can perform this action"); _;}
    modifier merchantOnly { require(isMerchant[msg.sender]== true, "Only merchants can perform this action"); _;}
    modifier driverOnly { require(isDriver[msg.sender]== true, "Only merchants can perform this action"); _;}
    modifier contractOnly {require(msg.sender == contractAccount,"Executable only by the contract acct"); _;}

    constructor(DLVToken _token) payable  {
        owner = payable(msg.sender);
        contractAccount=payable(address(this));
        token = _token;
    }

    fallback() external payable { emit display(contractAccount, msg.sender, msg.value, "fb");}
    receive() external  payable { emit display(contractAccount, msg.sender, msg.value, "rc");}

    function register(uint8 memberType) public {
        address _newMemberAddress = msg.sender;
        require(!membership[_newMemberAddress],"You are already a member!");
        
        membershipExpires[_newMemberAddress] = blockTimestamp().add(YEAR);
        if (memberType==1) {
            isMerchant[_newMemberAddress]= true;
        } else if(memberType==2) {
            require(drivers.length==50,"There is no vacancy for drivers");
            isDriver[_newMemberAddress]= true;  
        } else if (memberType==3){
            isPurchaser[_newMemberAddress]= true;
        }
       payFees(_newMemberAddress);  
    } 

    function blockTimestamp() public view returns(uint){
        return block.timestamp;
    }

/*
    sender transfers 1 ether (fee) to owner    
*/
    function payFees() public {
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
        membershipExpires[_member] = blockTimestamp().add(YEAR);
    }
    function payFees(address _member) public {
        //check msg.value == membership fee
        uint MEMBERSHIP_FEE;
        if (isMerchant[_member]== true) {
            MEMBERSHIP_FEE = MEMBERSHIP_FEE_MERCHANT;
        } else if (isDriver[_member]== true) {
           MEMBERSHIP_FEE = MEMBERSHIP_FEE_DRIVER;
        }
        if(isPurchaser[_member]){
             membership[_member]= true;
             membershipExpires[_member] = blockTimestamp().add(YEAR);
        }else{
            //check membership is invalid
            require(membershipExpires[_member] > blockTimestamp(), "Membership not expired");
            //check sufficient funds in account
            require(token.balanceOf(_member)> MEMBERSHIP_FEE, "Insufficient funds");
            //send the amount and update membership
            membership[_member]= token.transferFrom(_member,contractAccount, MEMBERSHIP_FEE);
            //check it has been paid
            require(membership[_member], "Membership: Transferred failed");
            //update new expiry time + 1 year
            membershipExpires[_member] = blockTimestamp().add(YEAR);
        }
    }


    function collect(uint _amount) public  ownerOnly{
        require(address(this).balance >= _amount,"insufficient funds");
        require(reentrancyGuard);
        reentrancyGuard=false;
        owner.transfer(_amount);
        reentrancyGuard=true;
    }

    

    function buyToken(uint32 quantity) external payable{
    
        require(quantity <= type(uint32).max, "Quantity exceeds maximum value: 4,000,000,000");
        address _member = msg.sender; 
        uint256 tranx_cost = quantity * price_per_token;
        require(_member.balance > msg.value,"Insufficent funds" );
        require(msg.value == tranx_cost, "Provide enough ether to complete the transaction. Check token price");
        token.mint(_member,quantity);
        emit display(contractAccount,_member,msg.value,"buyToken");
    }
 
    function orderItem(uint16 itemId, uint256 price) public purchaserOnly{
        require(itemId <= 10000, "ItemId is incorrect");
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
            emit deliveryUpdate(itemId,selectedItem.merchant,_purchaser,"Order Placed");
        }
        
    }
    function acceptOrder(uint16 itemId) public merchantOnly{
        require(itemId <= 10000, "ItemId is incorrect");
        ItemForDelivery memory selectedItem = items[itemId];
        require(selectedItem.merchant== msg.sender,"Orders can only be accepted by designated merchant");
        selectedItem.status = DeliveryStatus.OrderReceived;
        items[itemId] =selectedItem;
        emit deliveryUpdate(itemId,msg.sender,selectedItem.recipient,"Order Received");
    }
    function dispatchItem(uint16 itemId, address _driver) public  merchantOnly{
        require(itemId <= 10000, "ItemId is incorrect");
        ItemForDelivery memory selectedItem = items[itemId];
        require(selectedItem.merchant== msg.sender,"Orders can only be accepted by designated merchant"); 
        require(selectedItem.status == DeliveryStatus.OrderReceived, "Item is not available for delivery");
        uint256 delivery_fee = (item_prices[itemId]*5)/100;
        bool paid = token.transferFrom(msg.sender,contractAccount, delivery_fee);
        if(paid){
            emit display(msg.sender,contractAccount,delivery_fee,"payDelivery(DLV)");
            selectedItem.status = DeliveryStatus.Dispatched;
            selectedItem.driver = _driver;
            selectedItem.dispatchTimestamp = blockTimestamp();
            items[itemId] = selectedItem;
            emit deliveryUpdate(itemId,msg.sender,selectedItem.recipient,"Order in Transit");
        }
        
    }
    function reportDelivery(uint16 itemId) public  driverOnly{
        require(itemId <= 10000, "ItemId is incorrect");
        ItemForDelivery memory selectedItem = items[itemId]; 
        require(selectedItem.driver== msg.sender,"Deliveries can only be confirmed by designated driver"); 
        require(selectedItem.status == DeliveryStatus.Dispatched, "Item is not recorded as in transit");
        
        verifyDelivery(blockTimestamp(), itemId);
        
    }
    function verifyDelivery(uint256 deliveryTimestamp, uint16 itemId) public {
       //assumption of location and actual delivery of item
       ItemForDelivery memory selectedItem = items[itemId]; 
       int256 deliveryTime =int(deliveryTimestamp)- int(selectedItem.dispatchTimestamp);
       selectedItem.status = DeliveryStatus.Delivered;
       items[itemId]= selectedItem;
       payDriver(selectedItem.driver, itemId, deliveryTime, int(DELIVERY_DEADLINE));
       emit deliveryUpdate(itemId,selectedItem.merchant,selectedItem.recipient,"Order Delivered");
    }
    function payDriver(address _driverAddress, uint16 itemId, int256 deliveryTime,int DEADLINE) public   returns(bool){
         bool paid;
         ItemForDelivery memory selectedItem = items[itemId]; 
         uint256 driver_stipend = (item_prices[itemId].mul(4)).div(100);
         require(selectedItem.status == DeliveryStatus.Delivered, "Item must have been delivered");
         if(deliveryTime <= DEADLINE){
           paid= token.transfer(_driverAddress,driver_stipend);
           if (paid) emit display(contractAccount,_driverAddress,driver_stipend,"payDelivery(DLV)");
         }else{
          paid= token.transfer(_driverAddress,(driver_stipend.mul(50)).div(100));
            if(paid) emit display(contractAccount,_driverAddress,(driver_stipend.mul(50)).div(100),"payDelivery(DLV)");
         }
         return paid;
    }
}

