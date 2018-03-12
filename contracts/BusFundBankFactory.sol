pragma solidity^0.4.18;

import '../base_contracts/Ownable.sol';
import './BusFundBank.sol';

contract BusFundBankFactory is Ownable {

  address busInterface;
  mapping ( string => address ) allBusDatas;

  function BusFundBankFactory () public {
  }

  function initializeFactory (address _interface) public onlyOwner onlyUninitialized {
    busInterface = _interface;
  }

  function spawnFundBank () public onlyInterface {

  }

  modifier onlyInterface {
    require (busInterface == msg.sender);
    _;
  }

  modifier onlyUninitialized {
    require (busInterface == 0x0);
    _;
  }

}
