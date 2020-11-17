pragma solidity ^0.7.4;

import "./IERC1155.sol";


contract SwapERC1155 {
    IERC1155 public NFTContract;
    mapping (uint256 => Trade) public trades;
    uint256 public tradeID;

    event CreateTrade(address creator, uint256[] fromTokenID, uint256[] toTokenID, uint256 tradeID);
    event DeleteTrade(address creator, uint256[] fromTokenID, uint256[] toTokenID, uint256 tradeID);
    event AcceptTrade(address accepter, uint256[] fromTokenID, uint256[] toTokenID, uint256 tradeID);

    struct Trade {
        address creator;
        uint256[] fromTokenIDs;
        uint256[] toTokenIDs;
    }

    constructor(address _address) {
        NFTContract = IERC1155(_address);
    }

    function createTrade(uint256[] calldata _fromTokenIDs, uint256[] calldata _toTokenIDs) public {
        for(uint i = 0; i < _fromTokenIDs.length; i++) {
            require(NFTContract.balanceOf(msg.sender, _fromTokenIDs[i]) > 0, "CREATE_TRADE: EMPTY BALANCE");
        }
        Trade memory trade = Trade(msg.sender, _fromTokenIDs, _toTokenIDs);
        tradeID++;
        trades[tradeID] = trade;
        for(uint i = 0; i < _fromTokenIDs.length; i++) {
            NFTContract.safeTransferFrom(msg.sender, address(this), _fromTokenIDs[i], 1, "");
        }
        emit CreateTrade(msg.sender, _fromTokenIDs, _toTokenIDs, tradeID);
    }

    function deleteTrade(uint256 _tradeID) public {
        require(trades[_tradeID].creator == msg.sender, "DELETE_TRADE: NOT THE OWNER");
        Trade memory trade = trades[_tradeID];
        for(uint i = 0; i < trade.fromTokenIDs.length; i++) {
            NFTContract.safeTransferFrom(address(this), msg.sender, trade.fromTokenIDs[i], 1, "");
        }
        delete trades[_tradeID];
        emit DeleteTrade(msg.sender, trade.fromTokenIDs, trade.toTokenIDs, _tradeID);
    }

    function acceptTrade(uint256 _tradeID) public {
        Trade memory trade = trades[_tradeID];
        for(uint i = 0; i < trade.toTokenIDs.length; i++) {
            require(NFTContract.balanceOf(msg.sender, trade.toTokenIDs[i]) > 0, "ACCEPT_TRADE: EMPTY BALANCE");
            NFTContract.safeTransferFrom(msg.sender, trade.creator, trade.toTokenIDs[i], 1, "");
        }
        for (uint i = 0; i < trade.fromTokenIDs.length; i++) {
            NFTContract.safeTransferFrom(address(this), msg.sender, trade.fromTokenIDs[i], 1, "");
        }
        delete trades[_tradeID];
        emit AcceptTrade(msg.sender, trade.fromTokenIDs, trade.toTokenIDs, _tradeID);
    }

}
