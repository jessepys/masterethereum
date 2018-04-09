pragma solidity ^0.4.1;  //编译器要求

contract Add {
      address public owner;    //合约创建者

      function Add(){
          owner = msg.sender;
      }

      function Go(uint x, uint y) returns (uint){
          return x + y;            //加法
      }
}
