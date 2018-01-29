var WithDevilUpgradeableInterface = artifacts.require('./WithFullDevilUpgradeableInterface.sol');// Import contract of StandarTOken type

contract('02_WithDevilUpgradeableInterface', function(accounts){

    var contract,newcontract,web3,Me;
    const _1ether = 1e+18;
    Me = accounts[0];
    coFounder = accounts[2];
    newInterface = accounts[3];

    var deployment_config = {
      _interface:0
    },
    newWithDevilUpgradeableInterface = function(){
      return WithDevilUpgradeableInterface.new(
          deployment_config._interface,
          {from:Me}
      );
    };

    function forceMine(time){
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [time], id: 123});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
    }

    it('should deploy the contract', function (done) {
        newWithDevilUpgradeableInterface()
        .then(function(inst){
            contract = inst.contract;
            web3 = inst.constructor.web3;

            console.log('Address:',contract.address );

            contract.owner(function(e,r){
              console.log('Owner:', r);
            });
            contract.interfaceAddress(function(e,r){
              console.log('interfaceAddress:', r);
            });

            assert.notEqual(contract.address, null, 'Contract not successfully deployed');
            done();
        });
    });
    describe('Interface control::',function(){

        it('Should fail to begin setInterface from Rogue Account',function(done){
            let _value;
            contract.changeInterfaceCost.call(function(e,r){
              assert.equal(e,null,'Unable to fetch interface Cost');
              _value = r;

              contract.setInterface(newInterface,{from:accounts[1],value:_value},function(e,r){
                assert.notEqual(e,null,'Initiated setInterface from Rogue Address');
                done();
              });
            })
        });

        it('Should fail to begin setInterface process with wrong interfaceCost',function(done){
          const _value = 0;
          contract.setInterface(newInterface,{from:Me,value:_value},function(e,r){
            assert.notEqual(e,null,'Initiated setInterface with wrong Interface Cost');
            done();
          });
        });

        it('Should begin setInterface process',function(done){
          let _value;
          contract.changeInterfaceCost.call(function(e,r){
            assert.equal(e,null,'Unable to fetch interface Cost');
            _value = r;

            contract.setInterface(newInterface,{from:Me,value:_value},function(e,r){
              assert.equal(e,null,'unable to initiate setInterface process');
              done();
            });
          })
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

  });
