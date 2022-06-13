// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "./IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./IHeroes.sol";
import "./Traits.sol";

contract Cave is Ownable, IERC721Receiver, Pausable {

  // struct to store a stake's token, owner, and earning values
  struct Stake {
    uint16 tokenId;
    uint80 value;
    address owner;
  }

  event TokenStaked(address owner, uint256 tokenId, uint256 value);
  event HeroClaimed(uint256 tokenId, uint256 earned, bool unstaked);

  // reference to the Woolf NFT contract
  IHeroes heroes;

  // maps tokenId to stake

  mapping(uint256 => Stake) public theCave; 

  mapping(address => Stake[]) public theCaveV2; 

  uint256 public constant MINIMUM_TO_EXIT = 0 days;

  // number of Sheep staked in the theCave
  uint256 public totalExplorers;

  // emergency rescue to allow unstaking without any checks
  bool public rescueEnabled = false;

  /**
   * @param _heroes reference to the Heroes NFT contract
   */
  constructor(address _heroes) { 
    heroes = IHeroes(_heroes);
  }

  /** STAKING */

  /**
   * adds exploring NFT Heroes to the theCave
   * @param account the address of the staker
   * @param tokenIds the IDs of the NFT Heroes
   */
  function addManyToTheCave(address account, uint16[] calldata tokenIds) external {
    require(account == _msgSender() || _msgSender() == address(heroes), "DONT GIVE YOUR TOKENS AWAY");
    for (uint i = 0; i < tokenIds.length; i++) {
      if (_msgSender() != address(heroes)) { // dont do this step if its a mint + stake
        require(heroes.ownerOf(tokenIds[i]) == _msgSender(), "AINT YO TOKEN");
        heroes.transferFrom(_msgSender(), address(this), tokenIds[i]);
      } else if (tokenIds[i] == 0) {
        continue; // there may be gaps in the array for stolen tokens
      }

     _addExplorersTotheCave(account, tokenIds[i]);
    }
  }

  /**
   * adds a single Sheep to the theCave
   * @param account the address of the staker
   * @param tokenId the ID of the Sheep to add to the theCave
   */
  function _addExplorersTotheCave(address account, uint256 tokenId) internal whenNotPaused {
    theCave[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(block.timestamp)
    });

    theCaveV2[account].push(Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: uint80(block.timestamp)
    }));

    totalExplorers += 1;
    emit TokenStaked(account, tokenId, block.timestamp);
  }

  
  /** CLAIMING / UNSTAKING */

  /**
   * realize $WOOL earnings and optionally unstake tokens from the theCave / Pack
   * to unstake a Sheep it will require it has 2 days worth of $WOOL unclaimed
   * @param tokenIds the IDs of the tokens to claim earnings from
   * @param unstake whether or not to unstake ALL of the tokens listed in tokenIds
   */
  function claimManyFromtheCaveAndPack(uint16[] calldata tokenIds, bool unstake) external whenNotPaused {
    uint256 owed = 0;
    for (uint i = 0; i < tokenIds.length; i++) {
        owed += _claimExplorersFromTheCave(tokenIds[i], unstake);
    }
    if (owed == 0) return;
        // gold.mint(_msgSender(), owed);
  }

  /**
   * realize $WOOL earnings for a single Sheep and optionally unstake it
   * if not unstaking, pay a 20% tax to the staked Wolves
   * if unstaking, there is a 50% chance all $WOOL is stolen
   * @param tokenId the ID of the Sheep to claim earnings from
   * @param unstake whether or not to unstake the Sheep
   * @return owed - the amount of $WOOL earned
   */
  function _claimExplorersFromTheCave(uint256 tokenId, bool unstake) internal returns (uint256 owed) {
    Stake memory stake = theCave[tokenId];
    require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
    // require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT), "GONNA BE COLD WITHOUT TWO DAY'S WOOL");
    if (unstake) {
      heroes.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back Sheep
      delete theCave[tokenId];
      totalExplorers -= 1;
    } else {
      theCave[tokenId] = Stake({
        owner: _msgSender(),
        tokenId: uint16(tokenId),
        value: uint80(block.timestamp)
      }); // reset stake
    }
    emit HeroClaimed(tokenId, owed, unstake);
  }

 
  /**
   * emergency unstake tokens
   * @param tokenIds the IDs of the tokens to claim earnings from
   */
  function rescue(uint256[] calldata tokenIds) external {
    require(rescueEnabled, "RESCUE DISABLED");
    uint256 tokenId;
    Stake memory stake;
    for (uint i = 0; i < tokenIds.length; i++) {
        tokenId = tokenIds[i];
        stake = theCave[tokenId];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        heroes.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back Sheep
        delete theCave[tokenId];
        totalExplorers -= 1;
        emit HeroClaimed(tokenId, 0, true);
      
    }
  }

  /** ADMIN */

  /**
   * allows owner to enable "rescue mode"
   * simplifies accounting, prioritizes tokens out in emergency
   */
  function setRescueEnabled(bool _enabled) external onlyOwner {
    rescueEnabled = _enabled;
  }

  /**
   * enables owner to pause / unpause minting
   */
  function setPaused(bool _paused) external onlyOwner {
    if (_paused) _pause();
    else _unpause();
  }

  /** READ ONLY */

  /**
   * generates a pseudorandom number
   * @param seed a value ensure different outcomes for different sources in the same block
   * @return a pseudorandom value
   */
  function random(uint256 seed) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(
      tx.origin,
      blockhash(block.number - 1),
      block.timestamp,
      seed
    )));
  }

  function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
      require(from == address(0x0), "Cannot send tokens to theCave directly");
      return IERC721Receiver.onERC721Received.selector;
    }

  
}