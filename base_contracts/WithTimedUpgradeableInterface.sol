pragma solidity^0.4.18;

import './WithUpgradeableInterface.sol';

contract WithTimedUpgradeableInterface is WithUpgradeableInterface{

    uint256 public timeSetInterfaceRequested = 0;
    uint256 public confirmInterfaceWaitTime = 30 minutes;

    function WithTimedUpgradeableInterface(address _interface) WithUpgradeableInterface(_interface) public {}

    function setInterface(address _addr) payable public onlyOwner {
      require(timeSetInterfaceRequested == 0);
      timeSetInterfaceRequested = block.timestamp;
      super.setInterface(_addr);
    }

    function confirmSetInterface() payable public onlyOwner {
      require(timeSetInterfaceRequested != 0);
      require( (now - timeSetInterfaceRequested) >= confirmInterfaceWaitTime);
      timeSetInterfaceRequested = 0;
      super.confirmSetInterface();
    }

    function rejectSetInterface() payable public onlyOwner {
      require(timeSetInterfaceRequested != 0);
      timeSetInterfaceRequested = 0;
      super.rejectSetInterface();
    }
}
