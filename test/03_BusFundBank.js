var BusFundBank = artifacts.require('./BusFundBank.sol');// Import contract of StandarTOken type
var DummyToken = artifacts.require('./DummyToken.sol');// Import contract of StandarTOken type

contract('03_BusFundBank', function(accounts){

    var contract,newcontract,web3,Me,token;
    const _1ether = 1e+18;
    Me = accounts[0];
    coFounder = accounts[1];
    busData = accounts[2];
    console.log(accounts);

    var deployment_config = {
      _interface:busData
    },
    newBusFundBank = function(){
      return BusFundBank.new(
          deployment_config._interface,
          {from:Me}
      );
    };

    newToken = function(){
      return DummyToken.new(
          'Dummy',
          'DMY',
          {from:Me}
      );
    };

    function forceMine(time){
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [time], id: 123});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
    }

    it('should deploy the contract', function (done) {
        newBusFundBank()
        .then(function(inst){
            contract = inst.contract;
            web3 = inst.constructor.web3;

            console.log('Address:',contract.address );

            contract.owner(function(e,r){
              console.log('Owner:', r);
            });
            contract.busData(function(e,r){
              console.log('Bus Data:', r);
            });

            assert.notEqual(contract.address, null, 'Contract not successfully deployed');
            done();
        });
    });
    describe('EtherTransfer',function(){

        it('Should fail to send funds to the FundBank fallback',function(done){
            var _value = web3.toWei(1, 'ether');
            web3.eth.sendTransaction({from:Me,to:contract.address,value:_value},function(e,r){
              assert.notEqual(e,null,`Illegally sent ${_value/1e+18} Eth to FundBank`);
                done();
            });
        });

        it('Should successfully send funds to the FundBank',function(done){
            var _value = web3.toWei(1, 'ether');
            var balance = web3.eth.getBalance(contract.address);
            contract.fund(0,{from:Me,value:_value},function(e,r){
              assert.equal(e,null,`Unable to send ${_value/1e+18} Eth to FundBank`);
              var newBalance = web3.eth.getBalance(contract.address);
              var balanceChange = newBalance.minus(balance);
                assert.equal(Number(_value),Number(balanceChange) ,`${Number(balanceChange)} funded instead of ${Number(_value)}`);
                done();
            });
        });

        it('Rogue account should fail to send funds from FundBank',function(done){
          var _value = web3.toWei(0.5,'ether');
          contract.sendEther(Me, _value, {from:Me},function(e,r){
            assert.notEqual(e,null,'Funds sent from FundBank from Rogue address');
            done();
          });
        });

        it('Interface should successfully send funds from FundBank',function(done){
          var _value = web3.toWei(0.5, 'ether');
          var _balance = web3.eth.getBalance(Me);
          contract.sendEther(Me, _value, {from:busData},function(e,r){
            assert.equal(e,null,'Unable to send funds from FundBank');

            var _newbalance = web3.eth.getBalance(Me);
            var _diff = _newbalance.minus(_balance);
            assert.equal( _diff.eq(_value),true,`Sent ${_newbalance.minus(_balance).toString()} instead of ${_value.toString()}`);
            done();
          });
        });
    })

    describe('TokenTransfer',function(){
        it("Should create dummy token", function (done){
          newToken()
          .then(function(inst){
              token = inst.contract;
              web3 = inst.constructor.web3;

              console.log('Token Address:',token.address );

              console.log('Owner:', token.owner.call());

              assert.notEqual(token.address, null, 'Contract not successfully deployed');
              done();
          });
        })
        it('Should access FundBank token balance',function(){
          var _value = web3.toWei(1,'ether');
          var _balance = contract.getTokenBalance.call(token.address);
          assert.notEqual(_balance,null, 'Unable to fetch FundBank\'s balance');

          token.mint( contract.address, _value, {from:Me}, function(e,r) {
            assert.equal(e,null, 'Unable to mint new tokens to contract');
            var _newbalance = contract.getTokenBalance.call(token.address);
            var _diff = _newbalance.minus(_balance);
            assert.equal(_diff.toNumber(),_value, `${_diff.toNumber()} was minted instead of ${_value}`);
          })
        })

        it('Rogue Address Should fail to send tokens from FundBank',function(done){
          var _balance = contract.getTokenBalance.call(token.address);
          assert.notEqual(_balance,null, 'Unable to fetch FundBank\'s token balance');
          var _toSend = _balance.dividedBy(5);

          contract.sendTokens( token.address, accounts[4], _toSend, {from:accounts[3]}, function(e,r) {
            assert.notEqual(e,null, 'Sent tokens fron FundBank without permission');
            done();
          })
        })

        it('Interface Should send tokens from FundBank',function(done){
          var _balance = token.balanceOf.call(accounts[4]);
          var _busbalance = contract.getTokenBalance.call(token.address);
          assert.notEqual(_balance,null, 'Unable to account balance');
          assert.notEqual(_busbalance,null, 'Unable to fetch FundBank\'s token balance');
          var _toSend = _busbalance.dividedBy(5);

          contract.sendTokens( token.address, accounts[4], _toSend, {from:busData}, function(e,r) {
            assert.equal(e,null, 'Interface failed to send tokens from FundBank');
            var _newbalance = token.balanceOf.call(accounts[4]);
            assert.equal(_newbalance.minus(_balance).toNumber(),_toSend.toNumber(), `${_newbalance.minus(_balance).toNumber()} tokens sent instead of ${_toSend.toNumber()}`);
            done();
          })
        })

        it('Rogue Address Should fail to send batch tokens from FundBank',function(done){
          var _balance = contract.getTokenBalance.call(token.address);
          assert.notEqual(_balance,null, 'Unable to fetch FundBank\'s token balance');
          var _toSend = _balance.dividedBy(5);
          var addressList = [accounts[2],accounts[3],accounts[5]];
          var _balances = [];
          addressList.map( function(address,index){
            _balances[index] = token.balanceOf.call(address);
          })
          var _toSends = addressList.map(function(){
            return _toSend;
          })

          contract.sendBatchTokens( token.address, addressList, _toSends, {from:accounts[3]}, function(e,r) {
            assert.notEqual(e,null, 'Sent tokens fron FundBank without permission');
            done();
          })
        });

        it('Interface Should successfully send batch tokens from FundBank',function(done){
          var _balance = contract.getTokenBalance.call(token.address);
          assert.notEqual(_balance,null, 'Unable to fetch FundBank\'s token balance');
          var _toSend = _balance.dividedBy(5);
          var addressList = [accounts[2],accounts[3],accounts[5]];
          var _balances = [];
          addressList.map( function(address,index){
            _balances[index] = token.balanceOf.call(address);
          })
          var _toSends = addressList.map(function(){
            return _toSend;
          })

          contract.sendBatchTokens( token.address, [20], [20], {from:busData}, function(e,r) {
            assert.equal(e,null, 'Interface failed to send tokens from FundBank');
            addressList.map( function(address,index){
              _newbalance = token.balanceOf.call(address);
              assert(_newbalance.minus(_balances[index]), _toSends[index], `${_newbalance.minus(_balances[index])} tokens sent instead of ${_toSends[index]}`);
            })
            done();
          })
        })
    })

    describe('Fees handling',function(){

        it('Should successfully check fees balance in FundBank',function(){
          var feesBalance = contract.feesBalance.call();
          assert.notEqual(feesBalance,null,'Fees balance could not be successfully fetched.');
        })

        it('Should fail to withdraw fees balance by non-owner',function(done){
          var accountBalance = web3.eth.getBalance(accounts[5]);
          var balancetoSend = accountBalance.div(10);
          assert.equal(balancetoSend.gt(0),true,'Fee to be paid is not grater than 0');

          contract.fund( balancetoSend, {from:accounts[5], value: balancetoSend}, function(e,r) {
            assert.equal(e,null,'FundBank not successfully funded with fees');
            var feesBalance = contract.feesBalance.call();
            contract.withdrawFees( accounts[5], {from:coFounder}, function(e,r) {
              assert.notEqual(e,null,'Non-owner successfully withdrew Fees');
              done();
            });
          });
        })

        it('Should successfully withdraw fees balance from the contract',function(done){
          var feesBalance = contract.feesBalance.call();
          var accountBalance = web3.eth.getBalance(coFounder);
          contract.withdrawFees( coFounder, {from:Me}, function(e,r) {
            assert.equal(e,null,'Error withdrawing Fees from the contract');

            var newbalance = web3.eth.getBalance(coFounder);
            assert.equal(accountBalance.add(feesBalance).toNumber(), newbalance.toNumber(), `${newbalance.sub(accountBalance).toNumber()} sent instead of ${feesBalance.toNumber()}`)
            done();
          })
        });
    })

    describe('Resolve and Clean Sweep', function() {
      it('Should fail to resolve FundBank from Rogue Address', function(done) {
        var resolved = contract.resolved.call();
        assert.equal(resolved,false,'FundBank previously resolved');
        contract.setResolved( {from:Me}, function(e,r) {
          assert.notEqual(e,null,'Rogue acccount successfully resolved contract');
          done();
        });
      })

      it('Should successfully resolve FundBank', function(done) {
        var resolved = contract.resolved.call();
        assert.equal(resolved,false,'FundBank previously resolved');
        contract.setResolved( {from:busData}, function(e,r) {
          assert.equal(e,null,'FundBank not successfully resolved');
          var resolved = contract.resolved.call();
          assert.equal(resolved,true,'FundBank not successfully resolved');
          done();
        });
      })

      it('Should fail to cleanSweep from Rogue Account',function(done){
        contract.cleanSweep['address']( coFounder, {from:accounts[6]}, function(e,r) {
          assert.notEqual(e,null,'Rogue Account successfully cleanSweep-ed');
          done();
        })
      });

      it('Should successfully cleanSweep FundBank ',function(done){
        var accountBalance = web3.eth.getBalance(Me);
        var fundBankBalance = web3.eth.getBalance(contract.address);
        contract.cleanSweep['address']( Me, {from:busData}, function(e,r) {
          assert.equal(e,null,'Failed to successfully cleanSweep');

          var newaccountBalance = web3.eth.getBalance(Me);
          assert.equal(accountBalance.add(fundBankBalance).toNumber(),newaccountBalance.toNumber(), `Sent ${newaccountBalance.sub(accountBalance).toNumber()} from FundBank instead of ${fundBankBalance.toNumber()}`);
          done();
        })
      });

      it('Should fail to cleanSweep FundBank tokens from Rogue Account',function(done){
        contract.cleanSweep['address,address']( Me, token.address, {from:coFounder}, function(e,r) {
          assert.notEqual(e,null,'Failed to successfully cleanSweep');
          done();
        })
      });

      it('Should successfully cleanSweep FundBank tokens',function(done){
        var _fundBankbalance = contract.getTokenBalance.call(token.address);
        var _myBalance = token.balanceOf.call(Me);
        assert.equal(_fundBankbalance.toNumber() > 0, true, 'Contract\'s Token balance is equal to or less than 0')
        contract.cleanSweep['address,address']( Me, token.address, {from:Me}, function(e,r) {
          assert.equal(e,null,'Failed to successfully cleanSweep');

          var _myNewBalance = token.balanceOf.call(Me);
          assert.equal(_myBalance.add(_fundBankbalance).toNumber(),_myNewBalance.toNumber(), `Sent ${_myNewBalance.sub(_myBalance).toNumber()} from FundBank instead of ${_fundBankbalance.toNumber()}`);
          done();
        })
      });
    })

  });
