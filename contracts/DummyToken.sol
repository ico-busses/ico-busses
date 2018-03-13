pragma solidity ^0.4.11;

import '../libraries/SafeMath.sol';
import '../base_contracts/Ownable.sol';

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract DummyToken is Ownable {
  using SafeMath for uint256;

  string public name;
  string public symbol;
  uint256 public totalSupply;
  uint256 public decimals = 18;
  mapping(address => uint256) balances;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Mint(address indexed to, uint256 amount);

  function DummyToken (string _name, string _symbol ) public {
    name = _name;
    symbol = _symbol;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}
