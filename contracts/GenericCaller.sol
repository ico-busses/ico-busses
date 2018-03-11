pragma solidity ^0.4.18;

/**
Contract with ability Call generic functions
*/
contract GenericCaller{

  address genericCallAdmin; // Ensure only admin can use this

  function GenericCaller(address _genericCallAdmin) public {
    genericCallAdmin = _genericCallAdmin;
  }

  function callGenericFunction( address _addr, bytes4 _function, bytes32 _data) public onlyGenericCallAdmin {
    require(_addr != 0x0);
    require(_addr.call(_function, _data));
  }

  function updateGenericCallAdmin( address _addr ) public onlyGenericCallAdmin {
    require(_addr != 0x0);
    genericCallAdmin = _addr;
  }

  modifier onlyGenericCallAdmin{
    require(msg.sender == genericCallAdmin);
    _;
  }
}
