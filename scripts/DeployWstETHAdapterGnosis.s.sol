// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {CLSynchronicityPriceAdapterPegToBase} from "../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol";
import {BaseAggregatorsGnosis} from "../src/lib/BaseAggregatorsGnosis.sol";

contract DeployWstETHGnosis is Script {
    function run() external {
        uint256 deployerPrivateKey = 0;
        string memory mnemonic = vm.envString("MNEMONIC");

        if (bytes(mnemonic).length > 20) {
            deployerPrivateKey = vm.deriveKey(mnemonic, 0);
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);

      new CLSynchronicityPriceAdapterPegToBase(
      BaseAggregatorsGnosis.ETH_USD_AGGREGATOR,
      BaseAggregatorsGnosis.WSTETH_ETH_AGGREGATOR,
      8,
      'wstETH/ETH/USD'
    );

        vm.stopBroadcast();
    }
}
