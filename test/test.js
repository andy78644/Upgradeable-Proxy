const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");
  
  describe("Lab4", function () {
    beforeEach(async function () {
        // 取得 owner 和 user1 的帳號
        [owner, addr1, addr2] = await ethers.getSigners();
    
        // 部署 SafeFactory 合約
        const safeFactoryContract = await ethers.getContractFactory("SafeFactory");
        safeFactory = await safeFactoryContract.deploy();
        await safeFactory.deployed();
    
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
        dieToken = await Token.deploy(100000);
        await dieToken.deployed();
        dieToken.connect(addr1).transfer(addr2.address, 10000)
        
        // 分別讓 addr1 和 addr2 去 approve ProxySafe 存取資產
        await dieToken.connect(addr1).approve(ProxySafe.address, 50000);
        await dieToken.connect(addr2).approve(ProxySafe.address, 10000);
    });
    describe("Deployment", function () {
        it('Implementation contract owner should be same as safeFactory owner', async function () {
            safeImpl = await ethers.getContractAt("SafeUpgradeable", safeFactory.getSafeImplementation())
            expect(await safeImpl.getOwner()).to.equal(owner.address);
        })
        
        it('the caller of deploySafeProxy is the owner of the deployed Proxy', async function () {
            //safeProxy = await ethers.getContractAt("SafeUpgradeable", safeProxyContract)
            //console.log(safeProxy.proxyOwner());
            expect(await upgradableProxy.proxyOwner()).to.equal(owner.address);;
        })
    });
    describe("tax fee", function () {
        it('should deposit DIEToken', async function () {
            await ProxySafe.connect(addr1).deposit(50000, dieToken.address);
            await ProxySafe.connect(addr2).deposit(10000, dieToken.address);
            //console.log(await dieToken.connect(owner).balanceOf(ProxySafe.address));
            //await ProxySafe.connect(addr1).balanceof(dieToken.address);
            expect(await dieToken.balanceOf(addr1.address)).to.equal(40000);
            expect(await dieToken.balanceOf(addr2.address)).to.equal(0);

        })
        
        it('Should Withdraw DIEToken and minus tax fee', async function () {
            await ProxySafe.connect(addr1).deposit(50000, dieToken.address);
            await ProxySafe.connect(addr2).deposit(10000, dieToken.address);
            await ProxySafe.connect(addr1).withdraw(40000, dieToken.address);
            await ProxySafe.connect(addr2).withdraw(5000, dieToken.address);
      
            expect(await dieToken.balanceOf(addr1.address)).to.equal(80000);
            expect(await dieToken.balanceOf(addr2.address)).to.equal(5000);
        })
    });
    
    
  });
  