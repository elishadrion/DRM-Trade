pragma solidity ^0.7.4;

abstract contract RaribleUserToken {
    function balanceOf(address _owner, uint256 _id) virtual external view returns(uint256);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata data) virtual external;
    function creators(uint256 _id) virtual public view returns(address);
}

contract DRMTrade {
    
    RaribleUserToken rut = RaribleUserToken(0x44d6E8933F8271abcF253C72f9eD7e0e4C0323B3);
    mapping (uint256 => Trade) trades;
    uint256 tradeId;
    
    event CreateTrade(address creator, uint256 fromTokenId, uint256 toTokenId, uint256 tradeId);
    event DeleteTrade(address creator, uint256 tradeId);
    event AcceptTrade(address accepter, uint256 tradeId);
    
    struct Trade {
        address creator;
        uint256 fromTokenId;
        uint256 toTokenId;
    }
    
    constructor() {
        
    }
    
    function createTrade(uint256 _fromTokenId, uint256 _toTokenId) public {
       require(rut.balanceOf(msg.sender, _fromTokenId) > 0, "Don't rug me.");
       require(rut.creators(_toTokenId) != address(0));
       Trade memory trade = Trade(msg.sender, _fromTokenId, _toTokenId);
       tradeId = tradeId + 1;
       trades[tradeId] = trade;
       rut.safeTransferFrom(msg.sender, address(this), _fromTokenId, 1, "");
       emit CreateTrade(msg.sender, _fromTokenId, _toTokenId, tradeId);
    }
    
    function deleteTrade(uint256 _tradeId) public {
        require(trades[_tradeId].creator == msg.sender, "Only trade creator can delete it");
        rut.safeTransferFrom(address(this), msg.sender, trades[_tradeId].fromTokenId, 1, "");
        delete trades[_tradeId];
        emit DeleteTrade(msg.sender, _tradeId);
    }
    
    function acceptTrade(uint256 _tradeId) public {
        require(rut.balanceOf(msg.sender, trades[_tradeId].toTokenId) > 0, "Don't rug me.");
        rut.safeTransferFrom(msg.sender, trades[_tradeId].creator, trades[_tradeId].toTokenId, 1, "");
        rut.safeTransferFrom(address(this), msg.sender, trades[_tradeId].fromTokenId, 1, "");
        delete trades[_tradeId];
        emit AcceptTrade(msg.sender, _tradeId);
    }
    
}