// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from '../interfaces/ICLSynchronicityPriceAdapter.sol';

/**
 * @title CLSynchronicityPriceAdapter
 * @author BGD Labs
 * @notice Price adapter to calculate price of (Asset / Base) pair by using
 * @notice Chainlink Data Feeds for (Asset / Peg) and (Peg / Base) pairs.
 * @notice For example it can be used to calculate stETH / USD
 * @notice based on stETH / ETH and ETH / USD feeds.
 */
contract CLSynchronicityPriceAdapterPegToBase is ICLSynchronicityPriceAdapter {
  /**
   * @notice Price feed for (Base / Peg) pair
   */
  IChainlinkAggregator public immutable PEG_TO_BASE;

  /**
   * @notice Price feed for (Asset / Peg) pair
   */
  IChainlinkAggregator public immutable ASSET_TO_PEG;

  /**
   * @notice Number of decimals in the output of this price adapter
   */
  uint8 public immutable DECIMALS;

  /**
   * @notice This is a parameter to bring the resulting answer with the proper precision.
   * @notice will be equal to 10 to the power of the sum decimals of feeds
   */
  int256 public immutable DENOMINATOR;

  /**
   * @notice Maximum number of resulting and feed decimals
   */
  uint8 public constant MAX_DECIMALS = 18;

  string private _description;

  /**
   * @param pegToBaseAggregatorAddress the address of PEG / BASE feed
   * @param assetToPegAggregatorAddress the address of the ASSET / PEG feed
   * @param _decimals precision of the answer
   * @param pairDescription description
   */
  constructor(
    address pegToBaseAggregatorAddress,
    address assetToPegAggregatorAddress,
    uint8 _decimals,
    string memory pairDescription
  ) {
    PEG_TO_BASE = IChainlinkAggregator(pegToBaseAggregatorAddress);
    ASSET_TO_PEG = IChainlinkAggregator(assetToPegAggregatorAddress);

    if (_decimals > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (PEG_TO_BASE.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (ASSET_TO_PEG.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();

    DECIMALS = _decimals;
    _description = pairDescription;

    // equal to 10 to the power of the sum decimals of feeds
    unchecked {
      DENOMINATOR = int256(10 ** (PEG_TO_BASE.decimals() + ASSET_TO_PEG.decimals()));
    }
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function description() external view returns (string memory) {
    return _description;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function decimals() external view returns (uint8) {
    return DECIMALS;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function latestAnswer() public view virtual override returns (int256) {
    int256 assetToPegPrice = ASSET_TO_PEG.latestAnswer();
    int256 pegToBasePrice = PEG_TO_BASE.latestAnswer();

    if (assetToPegPrice <= 0 || pegToBasePrice <= 0) {
      return 0;
    }

    return (assetToPegPrice * pegToBasePrice * int256(10 ** DECIMALS)) / (DENOMINATOR);
  }
}
