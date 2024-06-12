// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Faucet {
    uint public numOfFunders;

    mapping(address => bool) public funders;

    //     mapping(uint => address)：

    // uint：这是映射的键类型，表示键是无符号整数。
    // address：这是映射的值类型，表示值是以太坊地址。
    // 总体来说，这个映射表示从无符号整数键到以太坊地址值的映射关系。
    mapping(uint => address) public lutFunders;

    receive() external payable {}
    function addFunds() external payable {
        address funder = msg.sender;
        if (!funders[funder]) {
            uint index = numOfFunders++;
            funders[funder] = true;
            lutFunders[index] = msg.sender;
        }
    }

    function withdraw(uint widthdrawAmount) external {
        if (widthdrawAmount < 100000000000000) {
            payable(msg.sender).transfer(widthdrawAmount);
        }
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
