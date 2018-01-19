pragma solidity^0.4.18;

contract BusInterface is ownable{

  address public busData;
  address public busFundBank;

  function addIcoSale(address _saleAddr, string _name, ) public payable isSetMinimumStake {}

  function setTokenAddress(uint256 icoIndex, address token) public canUpdateDetails(_addr){}

  function setIcoStarted(address _addr) public canUpdateDetails(_addr) {

  }






  function isOwner() public view constant returns (bool){
    return msg.sender == owner;
  }

  function isInvestor(address _ico) public view constant returns (bool){
    BusData()
    return (icos[_ico].investors[msg.sender].active == true && icos[_ico].investors[msg.sender].totalDeposit > 0);
  }

  modifier canUpdateDetails(address _ico){
    require( isOwner() || isInvestor(_ico) );
    _;
  }

  function isVetoed(){
    return isOwner();
  }

  modifier isSetMinimumStake{
    require(ms.value > minimumStake);
    _;
  }
}
