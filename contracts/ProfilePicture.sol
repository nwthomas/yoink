// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { Base64 } from "./libraries/Base64.sol";

contract ProfilePicture is Ownable, ERC721URIStorage {
  uint256 public newTokenID = 0;

  struct TokenMetadata {
    string name;
    string description;
    string imageUrl;
    string hair;
    string eyes;
    string favoriteSaying;
  }

  constructor(
    string memory _name,
    string memory _symbol,
    TokenMetadata memory _tokenMetadata
  ) ERC721(_name, _symbol) {
    mintNFT(_tokenMetadata);
  }

  function mintNFT(TokenMetadata memory _tokenMetadata) public onlyOwner {
    _safeMint(msg.sender, newTokenID);
    updateTokenURI(_tokenMetadata, newTokenID);
    newTokenID += 1;
  }

  function updateTokenURI(
    TokenMetadata memory _newTokenMetadata,
    uint256 _tokenId
  ) public onlyOwner {
    _setTokenURI(_tokenId, _buildTokenURI(_newTokenMetadata));
  }

  function _buildTokenURI(TokenMetadata memory _metadata)
    public
    pure
    returns (string memory)
  {
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"NAME": "',
            _metadata.name,
            '", "DESCRIPTION": "',
            _metadata.description,
            '", "IMAGE": "',
            _metadata.imageUrl,
            '", "HAIR": "',
            _metadata.hair,
            '", "EYES": "',
            _metadata.eyes,
            '", "FAVORITE_SAYING" "',
            _metadata.favoriteSaying,
            '"}'
          )
        )
      )
    );

    string memory tokenURI = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return tokenURI;
  }
}
