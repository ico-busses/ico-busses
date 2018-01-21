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
  address public newOwner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) onlyOwner public {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }

  /**
  * @dev Accept Ownership
  */
  function acceptOwnership() onlyOwner public {
    require(newOwner == msg.sender);
    OwnershipTransferred(owner, newOwner);
    newOwner = 0x0;
    owner = newOwner;
  }

}

contract TimedOwnable is Ownable{

  uint256 public transferOwnerInitiated = 0;
  uint256 public transferOwnerWaitTime = 30 minutes;
  event transferOwnershipRequested( address newOwner, uint256 timestamp);

  function transferOwnership(address newOwner) onlyOwner public {
    transferOwnerInitiated = block.timestamp;
    super.transferOwnership(newOwner);
  }

  function rejectTransferOwnership() onlyOwner public {
    transferOwnerInitiated = 0;
    newOwner = 0;
  }

  function acceptOwnership() onlyOwner public {
    require( (now - transferOwnerInitiated) > transferOwnerWaitTime);
    transferOwnerInitiated = 0;
    super.acceptOwnership();
  }
}



contract WithFullDevilUpgradeableInterface is Ownable {

    address public interfaceAddress;
    address public newInterfaceAddress;
    bool public interfaceSet;
    uint256 public changeInterfaceCost = 0.12345 ether;
    uint256 public rejectInterfaceCost = 0.34567 ether;
    uint256 public timeSetInterfaceRequested = 0;
    uint256 public confirmInterfaceWaitTime = 30 minutes;

    event InterfaceSet(address previous, address present,uint256 blocktime);
    event setInterfaceRequested(address newAddress, uint256 blocktime);

    function WithFullDevilUpgradeableInterface(address _interface) public {
      interfaceAddress = _interface;
      interfaceSet = true;
      InterfaceSet(0, _interface,block.timestamp);
    }

    function setInterface(address _addr) payable public onlyOwner {
      require(msg.value == changeInterfaceCost);
      require(timeSetInterfaceRequested == 0);
      assert(owner != _addr);
      assert(interfaceAddress != _addr);

      newInterfaceAddress = _addr;
      interfaceSet = false;
      timeSetInterfaceRequested = block.timestamp;

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
      require( (now - timeSetInterfaceRequested) >= confirmInterfaceWaitTime);
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}


contract BusFundBank is TimedOwnable,WithFullDevilUpgradeableInterface{
  using SafeMath for uint;

  uint256 feesBalance;

  event EtherTransfer(address to,uint256 amount);

  function BusFundBank(address _interface) WithFullDevilUpgradeableInterface(_interface) public {}

  function getTokenBalance( address _token) public constant returns(uint256){
    return BasicToken(_token).balanceOf(this);
  }

  function sendTokens(address _token,  address _to,uint256 _value) public onlyInterface isInterfaceSet {
    require( getTokenBalance(_token) >= _value );
    BasicToken(_token).transfer(_to,_value);
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

  function () public payable{}
}
