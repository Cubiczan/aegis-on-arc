// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
contract MockUSDC {
    mapping(address=>uint256) public balanceOf; mapping(address=>mapping(address=>uint256)) public allowance;
    uint8 public constant decimals = 6;
    function mint(address t,uint256 v) external { balanceOf[t]+=v; }
    function approve(address s,uint256 v) external returns(bool){ allowance[msg.sender][s]=v; return true; }
    function transfer(address t,uint256 v) external returns(bool){ require(balanceOf[msg.sender]>=v); balanceOf[msg.sender]-=v; balanceOf[t]+=v; return true; }
    function transferFrom(address f,address t,uint256 v) external returns(bool){ require(allowance[f][msg.sender]>=v && balanceOf[f]>=v); allowance[f][msg.sender]-=v; balanceOf[f]-=v; balanceOf[t]+=v; return true; }
}
