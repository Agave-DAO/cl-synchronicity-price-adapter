// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';
import {IERC4626} from 'forge-std/interfaces/IERC4626.sol';
import {ICLSynchronicityPriceAdapter} from '../interfaces/ICLSynchronicityPriceAdapter.sol';

/**
 * @title ERC4626SynchronicityPriceAdapter
 * @author Agave
 * @notice Price adapter to calculate price of (ERC4626 shares / Peg) pair by using
 * @notice the ERC4626 convertToAssets() and Chainlink Data Feeds for (Peg / Base).
 * @notice For example it can be used to calculate sDAI / USD
 * @notice based on sDAI / WXDAI and WXDAI / USD feeds.
 */
contract ERC4626SynchronicityPriceAdapter is ICLSynchronicityPriceAdapter {
  /**
   * @notice Price feed for (Base / Peg) pair
   */
  IChainlinkAggregator public immutable PEG_TO_BASE;

  /**
   * @notice ERC4626 vault for (ERC4626 shares / Peg) pair
   */
  IERC4626 public immutable ERC4626_TO_PEG;

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
   * @param erc4626ToPegAggregatorAddress the address of the VAULT with PEG as reserve
   * @param _decimals precision of the answer
   * @param pairDescription description
   */
  constructor(
    address pegToBaseAggregatorAddress,
    address erc4626ToPegAggregatorAddress,
    uint8 _decimals,
    string memory pairDescription
  ) {
    PEG_TO_BASE = IChainlinkAggregator(pegToBaseAggregatorAddress);
    ERC4626_TO_PEG = IERC4626(erc4626ToPegAggregatorAddress);

    if (_decimals > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (PEG_TO_BASE.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (ERC4626_TO_PEG.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();

    DECIMALS = _decimals;
    _description = pairDescription;

    // equal to 10 to the power of the sum decimals of feeds
    unchecked {
      DENOMINATOR = int256(10 ** (PEG_TO_BASE.decimals() + ERC4626_TO_PEG.decimals()));
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
    int256 erc4626shares = int256(10 ** ERC4626_TO_PEG.decimals());
    int256 pegToBasePrice = PEG_TO_BASE.latestAnswer();
    int256 erc4626ToPegPrice = int256(ERC4626_TO_PEG.convertToAssets(uint256(erc4626shares)));

    if (erc4626ToPegPrice <= erc4626shares || pegToBasePrice <= 0) {
      return 0;
    }
  // ERC4626_TO_PEG.decimals() * chainlink 8 decimals * 
    return (erc4626ToPegPrice * pegToBasePrice * int256(10 ** DECIMALS)) / (DENOMINATOR);
  }
}