// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Base64 } from "./libraries/Base64.sol";

/// @title ProfilePicture
/// @notice Creates a modifiable NFT for using as a profile picture
/// @author Nathan Thomas
contract ProfilePicture is Ownable, ERC721URIStorage {
  using Strings for uint256;

  uint256 public newTokenID = 0;
  uint256 public mintingFee;

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
    bool isExemptAddress = exemptAddresses[msg.sender] || owner() == msg.sender;

    require(
      isExemptAddress || msg.value >= mintingFee,
      string(
        abi.encodePacked(
          "ProfilePicture: include minimum fee of ",
          (mintingFee / 1 ether).toString(),
          " ether"
        )
      )
    );
    _;
  }

  modifier isTokenOwner(uint256 _tokenID) {
    require(
      ownerOf(_tokenID) == msg.sender,
      "ProfilePicture: owner must update token URI"
    );
    _;
  }

  /// @notice Instantiates a new contract for minting custom personal profile pictures
  /// @param _name The name for the profile picture NFT collection
  /// @param _symbol The symbol to be used for the profile picture NFT collection
  /// @param _mintingFee The fee non-exempt addresses should pay to mint a profile picture
  /// @param _firstTokenMetadataURI The first token's metadata URI to be saved in state
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _mintingFee,
    string memory _firstTokenMetadataURI
  ) ERC721(_name, _symbol) {
    mintingFee = _mintingFee;
    mintNFT(_firstTokenMetadataURI);
  }

  /// @notice Adds an exempt address which will not be charged minting fees
  /// @param _address The address that will be exempt from minting fees
  function addExemptAddress(address _address) public onlyOwner {
    exemptAddresses[_address] = true;
    emit AddExemptAddress(_address);
  }

  /// @notice Removes an exempt address which will now have to pay minting fees
  /// @param _address The address to be removed from fee exemption
  function removeExemptAddress(address _address) public onlyOwner {
    exemptAddresses[_address] = false;
    emit RemoveExemptAddress(_address);
  }

  /// @notice Mints a new profile picture NFT with a dynamic metadata URL
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

  /// @notice Mins a new profile picture NFT with static token metadata
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

  /// @notice Allows the owner of any token to update the URL for that token's URI
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

  function _buildTokenURI(TokenMetadata memory _metadata)
    internal
    pure
    returns (string memory)
  {
    string memory json = Base64.encode(
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
            _buildMetadataAttributes(_metadata.attributes),
            "}"
          )
        )
      )
    );

    string memory tokenURI = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return tokenURI;
  }

  /// @notice Constructs a static JSON-compliant string for metadata attributes
  /// @param _attributes The attributes array to be converted into a string
  /// @return string The attributes string
  function _buildMetadataAttributes(Attribute[] memory _attributes)
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

      string memory attribute = string(
        abi.encodePacked(
          '{"trait_type": "',
          _attributes[i].trait_type,
          '", "value": "',
          _attributes[i].value,
          '"}'
        )
      );

      attributesJSON = string(
        abi.encodePacked(attributesJSON, comma, attribute)
      );
    }

    return string(abi.encodePacked(attributesJSON, "]"));
  }

  /// @notice Allows the contract owner to update the minting fee value
  /// @param _newMintingFee The new minting fee to be saved in state
  /// Note The minting fee must be greater-than-or-equal-to 0
  function updateMintingFee(uint256 _newMintingFee) public onlyOwner {
    require(_newMintingFee >= 0, "ProfilePicture: must be valid fee");
    mintingFee = _newMintingFee;
  }

  /// @notice Allows the owner of the contract to withdraw all ether in it
  function withdrawAllEther() external onlyOwner {
    uint256 addressBalance = address(this).balance;

    require(address(this).balance > 0, "ProfilePicture: no ether in contract");

    (bool success, ) = msg.sender.call{ value: addressBalance }("");
    require(success, "ProfilePicture: withdraw failed");
    emit Withdraw(msg.sender, address(this), addressBalance);
  }
}
