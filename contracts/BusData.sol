import './WithUpgradeableInterface.sol';

pragma solidity^0.4.18;

contract BusData is WithUpgradeableInterface{

  enum IcoStatus{presented,approved,started,ended,tokensarrived,completed}

  struct Investor{
    uint256 totalDeposit;
    bool active;
  }

  struct ICO{
    string name;
    uint256 lastFunded;
    uint256 totalFunds;
    address tokenAddress;
    IcoStatus status;
    address icoAddress ;
    mapping(address => Inestor) investors;
  }

  uint256 investFee = 0.03*1 ether;

  mapping(uint256 => ICO) public icos;
  mapping(address=>uint) public tokensIco;
  mapping(address=>uint) public icoAddressesIco;

  function createICO( address _icoAddress, string _name, ) public onlyInterface {

  }

  function joinICO( address _investor, uint256 _value ) public onlyInterface  {}


  function getIcoIndex(address _addr, bool _isTokenAddress) public pure constant returns(uint256 icoIndex){
    if(!_isTokenAddress){
      return icoAddressesIco[_addr];
    else{
      return tokensIco[_addr];
    }
  }

  function getTokenName(address _token) public pure constant returns(string){
    return ERC20Basic(_token).name();
  }

  function getTokenSymbol(address _token) public pure constant returns(string){
    return ERC20Basic(_token).symbol();
  }

  function getIcoAddress(uint256 _icoIndex) public view constant returns (address){
    assert(_icoIndex > 0);
    return icos[ _icoIndex ].icoAddress;
  }

  function getIcoName(uint256 _icoIndex) public view constant returns (address){
    assert(_icoIndex > 0);
    return icos[ _icoIndex ].name;
  }

  function isIcoAdded(address _ico) public view constant returns (bool){
    return getIcoIndex(_ico, false) > 0 ;
  }

  function isTokenAdded(address _token) public view constant returns (bool){
    return getIcoIndex(_token,true) > 0;
  }

  function isInvestor(uint256 _icoIndex, address _investor) public view constant returns (bool){
    assert(_icoIndex > 0);
    return (icos[_icoIndex].investors[msg.sender].active == true && icos[_icoIndex].investors[msg.sender].totalDeposit > 0);
  }



}
