import './Ownable.sol';

pragma solidity^0.4.18;

contract WithUpgradeableInterface is Ownable{

    address public interfaceAddress;
    address public newInterfaceAddress;
    bool public interfaceSet;

    event InterfaceSet(address previous, address present,uint256 blocktime);
    event setInterfaceRequested(address newAddress, uint256 blocktime);

    function WithUpgradeableInterface(address _interface) public {
      interfaceAddress = _interface;
      interfaceSet = true;
      InterfaceSet(0, _interface,block.timestamp);
    }

    function setInterface(address _addr) payable public onlyOwner {
      assert(owner != _addr);
      assert(interfaceAddress != _addr);
      newInterfaceAddress = _addr;
      interfaceSet = false;
      setInterfaceRequested(newInterfaceAddress,block.timestamp);
    }

    function confirmSetInterface() payable public onlyOwner {
      require(interfaceSet == false);
      address previousInterface = interfaceAddress;
      interfaceAddress = newInterfaceAddress;
      newInterfaceAddress = 0;
      interfaceSet = true;
      InterfaceSet(previousInterface, interfaceAddress,block.timestamp);
    }

    function rejectSetInterface() payable public onlyOwner {
      require(interfaceSet == false);
      newInterfaceAddress = 0;
      interfaceSet = true;
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
