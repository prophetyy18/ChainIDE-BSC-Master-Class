pragma solidity ^0.6.0;

contract StudentInformation {

    struct Student{
        uint number;
        bool attend;
        string name;
    }
    
    Student a;

    function setInformation(uint _number, bool _attend, string memory _name) public {
        a.number = _number;
        a.attend = _attend;
        a.name = _name;
    }


    function retrieve() public view returns (uint, bool ,string memory) {
        return (a.number, a.attend, a.name);
    }
}
