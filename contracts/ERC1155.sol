// SPDX-License-Identifier: GPL-3.0

pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract NFT is ERC1155, ERC1155Burnable {

    uint public constant STK = 0;

    constructor() ERC1155(""){
        _mint(msg.sender,STK,10**9,"");
    }

    function setUri(string memory uri) public {
        _setURI(uri);
    }

    function mint(address account,uint id,uint amount)public {
        _mint(account,id ,amount,"");
    }
}