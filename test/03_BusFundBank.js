var BusFundBank = artifacts.require('./BusFundBank.sol');// Import contract of StandarTOken type

contract('03_BusFundBank', function(accounts){

    var contract,newcontract,web3,Me;
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

        it('Should fail to send funds to the FundBank',function(done){
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
            assert.notEqual(e,null,'Funds sent from FUndBank from Rogue address');
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

        it.skip('Should send right amount to the contract from lender',function(done){
          var _lender = contract.lender.call(),
          _value = contract.getLoanValue.call(true),
          _mybal = web3.eth.getBalance(Me),
          txn = {from:_lender,to:contract.address,value: _value, gas: 210000 };

          web3.eth.sendTransaction(txn,function(e,r){
            var balance = contract.balanceOf.call(_lender),
            totalSupply = contract.actualTotalSupply.call();
            _mynewbal = web3.eth.getBalance(Me);
            assert.equal(e,null,'Loan not successfully funded by lender');
            assert.equal(Number(balance),Number(totalSupply),'Wrong number of tokens assigned to lender');
            assert.equal(Number(_mynewbal),Number(_mybal)+ deployment_config._initialAmount,'Wrong value of Ether sent to Owner');
            done();
          });
        });
    })

    describe.skip('Interest Accruing ',function(){
        it('Should fetch isInterestStatusUpdated status',function(){
            var isInterestStatusUpdated = contract.isInterestStatusUpdated.call();

            assert.notEqual(isInterestStatusUpdated,null, 'Did not successfully fetch isInterestStatusUpdated value, instead "'+isInterestStatusUpdated+'"');
        })

        it('Should run updateInterest function from any address',function(done){

          function doUpdate(){
            contract.updateInterest({from:accounts[3]},function(e,r){
              assert.equal(e,null,'Random address could not run updateInterest functon');
              done()
            });
          }

          //Update EVM time to required time
          var time = deployment_config._loanTerm*deployment_config._dayLength*1000;
          forceMine(time);

          assert.equal(contract.isTermOver.call(),true,'Loan tern has not over ( '+web3.eth.getBlock('latest').timestamp+' )');
          doUpdate();
        })

        it('Should not allow race condition on updateInterest function',function(done){
          //Update EVM time to required time
          var alldone=0,
          time = deployment_config._loanCycle*2*deployment_config._dayLength*1000;
          forceMine(time);

          var actualTotalSupply = contract.actualTotalSupply.call();

          contract.updateInterest({from:accounts[3]},function(e,r){
            var totalSupply = contract.totalSupply.call();
            assert.equal(Number(totalSupply) == Number(actualTotalSupply),true,'Leakage allowed mutiple runs of updateInterest: '+Number(totalSupply)+' !== '+Number(actualTotalSupply) );
            alldone++;
            checkDone();
          })

          contract.updateInterest({from:accounts[3]},function(e,r){
            var totalSupply = contract.totalSupply.call();
            assert.equal(Number(totalSupply) == Number(actualTotalSupply),true,'Leakage allowed mutiple runs of updateInterest: '+Number(totalSupply)+' !== '+Number(actualTotalSupply) );
            alldone++;
            checkDone();
          })

          function checkDone(){
            if(alldone>1)
              done();
          }

        })

        it('Should fail to allow owner run finishMinting function',function(done){
          assert.isNotOk(contract.finishMinting, "finishMiting shall be available internally only");
          done();
        })

    })

    describe.skip('Loan Refund',function(){
        it('Should fail to refund amount diffferent from total due',function(done){
            var _value = contract.getLoanValue.call(true);//fetch the initial loan value
            web3.eth.sendTransaction({from:Me,to:contract.address,value:_value},function(e,r){
              assert.notEqual(e,null,'Owner refunded Loan with wrong (initial without interest) amount');
              done();
            });
        })

        it('Should fail to refund correct amount from non-owner',function(done){
          var _value = contract.getLoanValue.call(false);//fetch the initial loan value
          web3.eth.sendTransaction({from:accounts[3],to:contract.address,value:_value},function(e,r){
            assert.notEqual(e,null,'Non-Owner successfully refunded Loan');
            done();
          });
        })

        it('Should successfully refund correct amount',function(done){
          var _value = contract.getLoanValue.call(false),//fetch the initial loan value
          _lender = contract.lender.call(),
          _lenderBalance = web3.eth.getBalance(_lender);

          web3.eth.sendTransaction({from:Me,to:contract.address,value:_value},function(e,r){
            var balance = contract.balanceOf.call(Me),
            totalSupply = contract.actualTotalSupply.call();
            _debtownernewbal = web3.eth.getBalance(_lender);
            assert.equal(e,null,'Loan not successfully refunded by Owner');
            assert.equal(Number(balance),Number(totalSupply),'Wrong number of tokens refunded to Owner');
            assert.equal(Number(_debtownernewbal),Number(_lenderBalance)+ Number(_value),'Wrong value of Ether sent to lender');
            done();
          });
        })

        it('Should successfully refund before contract maturation',function(done){
          deployNewDebtContract()
          .then(function(inst){
              newcontract = inst.contract;
              assert.notEqual(contract.address, null, 'Contract not successfully deployed');

              var _lender = newcontract.lender.call(),
              _value = newcontract.getLoanValue.call(true),
              _mybal = web3.eth.getBalance(Me),
              txn = {from:_lender,to:newcontract.address,value: _value, gas: 210000 };

              web3.eth.sendTransaction(txn,function(e,r){

                var _lender = newcontract.lender.call(),
                balance = newcontract.balanceOf.call(_lender),
                totalSupply = newcontract.actualTotalSupply.call();
                _mynewbal = web3.eth.getBalance(Me);

                assert.equal(e,null,'Loan not successfully funded by lender');
                assert.equal(Number(balance),Number(totalSupply),'Wrong number of tokens assigned to lender');
                assert.equal(Number(_mynewbal),Number(_mybal)+ deployment_config._initialAmount,'Wrong value of Ether sent to Owner');

                      var _value = newcontract.getLoanValue.call(false),//fetch the initial loan value
                      _lender = newcontract.lender.call(),
                      _lenderBalance = web3.eth.getBalance(_lender);
                      console.log('Loan term over:', newcontract.isTermOver.call() );

                      web3.eth.sendTransaction({from:Me,to:newcontract.address,value:_value},function(e,r){

                        var balance = newcontract.balanceOf.call(Me),
                        totalSupply = newcontract.actualTotalSupply.call();
                        _debtownernewbal = web3.eth.getBalance(_lender);
                        assert.equal(e,null,'Loan not successfully refunded by Owner');
                        assert.equal(Number(balance),Number(totalSupply),'Wrong number of tokens refunded to Owner');
                        assert.equal(Number(_debtownernewbal),Number(_lenderBalance)+ Number(_value),'Wrong value of Ether sent to lender');
                        done();
                      });
              });
          });
        });

        it('Should confirm loanValue does not increase after refundLoan',function(done){
          var time = deployment_config._loanCycle*2*deployment_config._dayLength*1000;
          forceMine(time);

          totalSupply = contract.totalSupply.call(),
          actualTotalSupply = contract.actualTotalSupply.call();

          newtotalSupply = newcontract.totalSupply.call(),
          newactualTotalSupply = newcontract.actualTotalSupply.call();

          assert.equal( Number(totalSupply), Number(actualTotalSupply), 'Loan increased from '+totalSupply+' to '+actualTotalSupply+' after loan was repaid');
          assert.equal( Number(newtotalSupply), Number(newactualTotalSupply), 'New Loan increased from '+newtotalSupply+' to '+newactualTotalSupply+' after loan was repaid');
          done();
        })

    })

  });
