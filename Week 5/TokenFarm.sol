pragma solidity ^0.6.0;

import "./DaiToken.sol";
import "./DappToken.sol";

//address 0x5edCa09E0E2B637AC63aF82d55de10db0cC25F95

contract TokenFarm{
    string public name = "Dapp Token Farm";
    DappToken public dappToken;
    DaiToken public daiToken;
    address public owner;

    mapping(address=>uint) public stakingBalance;
    mapping(address=>bool) public hasStaked;
    mapping(address=>bool) public isStaking;
    address[] public staker;

    constructor (DaiToken _DaiToken, DappToken _DappToken) public{
        dappToken = _DappToken;
        daiToken = _DaiToken;
        owner = msg.sender;
    }

    function stakeToken(uint _amount) public {
        require(_amount>0,"amount need to be more than 0");
        daiToken.transferFrom(msg.sender, address(this), _amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if(!hasStaked[msg.sender]){
            staker.push(msg.sender);
        }
        hasStaked[msg.sender] = true;
    }

    function unstakeToken() public {
        require(isStaking[msg.sender] == true,"You have nothing to unstake.");
        uint balance = stakingBalance[msg.sender];
        daiToken.transfer(msg.sender,balance);
        isStaking[msg.sender] = false;
    }

    function stakeAmount(address _owner) public view returns(uint) {
        returns stakingBalance[_owner];
    }

    function issusToken() public {
        require(msg.sender==owner,"trader is not owner");
        for(uint i=0; i<staker.length;i++){
            address recipient = staker[i];
            if(isStaking[recipient] == true){
                uint balance = stakingBalance[recipient];
                dappToken.transfer(recipient, balance);
            }
        }
    }

}