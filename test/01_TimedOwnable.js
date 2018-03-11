var TimedOwnable = artifacts.require('./TimedOwnable.sol');// Import contract of StandarTOken type

contract('01_TimedOwnable', function(accounts){

    var contract,newcontract,web3,Me;
    const _1ether = 1e+18;
    Me = accounts[0];
    newOwner = accounts[1];
    coFounder = accounts[2];

    var deployment_config = {
      _interface:0
    },
    newTimedOwnable = function(){
      return TimedOwnable.new(
          coFounder,
          //deployment_config._interface,
          {from:Me}
      );
    };

    function forceMine(time){
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [time], id: 123});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
    }

    it('should deploy the contract', function (done) {
        newTimedOwnable()
        .then(function(inst){
            contract = inst.contract;
            web3 = inst.constructor.web3;


            console.log('Address:',contract.address );
            contract.owner(function(e,r){
                console.log('Owner:', r);
              });
            contract.coFounder(function(e,r){
              assert.equal(r,coFounder,'Wrong coFOunder set at deployment');
              console.log('coFOunder:', r);
            });

            assert.notEqual(contract.address, null, 'Contract not successfully deployed');
            done();
        });
    });

    describe('Ownership Features::',function(){

      it('Should begin transfer Ownership process', function(done){
        contract.initiateTransferOwnership(newOwner,{from:Me},function(e,r){
         contract.newOwner.call(function(_e,_r){
          assert.equal(_r,newOwner,'Unable to begin transfer Ownership process');
          done();
          })
        })
      })

      it('Should fail to acceptOwnership before wait TIme elapsed', function(done){
        contract.acceptOwnership({from:newOwner},function(e,r){
          web3.eth.getBlock('latest',function(be,br){
            contract.transferOwnerInitiated.call(function(ie,ir){
              contract.transferOwnerWaitTime.call(function(we,wr){
                console.log('Time', br.timestamp);
                console.log('TransferInitiated',Number(ir) );
                console.log('WaitTime',Number(wr) );
                assert.equal( Number(ir.plus(wr)) > br.timestamp, true, 'Wait time already Exceeded');
                assert.notEqual(e, null, 'Accept Ownership completed before wait Time exceedded');
                done();
              })
            })
          })
        })
      })

      it('should fail to reject ownershipTransfer from rogue Account', function(done){
        contract.rejectTransferOwnership({from:newOwner},function(e,r){
            assert.notEqual(e,null,'Rogue Address successfully rejected ownership');
            done();
        })
      })

      it('should reject ownershipTransfer', function(done){
        contract.rejectTransferOwnership({from:Me},function(e,r){
            assert.notEqual(r,null,'Unable to reject Ownership transfer');
            done();
        })
      })


      it('should fail to accept ownershipTransfer from rogue Account', function(done){
        contract.initiateTransferOwnership(accounts[1],{from:Me},function(e,r){
          forceMine(1801);//Move time forward by 30 minutes
          contract.acceptOwnership({from:accounts[2]},function(e,r){
              assert.notEqual(e,null,`Rogue Address ( ${accounts[2]} ) successfully accepted ownership instead of ${accounts[1]}`);
              done();
          })
        });
      })

      it('Should acceptOwnership ', function(done){
        contract.acceptOwnership({from:accounts[1],gasLimit:3000000},function(e,r){
          assert.equal(e, null, 'Accept Ownership unable to be completed by receiving address');
          done();
        });
      })



      it('Should vetoTransferOwnership ', function(done){
        newTimedOwnable()
        .then(function(inst){
            const contract = inst.contract;
            contract.initiateTransferOwnership(accounts[1],{from:Me},function(e,r){
              var newOwner = contract.newOwner.call(function(_e,_r){
              assert.equal(_r,accounts[1],'Unable to begin transfer Ownership process');

                contract.vetoTransferOwnership({from:coFounder},function(e,r){
                  assert.equal(e, null, 'Ownership not successfully vetoed by coFounder');
                  done();
                });
              })
            })
          })
      })


    })
  });
