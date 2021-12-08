const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    local: {
      host: 'localhost',
      port: 7545,
      gas: 5000000,
      gasPrice: 5e9,
      network_id: '*',
    },
    ropsten: {
      provider: function() {
        if (!process.env.KYCDAO_ROPSTEN_PK) {
          console.error('KYCDAO_ROPSTEN_PK env variable is needed');
          process.abort();
        }
        return new HDWalletProvider(
          process.env.KYCDAO_ROPSTEN_PK,
          'https://ropsten.infura.io/v3/cf7a7eed37254ec4b95670607e76a917'
        );
      },
      gas: 5000000,
      gasPrice: 5e9,
      network_id: 3,
    },
    kovan: {
      provider: function() {
        if (!process.env.KYCDAO_KOVAN_PK) {
          console.error('KYCDAO_KOVAN_PK env variable is needed');
          process.abort();
        }
        return new HDWalletProvider(
          process.env.KYCDAO_ROPSTEN_PK,
          'https://kovan.infura.io/v3/cf7a7eed37254ec4b95670607e76a917'
        );
      },
      gas: 5000000,
      gasPrice: 5e9,
      network_id: 3,
    },
    sokol: {
      provider: function() {
        if (!process.env.KYCDAO_SOKOL_PK) {
          console.error('KYCDAO_SOKOL_PK env variable is needed');
          process.abort();
        }
        return new HDWalletProvider(
          process.env.KYCDAO_SOKOL_PK,
          "https://sokol.poa.network"
        );
      },
      gas: 5000000,
      gasPrice: 5e9,
      network_id: 77,
    },
    xdai: {
      provider: function() {
        if (!process.env.KYCDAO_XDAI_PK) {
          console.error('KYCDAO_XDAI_PK env variable is needed');
          process.abort();
        }
        return new HDWalletProvider(
          process.env.KYCDAO_XDAI_PK,
          "https://dai.poa.network"
        );
      },
      gas: 5000000,
      gasPrice: 5e9,
      network_id: 100,
    },
    mainnet: {
      provider: function() {
        if (!process.env.KYCDAO_MAIN_PK) {
          console.error('KYCDAO_MAIN_PK env variable is needed');
          process.abort();
        }
        return new HDWalletProvider(
          process.env.KYCDAO_MAIN_PK,
          'https://mainnet.infura.io/v3/cf7a7eed37254ec4b95670607e76a917'
        );
      },
      gas: 5000000,
      gasPrice: 5e9, // 5 gwei (check https://ethgasstation.info/)
      network_id: 1,
    },
    binancetestnet: {
      provider: function() {
        if (!process.env.KYCDAO_BINANCE_TEST_PK) {
          console.error('KYCDAO_BINANCE_TEST_PK env variable is needed');
          process.abort();
        }
        return new HDWalletProvider(
          process.env.KYCDAO_BINANCE_TEST_PK,
          'https://data-seed-prebsc-1-s1.binance.org:8545'
        );
      },
      gas: 5000000,
      gasPrice: 5e9,
      network_id: 97,
    },
  },
};
