"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Footer = () => {
    return (<footer className="py-6">
      <div className="flex justify-between max-w-6xl mx-auto px-6">
        <p>&copy; </p>
        <div className="space-x-4">
          <a href="#" className="hover:text-gray-400">
            Twitter
          </a>
          <a href="#" className="hover:text-gray-400">
            Github
          </a>
        </div>
      </div>
    </footer>);
};
exports.default = Footer;
