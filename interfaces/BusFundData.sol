pragma solidity^0.4.18;

import './TimedOwnable.sol';

contract BusFundBank is TimedOwnable {

  uint256 feesBalance;
  address busData;
  bool resolved;
  event EtherTransfer(address indexed to,uint256 amount);
  event TokenTransfer(address token,address indexed to,uint256 amount);

  function getTokenBalance( address _token) public constant returns(uint256);

  function setResolved () public;

  function doTokenTransfer(address _token,  address _to,uint256 _value) internal;

  function doEtherTransfer(address _to,uint256 _value) internal;

  function sendTokens(address _token,  address _to,uint256 _value) public;

  function sendBatchTokens(address _token, address[20] _addresses, uint256[20] _values ) public;

  function sendEther(address _to,uint256 _value) public;

  function withdrawFees(address _destination) public;

  function cleanSweep(address _destination, address _token) public;

  function cleanSweep(address _destination) public;

  function fund(uint256 fees) public payable;

  function () public;
}
