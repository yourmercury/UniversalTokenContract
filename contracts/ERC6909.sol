// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC6909.sol";

contract ERC6909 is IERC6909 {
    /// @dev Thrown when owner balance for id is insufficient.
    /// @param owner The address of the owner.
    /// @param id The id of the token.
    error InsufficientBalance(address owner, uint256 id);

    /// @dev Thrown when spender allowance for id is insufficient.
    /// @param spender The address of the spender.
    /// @param id The id of the token.
    error InsufficientPermission(address spender, uint256 id);

    /// @notice The total supply of each id.
    mapping(uint256 id => uint256 amount) public totalSupply;

    /// @notice Owner balance of an id.
    mapping(address owner => mapping(uint256 id => uint256 amount)) public balanceOf;

    /// @notice Spender allowance of an id.
    mapping(address owner => mapping(address spender => mapping(uint256 id => uint256 amount))) public allowance;

    /// @notice Checks if a spender is approved by an owner as an operator.
    mapping(address owner => mapping(address spender => bool)) public isOperator;

    /// @notice Transfers an amount of an id from the caller to a receiver.
    /// @param receiver The address of the receiver.
    /// @param id The id of the token.
    /// @param amount The amount of the token.
    function transfer(address receiver, uint256 id, uint256 amount) public {
        if (balanceOf[msg.sender][id] < amount) revert InsufficientBalance(msg.sender, id);
        balanceOf[msg.sender][id] -= amount;
        balanceOf[receiver][id] += amount;
        emit Transfer(msg.sender, receiver, id, amount);
    }

    /// @notice Transfers an amount of an id from a sender to a receiver.
    /// @param sender The address of the sender.
    /// @param receiver The address of the receiver.
    /// @param id The id of the token.
    /// @param amount The amount of the token.
    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) public {
        if (sender != msg.sender && !isOperator[sender][msg.sender]) {
            if (allowance[sender][msg.sender][id] < amount) {
                revert InsufficientPermission(msg.sender, id);
            }
            allowance[sender][msg.sender][id] -= amount;
        }
        if (balanceOf[sender][id] < amount) revert InsufficientBalance(sender, id);
        balanceOf[sender][id] -= amount;
        balanceOf[receiver][id] += amount;
        emit Transfer(sender, receiver, id, amount);
    }

    /// @notice Approves an amount of an id to a spender.
    /// @param spender The address of the spender.
    /// @param id The id of the token.
    /// @param amount The amount of the token.
    function approve(address spender, uint256 id, uint256 amount) public {
        allowance[msg.sender][spender][id] = amount;
        emit Approval(msg.sender, spender, id, amount);
    }

    /// @notice Sets or unsets a spender as an operator for the caller.
    /// @param spender The address of the spender.
    /// @param approved The approval status.
    function setOperator(address spender, bool approved) public {
        isOperator[msg.sender][spender] = approved;
        emit OperatorSet(msg.sender, spender, approved);
    }

    /// @notice Checks if a contract implements an interface.
    /// @param interfaceId The interface identifier, as specified in ERC-165.
    /// @return supported True if the contract implements `interfaceId` and
    function supportsInterface(bytes4 interfaceId) public pure returns (bool supported) {
        return interfaceId == type(IERC6909).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}