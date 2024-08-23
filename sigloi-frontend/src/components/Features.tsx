const Features = () => {
  return (
    <section className="bg-gray-800 text-white py-16">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto px-6">
        <div className="bg-gray-700 p-6 rounded-lg">
          <h3
            className="text-2xl font-bold mb-2"
            style={{ fontFamily: "Orbitron, sans-serif" }}
          >
            Staking ETH
          </h3>
          <p>
            Stake your ETH securely with the SigloiVault and earn yield while
            collateralizing your assets.
          </p>
        </div>
        <div className="bg-gray-700 p-6 rounded-lg">
          <h3
            className="text-2xl font-bold mb-2"
            style={{ fontFamily: "Orbitron, sans-serif" }}
          >
            Minting SIGUSD
          </h3>
          <p>
            Use your staked ETH to mint SIGUSD, an over-collateralized
            stablecoin designed for stability.
          </p>
        </div>
        <div className="bg-gray-700 p-6 rounded-lg">
          <h3
            className="text-2xl font-bold mb-2"
            style={{ fontFamily: "Orbitron, sans-serif" }}
          >
            Security
          </h3>
          <p>
            Your assets are protected by decentralized governance and robust
            smart contract audits.
          </p>
        </div>
      </div>
    </section>
  );
};

export default Features;
