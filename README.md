# ExampleDAO

A working example of how a contract `Box.sol` could be 100% controlled by a DAO. In this example:

-   We leverage [OpenZeppelin's on-chain governance contracts](https://docs.openzeppelin.com/contracts/4.x/api/governance) to deploy an on-chain voting protocol similar to [Compound’s Governor Alpha & Bravo](https://docs.compound.finance/v2/governance/).

-   An ERC20 token `GovToken.sol` is used for voting on proposals.

-   Every transaction that the DAO wants to send must be voted on.

## ⚒️ Built with Foundry

This project is built with [Foundry](https://github.com/foundry-rs/foundry) a portable and modular toolkit for Ethereum application development, which is required to build and deploy the project.

## 📂 Summary of contracts

### `Box.sol`

-   A simple storage contract that holds a single unsigned integer.

-   This contract will be 100% controlled by the DAO.

### `GovToken.sol`

-   An ERC20 token for voting in the DAO.

### `MyGovernor.sol`

-   A governor contract that allows token holders to vote on proposals.

### `Timelock.sol`

-   A timelock controller contract that allows certain actions to be delayed for a specific period of time.

## 🏗️ Getting started

Install project dependencies

```
make install
```

Build the project

```
make build
```

## 🧪 Running tests

The project includes a suite of unit tests to test various aspects of the contracts' functionality including:

➡️ updating the voting power

➡️ granting and revoking roles

➡️ updating the Box contract without governance

➡️ updating the Box contract with governance

To run the tests

```
make test
```
