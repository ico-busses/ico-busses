import '../base_contracts/Ownable.sol';

pragma solidity^0.4.18;

contract WithFullDevilUpgradeableInterface is Ownable {

    address public interfaceAddress;
    address public newInterfaceAddress;
    bool public interfaceSet;
    uint256 public changeInterfaceCost = 0.012345 ether;
    uint256 public rejectInterfaceCost = 0.034567 ether;
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
