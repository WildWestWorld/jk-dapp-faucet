// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Owned.sol";
import "./Logger.sol";
import "./IFaucet.sol";

contract Faucet is Owned, Logger, IFaucet {
    uint public numOfFunders;

    mapping(address => bool) public funders;

    //     mapping(uint => address)：

    // uint：这是映射的键类型，表示键是无符号整数。
    // address：这是映射的值类型，表示值是以太坊地址。
    // 总体来说，这个映射表示从无符号整数键到以太坊地址值的映射关系。
    mapping(uint => address) public lutFunders;

    // 在智能合约中，modifier 是一个用于修改其他函数行为的代码块。它可以在函数执行前或执行后执行特定的逻辑，从而对函数进行限制或扩展。

    modifier limitWithdraw(uint widthdrawAmount) {
        require(
            widthdrawAmount <= 1000000000000000000,
            "Cannot withdraw more than 0.1 ether"
        );
        // 这个特殊的符号表示修饰器的占位符。它指示了函数体应该在此处执行。
        _;
    }

    receive() external payable {}

    function emitLog() public pure override returns (bytes32) {
        return "Hello World";
    }

    function addFunds() external payable override {
        address funder = msg.sender;

        test3();
        if (!funders[funder]) {
            uint index = numOfFunders++;
            funders[funder] = true;
            lutFunders[index] = msg.sender;
        }
    }

    function test1() external onlyOwner {}

    function test2() external onlyOwner {}

    function withdraw(
        uint widthdrawAmount
    ) external override limitWithdraw(widthdrawAmount) {
        // payable：将地址 msg.sender 转换为一个可以接收以太币的 payable 地址。不是所有地址在智能合约中都可以接收以太币，必须显式声明为 payable。

        payable(msg.sender).transfer(widthdrawAmount);
    }

    function getAllFunders() public view returns (address[] memory) {
        address[] memory _funders = new address[](numOfFunders);
        for (uint i = 0; i < numOfFunders; i++) {
            _funders[i] = lutFunders[i];
        }
        return _funders;
    }

    function getFunderAtIndex(uint8 index) external view returns (address) {
        address[] memory _funders = getAllFunders();
        return _funders[index];
    }
}

//const instance = await Faucet.deployed();

//instance.addFunds({from: accounts[0],value: "2000000000000000000"})
//instance.addFunds({from: accounts[1],value: "2000000000000000000"})

// instance.withdraw("5000000000000000000",{from:accounts[1]})

// instance.getFunderAtIndex(0)
// instance.getAllFunders()
