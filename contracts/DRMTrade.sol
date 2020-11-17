pragma solidity ^0.7.4;

interface RaribleUserToken {
    function balanceOf(address _owner, uint256 _id) external view returns(uint256);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata data) external;
    function creators(uint256 _id) external view returns(address);
}

contract DRMTrade {
    RaribleUserToken public rut = RaribleUserToken(0x44d6E8933F8271abcF253C72f9eD7e0e4C0323B3);
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

    constructor() {}

    function createTrade(uint256[] calldata _fromTokenIDs, uint256[] calldata _toTokenIDs) public {
        for(uint i = 0; i < _fromTokenIDs.length; i++) {
            require(rut.balanceOf(msg.sender, _fromTokenIDs[i]) > 0, "CREATE_TRADE: EMPTY BALANCE");
        }
        for(uint i = 0; i < _toTokenIDs.length; i++) {
            require(rut.creators(_toTokenIDs[i]) != address(0), "CREATE_TRADE: TARGET TOKENS OWNER IS 0x0");
        }
        Trade memory trade = Trade(msg.sender, _fromTokenIDs, _toTokenIDs);
        tradeID++;
        trades[tradeID] = trade;
        for(uint i = 0; i < _fromTokenIDs.length; i++) {
            rut.safeTransferFrom(msg.sender, address(this), _fromTokenIDs[i], 1, "");
        }
        emit CreateTrade(msg.sender, _fromTokenIDs, _toTokenIDs, tradeID);
    }

    function deleteTrade(uint256 _tradeID) public {
        require(trades[_tradeID].creator == msg.sender, "DELETE_TRADE: NOT THE OWNER");
        Trade memory trade = trades[_tradeID];
        for(uint i = 0; i < trade.fromTokenIDs.length; i++) {
            rut.safeTransferFrom(address(this), msg.sender, trade.fromTokenIDs[i], 1, "");
        }
        delete trades[_tradeID];
        emit DeleteTrade(msg.sender, trade.fromTokenIDs, trade.toTokenIDs, _tradeID);
    }

    function acceptTrade(uint256 _tradeID) public {
        Trade memory trade = trades[_tradeID];
        for(uint i = 0; i < trade.toTokenIDs.length; i++) {
            require(rut.balanceOf(msg.sender, trade.toTokenIDs[i]) > 0, "ACCEPT_TRADE: EMPTY BALANCE");
            rut.safeTransferFrom(msg.sender, trade.creator, trade.toTokenIDs[i], 1, "");
        }
        for (uint i = 0; i < trade.fromTokenIDs.length; i++) {
            rut.safeTransferFrom(address(this), msg.sender, trade.fromTokenIDs[i], 1, "");
        }
        delete trades[_tradeID];
        emit AcceptTrade(msg.sender, trade.fromTokenIDs, trade.toTokenIDs, _tradeID);
    }

}
