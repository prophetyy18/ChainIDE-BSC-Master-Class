pragma solidity ^0.6.0;

contract MappingRecord {
    
    mapping(address=>uint) balanceOf;

    function setBalance(uint balance) public {
        balanceOf[msg.sender] = balance;
    }

    function getBalace() public view returns(uint){
        return(balanceOf[msg.sender]);
    }
}
