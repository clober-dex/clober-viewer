import { deployerTask } from '../template'
import {
  CHAIN_ID,
  CLOBER_FACTORY,
  CLOBER_FACTORY_V1,
  SUPPORT_V1_NO,
} from '../../utils/constant'

deployerTask(
  'prod:deploy-viewer',
  'Deploy Clober Viewer',
  async (taskArgs, hre, deployer) => {
    await deployer.deploy(
      'CloberViewer',
      [
        CLOBER_FACTORY[hre.network.name],
        CLOBER_FACTORY_V1[hre.network.name],
        CHAIN_ID[hre.network.name],
        SUPPORT_V1_NO[hre.network.name],
      ],
      {
        upgradeable: true,
      },
    )
  },
)
