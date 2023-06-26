//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../contracts/CloberViewer.sol";

contract CloberViewerTest is Test {
    string constant URL = "https://arbitrum.public-rpc.com";
    address constant CLOBER_FACTORY = 0x24aC0938C010Fb520F1068e96d78E0458855111D;
    address constant NFT_DEPLOYER = 0x58ed1f4913e652baF17C154551bd8E9dbc73fC56;
    uint256 arbitrum;
    CloberViewer viewer;

    function setUp() public {
        arbitrum = vm.createFork(URL);
        vm.selectFork(arbitrum);
        assertEq(vm.activeFork(), arbitrum);
        vm.rollFork(105060000);
        viewer = new CloberViewer(CLOBER_FACTORY, NFT_DEPLOYER, 42161);
    }

    function testGetAllMarket() public {
        address[] memory markets = viewer.getAllMarkets();
        assertEq(markets.length, 1);
        assertEq(markets[0], 0xcA4C669093572c5a23DE04B848a7f706eCBdFAC2);
    }

    function testGetAskDepths() public {
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepths(
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
        CloberViewer.DepthInfo[] memory depthInfo = viewer.getDepths(
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
}
