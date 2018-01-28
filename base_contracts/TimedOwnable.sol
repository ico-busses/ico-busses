import './Ownable.sol';

pragma solidity^0.4.18;

contract TimedOwnable is Ownable{

  address public coFounder;
  uint256 public transferOwnerInitiated = 0;
  uint256 public transferOwnerWaitTime = 30 minutes;
  event transferOwnershipRequested( address newOwner, uint256 timestamp);

  function TimedOwnable(address _coFounder) Ownable(){
    require(_coFounder != 0x0);
    coFounder = _coFounder;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(transferOwnerInitiated == 0);
    transferOwnerInitiated = block.timestamp;
    transferOwnershipRequested( newOwner, transferOwnerInitiated);
    super.transferOwnership(newOwner);
  }

  function rejectTransferOwnership() onlyOwner public {
    transferOwnerInitiated = 0;
  }

  function acceptOwnership() public {
    require(transferOwnerInitiated > 0);
    require( (now - transferOwnerInitiated) >= transferOwnerWaitTime);
    transferOwnerInitiated = 0;
    super.acceptOwnership();
  }

  function vetoTransferOwnership() public {
    require(coFounder == msg.sender);
    require(transferOwnerInitiated > 0);
    transferOwnerInitiated = 0;
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
