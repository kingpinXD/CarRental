pragma solidity ^0.4.17;


import "./Affiliate/AffiliateProgram.sol";
import "./CarCore.sol";


/**
*@author Tanmay Bhattacharya
 */

contract CarRental is CarCore {
    
     AffiliateProgram public affiliateProgram;

    /**
    * @notice We credit affiliates for renewals that occur within this time of
    * original purchase. E.g. If this is set to 1 year, and someone subscribes to
    * a monthly plan, the affiliate will receive credits for that whole year, as
    * the user renews their plan
    */

    event rentAgreementCreated(uint rentId,uint carId,uint createdtimestamp,uint expirationTime,address affiliate,address tenant);   
    event rentApproved(uint rentId);
    mapping (uint => rentAggrement) rentIdrentAggrement;
    

    uint256 public renewalsCreditAffiliatesFor = 1 years;

    /** internal **/
    function _performRent(
        uint256 _carID,
        uint256 _numDays,
        address _tenant,
        address _affiliate)
        internal returns (uint)
    {
        
        return _createRentAggrement(
        _carID,
        _numDays,
        _tenant,
        _affiliate
        );
    }
    
        
   
    function _createRentAggrement(
    uint256 _carId,
    uint256 _numDays,
    address _tenant,
    address _affiliate)
    internal
    returns (uint)
    {

        rentAggrement memory _newRentAggrement = rentAggrement({
        carId: _carId,
        createdtimestamp: now, // solium-disable-line security/no-block-members
        expirationTime: now+_numDays,
        approvedbyowner:false,
        affiliate: _affiliate,
        tenant :_tenant
        });

        uint256 rentId = allRentAggrements.push(_newRentAggrement) - 1; // solium-disable-line zeppelin/no-arithmetic-operations
        rentAgreementCreated(
        rentId,
        _newRentAggrement.carId,
        _newRentAggrement.createdtimestamp,
        _newRentAggrement.expirationTime,
        _newRentAggrement.affiliate,
        _newRentAggrement.tenant
        );
        
        return rentId;
    }
    function _handleAffiliate(
    address _affiliate,
    uint256 _carId,
    uint256 _rentId,
    uint256 _carRent)
    internal
    {
        uint256 affiliateCut = affiliateProgram.cutFor(
        _affiliate,
        _carId,
        _rentId,
        _carRent);
        if(affiliateCut > 0) {
        require(affiliateCut < _carRent);
        affiliateProgram.credit.value(affiliateCut)(_affiliate, _rentId);
        }
    }
    function _affiliateProgramIsActive() internal view returns (bool) {
        return
        affiliateProgram != address(0) &&
        affiliateProgram.storeAddress() == address(this) &&
        !affiliateProgram.paused();
    }

      /** executives **/
    function setAffiliateProgramAddress(address _address) external onlyCEO {
        AffiliateProgram candidateContract = AffiliateProgram(_address);
        require(candidateContract.isAffiliateProgram());
        affiliateProgram = candidateContract;
    }
    function setRenewalsCreditAffiliatesFor(uint256 _newTime) external onlyCEO {
        renewalsCreditAffiliatesFor = _newTime;
    }

    /** anyone **/

  /**
  * @notice Makes a purchase of a product.
  * @dev Requires that the value sent is exactly the price of the product
  * @param _carId - the car to rent
  * @param _numDays - the number of days the car is rented
  * @param _tenant - the address to rentee (doesn't have to be msg.sender)
  * @param _affiliate - the address to of the affiliate - use address(0) if none
  */
  function purchase(
    uint256 _carId,
    uint256 _numDays,
    address _tenant,
    address _affiliate
    )
    external
    payable
    whenNotPaused
    returns (uint256)
    {
        require(_carId != 0);
        require(_numDays != 0);
        require(_tenant != address(0));
        // msg.value can be zero: free products are supported

        // Don't bother dealing with excess payments. Ensure the price paid is
        // accurate. No more, no less.
        require(msg.value == CostForRent(_carId, _numDays));

        // Non-subscription products should send a _numCycle of 1 -- you can't buy a
        // multiple quantity of a non-subscription product with this function
        // solium-disable-next-line security/no-block-members, zeppelin/no-arithmetic-operations
        uint256 licenseId = _performRent(_carId, _numDays, _tenant, _affiliate);

        if(
        priceOf(_carId) > 0 &&
        _affiliate != address(0) &&
        _affiliateProgramIsActive()
        ) {
        _handleAffiliate(
            _affiliate,
            _carId,
            licenseId,
            msg.value);
        }

        return licenseId;
    }


    function CostForRent(uint _carId,uint _numDays) public returns(uint) {
        return totalCarPool[_carId].carRent.mul(_numDays);
    }
         /**
   * @notice ArrproveRent is called by car Owner to approve car rental
   * @param _rentId - rentID of the rental aggrement 
   *
   * 
   */
    function ApproveRent(uint _rentId) public returns(bool) {
        rentAggrement memory currentRent = allRentAggrements[_rentId];
        require(carIdToOwner[currentRent.carId]==msg.sender); //Only owner of car can approve renting request
        require(currentRent.approvedbyowner==false);
        currentRent.approvedbyowner==true;
        _rentCar(currentRent.carId,currentRent.expirationTime,currentRent.tenant);
    }

}