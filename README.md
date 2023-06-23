# Construct Besu IBFT
This project covers the process of configuring IBFT (Istanbul BFT) using Hyperledger Besu. Hyperledger Besu is an open-source Ethereum client used for building Ethereum-based and Ethereum-compatible blockchain networks.

For detailed information about Hyperledger Besu, please refer to [here](https://besu.hyperledger.org/en/stable/). The provided link contains comprehensive details about Besu's features, architecture, documentation, and community.
# install besu


## MacOS
### Prerequisites
- [Homebrew](https://brew.sh/)
- Java JDK
```bash
brew install openjdk
```

### install besu using Homebrew
```bash
brew tap hyperledger/besu
brew install hyperledger/besu/besu
```
### Linux / Unix

### Prerequisites
- [Java JDK 17+](https://www.oracle.com/java/technologies/downloads/)

### Install jdk 20.0.1
```bash
wget https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz && sudo tar -zxvf jdk-20_linux-x64_bin.tar.gz -C /usr/lib/
echo 'export JAVA_HOME=/usr/lib/jdk-20.0.1/' | sudo tee -a /etc/profile && source /etc/profile
```

### Besu setting
```bash
wget https://hyperledger.jfrog.io/hyperledger/besu-binaries/besu/23.4.1/besu-23.4.1.tar.gz && tar -zxvf besu-23.4.1.tar.gz -C /usr/lib/
```

### Bash alias
```bash
echo -e 'alias java="/usr/lib/jdk-20.0.1/bin/java"\nalias javac="/usr/lib/jdk-20.0.1/bin/javac"\nalias besu="/usr/lib/besu-23.4.1/bin/besu"' | sudo tee -a /etc/bashrc && source /etc/bashrc
```

### Install docker
```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
### Docker authentication
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
id
```

If the text printed on the terminal is not similar to the following, relaunch the terminal or log in again.
```
uid=1000(ubuntu) ...,999(docker)
```
### Install from packaged binaries
Download the [Besu packaged binaries](https://github.com/hyperledger/besu/releases).

# Create a private network using IBFT 2.0
## Prerequisites
- install [Docker Desktop](https://docs.docker.com/get-docker/)
- download docker image
```bash
docker pull hyperledger/besu:latest
```
### 1. Create a configuration file
make ibftConfigFile.json
```json
{
  "genesis": {
    "config": {
      "chainId": 1337,
      "berlinBlock": 0,
      "ibft2": {
        "blockperiodseconds": 2,
        "epochlength": 30000,
        "requesttimeoutseconds": 4
      }
    },
    "nonce": "0x0",
    "timestamp": "0x58ee40ba",
    "gasLimit": "0x47b760",
    "difficulty": "0x1",
    "mixHash": "0x63746963616c2062797a616e74696e65206661756c7420746f6c6572616e6365",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {
      "fe3b557e8fb62b89f4916b721be55ceb828dbd73": {
        "privateKey": "8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63",
        "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
        "balance": "0xad78ebc5ac6200000"
      },
      "627306090abaB3A6e1400e9345bC60c78a8BEf57": {
        "privateKey": "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3",
        "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
        "balance": "90000000000000000000000"
      },
      "f17f52151EbEF6C7334FAD080c5704D77216b732": {
        "privateKey": "ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f",
        "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
        "balance": "90000000000000000000000"
      }
    }
  },
  "blockchain": {
    "nodes": {
      "generate": true,
      "count": 4
    }
  }
}
```

### 2. Construct IBFT Network
```bash
./run_all.sh
```
This script runs all procedures below.

#### 2-1. Generate node keys and a genesis file
```bash
besu operator generate-blockchain-config --config-file=ibftConfigFile.json --to=networkFiles --private-key-file-name=key
```

#### 2-2. Copy key to Node folder
```bash
./copyKeys.sh
```

#### 2-3. Start bootnode
```bash
./bootnode.sh --CONTAINER_NAME="boot_node" --NODE_NUMBER=1
```

#### 2-4. Start Node-2,3,4
```bash
./node.sh --CONTAINER_NAME="Node-2" --NODE_NUMBER=2 --LOCAL_PORT=5670
./node.sh --CONTAINER_NAME="Node-3" --NODE_NUMBER=3 --LOCAL_PORT=5680
./node.sh --CONTAINER_NAME="Node-4" --NODE_NUMBER=4 --LOCAL_PORT=5690
```

### 3. Reset Network
```bash
./reset.sh
```

# Test Validator
For more information, see [hyperledger besu doc](https://besu.hyperledger.org/en/stable/private-networks/reference/api/#ibft_getvalidatorsbyblocknumber)

## ibft_proposeValidatorVote
Propose to add or remove a validator with the specified address.

Parameters
- address: string- account address
- proposal: boolean - true to propose adding validator or false to propose removing validator
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["42d4287eac8078828cf5f3486cfe601a275a49a5",true], "id":1}' http://127.0.0.1:[LOCAL_PORT]
```

### ibft_getValidatorsByBlockNumber
Lists the validators defined in the specified block.

Parameters
- blockNumber: string - integer representing a block number or one of the string tags latest, earliest, or pending, as described in Block Parameter
```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_getValidatorsByBlockNumber","params":["latest"], "id":1}' http://127.0.0.1:[LOCAL_PORT]
```
