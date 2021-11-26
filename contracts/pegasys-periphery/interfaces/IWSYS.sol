// SPDX-License-Identifier: GNU
pragma solidity >=0.5.0;

interface IWSYS {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function withdraw(uint256) external;
}
