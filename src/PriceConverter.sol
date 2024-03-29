// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * 价格转换库，用于将以太坊价格转换为美元价格。
 * 本库不作为抽象合约或接口，是因为实现具体功能更便于直接使用。
 */
library PriceConverter {
    /**
     * 获取当前以太坊对美元的汇率。
     * 该函数内部调用Chainlink的喂价合约获取最新价格。
     * 
     * @return uint256 以太坊对美元的汇率，乘以10^9（即保留9位小数）。
     */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // 调用合约获取最新汇率数据
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // 将获取的汇率转换为uint256格式，乘以10^9进行四舍五入
        return uint256(answer * 10000000000);
    }

    /**
     * 将以太坊金额转换为美元金额。
     * 
     * @param ethAmount 要转换的以太坊金额。
     * @return uint256 转换后的美元金额，保留9位小数。
     */
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // 获取当前ETH/USD价格
        // 计算ethAmount对应的美元金额，先转换为uint256，再除以1e18进行调整
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // 返回转换后的美元金额
        return ethAmountInUsd;
    }
}