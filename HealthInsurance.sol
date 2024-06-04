// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;



import "./Interface/IinsuranceFactory.sol";
import "./InsuranceLibrary.sol";
import "./Interface/IHealthInsurance.sol";

// Individual HealthInsurance(medical Insurance)

   // 1. Affordable - Cover most of the medical casses and chronic diseases.


    // Initial Amount : 10_000 wei
    // Per month Premium - will be caculated in library (according to his age, past medical history, type of insurance and habits)
    // Applicable for life type
    // Cover injury and diseases.
    // Max Claim Price : 1_00_00_00_00_00_000 wei
    // must pay minimum of 5 month premium payment before claim.




    // 2. Expensive - (Cover Most of the cases)  , Diseases, accidents, injury, life threatening dieases. etc..


   // Initial Amount : 20_000 wei
    // Per month Premium - will be caculated in library (according to his age, past accident and type of insurance)
    // Applicable for life time.
    // Claim Price :1_00_00_00_00_00_00_000 wei
    // must pay minimum of 12 month premium payment before claim.

contract HealthInsurance is IHealthInsurance{

    using PremiumCalculateLibrary for uint;

    address public owner;
    uint monthCount;
    address payable LiquidityPool;

     modifier onlyOwner{
        require(msg.sender == owner, "you are not the owner");
        _;
    }


    struct customerHabits{
        bool smoke;
        uint bmi;
        bool drink;
    }


    struct CustomerDetails{
        address ownerAddress;
        uint age;
        uint insuranceType;
        bool pastMedicalHistory;
        uint monthlyPremiumAmount;
        bool claimed;
        uint totalPremiumAmount;
        customerHabits habit;
    }

    CustomerDetails public customerDetails;



    //   address(new HealthInsurance(_owner,_age, _insuranceType, _pastMedicalHistory, monthlyPremium));
//    function healthInsurancePremiumCalculte(uint _age, bool _pastMedicalHistory, uint8 _typeofPremium, bool _smoke, uint _bmi, bool _drink) internal pure returns(uint montlyPremiumAmount){


    constructor(address _liquidityPool, address _owner, uint _age,uint8 _insuranceType, bool _pastMedicalHistory,uint _initialAmount,bool _smoke,uint _bmi,bool  _drink ) {
        LiquidityPool = payable(_liquidityPool);
        owner = _owner;
        uint monthlyPremiumAmount = _age.healthInsurancePremiumCalculte(_pastMedicalHistory,_insuranceType,_smoke,_bmi,_drink);
        customerHabits memory habit = customerHabits(_smoke, _bmi, _drink);
        customerDetails = CustomerDetails(_owner, _age, _insuranceType, _pastMedicalHistory,monthlyPremiumAmount, false,_initialAmount,habit);

    }





    function addPremium()public payable onlyOwner{
        require(msg.value > 0, "No amount is submitted");
        require(msg.value >= customerDetails.monthlyPremiumAmount, "Premium is not equal to the promised amount");
        uint bal = msg.value - customerDetails.monthlyPremiumAmount;
        monthCount++;
        customerDetails.totalPremiumAmount += customerDetails.monthlyPremiumAmount;
        (bool callMsg,) = LiquidityPool.call{value: msg.value}("");
        require(callMsg, "Transfer is not success");
        (bool responseMsg,) = owner.call{value:bal}("");
        require(responseMsg,"Transaction is not successful to owner");
      

    }




      function claimInsurance() public payable onlyOwner{
        require(customerDetails.claimed == false, "You already claimed the insurance");
            uint claimAmount = customerDetails.insuranceType == 1? 1e15: 1e17;
            uint requireMonth = customerDetails.insuranceType == 1? 5: 12;
        //Month Requirement according to type 1 or type 2 insurance policy.
        require(monthCount >= requireMonth, "you must may require months before claiming");
         // claim Amount according to type 1 or type 2 insurance policy.
       bool claimedStatus =  IinsuranceFactory(LiquidityPool).claimedInsurance(owner, claimAmount, address(this));
       require(claimedStatus, "Your insurance can't be claimed");
       customerDetails.claimed = true;
       monthCount = 0;
    }



    // getters

   
    function getPremiumAmount() public view returns(uint){
        return customerDetails.monthlyPremiumAmount;
    }

    function hasClamied() public view returns(bool){
        return customerDetails.claimed;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getMonth() public view returns(uint){
        return monthCount;
    }

    function getOwner() external view returns(address){
        return owner;
    }


}