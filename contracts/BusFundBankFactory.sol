pragma solidity^0.4.18;

import '../base_contracts/Ownable.sol';
import '../base_contracts/GenericCaller.sol';
import './BusFundBank.sol';

contract BusFundBankFactory is Ownable,GenericCaller {

  address public busInterface;
  mapping ( string => address ) allBusDatas;

  function BusFundBankFactory () GenericCaller(0x0) public {
  }

  function initializeFactory (address _interface) public onlyOwner onlyUninitialized {
    busInterface = _interface;
    genericCallAdmin = _interface;
  }

  function spawnFundBank (address _busData, string _busName) public onlyInterface {
    require(_busData != 0x0);
    require(bytes(_busName).length > 0);

    address _fundBank = new BusFundBank(_busData);
    allBusDatas[_busName] = _fundBank;
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
