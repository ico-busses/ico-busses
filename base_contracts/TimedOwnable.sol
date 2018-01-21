import './Ownable.sol';

pragma solidity^0.4.18;

contract TimedOwnable is Ownable{

  uint256 public transferOwnerInitiated = 0;
  uint256 public transferOwnerWaitTime = 30 minutes;
  event transferOwnershipRequested( address newOwner, uint256 timestamp);

  function transferOwnership(address newOwner) onlyOwner public {
    transferOwnerInitiated = block.timestamp;
    super.transferOwnership(newOwner);
  }

  function rejectTransferOwnership() onlyOwner public {
    transferOwnerInitiated = 0;
    newOwner = 0;
  }

  function acceptOwnership() onlyOwner public {
    require( (now - transferOwnerInitiated) > transferOwnerWaitTime);
    transferOwnerInitiated = 0;
    super.acceptOwnership();
  }
}
