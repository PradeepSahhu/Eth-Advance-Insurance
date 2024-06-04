# Eth-Advance Insurance Contract.

The objective of this project is to provide decentralized , transparent Insurance system to everyone such that they can pay little by little for a prosperous future.

## Here InsuranceFactory perform two main functions.

1.  Through it other insurance contracts (in this case Health and Car) insurance Contracts will be deployed
2.  It also act as a liquidity Pool (Here all the Premium Payed by the insurance Holdee will be collected) and if insurnace claimed ethers will be deducted from here after checks.

Only the Factory Owner (in this case the owner of the Insurance DAO) will be able to withdraw the money and invest it in some other DEFI's.

## There are two types of Insurance.

1. Car Insurance
2. Health Insurance

Each of them have two types of Policies.

1. Affordable (affordable Premium Amount per month, less requirements, cover most of the cases)
2. Expensive (High Premium Amount Per month, More requirements, Cover all the cases)

Any function inside the Insurance Contract (like Car Insurance Contract) can only be executed by the insurance holdee, external address like even the owner of insurance factory can't mess with it.
