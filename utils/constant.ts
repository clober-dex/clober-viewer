import { arbitrum, mainnet, polygon, polygonZkEvm } from '@wagmi/chains'

export const VOLATILE_A = 10000000000

export const VOLATILE_R = 1001000000000000000

export const CLOBER_FACTORY: { [network: string]: string } = {
  [mainnet.id]: '',
  [arbitrum.id]: '0x24aC0938C010Fb520F1068e96d78E0458855111D',
  [polygon.id]: '0x24aC0938C010Fb520F1068e96d78E0458855111D',
  [polygonZkEvm.id]: '',
}

export const CLOBER_FACTORY_V1: { [network: string]: string } = {
  [mainnet.id]: '',
  [arbitrum.id]: '0x93A43391978BFC0bc708d5f55b0Abe7A9ede1B91',
  [polygon.id]: '0x93A43391978BFC0bc708d5f55b0Abe7A9ede1B91',
  [polygonZkEvm.id]: '',
}

export const CHAIN_ID: { [network: string]: number } = {
  [mainnet.id]: 0,
  [arbitrum.id]: arbitrum.id,
  [polygon.id]: polygon.id,
  [polygonZkEvm.id]: 0,
}

export const SUPPORT_V1_NO: { [network: string]: number } = {
  [mainnet.id]: 0,
  [arbitrum.id]: 13,
  [polygon.id]: 8,
  [polygonZkEvm.id]: 0,
}
