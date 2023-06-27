pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./interfaces/CloberMarketFactory.sol";
import "./interfaces/CloberOrderBook.sol";
import "./interfaces/CloberOrderNFT.sol";
import "./interfaces/CloberOrderNFTDeployer.sol";

contract CloberViewer {
    struct DepthInfo {
        uint256 price;
        uint256 priceIndex;
        uint256 quoteAmount;
        uint256 baseAmount;
    }

    CloberMarketFactory private _factory;
    CloberOrderNFTDeployer private _orderNFTDeployer;
    uint256 private _cachedChainId;

    constructor(
        address factory,
        address orderNFTDeployer,
        uint256 cachedChainId
    ) {
        _factory = CloberMarketFactory(factory);
        _orderNFTDeployer = CloberOrderNFTDeployer(orderNFTDeployer);
        _cachedChainId = cachedChainId;
    }

    function getAllMarkets() external view returns (address[] memory markets) {
        uint256 length = _factory.nonce();

        markets = new address[](length);

        for (uint256 i = 0; i < length; ++i) {
            bytes32 salt = keccak256(abi.encode(_cachedChainId, i));
            markets[i] = CloberOrderNFT(_orderNFTDeployer.computeTokenAddress(salt)).market();
        }
    }

    function getDepths(
        address market,
        bool isBid,
        uint256 formPrice,
        uint256 toPrice
    ) external view returns (DepthInfo[] memory depths) {
        (uint16 formIndex, ) = CloberOrderBook(market).priceToIndex(formPrice, true);
        (uint16 toIndex, ) = CloberOrderBook(market).priceToIndex(toPrice, false);

        depths = new DepthInfo[](toIndex - formIndex + 1);

        unchecked {
            for (uint16 index = formIndex; index <= toIndex; ++index) {
                uint256 i = index - formIndex;
                uint64 rawAmount = CloberOrderBook(market).getDepth(isBid, index);
                depths[i].price = CloberOrderBook(market).indexToPrice(index);
                depths[i].priceIndex = index;
                depths[i].quoteAmount = CloberOrderBook(market).rawToQuote(rawAmount);
                depths[i].baseAmount = CloberOrderBook(market).rawToBase(rawAmount, index, false);
            }
        }
    }
}
