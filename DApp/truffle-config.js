module.exports = {
  networks: {
    ganacheK8s: {
      host: "ganache.default.svc.cluster.local",
      port: 8545,
      network_id: "*"
    }
  },
  compilers: {
    solc: {
      version: "0.8.20"
    }
  }
};
