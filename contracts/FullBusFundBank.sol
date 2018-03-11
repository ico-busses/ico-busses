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

contract WithFullDevilUpgradeableInterface is TimedOwnable {

    address public interfaceAddress;
    address public newInterfaceAddress;
    bool public interfaceSet;
    uint256 public changeInterfaceCost = 0.012345 ether;
    uint256 public rejectInterfaceCost = 0.034567 ether;
    uint256 public timeSetInterfaceRequested = 0;
    uint256 public confirmInterfaceWaitTime = 30 minutes;

    event InterfaceSet(address previous, address present,uint256 blocktime);
    event setInterfaceRequested(address newAddress, uint256 blocktime);

    function WithFullDevilUpgradeableInterface(address _coFounder,address _interface) TimedOwnable(_coFounder) public {
      interfaceAddress = _interface;
      interfaceSet = true;
      InterfaceSet(0, _interface,block.timestamp);
    }

    function setInterface(address _addr) payable public onlyOwner {
      require(msg.value == changeInterfaceCost);
      require(timeSetInterfaceRequested == 0);
      assert(owner != _addr);
      assert(interfaceAddress != _addr);

      timeSetInterfaceRequested = block.timestamp;
      newInterfaceAddress = _addr;
      interfaceSet = false;

      setInterfaceRequested(newInterfaceAddress,block.timestamp);
    }

    function confirmSetInterface() payable public onlyOwner {
      require(msg.value == changeInterfaceCost);
      require(timeSetInterfaceRequested != 0);
      require( (now - timeSetInterfaceRequested) >= confirmInterfaceWaitTime);
      require(interfaceSet == false);

      address previousInterface = interfaceAddress;
      interfaceAddress = newInterfaceAddress;
      newInterfaceAddress = 0;
      interfaceSet = true;
      timeSetInterfaceRequested = 0;

      InterfaceSet(previousInterface, interfaceAddress,block.timestamp);
      owner.transfer(changeInterfaceCost);
    }

    function rejectSetInterface() payable public onlyOwner {
      require(msg.value == rejectInterfaceCost);
      require(timeSetInterfaceRequested != 0);
      require(interfaceSet == false);

      newInterfaceAddress = 0;
      interfaceSet = true;
      timeSetInterfaceRequested = 0;

      owner.transfer(changeInterfaceCost);
    }

    modifier onlyInterface{
      require(msg.sender == interfaceAddress);
      _;
    }

    modifier isInterfaceSet{
      require(interfaceSet == true);
      _;
    }

}

contract ForeignToken {
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

import {ForeignToken as FERC20} from './FullBusFundBank.sol';
contract BusFundBank is WithFullDevilUpgradeableInterface{
  using SafeMath for uint;

  uint256 feesBalance;
  event EtherTransfer(address to,uint256 amount);

  function BusFundBank(address _coFounder, address _interface) WithFullDevilUpgradeableInterface(_coFounder,_interface) public {}

  function getTokenBalance( address _token) public constant returns(uint256){
    return FERC20(_token).balanceOf(this);
  }

  function sendTokens(address _token,  address _to,uint256 _value) public onlyInterface isInterfaceSet {
    require( getTokenBalance(_token) >= _value );
    FERC20(_token).transfer(_to,_value);
  }

  function sendBatchTokens(address _token, address[20] _addresses, uint256[20] _values ) public onlyInterface isInterfaceSet {
    for(uint256  t=0; t<_addresses.length; t++){
      if(_addresses[t] != 0x0 && _values[t] > 0)
        sendTokens(_token,_addresses[t],_values[t]);
    }
  }

  function sendEther(address _to,uint256 _value) public onlyInterface isInterfaceSet {
    require(_to != 0x0);
    require(_value > 0);
    EtherTransfer(_to,_value);
    _to.transfer(_value);
  }

  function withdrawFees() public onlyInterface isInterfaceSet {
    require(this.balance >= feesBalance);
    uint256 toPay = feesBalance;
    feesBalance = 0;
    EtherTransfer(owner,toPay);
    owner.transfer(toPay);
  }

  function confirmSetInterface() payable public onlyOwner {
    super.confirmSetInterface();
    feesBalance.add(changeInterfaceCost);
  }

  function rejectSetInterface() payable public onlyOwner {
    super.rejectSetInterface();
    feesBalance.add(msg.value.sub(changeInterfaceCost) );
  }

  function fund(uint256 fees) public payable{
    require(msg.value >= fees);
    feesBalance.add(fees);
  }

  function () public payable {}
}
