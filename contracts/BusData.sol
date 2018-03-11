pragma solidity^0.4.18;

import '../base_contracts/WithFullDevilUpgradeableInterface.sol';
import {ForeignToken as FERC20} from '../interfaces/ForeignToken.sol';

contract BusData is WithFullDevilUpgradeableInterface {

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
    mapping(address => Investor) investors;
  }

  uint256 investFee = 0.03*1 ether;

  mapping(uint256 => ICO) public icos;
  mapping(address=>uint) public tokensIco;
  mapping(address=>uint) public icoAddressesIco;
  mapping(address=>address[]) public investorIcos;

  function createICO( address _icoAddress, string _name ) public onlyInterface {}

  function joinICO( address _investor, uint256 _value ) public onlyInterface  {}

  function getIcoIndex(address _addr, bool _isTokenAddress) public view returns(uint256 icoIndex){
    if(!_isTokenAddress)
      return icoAddressesIco[_addr];
    else{
      return tokensIco[_addr];
    }
  }

  function getIco(uint256 _icoIndex) private view returns (ICO){
    return icos[ _icoIndex ];
  }

  function getIcoAddress(uint256 _icoIndex) public view returns (address){
    assert(_icoIndex > 0);
    return icos[ _icoIndex ].icoAddress;
  }

  function getIcoName(uint256 _icoIndex) public view returns (string){
    assert(_icoIndex > 0);
    return icos[ _icoIndex ].name;
  }

  function getInvestorIcos(address _investor) public view returns (uint) {
    return investorIcos[_investor].length;
  }

  function isIcoAdded(address _ico) public view returns (bool){
    return getIcoIndex(_ico, false) > 0 ;
  }

  function isTokenAdded(address _token) public view returns (bool){
    return getIcoIndex(_token,true) > 0;
  }

  function isInvestor(uint256 _icoIndex, address _investor) public view returns (bool){
    assert(_icoIndex > 0);
    return (icos[_icoIndex].investors[msg.sender].active == true && icos[_icoIndex].investors[msg.sender].totalDeposit > 0);
  }



}
