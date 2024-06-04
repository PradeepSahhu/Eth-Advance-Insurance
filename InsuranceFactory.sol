// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./CarInsurance.sol";
import "./Interface/ICarInsurance.sol";
import "./HealthInsurance.sol";
import "./Interface/IinsuranceFactory.sol";
import "./InsuranceLibrary.sol";
import "./Interface/IHealthInsurance.sol";

// Implementing Normal Factory methodology
// This contract Factory works as a liquidity Pool (all premium amount stored here)

contract InsuranceFactory is IinsuranceFactory {
    using PremiumCalculateLibrary for uint;

    // modifier

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not the owner");
        _;
    }

    modifier onlyInsuranceHoldee(address _contractAddress) {
        require(
            msg.sender == _contractAddress,
            "You are not a insurance holdee because your address don't match"
        );
        _;
    }

    address owner;

    address[] public allCarInsurance;
    address[] public allHealthInsurance;

    mapping(address => bool) private deployedCarInsurance;
    mapping(address => bool) private deployedHealthInsurance;

    // State Structure for CarInsurance;

    struct CarInsuranceInformation {
        uint InitialAmount;
        uint minimum_month;
        uint claimAmount;
        uint applicable_years;
        string applicableFor;
        string premiumPerMonth;
    }

    // state Structure for HealthInsurace;

    struct HealthInsuranceInformation {
        uint InitialAmount;
        uint minimum_month;
        uint claimAmount;
        uint applicable_years;
        string applicableFor;
        string premiumPerMonth;
    }

    constructor() {
        owner = msg.sender;
    }

    function calculateHealthInsurancePremium(
        uint _age,
        uint8 _insuranceType,
        bool _pastMedicalHistory,
        bool _smoke,
        uint _bmi,
        bool _drink
    ) public pure returns (uint monthlyPremium) {
        monthlyPremium = _age.healthInsurancePremiumCalculte(
            _pastMedicalHistory,
            _insuranceType,
            _smoke,
            _bmi,
            _drink
        );
    }

    function startHealthInsurance(
        address _owner,
        uint _age,
        uint8 _insuranceType,
        bool _pastMedicalHistory,
        bool _smoke,
        uint _bmi,
        bool _drink
    ) public payable {
        uint initPremium = _insuranceType == 1 ? 10000 : 20000;
        require(msg.value >= initPremium, "must fullfil the initial amount");
        uint bal = msg.value - initPremium;
        (bool resMsg, ) = payable(_owner).call{value: bal}("");
        require(resMsg, "Contract can't be initiated");
        address newHealthInsurance = address(
            new HealthInsurance(
                address(this),
                _owner,
                _age,
                _insuranceType,
                _pastMedicalHistory,
                initPremium,
                _smoke,
                _bmi,
                _drink
            )
        );
        allHealthInsurance.push(newHealthInsurance);
        deployedHealthInsurance[newHealthInsurance] = true;
    }

    function startCarInsurance(
        address _owner,
        uint _age,
        uint8 _insuranceType,
        bool _pastAccident
    ) public payable {
        uint initPremium = _insuranceType == 1 ? 5000 : 8000;
        require(msg.value >= initPremium, "must fulfil the initial amount");
        uint bal = msg.value - initPremium;
        (bool callMsg, ) = payable(_owner).call{value: bal}("");
        require(callMsg, "Insurance can't be Initiatted");
        address newCarInsurance = address(
            new CarInsurance(
                address(this),
                _owner,
                _age,
                _insuranceType,
                initPremium,
                _pastAccident
            )
        );
        allCarInsurance.push(newCarInsurance);
        deployedCarInsurance[newCarInsurance] = true;
    }

    function calculateCarPremium(
        uint _age,
        bool _pastAccident,
        uint8 _typeOfInsurance
    ) public pure returns (uint amount) {
        amount = _age.carInsuranceCalculatePremium(
            _pastAccident,
            _typeOfInsurance
        );
    }

    // General Functions of a insurance. like claiming the insurance and getting the balance of the liquidity pool
    // and withdrawing the money from the liquidity pool for investment in other DEFIs

    function claimedInsurance(
        address _ownerAddress,
        uint claimedValue,
        address _contractAddress
    ) external payable onlyInsuranceHoldee(_contractAddress) returns (bool) {
        require(
            deployedCarInsurance[_contractAddress] ||
                deployedHealthInsurance[_contractAddress],
            "You are not a insurance Holdee && not in the list"
        );
        (bool callMsg, ) = payable(_ownerAddress).call{value: claimedValue}("");
        require(callMsg, "your claimed can't be processed");
        return true;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdrawForInvestment() public payable onlyOwner {
        (bool callRes, ) = payable(owner).call{value: address(this).balance}(
            ""
        );
        require(callRes, "Can't withdraw the amount");
    }

    function addLiquidityPool() public payable {}

    function getCarInsuranceInfo(
        uint _type
    )
        public
        pure
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        string memory initPremium = _type == 1 ? "5000" : "8000";
        string memory minimumMonth = _type == 1 ? "3" : "8";
        string memory claimAmount = _type == 1 ? "1000000" : "10000000";
        string memory applicableYears = _type == 1 ? "10" : "12";
        string memory applicableForCases = _type == 1
            ? "Car incident, car Damage, Engine Issue"
            : "Every Damage to Car, Third Party Accident, Stolen, Theft, Fine";
        string memory monthlyPremium = "will be calculated";
        return (
            string.concat("Initial Amount : ", initPremium),
            string.concat("Minimum Month to Pay : ", minimumMonth),
            string.concat("Total Claim Amount : ", claimAmount),
            string.concat("Applicable for Years : ", applicableYears),
            string.concat("Will be Applied in cases : ", applicableForCases),
            string.concat("Montly premium to Pay : ", monthlyPremium)
        );
    }

    function getHealthInfo(
        uint _type
    )
        public
        pure
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        string memory initPremium = _type == 1 ? "10000" : "20000";
        string memory minimumMonth = _type == 1 ? "5" : "12";
        string memory claimAmount = _type == 1
            ? "10000000000000"
            : "1000000000000000";
        string memory applicableYears = _type == 1 ? "Life Time" : "Life Time";
        string memory applicableForCases = _type == 1
            ? "Hopitilization, Cardio Vascular Diseases"
            : "Accident, Cancer, Organ Transplantation, Diseases, Life threatening case";
        string memory monthlyPremium = "will be calculated";
        return (
            string.concat("Initial Amount : ", initPremium),
            string.concat("Minimum Month to Pay : ", minimumMonth),
            string.concat("Total Claim Amount : ", claimAmount),
            string.concat("Applicable for Years : ", applicableYears),
            string.concat("Will be Applied in cases : ", applicableForCases),
            string.concat("Montly premium to Pay : ", monthlyPremium)
        );
    }

    fallback() external payable {}

    receive() external payable {}
}
