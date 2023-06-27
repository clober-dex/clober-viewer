import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'

import {
  CHAIN_ID,
  CLOBER_FACTORY,
  CLOBER_FACTORY_V1,
  SUPPORT_V1_NO,
} from '../../utils/constant'
import { liveLog } from '../../utils/misc'

const deployFunction: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment,
) {
  const { deployments, getNamedAccounts } = hre
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()
  const cloberViewerDeployResult = await deploy('CloberViewer', {
    from: deployer,
    args: [
      CLOBER_FACTORY[hre.network.name],
      CLOBER_FACTORY_V1[hre.network.name],
      CHAIN_ID[hre.network.name],
      SUPPORT_V1_NO[hre.network.name],
    ],
    proxy: {
      proxyContract: 'OpenZeppelinTransparentProxy',
    },
    log: true,
  })

  liveLog(
    `CloberView deployed on tx ${cloberViewerDeployResult.transactionHash}`,
  )
}

deployFunction.tags = ['CloberViewer']
deployFunction.dependencies = []
export default deployFunction
