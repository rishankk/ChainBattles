// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct playerStats {
        uint256 levels;
        uint256 hp;
        uint256 strength;
        uint256 speed;
    }

    mapping(uint256 => playerStats) public tokenIdtoStats;

    //uint => struct(levels,hp,strength,speed)

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId) public returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getStats(tokenId).levels.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "HP: ",
            getStats(tokenId).hp.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            getStats(tokenId).strength.toString(),
            "</text>",
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            getStats(tokenId).speed.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getStats(uint256 tokenId)
        public
        view
        returns (playerStats memory)
    {
        return tokenIdtoStats[tokenId];
    }

    function getTokenURI(uint256 tokenId) public returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function random() public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % 10;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        tokenIdtoStats[newTokenId].levels = random();
        tokenIdtoStats[newTokenId].hp = random();
        tokenIdtoStats[newTokenId].strength = random();
        tokenIdtoStats[newTokenId].speed = random();
        //add stats, random
        _setTokenURI(newTokenId, getTokenURI(newTokenId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Token id does not exist");
        require(ownerOf(tokenId) == msg.sender, "Only owners can train");
        uint256 currentLevel = tokenIdtoStats[tokenId].levels;
        tokenIdtoStats[tokenId].levels = currentLevel + 1;
        uint256 currentHp = tokenIdtoStats[tokenId].hp;
        tokenIdtoStats[tokenId].hp = currentHp + 1;
        uint256 currentStrength = tokenIdtoStats[tokenId].strength;
        tokenIdtoStats[tokenId].strength = currentStrength + 1;
        uint256 currentSpeed = tokenIdtoStats[tokenId].speed;
        tokenIdtoStats[tokenId].speed = currentSpeed + 1;
        //pseudorandom number for stats
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
