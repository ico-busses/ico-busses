pragma solidity^0.4.18;

import '../libraries/SafeMath.sol';
import '../base_contracts/TimedOwnable.sol';
import {ForeignToken as FERC20} from '../interfaces/ForeignToken.sol';

contract BusFundBank is TimedOwnable {
  using SafeMath for uint;

  uint256 feesBalance;
  address busData;
  bool resolved;
  event EtherTransfer(address indexed to,uint256 amount);
  event TokenTransfer(address token,address indexed to,uint256 amount);

  function BusFundBank(address _interface) TimedOwnable(0x1) public {
    busData = _interface;
  }

  function getTokenBalance( address _token) public constant returns(uint256){
    return FERC20(_token).balanceOf(this);
  }

  function setResolved () public onlyInterface {
    resolved = true;
  }

  function doTokenTransfer(address _token,  address _to,uint256 _value) internal {
    TokenTransfer(_token,_to,_value);
    FERC20(_token).transfer(_to,_value);
  }

  function doEtherTransfer(address _to,uint256 _value) internal {
    EtherTransfer(_to,_value);
    _to.transfer(_value);
  }

  function sendTokens(address _token,  address _to,uint256 _value) public onlyInterface {
    require( getTokenBalance(_token) >= _value );
    doTokenTransfer(_token,_to,_value);
  }

  function sendBatchTokens(address _token, address[20] _addresses, uint256[20] _values ) public onlyInterface {
    for(uint256  t=0; t<_addresses.length; t++){
      if(_addresses[t] != 0x0 && _values[t] > 0)
        sendTokens(_token,_addresses[t],_values[t]);
    }
  }

  function sendEther(address _to,uint256 _value) public onlyInterface {
    require(_to != 0x0);
    require(_value > 0);
    doEtherTransfer(_to,_value);
  }

  function withdrawFees(address _destination) public onlyOwner {
    require(this.balance >= feesBalance);
    uint256 toPay = feesBalance;
    feesBalance = 0;
    doEtherTransfer(_destination,toPay);
  }

  function cleanSweep(address _destination, address _token) public canSweep onlyResolved {
    uint toPay = getTokenBalance(_token);
    require(toPay >= 0);
    doTokenTransfer(_token,_destination,toPay);
  }

  function cleanSweep(address _destination) public canSweep onlyResolved{
    require(this.balance >= 0);
    doEtherTransfer(_destination,this.balance);
  }

  function fund(uint256 fees) public payable{
    require(msg.value >= fees);
    feesBalance.add(fees);
  }

  function () public {}

  modifier canSweep {
    require (busData == msg.sender || owner == msg.sender);
    _;
  }

  modifier onlyResolved {
    require (resolved == true);
    _;
  }

  modifier onlyInterface {
    require (busData == msg.sender);
    _;
  }
}
