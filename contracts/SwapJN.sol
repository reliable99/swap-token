// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;
import {IERC20} from "./IERC20.sol";

contract SwapToken {
    
    IERC20 public baseToken;
    IERC20 public celoToken;
    uint256 public exchangeRate;

    event SwapBase(
        address indexed user,
        uint256 baseAmount,
        uint256 celoAmount
    );
    event SwapCelo(
        address indexed user,
        uint256 celoAmount,
        uint256 baseAmount
    );

    event TokensDeposited(
        address indexed depositor,
        uint256 baseAmount,
        uint256 celoAmount
    );

    
    constructor(address _baseToken, address _celoToken, uint256 _exchangeRate) {
        baseToken = IERC20(_baseToken);
        celoToken = IERC20(_celoToken);
        exchangeRate = _exchangeRate;
    }

    function swapBaseToCelo(uint256 _amount) public {
        require(msg.sender != address(0), "Not allowed");
        uint256 celoAmount = _amount * exchangeRate; 
        require(
            celoToken.balanceOf(address(this)) >= celoAmount,
            "Not enough Celo Token"
        ); // There should be enough token to be swapped

        require(
            baseToken.transferFrom(msg.sender, address(this), _amount),
            "Base transfer failed"
        );

        require(
            celoToken.transfer(msg.sender, celoAmount),
            "Celo transfer failed"
        );
        emit SwapBase(msg.sender, _amount, celoAmount);
    }

    function swapCeloToBase(uint256 _amount) public {
        require(msg.sender != address(0), "Not allowed");

        uint256 baseAmount = _amount / exchangeRate; // exchanging 2 Celo with 2 as exchange rate will be 2 / 2 = 1 Base
        require(
            baseToken.balanceOf(address(this)) >= baseAmount,
            "Not enough Base amount"
        ); // There should be enough token to be swapped

        require(
            celoToken.transferFrom(msg.sender, address(this), _amount),
            "Celo transfer failed"
        );

        require(
            baseToken.transfer(msg.sender, baseAmount),
            "Base transfer failed"
        );
        emit SwapCelo(msg.sender, _amount, baseAmount);
    }

    // To ensure that the contract doesn't run out of both tokens
    function depositTokens(uint256 baseAmount, uint256 celoAmount) public {
        baseToken.transferFrom(msg.sender, address(this), baseAmount);
        celoToken.transferFrom(msg.sender, address(this), celoAmount);

        emit TokensDeposited(msg.sender, baseAmount, celoAmount);
    }
}

