// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IUniswapV2Factory.sol";
import "./UniswapV2Pair.sol";

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;//Receives fees (0.3%) when turned on(ie when not addres(0))
    address public feeToSetter;// owner or admin

    mapping(address => mapping(address => address)) public getPair;// tracks all the pairs, created

    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair,uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA,address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB? (tokenA, tokenB): (tokenB, tokenA);//Less number of tokens --> becomes token0
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0),"UniswapV2: PAIR_EXISTS"); // '..==address(0)', means this pair has not been created before
        
        bytes memory bytecode = type(UniswapV2Pair).creationCode;//? "creationCode" is a property that returns the bytecode required to deploy an instance of the "UniswapV2Pair" contract. With the help of the bytecode n instance of the "UniswapV2Pair" contract is created,  which is used in the "createPair" function to deploy a new instance of the "UniswapV2Pair" contract. 

        bytes32 salt = keccak256(abi.encodePacked(token0, token1));//? provents front-running

        assembly {pair := create2(0, add(bytecode, 32), mload(bytecode), salt)}//? The "create2" opcode is used to create a new contract with a deterministic address. The first argument, "0", is the value that is sent with the contract creation. The second argument is the size of the bytecode, in this case "add(bytecode, 32)" is the size of the "bytecode" plus 32 bytes. The third argument is the bytecode of the contract being created, which is loaded from memory using the "mload" opcode. The fourth argument is the salt, which is a hash of the token addresses. The address of the newly created contract is stored in the "pair" variable.

        IUniswapV2Pair(pair).initialize(token0, token1);//?The second line calls the initialize function on the newly deployed contract to initialize it with the specified token addresses

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");//Only  the contract owner can set where the fees will go
        feeTo = _feeTo;
    }

//To change contract ownership, only owner has the access
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
