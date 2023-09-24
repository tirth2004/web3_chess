// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract GameContract is ReentrancyGuard {
  using SafeMath for uint256;

  using Counters for Counters.Counter;
  Counters.Counter private _gameIds;

  event GetGameOutcome(GameOutcome);

  enum GameStatus {
    started,
    ongoing,
    ended
  }

  enum GameOutcome {
    draw,
    playerOne,
    playerTwo
  }
  struct Game {
    address playerOne;
    address playerTwo;
    uint256 stake;
    string gameCode;
    GameStatus status;
    GameOutcome outcome;
  }

  mapping(address => uint256) public playerBalances;
  mapping(string => Game) public games;
  mapping(GameOutcome => string) public outcomes;

  constructor() {
    outcomes[GameOutcome.draw] = "draw";
    outcomes[GameOutcome.playerOne] = "playerOne";
    outcomes[GameOutcome.playerTwo] = "playerTwo";
  }

  function compareStrings(string memory a, string memory b)
    public
    view
    returns (bool)
  {
    return (keccak256(abi.encodePacked((a))) ==
      keccak256(abi.encodePacked((b))));
  }

  function startGame(
    string memory gameCode,
    address opponent,
    uint256 stake
  ) external payable{
    require(
      stake <= playerBalances[msg.sender]
    );

    playerBalances[msg.sender] = playerBalances[msg.sender].sub(stake);

    games[gameCode].gameCode = gameCode;
    games[gameCode].playerOne = msg.sender;
    games[gameCode].playerTwo = opponent;
    games[gameCode].stake = stake;
    games[gameCode].status = GameStatus.started;
  }


  function participateGame(string memory gameCode) external {
    require(
      games[gameCode].playerTwo == msg.sender
    );
    require(
      games[gameCode].status == GameStatus.started
    );

    uint256 gameStake = games[gameCode].stake;
    require(
      gameStake <= playerBalances[msg.sender]
    );

    playerBalances[msg.sender] = playerBalances[msg.sender].sub(gameStake);
    games[gameCode].status = GameStatus.ongoing;
  }

 
  function endGame(
    string memory gameCode,
    string memory result
  ) external {
    require(
      games[gameCode].status == GameStatus.ongoing
    );
    require(
      compareStrings(result, outcomes[GameOutcome.playerTwo]) ||
        compareStrings(result, outcomes[GameOutcome.draw]) ||
        compareStrings(result, outcomes[GameOutcome.playerOne])
    );

    games[gameCode].status = GameStatus.ended;

    address playerOne = games[gameCode].playerOne;
    address playerTwo = games[gameCode].playerTwo;

    uint256 gameStake = games[gameCode].stake;

    if (compareStrings(result, outcomes[GameOutcome.draw])) {
      games[gameCode].outcome = GameOutcome.draw;
      playerBalances[playerOne] = playerBalances[playerOne].add(gameStake);
      playerBalances[playerTwo] = playerBalances[playerTwo].add(gameStake);
    } else if (compareStrings(result, outcomes[GameOutcome.playerOne])) {
      games[gameCode].outcome = GameOutcome.playerOne;
      uint256 totalStakeWon = gameStake.mul(2);
      playerBalances[playerOne] = playerBalances[playerOne].add(totalStakeWon);
    } else if (compareStrings(result, outcomes[GameOutcome.playerTwo])) {
      games[gameCode].outcome = GameOutcome.playerTwo;
      uint256 totalStakeWon = gameStake.mul(2);
      playerBalances[playerTwo] = playerBalances[playerTwo].add(totalStakeWon);
    }
  }

  function withdraw() external nonReentrant {
    uint256 playerBalance = playerBalances[msg.sender];
    require(playerBalance > 0, "No balance");

    playerBalances[msg.sender] = 0;
    (bool success, ) = address(msg.sender).call{value: playerBalance}("");
    require(success, "withdraw failed to send");
  }

  function deposit() external payable {
    require(msg.value > 0, "Please Deposit a valid amount greater than zero");
    playerBalances[msg.sender] = playerBalances[msg.sender].add(msg.value);
  }
  
}