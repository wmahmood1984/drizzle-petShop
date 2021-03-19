const Adoption = artifacts.require("ERC721.sol");

module.exports = function (deployer) {
  deployer.deploy(Adoption);
};
