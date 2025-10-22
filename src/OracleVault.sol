//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";



contract OracleVault {

    AggregatorV3Interface internal priceFeed;

    mapping(address => uint256) public ethDeposits;
    mapping(address => uint256) public borrowedAmount;

    uint256 public constant COLLATERAL_RATIO = 150; // 150%
    uint256 public constant DECIMALS = 1e18;

    constructor(address _feed){
        priceFeed = AggregatorV3Interface(_feed);
    }

    function depositEth() public payable{
        require(msg.value>0,"Invalid Amount!!!");
        
        ethDeposits[msg.sender] += msg.value;
    }


    function borrow(uint amountUSD) public {
        uint ethPrice = getEthPrice();
        uint256 collateralValueUSD =
            (ethDeposits[msg.sender] * ethPrice) / 1e8;

        require(collateralValueUSD * 100 / COLLATERAL_RATIO >= amountUSD,"undercollateralized");

        borrowedAmount[msg.sender] += amountUSD;
    }

    function repay(uint amountUSD) public {
        require(borrowedAmount[msg.sender]>=amountUSD,"insufficient balance!!!");
        borrowedAmount[msg.sender] -= amountUSD;
    }


    function liquidate(address user) public {
        uint256 ethPrice = getEthPrice();
        uint256 collateralValueUSD =(ethDeposits[user] * ethPrice) / 1e8;

        if (collateralValueUSD * 100 < borrowedAmount[user] * COLLATERAL_RATIO) {
            ethDeposits[user] = 0;
            borrowedAmount[user] = 0;
            payable(msg.sender).transfer(ethDeposits[user]); // small bounty
        } else {
            revert("still healthy");
        }


    }


    function getEthPrice() public view returns (uint256){
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "invalid price");
        return uint256(price);

    }

}