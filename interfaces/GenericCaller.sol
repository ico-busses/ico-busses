pragma solidity ^0.4.18;

/**
Contract with ability Call generic functions
*/
contract GenericCaller{

  address genericCallAdmin;

  function callGenericFunction( address _addr, bytes4 _function, bytes32 _data) public;

  function updateGenericCallAdmin( address _addr ) public;
}
