pragma solidity ^0.6.0;

contract OwnerShip {

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) public OnlyOwner{
        owner = newOwner;
    }
}
