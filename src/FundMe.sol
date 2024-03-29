// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 导入Chainlink的AggregatorV3Interface接口和自定义的PriceConverter合约
import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 定义一个自定义错误，用于当非所有者尝试执行仅所有者才能执行的操作时
error FundMe_NotOwner();

// 定义FundMe合约，用于接受资金并管理资金来源
contract FundMe {
    // 使用PriceConverter工具合约来转换金额
    using PriceConverter for uint256;

    // 映射地址到已资助的金额
    mapping(address => uint256) private s_addressToAmountFunded;
    // 存储资助者的地址数组
    address[] private s_funders;

    // 所有者地址，合约部署者即为所有者
    address private /* immutable */ i_owner;
    // 最低资助金额（以USD为单位）
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    AggregatorV3Interface private s_priceFeed;
    
    // 构造函数，初始化所有者地址为部署者地址
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // 资助函数，允许用户向合约发送以ETH形式的资金
    function fund() public payable {
        // 需要发送的ETH价值至少达到最低USD金额
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    // 获取链link价格喂养合约的版本号
    function getVersion() public view returns (uint256){
        return  s_priceFeed.version();
    }
    
    // 仅所有者可以执行的操作修饰符
    modifier onlyOwner {
        if (msg.sender != i_owner) revert FundMe_NotOwner();
        _;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        // 创建一个新的数组，用于存储所有资助者的地址
        address[] memory funders = new address[](fundersLength);
        // 将所有资助者的地址复制到新数组中
        for (uint256 funderIndex=0; funderIndex < fundersLength; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;

        }
        s_funders = new address[](0);
        
        // 将合约余额转移到所有者地址
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
       
    }
    
    // 提取资金函数，仅所有者可以调用，用于将合约内的所有资金转移到所有者地址
    function withdraw() public onlyOwner {
        // 清空所有资助者的资助金额并重置资助者列表
        for (uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        
        // 将合约余额转移到所有者地址
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // 定义fallback函数，用于处理意外的以太币转账和未定义的函数调用
    fallback() external payable {
        fund();
    }

    // 定义receive函数，专门用于接收以太币
    receive() external payable {
        fund();
    }

    function getAddressToAmountFunded(address funderAddress) external view returns (uint256) {
        return s_addressToAmountFunded[funderAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

}