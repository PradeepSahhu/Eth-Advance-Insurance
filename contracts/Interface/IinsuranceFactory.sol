// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;



///@title The Interface for the InsuranceFactory.
///@notice By reading v3 and v2 documentation of uniswap i am trying to adopt the best documentation practices of development.

interface IinsuranceFactory {



    ///@notice To calculate the health Insurance Premium amount.

    function calculateHealthInsurancePremium(uint _age, uint8 _insuranceType, bool _pastMedicalHistory, bool _smoke, uint _bmi, bool _drink) external  returns(uint monthlyPremium);


     /// @notice to initiate the health insurane of a person
    function startHealthInsurance(address _owner, uint _age, uint8 _insuranceType, bool _pastMedicalHistory, bool smoke, uint _bmi, bool drink) external payable  ;



     /// @notice to initiate the car insurance.
    function startCarInsurance(address _owner,uint _age, uint8 _insuranceType, bool _pastAccident) external  payable;


    function calculateCarPremium(uint _age, bool _pastAccident, uint8 typeOfInsurance) external view returns(uint amount);


    /// @notice in order to claim the insurace from the liquidity pool (contrat factory)
    /// @param _ownerAddress the address of the person who will claim the insurance amount
    /// @param claimedValue for the test the claimed value is being asked
    function claimedInsurance(address _ownerAddress, uint claimedValue, address _contractAddress) external payable returns(bool);


    ///@notice get the balance of the liquidity pool

    function getBalance() external view returns(uint);


    /// @notice to withdraw the liquidity pool amount for investment in other DEFI's only by the factory owner.

     function withdrawForInvestment() external payable;


      ///@notice To refill the liquidity pool (The profit from the Investment can be used to refill the liquidity pool.

      function addLiquidityPool() external payable;

      ///@notice To get the Information about current Car Insurance Plan.

    function getCarInsuranceInfo(uint _type) external pure returns(string memory, string memory ,string memory, string memory , string memory , string memory);


           ///@notice To get the Information about current Health Insurance Plan.
        function getHealthInfo(uint _type) external pure returns(string memory, string memory ,string memory, string memory , string memory , string memory);

  
}