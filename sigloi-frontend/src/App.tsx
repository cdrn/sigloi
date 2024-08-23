import { useState } from "react";
import "./App.css";
import "@fontsource/orbitron"; // defaults to 400 weight
import "@fontsource/orbitron/500.css"; // optional for specific weight
import "@fontsource/orbitron/700.css"; // optional for specific weight
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import Features from "./components/Features";
import Hero from "./components/Hero";

function App() {
  return (
    <>
      <div>
        <Navbar />
        <main>
          <Hero />
          <Features />
        </main>
        <Footer />
      </div>
    </>
  );
}

export default App;
