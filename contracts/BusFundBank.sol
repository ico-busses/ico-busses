import './WithFullDevilUpgradeableInterface.sol';
import './SafeMath.sol';

pragma solidity^0.4.18;

contract BusFundBank is TimedOwnable,WithFullDevilUpgradeableInterface{
  using SafeMath for uint;

  uint256 feesBalance;

  event EtherTransfer(address to,uint256 amount);

  function BusFundBank(address _interface) UpgradeableInterface(_interface) public {

  }

  function getTokenBalance( address _token) public pure returns(uint256){
    return ERC20(_token).balanceOf(this);
  }

  function sendTokens(address _token,  address _to,uint256 _value) public onlyInterface isInterfaceSet {
    require( getTokenBalance(_token) >= _value );
    ERC20(_token).transfer(_to,_value);
  }

  function sendBatchTokens(address _token, address[20] _addresses, uint256[20] _values ) public onlyInterface isInterfaceSet {
    for(uint256  t=0; t<_addresses.length; t++){
      if(_addresses[t] != 0x0 && _values[t] > 0)
        sendTokens(_token,_addresses[t],_values[t]);
    }
  }

  function sendEther(address _to,uint256 _value) public onlyInterface isInterfaceSet {
    require(_to != 0x0);
    require(_value > 0);
    EtherTransfer(_to,_value);
    _to.transfer(_value);
  }

  function withdrawFees() public onlyInterface isInterfaceSet {
    require(this.balance >= feesBalance);
    uint256 toPay = feesBalance;
    feesBalance = 0;
    EtherTransfer(owner,toPay);
    owner.transfer(toPay);
  }

  function confirmSetInterface() payable public onlyOwner {
    super.confirmSetInterface();
    feesBalance.add(changeInterfaceCost);
  }

  function rejectSetInterface() payable public onlyOwner {
    super.rejectSetInterface();
    feesBalance.add(msg.value.sub(changeInterfaceCost) );
  }

  function (uint256 fees) public payable{
    require(msg.value >= fees);
    feesBalance.add(fees);
  }

  function () public payable{}
}
