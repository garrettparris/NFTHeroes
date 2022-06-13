  struct Traits {
    uint256 race;
    uint256 pants;
    uint256 weapon;
    uint256 shield;
    uint256 clothes;
    uint256 head;
    uint256 shoes;
    uint256 hair;
    uint256 bg;
    uint256 magic;
    uint256 strength;
    uint256 intelligence;
    uint256 stamina;
    uint256 dexterity;
    uint256 creativity;
  }

interface IHeroes {
  function CDN_ENABLED (  ) external view returns ( bool );
  function CDN_PREFIX (  ) external view returns ( string memory);
  function approve ( address to, uint256 tokenId ) external;
  function balanceOf ( address owner ) external view returns ( uint256 );
  function enableCdn ( bool value, string memory prefix ) external;
  function genSvg ( uint256 tokenId ) external view returns ( string memory);
  function genTraits ( uint256 tokenId ) external view returns ( Traits memory );
  function getApproved ( uint256 tokenId ) external view returns ( address );
  function getJsonString ( uint256 tokenId ) external view returns ( string memory);
  function getSeed ( uint256 tokenId ) external view returns ( uint256 );
  function getSeedPart ( uint256 tokenId, uint256 num ) external view returns ( uint16 );
  function isApprovedForAll ( address owner, address operator ) external view returns ( bool );
  function merlinMint ( uint256 amount ) external;
  function mint ( uint256 amount ) external;
  function mintCustom ( string memory tokenUriHash, address to ) external;
  function name (  ) external view returns ( string memory);
  function owner (  ) external view returns ( address );
  function ownerOf ( uint256 tokenId ) external view returns ( address );
  function renounceOwnership (  ) external;
  function safeTransferFrom ( address from, address to, uint256 tokenId ) external;
  function safeTransferFrom ( address from, address to, uint256 tokenId, bytes memory _data ) external;
  function setApprovalForAll ( address operator, bool approved ) external;
  function setBaseUri ( string memory baseUri ) external;
  function supportsInterface ( bytes4 interfaceId ) external view returns ( bool );
  function symbol (  ) external view returns ( string memory );
  function tokenByIndex ( uint256 index ) external view returns ( uint256 );
  function tokenIdToSeed ( uint256 ) external view returns ( uint256 );
  function tokenOfOwnerByIndex ( address owner, uint256 index ) external view returns ( uint256 );
  function tokenURI ( uint256 tokenId ) external view returns ( string memory);
  function totalSupply (  ) external view returns ( uint256 );
  function transferFrom ( address from, address to, uint256 tokenId ) external;
  function transferOwnership ( address newOwner ) external;
  function updateDescription ( string memory d ) external;
  function updateSigner ( address signer ) external;
  function withdraw ( address sendTo ) external;
}
