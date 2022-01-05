// SPDX-License-Identifier: MIT
// Nobility ft. Noble Knights NFTs
//
//
//            .
//           /.\
//           |.|
//           |.|
//           |.|
//           |.|   ,'`.
//           |.|  ;\  /:
//           |.| /  \/  \
//           |.|<.<_\/_>,>
//           |.| \`.::,'/
//           |.|,'.'||'/.
//        ,-'|.|.`.____,'`.
//      ,' .`|.| `.____,;/ \
//     ,'=-.`|.|\ .   \ |,':
//    /_   :)|.|.`.___:,:,'|.
//   (  `-:;\|.|.`.)  |.`-':,\
//   /.   /  ;.:--'   |    | ,`.
//  / _>-'._.'-'.     |.   |' / )._
// :.'    ((.__;/     |    |._ /__ `.___
// `.>._.-' |)=(      |.   ;  '--.._,`-.`.
//          ',--'`-._ | _,:          `='`'
//          /_`-. `..`:'/_.\
//         :__``--..\\_/_..:
//         |  ``--..,:;\__.|
//         |`--..__/:;  :__|
//         `._____:-;_,':__;
//          |:'    /::'  `|
//          |,---.:  :,-'`;
//          : __  )  ;__,'\
//          \' ,`/   \__  :
//          :. |,:   :  `./
//          | `| |   |   |:
//          |  | |   |   ||
//          |  | |   |   ||
//          |  | |   '   ||
//          |  : |    \  ||
//          |  ; :    :  ||
//          | / ,;    |\,'`.
//          ;-.(,'    '-._,-`.
//        ,'-.//          `--'
//        `---'
//
//
//NBLK is a utility token for the Noble Knights NFT Ecosystem.
//$NBLK holds NO economic value. 
//It is earned by active holding Noble Knight NFTS. Each Genesis Knight will be eligible to claim tokens at a rate of 5 $NBLK per day.

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

interface iNobleKnights {
    function balanceGenesis(address owner) external view returns(uint256);
}

contract Nobility is ERC20, Ownable {

    iNobleKnights public NobleKnights;

    uint256 constant public BASE_RATE = 5 ether;
    uint256 public START;
    bool rewardPaused = false;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastUpdate;

    mapping(address => bool) public allowedAddresses;

    constructor(address knightAddress) ERC20("Nobility", "NBLK") {
        NobleKnights = iNobleKnights(knightAddress);
        START = block.timestamp;
    }

    function updateReward(address from, address to) external {
        require(msg.sender == address(NobleKnights));
        if(from != address(0)){
            rewards[from] += getPendingReward(from);
            lastUpdate[from] = block.timestamp;
        }
        if(to != address(0)){
            rewards[to] += getPendingReward(to);
            lastUpdate[to] = block.timestamp;
        }
    }

    function claimReward() external {
        require(!rewardPaused, "Claiming reward has been paused"); 
        _mint(msg.sender, rewards[msg.sender] + getPendingReward(msg.sender));
        rewards[msg.sender] = 0;
        lastUpdate[msg.sender] = block.timestamp;
    }


    function claimNblkRewards(address _address, uint256 _amount) external {
        require(!rewardPaused,                "Claiming reward has been paused"); 
        require(allowedAddresses[msg.sender], "Address does not have permission to distrubute tokens");
        _mint(_address, _amount);
    }

    function burn(address user, uint256 amount) external {
        require(allowedAddresses[msg.sender] || msg.sender == address(NobleKnights), "Address does not have permission to burn");
        _burn(user, amount);
    }

    function getTotalClaimable(address user) external view returns(uint256) {
        return rewards[user] + getPendingReward(user);
    }

    function getPendingReward(address user) internal view returns(uint256) {
        return NobleKnights.balanceGenesis(user) * BASE_RATE * (block.timestamp - (lastUpdate[user] >= START ? lastUpdate[user] : START)) / 86400;
    }

    function setAllowedAddresses(address _address, bool _access) public onlyOwner {
        allowedAddresses[_address] = _access;
    }

    function toggleReward() public onlyOwner {
        rewardPaused = !rewardPaused;
    }
}