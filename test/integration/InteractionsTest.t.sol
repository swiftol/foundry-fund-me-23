pragma solidity ^0.8.18;

// import {Script,console} from "forge-std/Script.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {WithrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    uint256 number = 1;
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER);
        // vm.deal(USER,1e18);
        // fundFundMe.fundFundMe(address(fundMe));

        // address funder = fundMe.getFunder(0);
        // assertEq(funder,USER);
        fundFundMe.fundFundMe(address(fundMe));

        WithrawFundMe withrawFundMe = new WithrawFundMe();
        withrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
    function testUserCanFundInteractions2() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        vm.prank(USER);
        vm.deal(USER,1e18);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }
}
