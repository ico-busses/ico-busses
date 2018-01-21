pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  address public newOwner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) onlyOwner public {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }

  /**
  * @dev Accept Ownership
  */
  function acceptOwnership() onlyOwner public {
    require(newOwner == msg.sender);
    OwnershipTransferred(owner, newOwner);
    newOwner = 0x0;
    owner = newOwner;
  }

}
