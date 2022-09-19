// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5 <0.9.0;
pragma abicoder v2;

import 'forge-std/Vm.sol';

interface ITimelockExecutor {
  struct SPropQueueParams {
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
  }

  function queue(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    bool[] memory withDelegatecalls
  ) external;

  function execute(uint256 actionsSetId) external;

  function getActionsSetCount() external view returns (uint256);

  function getDelay() external view returns (uint256);
}


library TimelockHelpers {
  address public constant SHORT_EXECUTOR =
    0xEE56e2B3D491590B5b31738cC34d5232F378a8D5;

  ITimelockExecutor internal constant TIMELOCK_EXECUTOR =
    ITimelockExecutor(0xAce1d11d836cb3F51Ef658FD4D353fFb3c301218);

  function queueActionSet(
    Vm vm,
    ITimelockExecutor.SPropQueueParams memory params
  ) internal returns (uint256) {
    vm.startPrank(SHORT_EXECUTOR);
    uint256 count = TIMELOCK_EXECUTOR.getActionsSetCount();
    TIMELOCK_EXECUTOR.queue(
      params.targets,
      params.values,
      params.signatures,
      params.calldatas,
      params.withDelegatecalls
    );
    vm.stopPrank();
    return count;
  }

  function executeActionSet(uint256 actionSetId) internal {
    TIMELOCK_EXECUTOR.execute(actionSetId);
  }

  function getTimelockExecutorDelay() internal view returns (uint256) {
    return TIMELOCK_EXECUTOR.getDelay();
  }
}
