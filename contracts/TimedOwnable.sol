import '../base_contracts/Ownable.sol';

pragma solidity^0.4.18;

contract TimedOwnable is Ownable{

  uint256 transferInitiated = 0;
  uint256 transferWaitTime = 30 minutes;
  event transferOwnershipRequested( address newOwner, uint256 timestamp);

  function transferOwnership(address newOwner) onlyOwner public{
    transferInitiated = block.timestamp;
    super.transferOwnership(newOwner);
  }

  function acceptOwnership() {
    require( (now - transferInitiated) > transferWaitTime);
    transferInitiated = 0;
    super.acceptOwnership();
  }
}
