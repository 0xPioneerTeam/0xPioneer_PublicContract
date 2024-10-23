import { Contract, BigNumber } from "ethers/lib";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from "../utils/util_contracttool";
import { logtools } from "../utils/util_log";
import { TestTool } from "../utils/util_testtool";
import { ethers } from "hardhat";

describe("Asset Test", function () {
    before(inittest);
    it("should mint succ", mint);
    it("should transfer succ", transfer);
    // it("should pause batch succ", pause);
});

var testtool: TestTool;

import * as hre from "hardhat";
import { assert } from "chai";
import { addChargeToken, eth_addr } from "../init/init_Config";

var PioneerSyCoin20Minter: Contract;
var PioneerTokenMinePool : Contract;
var PioneerToken20 : Contract;

async function inittest() {
    testtool = await TestTool.Init();

    PioneerSyCoin20Minter = ContractInfo.getContract("PioneerSyCoin20Minter");
    PioneerTokenMinePool = ContractInfo.getContract("PioneerTokenMinePool");
    PioneerToken20 = await ContractTool.GetProxyContract("PioneerToken20", "PCapped20");

    await ContractTool.PassBlock(hre, 1000);
}

async function mint() {
    let signerAddr = await PioneerSyCoin20Minter.signer.getAddress();

    await ContractTool.CallState(PioneerSyCoin20Minter, "mintCoin20", [signerAddr, "100000000000000000"]);

    //await ContractTool.CallState(PioneerToken20, "transfer", ["addr:PioneerTokenMinePool", "500000000000000000000000"]);

    await ContractTool.CallState(PioneerTokenMinePool, "send", [signerAddr, "200000000000000000", ethers.utils.formatBytes32String("")]);
}
async function transfer() {

}
