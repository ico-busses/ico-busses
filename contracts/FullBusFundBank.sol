pragma solidity ^0.4.18;


/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
  uint256 c = a * b;
  assert(a == 0 || c / a == b);
  return c;
}

function div(uint256 a, uint256 b) internal constant returns (uint256) {
  // assert(b > 0); // Solidity automatically throws when dividing by 0
  uint256 c = a / b;
  // assert(a == b * c + a % b); // There is no case in which this doesn't hold
  return c;
}

function sub(uint256 a, uint256 b) internal constant returns (uint256) {
  assert(b <= a);
  return a - b;
}

function add(uint256 a, uint256 b) internal constant returns (uint256) {
  uint256 c = a + b;
  assert(c >= a);
  return c;
}
}


/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
address public owner;

event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

/**
 * @dev The Ownable constructor sets the original `owner` of the contract to the sender
 * account.
 */
function Ownable() public {
  owner = msg.sender;
}

/**
 * @dev Throws if called by any account other than the owner.
 */
modifier onlyOwner() {
  require(msg.sender == owner);
  _;
}

/**
 * @dev Allows the current owner to transfer control of the contract to a newOwner.
 * @param newOwner The address to transfer ownership to.
 */
function transferOwnership(address newOwner) internal {
  require(newOwner != address(0));
  OwnershipTransferred(owner, newOwner);
  owner = newOwner;
}
}

contract TimedOwnable is Ownable{

  address public newOwner;
  address public coFounder;
  uint256 public transferOwnerInitiated = 0;
  uint256 public transferOwnerWaitTime = 30 minutes;
  event transferOwnershipRequested( address newOwner, uint256 timestamp);

  function TimedOwnable(address _coFounder) public {
    require(_coFounder != 0x0);
    coFounder = _coFounder;
  }

  function initiateTransferOwnership(address _newOwner) onlyOwner public {
    require(transferOwnerInitiated == 0);
    transferOwnerInitiated = block.timestamp;
    transferOwnershipRequested( newOwner, transferOwnerInitiated);
    newOwner = _newOwner;
  }

  function rejectTransferOwnership() onlyOwner public {
    transferOwnerInitiated = 0;
  }

  function acceptOwnership() public {
    require(newOwner == msg.sender);
    require(transferOwnerInitiated > 0);
    require( (now - transferOwnerInitiated) >= transferOwnerWaitTime);
    transferOwnerInitiated = 0;
    super.transferOwnership(newOwner);
  }

  function vetoTransferOwnership() public {
    require(coFounder == msg.sender);
    require(transferOwnerInitiated > 0);
    transferOwnerInitiated = 0;
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract ForeignToken {
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

import {ForeignToken as FERC20} from './FullBusFundBank.sol';
contract BusFundBank is TimedOwnable {
  using SafeMath for uint;

  uint256 feesBalance;
  address busData;
  bool resolved;
  event EtherTransfer(address indexed to,uint256 amount);
  event TokenTransfer(address token,address indexed to,uint256 amount);

  function BusFundBank(address _interface) TimedOwnable(0x1) public {
    busData = _interface;
  }

  function getTokenBalance( address _token) public constant returns(uint256){
    return FERC20(_token).balanceOf(this);
  }

  function setResolved () public onlyInterface {
    resolved = true;
  }

  function doTokenTransfer(address _token,  address _to,uint256 _value) internal {
    TokenTransfer(_token,_to,_value);
    FERC20(_token).transfer(_to,_value);
  }

  function doEtherTransfer(address _to,uint256 _value) internal {
    EtherTransfer(_to,_value);
    _to.transfer(_value);
  }

  function sendTokens(address _token,  address _to,uint256 _value) public onlyInterface {
    require( getTokenBalance(_token) >= _value );
    doTokenTransfer(_token,_to,_value);
  }

  function sendBatchTokens(address _token, address[20] _addresses, uint256[20] _values ) public onlyInterface {
    for(uint256  t=0; t<_addresses.length; t++){
      if(_addresses[t] != 0x0 && _values[t] > 0)
        sendTokens(_token,_addresses[t],_values[t]);
    }
  }

  function sendEther(address _to,uint256 _value) public onlyInterface {
    require(_to != 0x0);
    require(_value > 0);
    doEtherTransfer(_to,_value);
  }

  function withdrawFees(address _destination) public onlyOwner {
    require(this.balance >= feesBalance);
    uint256 toPay = feesBalance;
    feesBalance = 0;
    doEtherTransfer(_destination,toPay);
  }

  function cleanSweep(address _destination, address _token) public canSweep onlyResolved {
    uint toPay = getTokenBalance(_token);
    require(toPay >= 0);
    doTokenTransfer(_token,_destination,toPay);
  }

  function cleanSweep(address _destination) public canSweep onlyResolved{
    require(this.balance >= 0);
    doEtherTransfer(_destination,this.balance);
  }

  function fund(uint256 fees) public payable{
    require(msg.value >= fees);
    feesBalance.add(fees);
  }

  function () public {}

  modifier canSweep {
    require (busData == msg.sender || owner == msg.sender);
    _;
  }

  modifier onlyResolved {
    require (resolved == true);
    _;
  }

  modifier onlyInterface {
    require (busData == msg.sender);
    _;
  }
}
