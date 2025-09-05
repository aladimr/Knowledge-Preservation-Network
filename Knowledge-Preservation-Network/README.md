# Knowledge Preservation Network Smart Contract

A decentralized platform built on the Stacks blockchain for documenting, preserving, and verifying traditional knowledge and skills from cultures around the world.

##  Overview

The Knowledge Preservation Network is designed to create a permanent, decentralized repository of traditional knowledge, skills, and cultural practices. Contributors can submit detailed documentation of traditional practices, which are then verified by the community through a staking and voting mechanism.

##  Features

### Core Functionality
- **Knowledge Submission**: Add detailed traditional knowledge entries with cultural context
- **Community Verification**: Stake-based voting system for knowledge authenticity
- **Reputation System**: Contributors earn reputation points for verified contributions
- **Cultural Documentation**: Comprehensive metadata including cultural origins and significance
- **Incentive Mechanism**: Staking rewards for verified knowledge contributions

### Key Components
- **Knowledge Entries**: Title, description, category, cultural origin, and timestamps
- **Detailed Content**: Step-by-step processes, materials needed, and cultural significance
- **Verification System**: Community voting with minimum threshold requirements
- **Contributor Profiles**: Track contributions, reputation, and staking history
- **Category Management**: Organize knowledge by traditional skill categories
- **Cultural Origins**: Track knowledge distribution across different cultures

##  Contract Functions

### Public Functions

#### `add-knowledge-entry`
Submit new traditional knowledge to the network.

**Parameters:**
- `title`: Brief title of the knowledge (max 100 chars)
- `description`: Short description (max 500 chars)
- `category`: Knowledge category (e.g., "crafts", "medicine", "cooking")
- `cultural-origin`: Cultural or geographic origin
- `detailed-content`: Comprehensive explanation (max 2000 chars)
- `materials-needed`: Required materials list
- `step-by-step-process`: Detailed process instructions
- `cultural-significance`: Cultural and historical context
- `preservation-notes`: Additional preservation information
- `stake-amount`: STX amount to stake (minimum 1 STX)

**Returns:** Knowledge ID if successful

#### `vote-for-verification`
Vote on the authenticity and accuracy of submitted knowledge.

**Parameters:**
- `knowledge-id`: ID of the knowledge entry to vote on
- `vote`: Boolean (true for approve, false for reject)

**Returns:** Success confirmation

### Read-Only Functions

#### `get-knowledge-entry`
Retrieve basic information about a knowledge entry.

#### `get-knowledge-content`
Retrieve detailed content of a knowledge entry.

#### `get-contributor-profile`
Get contributor statistics and reputation information.

#### `get-category-stats`
View statistics for a specific knowledge category.

#### `get-cultural-origin-stats`
View statistics for knowledge from a specific cultural origin.

### Administrative Functions

#### `set-verification-threshold`
Update the minimum number of votes required for verification (owner only).

#### `set-min-stake-amount`
Update the minimum staking requirement (owner only).

##  Technical Specifications

### Constants
- `CONTRACT-OWNER`: Contract deployer address
- Error codes for various failure conditions

### Data Variables
- `next-knowledge-id`: Auto-incrementing knowledge entry ID
- `min-stake-amount`: Minimum STX required for submissions (default: 1 STX)
- `verification-threshold`: Minimum votes needed for verification (default: 5)

### Data Maps
- `knowledge-entries`: Core knowledge metadata
- `knowledge-content`: Detailed knowledge content
- `verification-votes`: Community voting records
- `contributors`: Contributor profiles and statistics
- `knowledge-categories`: Category organization and counts
- `cultural-origins`: Cultural origin tracking
- `contributor-stakes`: Staking records and amounts

##  Economic Model

### Staking Mechanism
- Contributors must stake a minimum of 1 STX when submitting knowledge
- Stakes are held until the knowledge is verified or rejected
- Verified knowledge returns the stake plus a 10% bonus
- Rejected knowledge results in stake forfeiture

### Reputation System
- Contributors earn reputation points for verified submissions
- Reputation affects voting weight in future verifications
- Higher reputation contributors receive priority in the interface

### Incentive Structure
- Verification bonus encourages quality submissions
- Community voting ensures knowledge authenticity
- Long-term reputation building promotes continued participation

##  Deployment Instructions

### Prerequisites
- Clarinet CLI installed
- Stacks wallet configured
- Sufficient STX for deployment

### Local Development
```bash
# Clone the repository
git clone <repository-url>
cd knowledge-preservation-network

# Install dependencies
clarinet requirements

# Run local tests
clarinet test

# Start local blockchain
clarinet integrate
```

### Mainnet Deployment
```bash
# Deploy to mainnet
clarinet deploy --network mainnet

# Verify contract deployment
stx call_read_only_function <contract-address> knowledge-preservation get-current-knowledge-id
```

##  Testing

### Unit Tests
The contract includes comprehensive tests for:
- Knowledge submission and validation
- Voting and verification mechanisms
- Staking and reward distribution
- Access control and error handling

### Integration Tests
- End-to-end knowledge submission and verification flow
- Multi-user voting scenarios
- Economic incentive verification

##  Security Considerations

### Access Control
- Owner-only functions are properly protected
- Vote validation prevents double-voting
- Stake requirements prevent spam submissions

### Economic Security
- Minimum stake prevents low-quality submissions
- Community verification ensures knowledge authenticity
- Reputation system builds long-term trust

### Data Integrity
- Immutable knowledge storage on blockchain
- Transparent verification process
- Audit trail for all contributions and votes

## 📊 Usage Examples

### Submitting Traditional Knowledge
```clarity
;; Example: Adding a traditional pottery technique
(contract-call? .knowledge-preservation add-knowledge-entry
  "Traditional Clay Pottery Glazing"
  "Ancient technique for creating durable ceramic glazes using local materials"
  "crafts"
  "Ancestral Puebloan Culture, Southwestern USA"
  "This technique involves collecting specific clay types from desert regions..."
  "Clay, plant ash, mineral pigments, water"
  "1. Prepare clay base... 2. Mix with ash... 3. Apply in thin layers..."
  "This glazing method represents centuries of ceramic innovation..."
  "Requires knowledge of local clay deposits and seasonal plant cycles"
  u1000000) ;; 1 STX stake
```

### Voting on Knowledge
```clarity
;; Vote to verify knowledge entry #1
(contract-call? .knowledge-preservation vote-for-verification u1 true)
```

### Checking Contributor Profile
```clarity
;; View contributor statistics
(contract-call? .knowledge-preservation get-contributor-profile 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

##  Contributing

We welcome contributions from cultural preservationists, blockchain developers, and community members interested in preserving traditional knowledge.

### Guidelines
- Ensure cultural sensitivity in all submissions
- Verify accuracy of traditional knowledge
- Respect intellectual property and cultural protocols
- Follow smart contract security best practices

##  License

This project is licensed under the MIT License - see the LICENSE file for details.

## Cultural Impact

The Knowledge Preservation Network aims to:
- Preserve endangered traditional knowledge
- Empower indigenous and traditional communities
- Create economic incentives for knowledge sharing
- Build a global repository of human cultural heritage
- Support intergenerational knowledge transfer

## Support

For questions, suggestions, or technical support:
- Create an issue in the repository
- Join our community discussions
- Contact the development team

---

**Note**: This contract handles culturally sensitive information. Please ensure you have appropriate permissions and respect cultural protocols when submitting traditional knowledge.