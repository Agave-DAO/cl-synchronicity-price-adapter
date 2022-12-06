// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './CLSynchronicityPriceAdapterBaseToPeg.sol';
import {IAaveOracle} from 'aave-address-book/AaveV2.sol';
import {AaveV2EthereumArc} from 'aave-address-book/AaveAddressBook.sol';

/**
 * @title ArcProposalPayloadStablecoinsPriceAdapter
 * @author BGD Labs
 * @notice Aave governance payload to add price adapter for stable coins
 */
contract ArcProposalPayloadStablecoinsPriceAdapter {
  address public constant ETH_USD_AGGREGATOR =
    0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  function _initAssetAggregators()
    internal
    pure
    returns (address[] memory, address[] memory)
  {
    address[] memory assets = new address[](1);
    address[] memory aggregators = new address[](1);

    // USDC
    assets[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    aggregators[0] = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;

    return (assets, aggregators);
  }

  function execute() external {
    (
      address[] memory assets,
      address[] memory aggregators
    ) = _initAssetAggregators();
    address[] memory adapters = new address[](assets.length);

    // for each stable coin make price adapter
    for (uint8 i = 0; i < assets.length; i++) {
      CLSynchronicityPriceAdapterBaseToPeg adapter = new CLSynchronicityPriceAdapterBaseToPeg(
          ETH_USD_AGGREGATOR,
          aggregators[i],
          18
        );

      adapters[i] = address(adapter);
    }

    // set new asset source for all stable coins
    AaveV2EthereumArc.ORACLE.setAssetSources(assets, adapters);
  }
}
