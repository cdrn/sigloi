"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Navbar = () => {
    return (<header className="flex justify-between items-center p-6">
      <div className="text-3xl font-bold relative crt-text" style={{ fontFamily: "Orbitron, sans-serif" }}>
        Sigloi
      </div>
      <nav className="flex space-x-6 flex justify-between items-center">
        <a href="#" className="hover:text-gray-400">
          Home
        </a>
        <a href="#" className="hover:text-gray-400">
          How it Works
        </a>
        <a href="#" className="hover:text-gray-400">
          Docs
        </a>
        <button className="bg-blue-600 hover:bg-blue-500 text-white px-4 py-2 rounded">
          Launch App
        </button>
      </nav>
    </header>);
};
exports.default = Navbar;
