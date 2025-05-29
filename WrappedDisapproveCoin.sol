// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// WDC contract created in 2014 at 0xABb08ab91544C560C5283f3F68B368dBc68135b5


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface DisapproveCoin {

    function coinBalanceOf(address _owner) external returns (uint256);
    function sendCoin(uint256 _amount, address _receiver) external;
}

contract DropBox is Ownable(msg.sender) {

    function collect(uint256 value, DisapproveCoin dcInt) public onlyOwner {
        dcInt.sendCoin(value, owner());
    }
}

contract WrappedDisapproveCoin is ERC20 {

    event DropBoxCreated(address indexed owner);
    event Wrapped(uint256 indexed value, address indexed owner);
    event Unwrapped(uint256 indexed value, address indexed owner);

    address constant dcAddr = 0x8494F777d13503BE928BB22b1F4ae3289E634FD3;
    DisapproveCoin constant dcInt = DisapproveCoin(dcAddr);

    mapping(address => address) public dropBoxes;

    constructor() ERC20("Wrapped DisapproveCoin", "WDC") {}

    function createDropBox() public {
        require(dropBoxes[msg.sender] == address(0), "Drop box already exists");

        dropBoxes[msg.sender] = address(new DropBox());
        
        emit DropBoxCreated(msg.sender);
    }

    function wrap(uint256 value) public {
        address dropBox = dropBoxes[msg.sender];

        require(dropBox != address(0), "You must create a drop box first"); 
        require(dcInt.coinBalanceOf(dropBox) >= value, "Not enough coins in drop box");

        DropBox(dropBox).collect(value, dcInt);
        _mint(msg.sender, value);
        
        emit Wrapped(value, msg.sender);
    }

    function unwrap(uint256 value) public {
        require(balanceOf(msg.sender) >= value, "Not enough coins to unwrap");

        dcInt.sendCoin(value, msg.sender);
        _burn(msg.sender, value);

        emit Unwrapped(value, msg.sender);
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }
}
