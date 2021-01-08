const Factory = artifacts.require('uniswapv2/UniswapV2Factory.sol');
const Router = artifacts.require('uniswapv2/UniswapV2Router02.sol');
const WETH = artifacts.require('WETH.sol');
const MockERC20 = artifacts.require('MockERC20.sol');

const LoadToken = artifacts.require('LoadToken.sol') 
const Minter = artifacts.require('Minter.sol'); 
const InvestorsVault = artifacts.require('InvestorsVault.sol');
const LoadTreasury = artifacts.require('LoadTreasury.sol');
const Timelock = artifacts.require('Timelock.sol');
const Migrator = artifacts.require('Migrator.sol');

module.exports = async function(deployer, _network, addresses) {
  const [admin, _] = addresses;

  await deployer.deploy(WETH);
  const weth = await WETH.deployed();
  const tokenA = await MockERC20.new('Token A', 'TKA', web3.utils.toWei('1000'));
  const tokenB = await MockERC20.new('Token B', 'TKB', web3.utils.toWei('1000'));

  await deployer.deploy(Factory, admin);
  const factory = await Factory.deployed();
  await factory.createPair(weth.address, tokenA.address);
  await factory.createPair(weth.address, tokenB.address);
  await deployer.deploy(Router, factory.address, weth.address);
  const router = await Router.deployed();

  await deployer.deploy(LoadToken);
  const loadToken = await LoadToken.deployed();

  await deployer.deploy(
    Minter,
    loadToken.address,
    admin,
    web3.utils.toWei('100'),
    1,
    1
  );
  const minter = await Minter.deployed();
  await loadToken.transferOwnership(minter.address);

  await deployer.deploy(InvestorsVault, loadToken.address);
  const investorsVault = await InvestorsVault.deployed();

  await deployer.deploy(
    LoadTreasury,
    factory.address, 
    investorsVault.address, 
    loadToken.address, 
    weth.address
  );
  const loadTreasury = await LoadTreasury.deployed();
  await factory.setFeeTo(loadTreasury.address, {from: addresses[0]});

  await deployer.deploy(
    Migrator,
    minter.address,
    '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f',
    factory.address,
    1
  );
};