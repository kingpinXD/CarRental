pragma solidity ^0.4.17;

import "./RentBase.sol";


contract Car is RentBase {
    event CarCreated(
        uint256 id,
        string carMake,
        uint carRent,
        bool isAvailable
    );
    event CarInventoryAdjusted(uint256 CarId, uint256 available);
    event CarPriceChanged(uint256 CarId, uint256 price);
    event CarRenewableChanged(uint256 CarId, bool renewable);
        /**
    * @notice Car defines a Car
    * * isAvailable : Car will not be available if it has been rented out 
    */
    struct Car {
        string carMake;
        uint256 carRent;
        bool isAvailable;
    }
    
    mapping (uint => address) carToOwner;
    mapping (address => uint) ownerCarCount;
    Car[] totalCarPool;
   
    function _addCarToPool (string _carMake,uint _carRent) internal {        
        uint id = totalCarPool.push(Car(_carMake,_carRent,true)) - 1;
        carToOwner[id] = msg.sender;
        ownerCarCount[msg.sender]++;
        CarCreated(id,_carMake,_carRent,true);
    }
    function _CarDoesNotExist(uint CarId) internal view returns(bool) {
        return (carToOwner[CarId] == 0x0000000000000000000000000000000000000000);
    }
    
    function _CarExists(uint CarId) internal view returns(bool) {
        return (carToOwner[CarId] != 0x0000000000000000000000000000000000000000);
    }
    function _isAvailable(uint CarId) internal view returns(bool) {
        return totalCarPool[CarId].isAvailable ;
    }
    

    function _setRent(uint256 _CarId, uint256 _rent) internal
    {
        require(_CarExists(_CarId));
        totalCarPool[_CarId].carRent = _rent;
    }

    function _rentCar(uint _CarId,uint _numMonths,address tenantAddress)internal {
        require(_CarExists(_CarId));
        require(_isAvailable(_CarId));//need to include duration in this
        totalCarPool[_CarId].isAvailable=false;
        carToOwner[_CarId]=tenantAddress;    
    }
    
    /**
   * @notice createCar creates a new Car in the system
   * @param _carMake - the make of the car (cannot be changed)
   * @param _carRent - the starting price (price can be changed)
   * 
   */
    function CreateCar (string _carMake,uint _carRent) external onlyCEOOrCOO {  
     _addCarToPool(_carMake,_carRent);
    }
    /**
    * @notice setPrice - sets the price of a Car
    * @param _CarId - the Car id
    * @param _price - the Car price
    */
    
    function SetRent(uint256 _CarId, uint256 _rent) external onlyCLevel
    {
        _setRent(_CarId, _rent);
    }
     /**
    * @notice The rental price of a Car
    * @param _CarId - the Car id
    */
      function priceOf(uint256 _CarId) public view returns (uint256) {
        return totalCarPool[_CarId].carRent;
    }

    /**
    * @notice The availablity of a Car
    * @param _CarId - the Car id
    */
    function isAvailable(uint256 _CarId) public view returns (bool) {
        return totalCarPool[_CarId].isAvailable;
    }


}