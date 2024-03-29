// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MockV3Aggregator
 * @notice 基于FluxAggregator合约的模拟合约
 * @notice 使用此合约时，您需要测试其他合约从聚合器合约读取数据的能力，
 * 但聚合器如何得到答案并不重要。
 */
contract MockV3Aggregator {
    uint256 public constant version = 4; // 版本号

    uint8 public decimals; // 精度
    int256 public latestAnswer; // 最新答案
    uint256 public latestTimestamp; // 最新更新时间戳
    uint256 public latestRound; // 最新轮次

    // 映射：轮次到答案
    mapping(uint256 => int256) public getAnswer;
    // 映射：轮次到时间戳
    mapping(uint256 => uint256) public getTimestamp;
    // 映射：轮次到开始时间戳（私有）
    mapping(uint256 => uint256) private getStartedAt;

    /**
     * @notice 构造函数
     * @param _decimals 精度
     * @param _initialAnswer 初始答案
     */
    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        updateAnswer(_initialAnswer); // 初始化答案
    }

    /**
     * @notice 更新答案
     * @param _answer 新答案
     */
    function updateAnswer(int256 _answer) public {
        latestAnswer = _answer;
        latestTimestamp = block.timestamp; // 使用当前区块时间戳
        latestRound++; // 更新轮次
        getAnswer[latestRound] = _answer; // 记录答案
        getTimestamp[latestRound] = block.timestamp; // 记录时间戳
        getStartedAt[latestRound] = block.timestamp; // 记录开始时间戳
    }

    /**
     * @notice 更新指定轮次的数据
     * @param _roundId 轮次ID
     * @param _answer 答案
     * @param _timestamp 时间戳
     * @param _startedAt 开始时间戳
     */
    function updateRoundData(uint80 _roundId, int256 _answer, uint256 _timestamp, uint256 _startedAt) public {
        latestRound = _roundId; // 更新最新轮次
        latestAnswer = _answer; // 更新答案
        latestTimestamp = _timestamp; // 更新时间戳
        getAnswer[latestRound] = _answer; // 更新答案记录
        getTimestamp[latestRound] = _timestamp; // 更新时间戳记录
        getStartedAt[latestRound] = _startedAt; // 更新开始时间戳记录
    }

    /**
     * @notice 获取指定轮次的数据
     * @param _roundId 轮次ID
     * @return roundId 轮次ID, answer 答案, startedAt 开始时间戳, updatedAt 更新时间戳, answeredInRound 答案所在的轮次
     */
    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, getAnswer[_roundId], getStartedAt[_roundId], getTimestamp[_roundId], _roundId);
    }

    /**
     * @notice 获取最新轮次的数据
     * @return roundId 轮次ID, answer 答案, startedAt 开始时间戳, updatedAt 更新时间戳, answeredInRound 答案所在的轮次
     */
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (
            uint80(latestRound),
            getAnswer[latestRound],
            getStartedAt[latestRound],
            getTimestamp[latestRound],
            uint80(latestRound)
        );
    }

    /**
     * @notice 获取合约描述信息
     * @return 描述信息字符串
     */
    function description() external pure returns (string memory) {
        return "v0.6/test/mock/MockV3Aggregator.sol";
    }
}