pragma solidity^0.4.18;

import './Ownable.sol';

contract TimedOwnable is Ownable{

  address public coFounder;
  uint256 public transferOwnerInitiated = 0;
  uint256 public transferOwnerWaitTime = 30 minutes;
  event transferOwnershipRequested( address newOwner, uint256 timestamp);

  function initiateTransferOwnership(address newOwner) public;

  function rejectTransferOwnership() public;

  function acceptOwnership() public;

  function vetoTransferOwnership() public;
}
