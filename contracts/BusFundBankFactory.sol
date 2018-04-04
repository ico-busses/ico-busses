pragma solidity^0.4.18;

import '../base_contracts/Ownable.sol';
import '../base_contracts/GenericCaller.sol';
import './BusFundBank.sol';

contract BusFundBankFactory is Ownable,GenericCaller {

  address public busInterface;
  address[] allBusFunds;
  mapping ( string => address ) allBusFundNames;

  event BusFundBankCreated( address BusFundBank, string Name );

  function BusFundBankFactory () GenericCaller(0x0) public {
  }

  function initializeFactory (address _interface) public onlyOwner onlyUninitialized {
    busInterface = _interface;
    genericCallAdmin = _interface;
  }

  function spawnFundBank (address _busData, string _busName) public onlyInterface returns (address) {
    require(_busData != 0x0);
    require(bytes(_busName).length > 0);

    address _fundBank = new BusFundBank(_busData);
    allBusFundNames[_busName] = _fundBank;
    allBusFunds.push(_fundBank);
    BusFundBankCreated(_fundBank, _busName);

    return _fundBank;
  }

  function countAllCreated() public view returns (uint256) {
    return allBusFunds.length;
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
