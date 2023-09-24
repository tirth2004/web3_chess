require("@nomicfoundation/hardhat-toolbox");
const ALCHEMY_API_KEY = "v3-2PyZNm7RpJ2IHb1KKZOpaErj4WD0N";
const GOERLI_PRIVATE_KEY = "8974e1f6067a2db4fa656c1064acd43d09e21c4208e3f5c69b43d6a6dcd80e3d";



/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  etherscan: {
    apiKey: "SJ8N51NTEA7FUEPSV4MY8H28BVD9Y3NRYD",
  },
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY],
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
  },
};

// module.exports = {
//   solidity: "0.8.19",
//   networks: {
//     ganache: {
//       url: "http://127.0.0.1:7545", // Ganache local network URL
//       chainId: 1337, // Ganache chain ID
//     },
//     // ... other network configurations if needed
//   },
//   // ... rest of the configuration
// };


