pragma solidity ^0.4.17;


import "./Affiliate/AffiliateProgram.sol";
import "./Car.sol";




contract CarRental is Car {
    
     AffiliateProgram public affiliateProgram;

    /**
    * @notice We credit affiliates for renewals that occur within this time of
    * original purchase. E.g. If this is set to 1 year, and someone subscribes to
    * a monthly plan, the affiliate will receive credits for that whole year, as
    * the user renews their plan
    */

    event rentAgreementCreated(uint rentId,uint carId,uint createdtimestamp,uint expirationTime,address affiliate);   
    event rentApproved(uint rentId);
    mapping (uint => rentAggrement) rentIdToRentaggrement;
    

    uint256 public renewalsCreditAffiliatesFor = 1 years;

    /** internal **/
    function _performRent(
        uint256 _carID,
        uint256 _numMonths,
        address _tenant,
        address _affiliate)
        internal returns (uint)
    {
        //_rentCar(_carID,_numMonths,_tenant);
        return _createRentAggrement(
        _carID,
        _numMonths,
        _tenant,
        _affiliate
        );
    }
    
        
   
    function _createRentAggrement(
    uint256 _carId,
    uint256 _numMonths,
    address _tenant,
    address _affiliate)
    internal
    returns (uint)
    {

        rentAggrement memory _newRentAggrement = rentAggrement({
        carId: _carId,
        createdtimestamp: now, // solium-disable-line security/no-block-members
        expirationTime: _calculatexpiration(now,_numMonths),
        affiliate: _affiliate
        });

        uint256 rentId = allRentAggrements.push(_newRentAggrement) - 1; // solium-disable-line zeppelin/no-arithmetic-operations
        rentAgreementCreated(
        rentId,
        _newRentAggrement.carId,
        _newRentAggrement.createdtimestamp,
        _newRentAggrement.expirationTime,
        _newRentAggrement.affiliate
        );
        
        return rentId;
    }

    function _calculatexpiration(uint _numMonth) internal   {
        
    }

    function approveRental(uint _rentId,uint _carId) public   {
        allRentAggrements[_rentId].approvedbyowner =true;
        rentApproved(_rentId);
    }

}