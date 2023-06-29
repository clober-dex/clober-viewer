// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/CloberMarketFactory.sol";
import "./interfaces/CloberMarketFactoryV1.sol";
import "./interfaces/CloberOrderBook.sol";
import "./interfaces/CloberPriceBook.sol";
import "./interfaces/CloberOrderNFT.sol";
import "./interfaces/CloberOrderNFTDeployer.sol";
import "./PriceBook.sol";

contract CloberViewer is PriceBook {
    struct DepthInfo {
        uint256 price;
        uint256 priceIndex;
        uint256 quoteAmount;
        uint256 baseAmount;
    }

    CloberMarketFactory private immutable _factory;
    CloberMarketFactoryV1 private immutable _factoryV1;
    CloberOrderNFTDeployer private immutable _orderNFTDeployer;
    uint256 private immutable _cachedChainId;
    uint256 private immutable _v1PoolCount;

    uint128 private constant VOLATILE_A = 10000000000;
    uint128 private constant VOLATILE_R = 1001000000000000000;

    constructor(
        address factory,
        address factoryV1,
        uint256 cachedChainId,
        uint256 v1PoolCount
    ) PriceBook(VOLATILE_A, VOLATILE_R) {
        require(factory != address(0) || factoryV1 != address(0));
        _factory = CloberMarketFactory(factory);
        _factoryV1 = CloberMarketFactoryV1(factoryV1);
        _orderNFTDeployer = factory == address(0)
            ? CloberOrderNFTDeployer(address(0))
            : CloberOrderNFTDeployer(_factory.orderTokenDeployer());
        _cachedChainId = cachedChainId;
        if (factoryV1 == address(0)) v1PoolCount = 0;
        _v1PoolCount = v1PoolCount;
    }

    function getAllMarkets() external view returns (address[] memory markets) {
        unchecked {
            uint256 length;
            if (address(_factory) == address(0)) {
                length = _factoryV1.nonce();
                markets = new address[](length);
                for (uint256 i = 0; i < length; ++i) {
                    markets[i] = CloberOrderNFT(_factoryV1.computeTokenAddress(i)).market();
                }
            } else {
                length = _factory.nonce() + _v1PoolCount;

                markets = new address[](length);
                for (uint256 i = 0; i < _v1PoolCount; ++i) {
                    markets[i] = CloberOrderNFT(_factoryV1.computeTokenAddress(i)).market();
                }

                for (uint256 i = _v1PoolCount; i < length; ++i) {
                    bytes32 salt = keccak256(abi.encode(_cachedChainId, i - _v1PoolCount));
                    markets[i] = CloberOrderNFT(_orderNFTDeployer.computeTokenAddress(salt)).market();
                }
            }
        }
    }

    function getDepthsByPriceIndex(
        address market,
        bool isBid,
        uint16 fromIndex,
        uint16 toIndex
    ) public view returns (DepthInfo[] memory depths) {
        depths = new DepthInfo[](toIndex - fromIndex + 1);

        unchecked {
            for (uint16 index = fromIndex; index <= toIndex; ++index) {
                uint256 i = index - fromIndex;
                uint64 rawAmount = CloberOrderBook(market).getDepth(isBid, index);
                depths[i].price = CloberOrderBook(market).indexToPrice(index);
                depths[i].priceIndex = index;
                depths[i].quoteAmount = CloberOrderBook(market).rawToQuote(rawAmount);
                depths[i].baseAmount = CloberOrderBook(market).rawToBase(rawAmount, index, false);
            }
        }
    }

    function getDepthsByPrice(
        address market,
        bool isBid,
        uint256 fromPrice,
        uint256 toPrice
    ) external view returns (DepthInfo[] memory) {
        uint16 fromIndex;
        uint16 toIndex;
        CloberMarketFactoryV1.MarketInfo memory marketInfo;
        if (address(_factoryV1) != address(0)) marketInfo = _factoryV1.getMarketInfo(market);
        if (marketInfo.marketType == CloberMarketFactoryV1.MarketType.NONE) {
            (fromIndex, ) = CloberOrderBook(market).priceToIndex(fromPrice, true);
            (toIndex, ) = CloberOrderBook(market).priceToIndex(toPrice, false);
        } else if (marketInfo.marketType == CloberMarketFactoryV1.MarketType.VOLATILE) {
            require((marketInfo.a == VOLATILE_A) && (marketInfo.factor == VOLATILE_R));
            fromIndex = _volatilePriceToIndex(fromPrice, true);
            toIndex = _volatilePriceToIndex(toPrice, false);
        } else {
            fromIndex = _stablePriceToIndex(marketInfo.a, marketInfo.factor, fromPrice, true);
            toIndex = _stablePriceToIndex(marketInfo.a, marketInfo.factor, toPrice, false);
        }

        return getDepthsByPriceIndex(market, isBid, fromIndex, toIndex);
    }
}
