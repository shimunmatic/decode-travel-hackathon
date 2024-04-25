# Decode Travel Hackathon

| Team         | Challange      |
| ------------ | -------------- |
| Blockshackle | Alpitour World |

## About

Idea of the project is to pay for the services of the local guide with a digital currency.
With the customers payment to the tour operator (Alpitour), the customer has completed their booking.
After the first customer has registered for a tour, the [contract](contracts/ExcursionContract.sol) is deployed to the blockchain by the tour opeartor. 

The contract contains information about the tour, checkpoints, customers, local guide and desired currency of the payment. [ExcursionContract Diagram](ExcursionContractDiagram.png)

After the deployment, the tour operator adds the customers address to the contract.

For every additional customer that joins the same tour, only their address is added to previuosly deployed contract.

Process flow:
1. Customers scan the QR code shown by the tour guide and the app triggers the check-in process in the contract. The contract checks that it has enough funds allocated based on the number of customers and the unit price.
2. By scanning the QR code at the checkpoint, the app triggers the check-in process for the checkpoint which identification lies in the QR code. (after the check in, NFT is generated and is assigned to the customers wallet)
3. After all customers have checked in at the last checkpoint, which id is provided in the construcor of the contract, the process for ending the journey is triggered and the funds are transfered to the tour guide.
   
## Codebase

[ExcursionContract](contracts/ExcursionContract.sol) - main contract which handles the process of the payment to the tour guide and keep track of the customer check ins
[USDC](contracts/USDC.sol) - contract for creating test coins
[UtravekNFT](contracts/UtravelNFT.sol) - contract for creating NFTs

## architecture

