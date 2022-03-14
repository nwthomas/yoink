// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Base64 } from "./libraries/Base64.sol";

/// @title GimmeToken
/// @notice Creates modifiable NFTs for any wallet address
/// @author Nathan Thomas <nathan@loom.com>
contract GimmeToken is Ownable, ERC721URIStorage {
  using Strings for uint256;

  uint256 public newTokenID = 1;
  uint256 public mintingFee = 0;

  mapping(address => bool) public exemptAddresses;

  // https://docs.opensea.io/docs/metadata-standards
  struct Attribute {
    string trait_type;
    string value;
  }
  struct TokenMetadata {
    string description;
    string image;
    string name;
    Attribute[] attributes;
  }

  event AddExemptAddress(address indexed exemptAddress);
  event RemoveExemptAddress(address indexed removedAddress);
  event MintToken(address indexed owner, uint256 indexed tokenID);
  event UpdateTokenURI(address indexed owner, uint256 indexed tokenID);
  event Withdraw(address indexed to, address indexed project, uint256 amount);

  modifier isMinimumFeeOrExemptAddress() {
    require(
      exemptAddresses[msg.sender] ||
        owner() == msg.sender ||
        msg.value >= mintingFee,
      string(
        abi.encodePacked(
          "GimmeToken: fee of ",
          (mintingFee / 1 ether).toString(),
          " ether required"
        )
      )
    );
    _;
  }

  modifier isTokenOwner(uint256 _tokenID) {
    require(ownerOf(_tokenID) == msg.sender, "GimmeToken: not token owner");
    _;
  }

  /// @notice Instantiates a new contract for creating custom NFTs
  /// @param _name The name for the NFT collection
  /// @param _symbol The symbol to be used for the NFT collection
  /// @param _mintingFee The fee non-exempt addresses should pay to mint a custom NFT
  /// @param _firstTokenMetadataURI The first token's metadata URI to be saved in state
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _mintingFee,
    string memory _firstTokenMetadataURI
  ) ERC721(_name, _symbol) {
    updateMintingFee(_mintingFee);
    mintNFT(_firstTokenMetadataURI);
  }

  /// @notice Toggles the boolean value of addresses to be exempt from minting fee
  /// @param _addresses The addresses that will have their exemption toggled
  /// Note This function can toggle true -> false and false -> true for various
  /// addresses in the same array within the same transaction
  function toggleExemptAddresses(address[] memory _addresses)
    external
    onlyOwner
  {
    require(_addresses.length > 0, "GimmeToken: invalid addresses");

    for (uint256 i = 0; i < _addresses.length; i++) {
      exemptAddresses[_addresses[i]] = !exemptAddresses[_addresses[i]];

      if (exemptAddresses[_addresses[i]]) {
        emit AddExemptAddress(_addresses[i]);
      } else {
        emit RemoveExemptAddress(_addresses[i]);
      }
    }
  }

  /// @notice Mints a new custom NFT with a dynamic metadata URL
  /// @param _newTokenMetadataURI The URI to be assigned to the new token
  /// @dev The token metadata URL should load in JSON in the following schema:
  /// https://docs.opensea.io/docs/metadata-standards
  function mintNFT(string memory _newTokenMetadataURI)
    public
    payable
    isMinimumFeeOrExemptAddress
  {
    _safeMint(msg.sender, newTokenID);
    emit MintToken(msg.sender, newTokenID);

    updateTokenURI(newTokenID, _newTokenMetadataURI);
    newTokenID += 1;
  }

  /// @notice Mins a new custom NFT with static token metadata
  /// @param _newTokenMetadata The static metadata object for the token
  /// @dev The token metadata schema should follow these instructions:
  /// https://docs.opensea.io/docs/metadata-standards
  function mintNFT(TokenMetadata memory _newTokenMetadata)
    public
    payable
    isMinimumFeeOrExemptAddress
  {
    _safeMint(msg.sender, newTokenID);
    emit MintToken(msg.sender, newTokenID);

    updateTokenURI(newTokenID, _newTokenMetadata);
    newTokenID += 1;
  }

  /// @notice Allows the owner of any NFT to update the URL for that token's URI
  /// @param _tokenID The token ID that will have its URI updated
  /// @param _newTokenMetadataURI The metadata URI to update for the token ID
  function updateTokenURI(uint256 _tokenID, string memory _newTokenMetadataURI)
    public
    isTokenOwner(_tokenID)
  {
    _setTokenURI(_tokenID, _newTokenMetadataURI);
    emit UpdateTokenURI(msg.sender, _tokenID);
  }

  /// @notice Allows the owner of any token to assign a static metadata object
  /// @param _tokenID The token ID that will have its URI updated
  /// @param _newTokenMetadata The metadata object to be parsed into base 64
  /// encoding and stored onchain
  function updateTokenURI(
    uint256 _tokenID,
    TokenMetadata memory _newTokenMetadata
  ) public isTokenOwner(_tokenID) {
    _setTokenURI(_tokenID, _buildTokenURI(_newTokenMetadata));
    emit UpdateTokenURI(msg.sender, _tokenID);
  }

  /// @notice Builds a static token URI in base 64 encoding to be saved in state
  /// @param _metadata The metadata to be converted to JSON and base 64 encoded
  function _buildTokenURI(TokenMetadata memory _metadata)
    internal
    pure
    returns (string memory)
  {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            bytes(
              string(
                abi.encodePacked(
                  '{"name": "',
                  _metadata.name,
                  '", "description": "',
                  _metadata.description,
                  '", "image": "',
                  _metadata.image,
                  '", "attributes": ',
                  _buildAttributesJSON(_metadata.attributes),
                  "}"
                )
              )
            )
          )
        )
      );
  }

  /// @notice Constructs a static JSON-compliant string for attributes metadata
  /// @param _attributes The attributes array to be converted into a string
  /// @return string The attributes string
  function _buildAttributesJSON(Attribute[] memory _attributes)
    internal
    pure
    returns (string memory)
  {
    string memory attributesJSON = "[";

    if (_attributes.length <= 0) {
      return string(abi.encodePacked(attributesJSON, "]"));
    }

    for (uint256 i = 0; i < _attributes.length; i++) {
      string memory comma = "";

      if (i > 0) {
        comma = ",";
      }

      attributesJSON = string(
        abi.encodePacked(
          attributesJSON,
          comma,
          '{"trait_type": "',
          _attributes[i].trait_type,
          '", "value": "',
          _attributes[i].value,
          '"}'
        )
      );
    }

    return string(abi.encodePacked(attributesJSON, "]"));
  }

  /// @notice Allows the contract owner to update the minting fee value
  /// @param _newMintingFee The new minting fee to be saved in state
  /// Note The minting fee must be greater-than-or-equal-to 0
  function updateMintingFee(uint256 _newMintingFee) public onlyOwner {
    mintingFee = _newMintingFee;
  }

  /// @notice Allows the owner of the contract to withdraw all ether in it
  function withdrawAllEther() external onlyOwner {
    uint256 addressBalance = address(this).balance;

    require(address(this).balance > 0, "GimmeToken: no ether in contract");

    (bool success, ) = msg.sender.call{ value: addressBalance }("");
    require(success, "GimmeToken: withdraw failed");
    emit Withdraw(msg.sender, address(this), addressBalance);
  }
}
