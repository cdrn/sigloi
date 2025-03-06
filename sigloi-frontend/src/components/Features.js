"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Features = () => {
    return (<section className="py-16">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto px-6">
        <div className="p-6 rounded-lg">
          <h3 className="text-2xl font-bold mb-2" style={{ fontFamily: "Orbitron, sans-serif" }}>
            Staking ETH
          </h3>
          <p>
            Stake your ETH securely with the SigloiVault and earn yield while
            collateralizing your assets.
          </p>
        </div>
        <div className="p-6 rounded-lg">
          <h3 className="text-2xl font-bold mb-2" style={{ fontFamily: "Orbitron, sans-serif" }}>
            Minting SIGUSD
          </h3>
          <p>
            Use your staked ETH to mint SIGUSD, a USD pegged stablecoin backed
            by LSTs
          </p>
        </div>
        <div className="p-6 rounded-lg">
          <h3 className="text-2xl font-bold mb-2" style={{ fontFamily: "Orbitron, sans-serif" }}>
            Security
          </h3>
          <p>
            Your assets are protected by decentralized governance and robust
            smart contract audits.
          </p>
        </div>
      </div>
    </section>);
};
exports.default = Features;
