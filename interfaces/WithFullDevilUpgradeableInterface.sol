pragma solidity^0.4.18;

import './TimedOwnable.sol';

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

    function setInterface(address _addr) payable public;

    function confirmSetInterface() payable public;

    function rejectSetInterface() payable public;

}
