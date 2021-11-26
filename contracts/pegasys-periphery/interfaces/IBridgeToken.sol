// SPDX-License-Identifier: GNU
pragma solidity >=0.5.0;

import "../../pegasys-core/interfaces/IPegasysERC20.sol";

interface IBridgeToken is IPegasysERC20 {
    function swap(address token, uint256 amount) external;

    function swapSupply(address token) external view returns (uint256);
}
