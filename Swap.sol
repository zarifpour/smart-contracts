//SPDX-License-Identifier: mit
pragma solidity ^0.8.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Snowslide is ERC20 {
    function mintToken(address _contract) external returns (bool);
}

contract Wrapper {
    
    address constant public TOKEN_A = 0x261965375CA7EE921e7eC11Aa94F2102Cb2B0799; // HillCoin
    address constant public TOKEN_B = 0x65aC48bbCF2d1BF900ad787672694496fdaCd9EC; // MountainToken
    address constant public TOKEN_C = 0x57c7F9806419D548e90592643BC426fd57644D74; // Snowslide
    
    constructor() {
       Snowslide(TOKEN_C).mintToken(address(this));
    }
    
    /**
     * Convert an amount of input token_ to an equivalent amount of the output token
     *
     * @param token_ address of token to swap
     * @param amount amount of token to swap/receive
     */
    function swap(address token_, uint amount) external {
        require(token_ == TOKEN_A || token_ == TOKEN_B, "Invalid token (address).");
        
        uint256 contractBalance = Snowslide(TOKEN_C).balanceOf(address(this));
        uint256 senderBalance = ERC20(token_).balanceOf(msg.sender);
        
        require(contractBalance >= amount, "Not enough tokens in contract."); // Confirm contract has enough tokens
        require(senderBalance >= amount, "Insufficient Funds"); // Confirm user has enough tokens
        
        bool transferredToContract = ERC20(token_).transferFrom(msg.sender, address(this), amount);
        bool transferredToSender = Snowslide(TOKEN_C).transfer(msg.sender, amount);
        
        require(transferredToContract, "Token transfer failed"); // Transfer tokens from Sender -> Contract
        require(transferredToSender, "Snowslide transfer failed"); // Transfer tokens from Contract -> Sender
    }

    /**
     * Convert an amount of the output token to an equivalent amount of input token_
     *
     * @param token_ address of token to receive
     * @param amount amount of token to swap/receive
     */
    function unswap(address token_, uint amount) external {
        require(token_ == TOKEN_A || token_ == TOKEN_B, "Invalid token (address).");
        
        uint256 contractBalance = ERC20(token_).balanceOf(address(this));
        uint256 senderBalance = Snowslide(TOKEN_C).balanceOf(msg.sender);
        
        require(contractBalance >= amount, "Not enough tokens in contract."); // Confirm contract has enough tokens
        require(senderBalance >= amount, "Insufficient Funds"); // Confirm user has enough tokens
        
        bool transferredToContract = Snowslide(TOKEN_C).transferFrom(msg.sender, address(this), amount);
        bool transferredToSender = ERC20(token_).transfer(msg.sender, amount);
        
        require(transferredToContract, "Snowslide transfer failed"); // Transfer tokens from Sender -> Contract
        require(transferredToSender, "Token transfer failed"); // Transfer tokens from Contract -> Sender
    }
}
