import { BigNumber } from "ethers/lib";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ContractInfo } from "../utils/util_contractinfo";
import { ContractTool } from '../utils/util_contracttool';
import { logtools } from "../utils/util_log";

export class Init_Assets {

    static async InitAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Init_Assets");

//======init assets
        let PioneerSyCoin20 = await ContractTool.GetProxyContract("PioneerSyCoin20", "PMintable20");
        await ContractTool.CallState(PioneerSyCoin20, "initMintable20", ["0xPioneer Psyche Energy", "PSYC", 0]);
        await ContractTool.CallState(PioneerSyCoin20, "setMinter", ["addr:PioneerSyCoin20Minter"]);

        let PioneerToken20 = await ContractTool.GetProxyContract("PioneerToken20", "PCapped20");
        await ContractTool.CallState(PioneerToken20, "initCapped20", ["0xPioneer Token", "PIOT", "100000000000000000000000000000"]);

        // TO DO : transfer mine token to mine pool 50%?
        await ContractTool.CallState(PioneerToken20, "transfer", ["addr:PioneerTokenMinePool", "50000000000000000000000000000"]);

        // off on chain
        let PioneerOffOnChainBridge = ContractInfo.getContract("PioneerOffOnChainBridge");
        await ContractTool.CallState(PioneerOffOnChainBridge, "init", ["addr:PioneerSyCoin20", "addr:PioneerToken20"]);

        return true;
    }

    static async ConfigAll(hre: HardhatRuntimeEnvironment): Promise<boolean> {
        logtools.logblue("==Config_Assets");

//======config assets

        return true;
    }
}     
