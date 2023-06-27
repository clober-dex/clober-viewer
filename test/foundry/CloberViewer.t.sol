//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../contracts/CloberViewer.sol";

contract CloberViewerTest is Test {
    string constant URL = "https://arbitrum.public-rpc.com";
    address constant CLOBER_FACTORY = 0x24aC0938C010Fb520F1068e96d78E0458855111D;
    address constant CLOBER_FACTORY_V1 = 0x93A43391978BFC0bc708d5f55b0Abe7A9ede1B91;
    uint256 arbitrum;
    CloberViewer viewer;

    function setUp() public {
        arbitrum = vm.createFork(URL);
        vm.selectFork(arbitrum);
        assertEq(vm.activeFork(), arbitrum);
        vm.rollFork(105060000);
        viewer = new CloberViewer(CLOBER_FACTORY, CLOBER_FACTORY_V1, 42161);
    }

    function testGetAllMarket() public {
        address[] memory markets = viewer.getAllMarkets();
        assertEq(markets.length, 14);

        assertEq(markets[0], 0xC3c5316AE6f1e522E65074b70608C1Df01F93AE0);
        assertEq(markets[6], 0x31953016364543d12FEFbc1418810Ded511044a0);
        assertEq(markets[13], 0xcA4C669093572c5a23DE04B848a7f706eCBdFAC2);
    }

    function testGetAskDepths() public {
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepthsByPrice(
            0xcA4C669093572c5a23DE04B848a7f706eCBdFAC2,
            false,
            146000000000000,
            149000000000000
        );
        assertEq(depthInfo.length, 2);
        assertEq(depthInfo[0].price, 146815166275788);
        assertEq(depthInfo[0].quoteAmount, 199788779);
        assertEq(depthInfo[0].baseAmount, 1360818395455838781356042);
        assertEq(depthInfo[1].price, 148283317938545);
        assertEq(depthInfo[1].quoteAmount, 200000000);
        assertEq(depthInfo[1].baseAmount, 1348769388090497292116848);
    }

    function testGetBidDepths() public {
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepthsByPrice(
            0xcA4C669093572c5a23DE04B848a7f706eCBdFAC2,
            true,
            136000000000000,
            137000000000000
        );
        assertEq(depthInfo.length, 1);
        assertEq(depthInfo[0].price, 136937156290258);
        assertEq(depthInfo[0].quoteAmount, 374);
        assertEq(depthInfo[0].baseAmount, 2731179835568172624);
    }

    function testGetAskDepthsV1Volatile() public {
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepthsByPrice(
            0xE462374433029Bf889532F7fd3692ccAB736a559,
            false,
            1990000000000000000,
            2000000000000000000
        );
        assertEq(depthInfo.length, 5);
        assertEq(depthInfo[0].price, 1991257053078898004);
        assertEq(depthInfo[0].quoteAmount, 19912570);
        assertEq(depthInfo[0].baseAmount, 9999999733440251112);
        assertEq(depthInfo[1].price, 1993248310131976904);
        assertEq(depthInfo[1].quoteAmount, 0);
        assertEq(depthInfo[1].baseAmount, 0);
    }

    function testGetBidDepthsV1Volatile() public {
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepthsByPrice(
            0xE462374433029Bf889532F7fd3692ccAB736a559,
            true,
            1001000000000000000,
            1004000000000000000
        );
        assertEq(depthInfo.length, 3);
        assertEq(depthInfo[0].price, 1001110511271748314);
        assertEq(depthInfo[0].quoteAmount, 0);
        assertEq(depthInfo[0].baseAmount, 0);
        assertEq(depthInfo[1].price, 1002111621783020066);
        assertEq(depthInfo[1].quoteAmount, 1204443);
        assertEq(depthInfo[1].baseAmount, 1201905031155091497);
        assertEq(depthInfo[2].price, 1003113733404803086);
        assertEq(depthInfo[2].quoteAmount, 0);
        assertEq(depthInfo[2].baseAmount, 0);
    }

    function testGetAskDepthsV1Stable() public {
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepthsByPrice(
            0xa416b5807c68259B057326dEEF59d5B2053969EE,
            false,
            895000000000000000,
            905000000000000000
        );
        assertEq(depthInfo.length, 3);
        assertEq(depthInfo[0].price, 895000000000000000);
        assertEq(depthInfo[0].quoteAmount, 0);
        assertEq(depthInfo[0].baseAmount, 0);
        assertEq(depthInfo[1].price, 900000000000000000);
        assertEq(depthInfo[1].quoteAmount, 2998135351498000000000);
        assertEq(depthInfo[1].baseAmount, 3331261501664444444444);
        assertEq(depthInfo[2].price, 905000000000000000);
        assertEq(depthInfo[2].quoteAmount, 0);
        assertEq(depthInfo[2].baseAmount, 0);
    }

    function testGetBidDepthsV1Stable() public {
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepthsByPrice(
            0x02F4DC911919AcB274ceA42DfEb3481C88E4D330,
            true,
            997800000000000000,
            998000000000000000
        );
        assertEq(depthInfo.length, 3);
        assertEq(depthInfo[0].price, 997800000000000000);
        assertEq(depthInfo[0].quoteAmount, 0);
        assertEq(depthInfo[0].baseAmount, 0);
        assertEq(depthInfo[1].price, 997900000000000000);
        assertEq(depthInfo[1].quoteAmount, 4989500);
        assertEq(depthInfo[1].baseAmount, 5000000000000000000);
        assertEq(depthInfo[2].price, 998000000000000000);
        assertEq(depthInfo[2].quoteAmount, 0);
        assertEq(depthInfo[2].baseAmount, 0);
    }
}
