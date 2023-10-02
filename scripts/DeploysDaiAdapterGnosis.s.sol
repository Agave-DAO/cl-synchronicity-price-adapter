// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {ERC4626SynchronicityPriceAdapter} from "../src/contracts/ERC4626SynchronicityPriceAdapter.sol";
import {BaseAggregatorsGnosis} from "../src/lib/BaseAggregatorsGnosis.sol";

contract DeploysDAIGnosis is Script {
    function run() external {
        uint256 deployerPrivateKey = 0;
        string memory mnemonic = vm.envString("MNEMONIC");

        if (bytes(mnemonic).length > 20) {
            deployerPrivateKey = vm.deriveKey(mnemonic, 0);
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);

      new ERC4626SynchronicityPriceAdapter(
      BaseAggregatorsGnosis.WXDAI_USD_AGGREGATOR,
      BaseAggregatorsGnosis.SDAI_WXDAI_ERC4626,
      8,
      'sDAI/WXDAI/USD'
    );

        vm.stopBroadcast();
    }
}
