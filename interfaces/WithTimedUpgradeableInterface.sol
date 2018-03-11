pragma solidity^0.4.18;

import './WithUpgradeableInterface.sol';

contract WithTimedUpgradeableInterface is WithUpgradeableInterface{

    uint256 public timeSetInterfaceRequested = 0;
    uint256 public confirmInterfaceWaitTime = 30 minutes;

    function setInterface(address _addr) payable public;

    function confirmSetInterface() payable public;

    function rejectSetInterface() payable public;
    
}
