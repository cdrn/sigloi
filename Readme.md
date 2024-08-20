# Sigloi 

**Sigloi** is a decentralized protocol that allows users to mint **SIGUSD**, a dollar-pegged stablecoin, by depositing **liquid staking tokens** (LSTs) as collateral. the unique aspect of the protocol is that the collateral itself generates yield while locked in the system, ensuring that users can continue earning passive income on their staked assets.

## key features
- **overcollateralization**: users deposit liquid staking tokens (e.g., steth, rpl) to mint SIGUSD, with a safe overcollateralization ratio (e.g., 150%).
- **collateral yield**: the liquid staking tokens used as collateral generate yield while locked in the protocol, benefiting users even as they mint stablecoins.
- **staking sigusd**: users can stake their SIGUSD in protocol pools to earn additional rewards.
- **liquidation protection**: the protocol automatically monitors collateral-to-debt ratios and triggers liquidation if collateral values fall below safe thresholds.
- **oracle integration**: the protocol uses oracles to ensure accurate pricing of the collateral and to manage risk.

## roadmap
1. **v1 - core contracts**: deposit, mint, and liquidation mechanics, with collateral limited to liquid staking tokens.
2. **v2 - staking and yield**: implement staking of SIGUSD and reward distribution.
3. **v3 - governance**: introduce a governance token to manage protocol parameters and upgrades.
4. **v4 - multi-collateral support**: expand collateral types to other yield-bearing assets.


## Quick guide

### sigloi-contracts
1. **Install Foundry**: Run `curl -L https://foundry.paradigm.xyz | sh` to install Foundry.
2. **Clone the repository**: Run `git clone https://github.com/cdrn/sigloi.git` to clone the repository.
3. **Navigate to the contracts directory**: Run `cd sigloi-contracts` to navigate to the contracts directory.
4. **Install dependencies**: Run `forge install` to install the dependencies.
5. **Compile the contracts**: Run `forge build` to compile the contracts.
6. **Test the contracts**: Run `forge test` to test the contracts.


