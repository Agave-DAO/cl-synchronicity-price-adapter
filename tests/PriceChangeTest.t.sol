// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {ProposalPayloadStablecoinsPriceAdapter} from '../src/contracts/ProposalPayloadStablecoinsPriceAdapter.sol';
import {StablecoinPriceAdapter} from '../src/contracts/StablecoinPriceAdapter.sol';
import {IAaveOracle} from '../src/interfaces/IAaveOracle.sol';

contract PriceChangeTest is Test, ProposalPayloadStablecoinsPriceAdapter {

  uint8 public constant MAX_DIFF_PERCENTAGE = 2;

  function setUp() public {}

  function testStablecoinPriceAdapter() public {

    (address[] memory assets, address[] memory aggregators) = _initAssetAggregators();
    address[] memory adapters = new address[](assets.length);

    // for each stable coin make price adapter
    for (uint8 i = 0; i < assets.length; i++) {
      StablecoinPriceAdapter adapter = new StablecoinPriceAdapter(
          ETH_USD_AGGREGATOR,
          aggregators[i]
      );

      adapters[i] = address(adapter);
    }

    for (uint8 i = 0; i < assets.length; i++) {
        uint256 currentPrice = AAVE_ORACLE.getAssetPrice(assets[i]);
        uint256 newPrice = uint256(StablecoinPriceAdapter(adapters[i]).latestAnswer());
        
        uint256 maximumDifference = (currentPrice * MAX_DIFF_PERCENTAGE) / 100;
        uint256 lowerLimit = currentPrice - maximumDifference;
        uint256 upperLimit = currentPrice + maximumDifference;

        assertTrue(newPrice >= lowerLimit);
        assertTrue(newPrice <= upperLimit);
    }
  }

}