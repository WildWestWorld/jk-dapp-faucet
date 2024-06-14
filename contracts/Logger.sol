// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

abstract contract Logger {
    uint public testNum;

    constructor() {
        testNum = 1000;
    }

    //pure关键字表明该函数不访问合约状态，也不修改状态，
    // 因此它的实现必须是纯函数，只能通过输入参数计算结果并返回。

    // virtual关键字表示这个函数可以被子类重写
    function emitLog() public pure virtual returns (bytes32);

    function test3() internal pure returns (uint) {
        return 100;
    }

    function test5() external pure returns (uint) {
        test3();
        return 0;
    }
}
