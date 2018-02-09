import './Ownable.sol';

pragma solidity^0.4.18;

contract WithUpgradeableInterface is Ownable{

    address public interfaceAddress;
    address public newInterfaceAddress;
    bool public interfaceSet;

    event InterfaceSet(address previous, address present,uint256 blocktime);
    event setInterfaceRequested(address newAddress, uint256 blocktime);

    function setInterface(address _addr) payable public;

    function confirmSetInterface() payable public;

    function rejectSetInterface() payable public;
    
}
