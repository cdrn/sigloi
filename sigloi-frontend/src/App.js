"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("./App.css");
require("@fontsource/orbitron"); // defaults to 400 weight
require("@fontsource/orbitron/500.css"); // optional for specific weight
require("@fontsource/orbitron/700.css"); // optional for specific weight
const Navbar_1 = __importDefault(require("./components/Navbar"));
const Footer_1 = __importDefault(require("./components/Footer"));
const Features_1 = __importDefault(require("./components/Features"));
const Hero_1 = __importDefault(require("./components/Hero"));
function App() {
    return (<>
      <div>
        <Navbar_1.default />
        <main>
          <Hero_1.default />
          <Features_1.default />
        </main>
        <Footer_1.default />
      </div>
    </>);
}
exports.default = App;
