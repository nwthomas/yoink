// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ProfilePicture is Ownable, ERC721URIStorage {
  using Strings for uint256;

  uint256 public newTokenID = 0;
  uint256 public mintingFee;

  mapping(address => bool) public exemptAddresses;

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

  /// @notice Mints a new profile picture NFT
  /// @param _newTokenMetadataURI The URI to be assigned to the new token
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

  /// @notice Allows the owner of any token to update that token's URI
  /// @param _tokenID The token ID that will have its URI updated
  /// @param _newTokenMetadataURI The metadata URI to update for the token ID
  function updateTokenURI(uint256 _tokenID, string memory _newTokenMetadataURI)
    public
    isTokenOwner(_tokenID)
  {
    _setTokenURI(_tokenID, _newTokenMetadataURI);
    emit UpdateTokenURI(msg.sender, _tokenID);
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
