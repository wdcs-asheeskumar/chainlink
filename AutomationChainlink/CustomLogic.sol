//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

interface AutomationCompatibleInterface {

  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  function performUpkeep(bytes calldata performData) external;
}

pragma solidity ^0.8.19;

contract AutoCtr1 is AutomationCompatibleInterface {
    uint public interval;
    uint public maxCounter;
    event Logger(address indexed addr, bytes indexed checkD, uint timestamp,uint blocknbr, uint curcount);
    struct Target {
  
            uint lastTimeStamp;
            uint counter;
            address sender;
            }
    mapping(bytes => Target) public s_targets;

    constructor() {
      interval = 60;
      maxCounter = 4;
    }


    function checkUpkeep(bytes calldata checkData) external view  override returns (bool upkeepNeeded, bytes memory  performData ) {
          if ((s_targets[checkData].counter<maxCounter)&&(block.timestamp - s_targets[checkData].lastTimeStamp) > interval ) {
              return(true,checkData);
          } else {return(false,checkData);}
    }

    function performUpkeep(bytes calldata performData ) external override {
        uint currCount = 0;
        s_targets[performData].lastTimeStamp = block.timestamp;
        s_targets[performData].sender = msg.sender;
        currCount = s_targets[performData].counter +1;
        emit Logger(msg.sender, performData, block.timestamp,block.number, currCount);
        s_targets[performData].counter = currCount;  
    }
}