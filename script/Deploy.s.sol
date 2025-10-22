//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/OracleVault.sol";

contract DeployScript is Script{

    function run() external{
        address feed;
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 chainId = block.chainid;
        if(chainId==1){
            feed = address(uint160(uint256(keccak256("0x5f4eC3Df9cbd43714FE2740f5E3616155C5B8419"))));
        }
        else feed =address(uint160(uint256(keccak256("0x694AA1769357215DE4FAC081bf1f309aDC325306"))));
        
        OracleVault oracleVault = new OracleVault(feed);
        vm.stopBroadcast();
    }
}