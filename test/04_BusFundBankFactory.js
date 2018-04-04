var BusFundBankFactory = artifacts.require('./BusFundBankFactory.sol');// Import contract of StandarTOken type
var DummyToken = artifacts.require('./DummyToken.sol');// Import contract of StandarTOken type

contract('04_BusFundBankFactory:: ', function(accounts){

    var contract,newcontract,web3,Me,token;
    const _1ether = 1e+18;
    Me = accounts[0];
    coFounder = accounts[1];
    busInterface = accounts[2];
    console.log(accounts);

    var deployment_config = {
      _interface:busInterface
    },
    newBusFundBankFactory = function(){
      return BusFundBankFactory.new(
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
        newBusFundBankFactory()
        .then(function(inst){
            contract = inst.contract;
            web3 = inst.constructor.web3;

            console.log('New Factory:',contract.address );

            contract.owner(function(e,r){
              console.log('Owner:', r);
            });
            assert.notEqual(contract.address, null, 'Contract not successfully deployed');
            done();
        });
    });

  describe('initializeFactory() ',function(){
      it('Should fail to initializeFactory from Rogue account',function(done){
        contract.initializeFactory( busInterface, { from: accounts[5] }, function (e, r) {
          assert.notEqual(e, null,`Illegally initialized FundBankFactory`);
          done();
        });
      });

      it('Should successfully initializeFactory', function (done) {
        var _interface = contract.busInterface.call();
        assert.equal(Number(_interface), 0, `FundBankFactory already initialized`);

        contract.initializeFactory(busInterface, { from: Me }, function (e, r) {
          assert.equal(e, null, `Failed to initialize FundBankFactory`);
          var _interface = contract.busInterface.call();
          assert.equal(_interface, busInterface, `FundBankFactory initialized with ${_interface} instead of ${busInterface}`);
          done();
        });
      });

      it('Should fail to initializeFactory post-initialized',function(done){
        contract.initializeFactory( Me, { from: Me }, function (e, r) {
          assert.notEqual(e, null,`Illegally initialized FundBankFactory`);
          done();
        });
      });
    })

    describe('spawnFundBank() ',function(){
      var _busData = accounts[3];
      var _busName = 'Test Name';

      it('Should fail to spawnFundBank from Rogue account',function(done){
        contract.spawnFundBank( _busData, _busName, { from: accounts[5] }, function (e, r) {
          assert.notEqual(e, null,`Illegally initialized FundBankFactory`);
          done();
        });
      });

      it('Should fail to spawnFundBank with invalid info',function(done){
        contract.spawnFundBank( 0, _busName, { from: Me }, function (e, r) {
          assert.notEqual(e, null,`Illegally initialized FundBankFactory`);
          done();
        });
      });

      it.skip('Should successfully spawnFundBank',function(){
        contract.spawnFundBank( _busData, _busName, { from: Me }, function (e, r) {
          assert.equal(e,null, 'Failed to spawnFundBank');
          var _balance = contract.getTokenBalance.call(token.address);
        })
      });
    })
  });
