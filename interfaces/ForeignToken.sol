pragma solidity ^0.4.11;

contract ForeignToken {
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}
