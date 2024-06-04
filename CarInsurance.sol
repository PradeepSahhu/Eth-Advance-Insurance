// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Interface/IinsuranceFactory.sol";
import "./InsuranceLibrary.sol";
import "./Interface/ICarInsurance.sol";

contract CarInsurance is ICarInsurance {
    using PremiumCalculateLibrary for uint;

    // There are two types of insurance in this Car Contract. (insurance)

    // 1. Affordable - Cover Full Car Price , Less per month Premium , (Cover Less Cases)

    // Initial Amount : 5000 wei
    // Per month Premium - will be caculated in library (according to his age, past accident and type of insurance)
    // Applicable for next 10 years (120 months)
    // Cover Accidents, minor damage, engine issue.
    // Claim Price : 10_00_000 wei
    // must pay minimum of 5 month premium payment before claim.

    // 2. Expensive - (Cover Most of the cases)  , More per month Premium.

    // cases : Damage due to accident or natural calamity. Theft, Covers third party libialities.

    // Initial Amount : 8000 wei
    // Per month Premium - will be caculated in library (according to his age, past accident and type of insurance)
    // Applicable for next 12 years (144 months)
    // Claim Price : 100_00_000 wei
    // must pay minimum of 8 month premium payment before claim.

    // state variables.

    struct customerInfo {
        address customerAddress;
        uint customerAge;
        uint perMonthPremiumAmount;
        uint8 insuranceType;
        uint totalDepositedAmount;
        bool claimed;
    }

    address public immutable owner; // owner address of this insurance.
    address payable public immutable StoreBank; // reference of factory contract.
    uint public monthCount; // no. of months premium payed.
    customerInfo public customerDetails; // One Instance is for one customer.

    // modifier

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not the owner");
        _;
    }

    constructor(
        address _storeBank,
        address _owner,
        uint _age,
        uint8 _insuranceType,
        uint _initialAmount,
        bool _pastAccident
    ) {
        StoreBank = payable(_storeBank);
        owner = _owner;
        uint _perMonthPremiumAmount = _age.carInsuranceCalculatePremium(
            _pastAccident,
            _insuranceType
        );
        customerDetails = customerInfo({
            customerAddress: owner,
            customerAge: _age,
            perMonthPremiumAmount: _perMonthPremiumAmount,
            insuranceType: _insuranceType,
            totalDepositedAmount: _initialAmount,
            claimed: false
        });
    }

    function addPremium() public payable onlyOwner {
        require(msg.value > 0, "No amount is submitted");
        uint insuranceType = customerDetails.insuranceType;
        if (monthCount > (insuranceType == 1 ? 120 : 144)) {
            customerDetails.claimed = true;
        }
        require(
            msg.value >= customerDetails.perMonthPremiumAmount,
            "Premium is not equal to the promised amount"
        );
        uint bal = msg.value - customerDetails.perMonthPremiumAmount;
        monthCount++;
        customerDetails.totalDepositedAmount += customerDetails
            .perMonthPremiumAmount;
        (bool callMsg, ) = StoreBank.call{
            value: customerDetails.perMonthPremiumAmount
        }("");
        require(callMsg, "Transfer is not success");
        (bool responseMsg, ) = owner.call{value: bal}("");
        require(responseMsg, "Transaction is not successful to owner");
    }

    function claimInsurance() public payable onlyOwner {
        require(
            customerDetails.claimed == false,
            "You already claimed the insurance"
        );
        uint claimAmount = customerDetails.insuranceType == 1
            ? 1000000
            : 10000000;
        uint requireMonth = customerDetails.insuranceType == 1 ? 3 : 8;
        //Month Requirement according to type 1 or type 2 insurance policy.
        require(
            monthCount >= requireMonth,
            "you must may require months before claiming"
        );
        // claim Amount according to type 1 or type 2 insurance policy.
        bool claimedStatus = IinsuranceFactory(StoreBank).claimedInsurance(
            owner,
            claimAmount,
            address(this)
        );
        require(claimedStatus, "Your insurance can't be claimed");
        customerDetails.claimed = true;
        monthCount = 0;
    }

    function getPremiumAmount() public view returns (uint) {
        return customerDetails.perMonthPremiumAmount;
    }

    function hasClamied() public view returns (bool) {
        return customerDetails.claimed;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getMonth() public view returns (uint) {
        return monthCount;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
