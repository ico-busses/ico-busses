import './WithTimedUpgradeableInterface.sol';

pragma solidity^0.4.18;

contract WithDevilUpgradeableInterface is WithTimedUpgradeableInterface{

    uint256 public changeInterfaceCost = 0.12345 ether;
    uint256 public rejectInterfaceCost = 0.34567 ether;

    function WithDevilUpgradeableInterface(address _interface) WithTimedUpgradeableInterface(_interface) public {}

    function setInterface(address _addr) payable public onlyOwner {
      require(msg.value == changeInterfaceCost);
      super.setInterface(_addr);
    }

    function confirmSetInterface() payable public onlyOwner {
      require(msg.value == changeInterfaceCost);
      super.confirmSetInterface();
      owner.transfer(changeInterfaceCost);
    }

    function rejectSetInterface() payable public onlyOwner {
      require(msg.value == rejectInterfaceCost);
      super.rejectSetInterface();
      owner.transfer(changeInterfaceCost);
    }
}
