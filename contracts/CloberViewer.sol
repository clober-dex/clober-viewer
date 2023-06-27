pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./interfaces/CloberMarketFactory.sol";
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
    CloberMarketFactory private immutable _factoryV1;
    CloberOrderNFTDeployer private immutable _orderNFTDeployer;
    uint256 private immutable _cachedChainId;

    uint128 private constant VOLATILE_A = 10000000000;
    uint128 private constant VOLATILE_R = 1001000000000000000;

    constructor(
        address factory,
        address factoryV1,
        uint256 cachedChainId
    ) PriceBook(VOLATILE_A, VOLATILE_R) {
        _factory = CloberMarketFactory(factory);
        _factoryV1 = CloberMarketFactory(factoryV1);
        _orderNFTDeployer = CloberOrderNFTDeployer(_factory.orderTokenDeployer());
        _cachedChainId = cachedChainId;
    }

    function getAllMarkets() external view returns (address[] memory markets) {
        uint256 nonceV1 = 13; //_factoryV1.nonce()
        uint256 length = _factory.nonce() + nonceV1;

        markets = new address[](length);
        unchecked {
            for (uint256 i = 0; i < nonceV1; ++i) {
                markets[i] = CloberOrderNFT(CloberMarketFactory(_factoryV1).computeTokenAddress(i)).market();
            }

            for (uint256 i = nonceV1; i < length; ++i) {
                bytes32 salt = keccak256(abi.encode(_cachedChainId, i - nonceV1));
                markets[i] = CloberOrderNFT(_orderNFTDeployer.computeTokenAddress(salt)).market();
            }
        }
    }

    function getDepthsByPriceIndex(
        address market,
        bool isBid,
        uint16 formIndex,
        uint16 toIndex
    ) public view returns (DepthInfo[] memory depths) {
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

    function getDepthsByPrice(
        address market,
        bool isBid,
        uint256 formPrice,
        uint256 toPrice
    ) external view returns (DepthInfo[] memory) {
        uint16 formIndex;
        uint16 toIndex;
        CloberMarketFactory.MarketInfo memory marketInfo = _factoryV1.getMarketInfo(market);
        if (marketInfo.marketType == CloberMarketFactory.MarketType.NONE) {
            (formIndex, ) = CloberOrderBook(market).priceToIndex(formPrice, true);
            (toIndex, ) = CloberOrderBook(market).priceToIndex(toPrice, false);
        } else if (marketInfo.marketType == CloberMarketFactory.MarketType.VOLATILE) {
            require((marketInfo.a == VOLATILE_A) && (marketInfo.factor == VOLATILE_R));
            formIndex = _volatilePriceToIndex(formPrice, true);
            toIndex = _volatilePriceToIndex(toPrice, false);
        } else {
            formIndex = _stablePriceToIndex(marketInfo.a, marketInfo.factor, formPrice, true);
            toIndex = _stablePriceToIndex(marketInfo.a, marketInfo.factor, toPrice, false);
        }

        return getDepthsByPriceIndex(market, isBid, formIndex, toIndex);
    }
}
