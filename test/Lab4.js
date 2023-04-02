const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");
const { ethers } = require("hardhat");
  
describe("Lab4", function () {
    beforeEach(async function () {
        // 取得 owner 和 user1 的帳號
        [owner, addr1, addr2] = await ethers.getSigners();

        // 部署 implementation contract
        const safeUpgradeableContract = await ethers.getContractFactory("SafeUpgradeable");
        safeUpgradeable = await safeUpgradeableContract.deploy();
        await safeUpgradeable.deployed();

        // 部署 SafeFactory 合約
        const safeFactoryContract = await ethers.getContractFactory("SafeFactory");
        safeFactory = await safeFactoryContract.deploy();
        await safeFactory.deployed();

        // 更新 factory 的 implementation contract
        await safeFactory.updateSafeImplementation(safeUpgradeable.address);

        // 部署 SafeProxy 合約
        tx = await safeFactory.deploySafeProxy();
        const receipt = await tx.wait();
        const events = receipt.events.filter(
            (event) => event.event === "SafeProxy"
        );
        safeProxyContract = events[0].args.ProxyPosition;
        UpgradableProxyContract = await ethers.getContractFactory("UpgradableProxy");
        upgradableProxy = UpgradableProxyContract.attach(safeProxyContract);
        
        // 透過 SafeProxy 去連接 SafeContract 的 function
        ProxySafe = await ethers.getContractAt("SafeUpgradeable", safeProxyContract);
        
        // 部署 dieToken 並且分別轉入 addr1 和 addr2
        Token = await hre.ethers.getContractFactory("DIEToken", addr1);
        dieToken = await Token.deploy(ethers.utils.parseEther('100000'));
        await dieToken.deployed();
        dieToken.connect(addr1).transfer(addr2.address, ethers.utils.parseEther('10000'))
        
        // 分別讓 addr1 和 addr2 去 approve ProxySafe 存取資產
        await dieToken.connect(addr1).approve(ProxySafe.address, ethers.utils.parseEther('50000'));
        await dieToken.connect(addr2).approve(ProxySafe.address, ethers.utils.parseEther('10000'));
        
    });
    describe("Deployment", function () {
        it('the caller of deploySafe should be the owner of the deployed Safe contract', async function () {
            //deploy origin safe contract
            //Get event from deploySafe to get addresss of Safe Contract address
            tx = await safeFactory.deploySafe();
            const receipt = await tx.wait();
            const events = receipt.events.filter(
                (event) => event.event === "DeploySafe"
            );
            const safeContract = events[0].args.SafePosition;
            safe = await ethers.getContractAt("Safe", safeContract);
            expect(await safe.getOwner()).to.equal(await safeFactory.factoryOwner());
        })
        it('the caller of deploySafeProxy should be the owner of the deployed Proxy', async function () {
            expect(await upgradableProxy.proxyOwner()).to.equal(await safeFactory.factoryOwner());;
        })
        it('Implementation owner should be same as safeProxy owner', async function () {
            expect(await ProxySafe.getOwner()).to.equal(await upgradableProxy.proxyOwner());
        })
    });
    describe("tax fee", function () {
        it('should deposite DieToken and check balance reduced by fee', async function () {
            await ProxySafe.connect(addr1).deposit(ethers.utils.parseEther('50000'), dieToken.address);
            await ProxySafe.connect(addr2).deposit(ethers.utils.parseEther('10000'), dieToken.address);
            expect(await ProxySafe.connect(addr1).balanceOf(dieToken.address)).to.equal(ethers.utils.parseEther('49950'));
            expect(await ProxySafe.connect(addr2).balanceOf(dieToken.address)).to.equal(ethers.utils.parseEther('9990'));
        })
        
        it('Should Withdraw DIEToken reduced by tax fee', async function () {
            await ProxySafe.connect(addr1).deposit(ethers.utils.parseEther('50000'), dieToken.address);
            await ProxySafe.connect(addr2).deposit(ethers.utils.parseEther('10000'), dieToken.address);
            await ProxySafe.connect(addr1).withdraw(ethers.utils.parseEther('49950'), dieToken.address);
            await ProxySafe.connect(addr2).withdraw(ethers.utils.parseEther('9990'), dieToken.address);
            expect(await ProxySafe.connect(addr1).balanceOf(dieToken.address)).to.equal(0);
            expect(await ProxySafe.connect(addr2).balanceOf(dieToken.address)).to.equal(0);
        })
        it('Should only owner can call takeFee', async function () {
            await ProxySafe.connect(addr1).deposit(ethers.utils.parseEther('50000'), dieToken.address);
            await ProxySafe.connect(addr2).deposit(ethers.utils.parseEther('10000'), dieToken.address);
            await ProxySafe.connect(owner).takeFee(dieToken.address);
            expect(await dieToken.balanceOf(owner.address)).to.equal(ethers.utils.parseEther('60'));
        })
        it("should not allow non-owners to call takeFee", async function () {
            await ProxySafe.connect(addr1).deposit(ethers.utils.parseEther('50000'), dieToken.address);
            await ProxySafe.connect(addr2).deposit(ethers.utils.parseEther('10000'), dieToken.address);
            await expect(ProxySafe.connect(addr1).takeFee(dieToken.address)).to.be.revertedWith("only owner can call this function");
        });
    });


});
  