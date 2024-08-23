const Hero = () => {
  return (
    <section className="flex flex-col items-center hero-bg justify-center text-center bg-gradient-to-b from-gray-900 to-black text-white h-screen">
      <h1
        className="text-5xl font-extrabold tracking-wide"
        style={{ fontFamily: "Orbitron, sans-serif" }}
      >
        Stake ETH. Mint SIGUSD.
      </h1>
      <p className="mt-4 text-lg">
        A new way to collateralize your assets and earn yield.
      </p>
      <button className="mt-8 bg-blue-600 hover:bg-blue-500 text-white px-6 py-3 rounded-lg">
        Get Started
      </button>
    </section>
  );
};

export default Hero;
