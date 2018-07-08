pragma solidity ^0.4.17;

import "./RentalAccessControl.sol";

contract RentBase is RentalAccessControl{
    
    event rentaggrementCreated(address indexed owner,address indexed tenanat,uint carId,uint rentId);
    event rentaggrementRenewed(address indexed owner,address indexed tenanat,uint carId,uint rentId);
    struct rentAggrement {
        uint carId;
        uint createdtimestamp;
        uint expirationTime;
        bool approvedbyowner;
        address affiliate;
    }

    rentAggrement[] allRentAggrements;

    function _isValidrentAggrement(uint256 _rentId) internal view returns (bool) {
        return rentAggrementCarId(_rentId) != 0;
    }
      /**
   * @notice Get a rentAggrement's carID
   * @param _rentId the rentAggrement id
   */
    function rentAggrementCarId(uint256 _rentId) public view returns (uint256) {
        return allRentAggrements[_rentId].carId;
    }
     /**
   * @notice Get a rentAggrement's createdtimestamp
   * @param _rentId the rentAggrement id
   */
    function rentAggrementIssuedTime(uint256 _rentId) public view returns (uint256) {
    return allRentAggrements[_rentId].createdtimestamp;
    }
     /**
   * @notice Get a rentAggrement's expirationTime
   * @param _rentId the rentAggrement id
   */
    function rentAggrementExpirationTime(uint256 _rentId) public view returns (uint256) {
    return allRentAggrements[_rentId].expirationTime;
    }
    
    /**
    * @notice Get a the affiliate credited for the sale of this rentAggrement
    * @param _rentId the rentAggrement id
    */
    function rentAggrementAffiliate(uint256 _rentId) public view returns (address) {
        return allRentAggrements[_rentId].affiliate;
    }

    /**
    * @notice Get a rentAggrement's info
    * @param _rentId the rentAggrement id
    */
    function rentAggrementInfo(uint256 _rentId)
        public view returns (uint256, uint256, uint256, address)
    {
        return (
        rentAggrementCarId(_rentId),
        rentAggrementIssuedTime(_rentId),
        rentAggrementExpirationTime(_rentId),
        rentAggrementAffiliate(_rentId)
        );
    }
}