// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ICarInsurance{

        function addPremium() external payable;


        function claimInsurance() external  payable;

        function getPremiumAmount() external view returns(uint);


        function hasClamied() external view returns(bool);

        function getBalance() external view returns(uint);

        function getMonth() external view returns(uint);

        function getOwner() external view returns(address);
}