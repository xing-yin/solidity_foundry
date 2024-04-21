// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract TestStruct {
    struct Funder {
        address addr;
        uint256 amount;
    }

    mapping(uint256 => Funder) funders;

    function contribute(uint256 id) public payable {
        funders[id] = Funder({addr: msg.sender, amount: msg.value});
        funders[id] = Funder(msg.sender, msg.value);
    }

    function getFunder(uint256 id) public view returns (address, uint256) {
        return (funders[id].addr, funders[id].amount);
    }

    struct Person {
        address account;
        bool isMan;
        uint8 age;
    }

    function test() public {
        Person memory p1 = Person(address(0x0), false, 19);
        Person memory p2 = Person({
            account: address(0x0),
            isMan: false,
            age: 19
        });
    }
}
