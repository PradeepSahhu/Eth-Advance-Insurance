
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


library PremiumCalculateLibrary{


    // dynamic premium amount for each user.
    function carInsuranceCalculatePremium(uint age, bool isPastAccidents, uint8 typeOfPremium ) internal pure returns(uint monthlyPremiumAmount){
       monthlyPremiumAmount += typeOfPremium == 1 ? 800: 2000; // base amount
       monthlyPremiumAmount += age <= 25 ? 1400: 1000; // more premium for young drivers. 
       monthlyPremiumAmount += isPastAccidents? 800 : 0; // more premium amount for past accident drivers.
    }


    function healthInsurancePremiumCalculte(uint _age, bool _pastMedicalHistory, uint8 _typeofPremium, bool _smoke, uint _bmi, bool _drink) internal pure returns(uint montlyPremiumAmount){
        montlyPremiumAmount += _typeofPremium == 1? 2000: 5000;
        montlyPremiumAmount += _age < 30 ? 500: 1200;// younger means health and less changes of caught chronic disease
        montlyPremiumAmount += _pastMedicalHistory? 2000: 500; 
        montlyPremiumAmount += _smoke? 1000: 0;
        montlyPremiumAmount += _bmi < 19? 1200: 200;
        montlyPremiumAmount += _drink? 1000: 200; // and many more.

    }
}
