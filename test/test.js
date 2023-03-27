const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");
  
  describe("Lab4", function () {
    beforeEach(async function () {
        // 部署 SafeUpgradeable 合約
        //safeImpl = await ethers.getContractFactory("SafeUpgradeable");
        //safeImpl = await safeImpl.deploy();
        //safeImpl = await safeImpl.init();
    
        // 取得 owner 和 user1 的帳號
        [owner, addr1] = await ethers.getSigners();
    
        // 部署 SafeFactory 合約
        const safeFactoryContract = await ethers.getContractFactory("SafeFactory");
        safeFactory = await safeFactoryContract.deploy();
        await safeFactory.deployed();
        //safeImpl = await safeFactoryContract.deploySafe();
    
        // 部署 SafeProxy 合約
        safeProxy = await safeFactory.deploySafe();
        //tx = await safeFactory.deploySafe();
        //console.log(tx);
        
        //const receipt = await tx.wait();
        //console.log(receipt);
        //safeProxy = receipt.events[0].address;
        //console.log(safeProxy)
    });
    describe("Deployment", function () {
        it('Implementation contract owner should be same as safeFactory owner', async function () {
            safeImpl = await ethers.getContractAt("SafeUpgradeable", safeFactory.getSafeImplementation())
            expect(await safeImpl.getOwner()).to.equal(owner.address);
        })
        /*
        it('the caller of deploySafeProxy is the owner of the deployed Proxy', async function () {
            //console.log(safeProxy)
            safeProxy1 = await ethers.getContractAt("UpgradableProxy", safeProxy)
            expect(await safeProxy1.proxyOwner()).to.equal(owner.address);
        })
        */

    });
    
    
  });
  