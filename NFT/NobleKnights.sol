// SPDX-License-Identifier: MIT
//
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
//
//
                                                                         
pragma solidity ^0.8.0;

import "./NobleKnightsERC721.sol";

interface INobility {
    function burn(address _from, uint256 _amount) external;
    function updateReward(address _from, address _to) external;
} 

contract NobleKnights is NobleKnightsERC721 {
    
    struct Data {
        string name;
        string bio;
    }

    modifier knightOwner(uint256 knightId) {
        require(ownerOf(knightId) == msg.sender, "Cannot interact with a Noble Knight you do not own");
        _;
    }

    INobility public Nobility;
    
    uint256 constant public UPGRADE_PRICE = 650 ether;
    uint256 constant public NAME_CHANGE_PRICE = 100 ether;
    uint256 constant public BIO_CHANGE_PRICE = 100 ether;

    /**
     * @dev Keeps track of the state of noble knight
     * 0 - Unminted
     * 1 - upgrade
     * 2 - Revealed
     */
    mapping(uint256 => uint256) public regularKnight;
    mapping(uint256 => Data) public data;

    event KnightUpgrade(uint256 knightId, uint256 parent1, uint256 parent2);
    event KnightRevealed(uint256 knightId);
    event NameChanged(uint256 knightId, string knightName);
    event BioChanged(uint256 knightId, string knightBio);

    constructor(string memory name, string memory symbol, uint256 supply, uint256 genCount) NobleKnightsERC721(name, symbol, supply, genCount) {}

    function upgrade(uint256 parent1, uint256 parent2) external knightOwner(parent1) knightOwner(parent2) {
        uint256 supply = totalSupply();
        require(supply < maxSupply,                               "Cannot upgrade any more regular knights");
        require(parent1 < maxGenCount && parent2 < maxGenCount,   "Cannot upgrade with regular knights");
        require(parent1 != parent2,                               "Must select two unique knights");

        Nobility.burn(msg.sender, UPGRADE_PRICE);
        uint256 knightId = maxGenCount + regularCount;
        regularKnight[knightId] = 1;
        regularCount++;
        _safeMint(msg.sender, knightId);
        emit KnightUpgrade(knightId, parent1, parent2);
    }

    function reveal(uint256 knightId) external knightOwner(knightId) {
        regularKnight[knightId] = 2;
        emit KnightRevealed(knightId);
    }

    function changeName(uint256 knightId, string memory newName) external knightOwner(knightId) {
        bytes memory n = bytes(newName);
        require(n.length > 0 && n.length < 25,                          "Invalid name length");
        require(sha256(n) != sha256(bytes(data[knightId].name)),    "New name is same as current name");
        
        Nobility.burn(msg.sender, NAME_CHANGE_PRICE);
        data[knightId].name = newName;
        emit NameChanged(knightId, newName);
    }

    function changeBio(uint256 knightId, string memory newBio) external knightOwner(knightId) {
        Nobility.burn(msg.sender, BIO_CHANGE_PRICE);
        data[knightId].bio = newBio;
        emit BioChanged(knightId, newBio);
    }

    function setNobility(address NobilityAddress) external onlyOwner {
        Nobility = INobility(NobilityAddress);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public override {
        if (tokenId < maxGenCount) {
            Nobility.updateReward(from, to);
            balanceGenesis[from]--;
            balanceGenesis[to]++;
        }
        ERC721.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        if (tokenId < maxGenCount) {
            Nobility.updateReward(from, to);
            balanceGenesis[from]--;
            balanceGenesis[to]++;
        }
        ERC721.safeTransferFrom(from, to, tokenId, data);
    }
}