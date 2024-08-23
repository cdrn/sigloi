const Footer = () => {
  return (
    <footer className="bg-gray-900 text-white py-6">
      <div className="flex justify-between max-w-6xl mx-auto px-6">
        <p>&copy; 2024 Sigloi. All rights reserved.</p>
        <div className="space-x-4">
          <a href="#" className="hover:text-gray-400">
            Twitter
          </a>
          <a href="#" className="hover:text-gray-400">
            Github
          </a>
          <a href="#" className="hover:text-gray-400">
            Discord
          </a>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
