var WithFullDevilUpgradeableInterface = artifacts.require('./WithFullDevilUpgradeableInterface.sol');// Import contract of StandarTOken type

contract('02_WithFullDevilUpgradeableInterface', function(accounts){

    var contract,newcontract,web3,Me;
    const _1ether = 1e+18;
    Me = accounts[0];
    coFounder = accounts[2];
    newInterface = accounts[3];

    var deployment_config = {
      _interface:0
    },
    newWithFullDevilUpgradeableInterface = function(){
      return WithFullDevilUpgradeableInterface.new(
          coFounder,
          deployment_config._interface,
          {from:Me}
      );
    };

    function forceMine(time){
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [time], id: 123});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
    }

    function snapShot () {
      snapshot = web3.currentProvider.send({jsonrpc: "2.0", method: "evm_snapshot", params: [], id: 123}).result;
    }

    after (function() {
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_revert", params: [snapshot]})
    })

    it('should deploy the contract', function (done) {
        newWithFullDevilUpgradeableInterface()
        .then(function(inst){
            contract = inst.contract;
            web3 = inst.constructor.web3;
            snapShot();

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

        it('Should fail to confirmInterface process',function(done){
          let _value;
          contract.changeInterfaceCost.call(function(e,r){
            assert.equal(e,null,'Unable to fetch interface Cost');
            _value = r;

            contract.confirmSetInterface({from:newInterface,value:_value},function(e,r){
              assert.notEqual(e,null,'seInterface confirmed before confirmation wait time exhausted');
              done();
            });
          })
        });

        it('Should rejectSetInterface',function(done){
          let _value;
          contract.rejectInterfaceCost.call(function(e,r){
            assert.equal(e,null,'Unable to fetch rejectInterfaceCost');
            _value = r;

            contract.rejectSetInterface({from:Me,value:_value },function(e,r){
              assert.equal(e,null,`unable to rejectInterface by ${Me} with rejectCost ${Number(_value)}`);
              done();
            });
          })
        });

        it('Should complete ugradeInterface process',function(done){
          let _value;
          contract.changeInterfaceCost.call(function(e,r){
            assert.equal(e,null,'Unable to fetch interface Cost');
            _value = r;

            contract.setInterface(newInterface,{from:Me,value:_value},function(e,r){
              assert.equal(e,null,'unable to initiate setInterface process');

              forceMine(1801);//Move time forward by 30 minutes
              contract.confirmSetInterface({from:newInterface,value:_value},function(e,r){
                assert.notEqual(e,null,'seInterface not confirmed by newInterface after waitTime exhausted');
                done();
              });
            });
          })
        });
    })

  });
