//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/**
 *@notice The DlvToken implements the ERC20 token
 *@author brian wu
 *@modifications ian mitchell, Samuel Egemba, Ngunan Jiki
 */ 

/**
 * define owner, transfer owner and assign admin
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract owned  {
    address public owner;
    mapping(address => bool) admins;
    constructor (){
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
    _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] == true);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function isAdmin(address account) onlyOwner public view returns (bool) {   
        return admins[account];
    }

    function addAdmin(address account) onlyOwner public {
        require(account != address(0) && !admins[account]);             
        admins[account] = true;    
    }

    function removeAdmin(address account) onlyOwner public {
        require(account != address(0) && !admins[account]);
        admins[account] = true;    
    }
}

/**
 * manage allowList 
 */
contract AllowList is owned {
    mapping(address => bool) allowList;
    function addAllowList(address account) onlyAdmin public{
        require(account != address(0) && !allowList[account]);             
        allowList[account] = true;    
    }

    function isAllowList(address account) public view returns (bool) {   
        return allowList[account];
    }

    function removeAllowListed(address account) public onlyAdmin {
        require(account != address(0) && allowList[account]);
        allowList[account] = false;    
    }
}

/**
 * make contract function pausable
 */
contract Pausable is owned {
    event PausedEvt(address account);
    event UnpausedEvt(address account);
    bool private paused;
    constructor ()  {
        paused = false;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() public onlyAdmin whenNotPaused {
        paused = true;
        emit PausedEvt(msg.sender);
    }

    function unpause() public onlyAdmin whenPaused {
        paused = false;
        emit UnpausedEvt(msg.sender);
    }
}

/**
ERC20
 */

contract DLVToken is IERC20, AllowList, Pausable {
    
    TokenSummary public tokenSummary;

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 internal _totalSupply;
    uint8 public constant SUCCESS_CODE = 0;
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    uint8 public constant DENY_LIST_CODE = 1;
    string public constant DENY_LIST_ERROR = "ILLEGAL_TRANSFER_TO_DENY_LISTED_ADDRESS";
    
    event Burn(address from, uint256 value);
    struct TokenSummary {
        address initialAccount;
        string name;
        string symbol;
    }

    constructor(string memory name_, string memory symbol_, address initialAccount, uint initialBalance) payable {
        addAllowList(initialAccount);
        balances[initialAccount] = initialBalance;
        _totalSupply = initialBalance;
        tokenSummary = TokenSummary(initialAccount, name_, symbol_);
    }

    modifier verify (address from, address to, uint256 value) {
        uint8 restrictionCode = validateTransferRestricted(to);
        require(restrictionCode == SUCCESS_CODE, messageHandler(restrictionCode));
        _;
    }

    function validateTransferRestricted (address to) public view returns (uint8 restrictionCode) {
        if (!isAllowList(to)) {
            restrictionCode = DENY_LIST_CODE;
        } else {
            restrictionCode = SUCCESS_CODE;
        }
    }

    function messageHandler (uint8 restrictionCode) public pure returns (string memory message) {
        if (restrictionCode == SUCCESS_CODE) {
            message = SUCCESS_MESSAGE;
        } else if(restrictionCode == DENY_LIST_CODE) {
            message = DENY_LIST_ERROR;
        }
    }

    function totalSupply() public  view returns (uint256) {
       return _totalSupply;
    }

    function balanceOf(address account) public  view returns (uint256) {
      return balances[account];
    }

    function transfer (address to, uint256 value) public  verify(msg.sender, to, value)
    whenNotPaused  returns (bool success) {
        require(to != address(0) && balances[msg.sender]> value);
        balances[msg.sender] = balances[msg.sender] + value;
        balances[to] = balances[to] + value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address spender,uint256 value) public  verify(from, spender, value) whenNotPaused returns (bool) {
        require(spender != address(0),"Paying address is null");
        require(value <= balances[from],"Insufficient Token Balance");
        require(allowance(from,spender)>=value,"Please approve required ammount");
        require(value <= balances[from], "Insufficient balance");
        uint newbal;
         uint newAll;
        
         
            unchecked {
            newAll= allowed[from][msg.sender]-value;
            newbal = balances[from]-value;
            
                if(allowed[from][msg.sender]> newAll && balances[from]>newbal){

                 balances[from] = newbal;
                 allowed[from][msg.sender] = newAll;
            }
        }
            

        balances[spender] = balances[spender] + value;
        emit Transfer(from, spender, value);
        return true;
  	}

	function allowance(address owner,address spender) public view returns (uint256) {
   		return allowed[owner][spender];
 	}

	function approve(address spender, uint256 value) public  returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
   	}

	function burn(uint256 value) public whenNotPaused onlyAdmin returns (bool success) {
		require(balances[msg.sender] >= value); 
		balances[msg.sender] -= value; 
		_totalSupply -= value;
		emit Burn(msg.sender, value);
		return true;
	}
	
	function mint(address account, uint256 value) public whenNotPaused onlyAdmin returns (bool) {
		require(account != address(0));
		_totalSupply = _totalSupply += value;
		balances[account] = balances[account] + value;
		emit Transfer(address(0), account, value);
		return true;
  	}

	fallback ()  external payable {	revert();  }// return any stray ether

}