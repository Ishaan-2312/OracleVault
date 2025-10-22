//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/OracleVault.sol";

contract OracleVaultTest is Test {

    OracleVault vault;
    address feed = address(uint160(uint256(keccak256("0x694AA1769357215DE4FAC081bf1f309aDC325306"))));
    
    function setUp() external{
        vault = new OracleVault(feed);

    }


    function testDepositAndBorrow() public {
        vm.deal(address(this), 10 ether);
        vault.depositEth{value: 5 ether}();

        uint256 ethPrice = vault.getEthPrice();
        console.log("EthPrice",ethPrice); // e.g., 1800 * 1e8
        uint256 collateralUSD = (5 ether * ethPrice) / 1e8;
        uint256 maxBorrow = (collateralUSD * 100) / 150;

        vault.borrow(maxBorrow / 2); // safe borrow
        assertGt(vault.borrowedAmount(address(this)), 0);
    }
}