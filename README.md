SubNFT-Access Smart Contract

The **SubNFT-Access** smart contract provides a **subscription-based access control system** on the Stacks blockchain using NFTs. Instead of traditional tokens, NFTs act as subscription passes that grant gated access to content, platforms, or services for a limited time.

---

Features
- **NFT-based Subscription Passes**: Each minted NFT represents a subscription with an expiration date.
- **Configurable Duration**: Subscription periods are customizable at minting or renewal.
- **Renewal Mechanism**: Extend subscriptions by renewing NFTs.
- **Access Validation**: Read-only function to check if a user has an active subscription.
- **Revocation Control**: Admin can revoke subscriptions before expiry if needed.
- **Decentralized Access**: Ideal for gated communities, creator platforms, or service memberships.

---

Contract Functions

Public Functions
- `mint-subnft (recipient duration)`  
  Mint a new subscription NFT for a given recipient with a specified duration.

- `renew-subnft (token-id duration)`  
  Extend the validity period of an existing subscription NFT.

- `revoke-subnft (token-id)`  
  Revoke an existing subscription NFT before its expiration.

Read-Only Functions
- `check-access (user)`  
  Returns `true` if the user holds an active subscription NFT.

---

Use Cases
- **Token-Gated Communities**: Access to DAO voting, exclusive chats, or events.  
- **Content Subscriptions**: NFT-based subscriptions for music, courses, or newsletters.  
- **Membership Clubs**: Gym, professional networks, or co-working spaces on-chain.  
- **Tiered Access Models** (future extension).  

---

Deployment & Testing

Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet/installation) installed for local development and testing.

Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/subnft-access.git
   cd subnft-access
