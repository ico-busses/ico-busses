import './Ownable.sol';

pragma solidity^0.4.18;

contract TimedOwnable is Ownable{

  address public coFounder;
  uint256 public transferOwnerInitiated = 0;
  uint256 public transferOwnerWaitTime = 30 minutes;
  event transferOwnershipRequested( address newOwner, uint256 timestamp);

  function transferOwnership(address newOwner) public;

  function rejectTransferOwnership() onlyOwner public;

  function acceptOwnership() public;

  function vetoTransferOwnership() public;
}
