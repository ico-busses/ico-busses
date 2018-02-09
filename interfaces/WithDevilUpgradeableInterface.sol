import './WithTimedUpgradeableInterface.sol';

pragma solidity^0.4.18;

contract WithDevilUpgradeableInterface is WithTimedUpgradeableInterface{

    uint256 public changeInterfaceCost = 0.012345 ether;
    uint256 public rejectInterfaceCost = 0.034567 ether;


    function setInterface(address _addr) payable public;

    function confirmSetInterface() payable public;

    function rejectSetInterface() payable public;
    
}
