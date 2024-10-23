
import { InitTool } from "../utils/util_inittool";
import { Init_Assets } from "./Init_Assets";

export function RegAll() {
    InitTool.RegForGroup("Assets", Init_Assets.InitAll, undefined, Init_Assets.ConfigAll, ["test/test_assets.ts"]);
}