pragma solidity ^0.4.17;

import "./CarOwnership.sol";
/**
*@author Tanmay Bhattacharya
 */
contract CarCore is CarOwnership{

    function _addCarToPool (string _carMake,uint _carRent,address _to) internal {        
    uint id = totalCarPool.push(Car(_carMake,_carRent,true)) - 1;
    mint(_to,id);
    //carIdToOwner[id] = msg.sender;
    //ownerCarCount[msg.sender]++;
    //ownerListofCars[msg.sender].push(id);
    
    CarCreated(id,_carMake,_carRent,true);
    }

    function _rentCar(uint _CarId,uint _expiration,address tenantAddress)internal {
    require(_CarExists(_CarId));
    require(_isAvailable(_CarId));//need to include duration in this
    approve(tenantAddress,_CarId);

    totalCarPool[_CarId].isAvailable=false;
                                                    //add code to substract and add to ownerListofCars
    carIdToOwner[_CarId]=tenantAddress;    
    }
     /**
   * @notice createCar creates a new Car in the system
   * @param _carMake - the make of the car (cannot be changed)
   * @param _carRent - the starting price (price can be changed)
   * 
   */
    function CreateCar (string _carMake,uint _carRent) external onlyCEOOrCOO {  
     _addCarToPool(_carMake,_carRent,msg.sender);
    }

}