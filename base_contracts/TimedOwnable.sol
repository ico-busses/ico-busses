pragma solidity^0.4.21;

import './Ownable.sol';

contract TimedOwnable is Ownable{

  address public newOwner;
  address public coFounder;
  uint256 public transferOwnerInitiated = 0;
  uint256 public transferOwnerWaitTime = 30 minutes;
  event TransferOwnershipRequested( address newOwner, uint256 timestamp);

  function TimedOwnable(address _coFounder) public {
    require(_coFounder != 0x0);
    coFounder = _coFounder;
  }

  function initiateTransferOwnership(address _newOwner) onlyOwner public {
    require(transferOwnerInitiated == 0);
    transferOwnerInitiated = block.timestamp;
    emit TransferOwnershipRequested( newOwner, transferOwnerInitiated);
    newOwner = _newOwner;
  }

  function rejectTransferOwnership() onlyOwner public {
    transferOwnerInitiated = 0;
  }

  function acceptOwnership() public {
    require(newOwner == msg.sender);
    require(transferOwnerInitiated > 0);
    require( (now - transferOwnerInitiated) >= transferOwnerWaitTime);
    transferOwnerInitiated = 0;
    super.transferOwnership(newOwner);
  }

  function vetoTransferOwnership() public {
    require(coFounder == msg.sender);
    require(transferOwnerInitiated > 0);
    transferOwnerInitiated = 0;
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
