import { BigNumber } from 'ethers'

import { deployerTask } from '../template'
import { computeCreate1Address, liveLog } from '../../utils/misc'
import { waitForTx } from '../../utils/contract'

deployerTask(
  'prod:deploy-viewer',
  'Deploy Clober Viewer',
  async (taskArgs, hre, deployer) => {
    const signer = await deployer.getSigner()
  },
)
