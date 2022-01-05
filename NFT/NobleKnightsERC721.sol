// SPDX-License-Identifier: MIT
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

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract NobleKnightsERC721 is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private baseURI;

    uint256 public maxSupply;
    uint256 public maxGenCount;
    uint256 public regularCount = 0;
    uint256 public price = 0.04444 ether;

    bool public presaleActive = false;
    bool public saleActive = false;

    mapping (address => uint256) public presaleWhitelist;
    mapping (address => uint256) public balanceGenesis;

    constructor(string memory name, string memory symbol, uint256 supply, uint256 genCount) ERC721(name, symbol) {
        maxSupply = supply;
        maxGenCount = genCount;
    }

    function mintPresale(uint256 numberOfMints) public payable {
        uint256 supply = totalSupply();
        uint256 reserved = presaleWhitelist[msg.sender];
        require(presaleActive,                              "Presale must be active to mint");
        require(reserved > 0,                               "No tokens reserved for this address");
        require(numberOfMints <= reserved,                  "Can't mint more than reserved");
        require(supply.add(numberOfMints) <= maxGenCount,   "Purchase would exceed max supply of Genesis Noble Knights");
        require(price.mul(numberOfMints) == msg.value,      "Ether value sent is not correct");
        presaleWhitelist[msg.sender] = reserved - numberOfMints;

        for(uint256 i; i < numberOfMints; i++){
            _safeMint(msg.sender, supply + i);
            balanceGenesis[msg.sender]++;
        }
    }

   function mint(uint256 numberOfMints) public payable {
    uint256 supply = totalSupply();
    require(saleActive,                                 "Sale must be active to mint");
    require(numberOfMints > 0 && numberOfMints < 3,     "Invalid purchase amount");
    require(supply.add(numberOfMints) <= maxGenCount,   "Purchase would exceed max supply of Genesis Noble Knights");
    require(price.mul(numberOfMints) == msg.value,      "Ether value sent is not correct");
        
    for(uint256 i; i < numberOfMints; i++) {
        _safeMint(msg.sender, supply + i);
        balanceGenesis[msg.sender]++;
        }
    }

    function editPresale(address[] calldata presaleAddresses, uint256[] calldata amount) external onlyOwner {
        for(uint256 i; i < presaleAddresses.length; i++){
            presaleWhitelist[presaleAddresses[i]] = amount[i];
        }
    }

    function walletOfOwner(address owner) external view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokensId;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function togglePresale() public onlyOwner {
        presaleActive = !presaleActive;
    }

    function toggleSale() public onlyOwner {
        saleActive = !saleActive;
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }
    
    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }
    
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}