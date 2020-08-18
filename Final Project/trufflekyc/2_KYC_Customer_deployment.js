const Migrations = artifacts.require("KYC_Customer");

module.exports = function(deployer) {
  deployer.deploy(KYC_Customer);
};
