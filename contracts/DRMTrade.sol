pragma solidity ^0.7.4;

interface RaribleUserToken {
    function balanceOf(address _owner, uint256 _id) virtual external view returns(uint256);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata data) virtual external;
    function creators(uint256 _id) virtual public view returns(address);
}

contract DRMTrade {

    RaribleUserToken public rut = RaribleUserToken(0x44d6E8933F8271abcF253C72f9eD7e0e4C0323B3);
    mapping (uint256 => Trade) public trades;
    uint256 public tradeID;

    event CreateTrade(address creator, uint256 fromTokenID, uint256 toTokenID, uint256 tradeID);
    event DeleteTrade(address creator, uint256 fromTokenID, uint256 toTokenID, uint256 tradeID);
    event AcceptTrade(address accepter, uint256 fromTokenID, uint256 toTokenID, uint256 tradeID);

    struct Trade {
        address creator;
        uint256 fromTokenID;
        uint256 toTokenID;
    }

    constructor() {}

    function createTrade(uint256 _fromTokenID, uint256 _toTokenID) public {
       require(rut.balanceOf(msg.sender, _fromTokenID) > 0, "CREATE_TRADE: EMPTY BALANCE");
       require(rut.creators(_toTokenID) != address(0));
       Trade memory trade = Trade(msg.sender, _fromTokenID, _toTokenID);
       tradeID++;
       trades[tradeID] = trade;
       rut.safeTransferFrom(msg.sender, address(this), _fromTokenID, 1, 0x0);
       emit CreateTrade(msg.sender, _fromTokenID, _toTokenID, tradeID);
    }

    function deleteTrade(uint256 _tradeID) public {
        require(trades[_tradeID].creator == msg.sender, "DELETE_TRADE: NOT THE OWNER");
        Trade memory trade = trades[_tradeID];
        rut.safeTransferFrom(address(this), msg.sender, trades[_tradeID].fromTokenID, 1, 0x0);
        delete trades[_tradeID];
        emit DeleteTrade(msg.sender, trade.fromTokenID, trade.toTokenID, _tradeID);
    }

    function acceptTrade(uint256 _tradeID) public {
        require(rut.balanceOf(msg.sender, trades[_tradeID].toTokenID) > 0, "CREATE_TRADE: EMPTY BALANCE");
        Trade memory trade = trades[_tradeID];
        rut.safeTransferFrom(msg.sender, trades[_tradeID].creator, trades[_tradeID].toTokenID, 1, 0x0);
        rut.safeTransferFrom(address(this), msg.sender, trades[_tradeID].fromTokenID, 1, 0x0);
        delete trades[_tradeID];
        emit AcceptTrade(msg.sender, trade.fromTokenID, trade.toTokenID, _tradeID);
    }

}
