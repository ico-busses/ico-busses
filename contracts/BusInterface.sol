pragma solidity^0.4.18;

import '../base_contracts/GenericCaller.sol';
import './BusFundBank.sol';
import './BusData.sol';

contract BusInterface is Ownable,GenericCaller{

  address public busData;
  address public busFundBank;
  uint256 public minimumStake;

  address[] public busDataFactories;
  address[] public busFundBankFactories;

  function BusInterface () GenericCaller (msg.sender) public {

  }

  function addIcoSale(address _saleAddr, string _name ) public payable isSetMinimumStake {}

  function setTokenAddress(uint256 icoIndex, address token) public canUpdateDetails(msg.sender){}

  function setIcoStarted(address _addr) public canUpdateDetails(_addr) {

  }

  function getActiveBusDataFactory () public view returns (address) {
    return busDataFactories[busDataFactories.length];
  }

  function getActiveBusFundBankFactory() public view returns (address) {
    return busFundBankFactories[busFundBankFactories.length];
  }






  function isOwner() public view returns (bool){
    //return msg.sender == owner;
  }

  function isInvestor(address _ico) public view returns (bool){
    //BusData()
    //return (icos[_ico].investors[msg.sender].active == true && icos[_ico].investors[msg.sender].totalDeposit > 0);
  }

  modifier canUpdateDetails(address _ico){
    require( isOwner() || isInvestor(_ico) );
    _;
  }

  function isVetoed(){
    //return isOwner();
  }

  modifier isSetMinimumStake{
    require(msg.value > minimumStake);
    _;
  }
}
