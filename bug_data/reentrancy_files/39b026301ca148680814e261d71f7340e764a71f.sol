/**
▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓▌        ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
  ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓

                           Trust math, not hardware.
*/

pragma solidity 0.5.17;

/**
▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓▌        ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
  ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓

                           Trust math, not hardware.
*/

pragma solidity 0.5.17;

/// @title Keep Random Beacon
///
/// @notice Keep Random Beacon generates verifiable randomness that is resistant
/// to bad actors both in the relay network and on the anchoring blockchain.
interface IRandomBeacon {
    /// @notice Event emitted for each new relay entry generated. It contains
    /// request ID allowing to associate the generated relay entry with relay
    /// request created previously with `requestRelayEntry` function. Event is
    /// emitted no matter if callback was executed or not.
    ///
    /// @param requestId Relay request ID for which entry was generated.
    /// @param entry Generated relay entry.
    event RelayEntryGenerated(uint256 requestId, uint256 entry);

    /// @notice Provides the customer with an estimated entry fee in wei to use
    /// in the request. The fee estimate is only valid for the transaction it is
    /// called in, so the customer must make the request immediately after
    /// obtaining the estimate. Insufficient payment will lead to the request
    /// being rejected and the transaction reverted.
    ///
    /// The customer may decide to provide more ether for an entry fee than
    /// estimated by this function. This is especially helpful when callback gas
    /// cost fluctuates. Any surplus between the passed fee and the actual cost
    /// of producing an entry and executing a callback is returned back to the
    /// customer.
    /// @param callbackGas Gas required for the callback.
    function entryFeeEstimate(uint256 callbackGas)
        external
        view
        returns (uint256);

    /// @notice Submits a request to generate a new relay entry. Executes
    /// callback on the provided callback contract with the generated entry and
    /// emits `RelayEntryGenerated(uint256 requestId, uint256 entry)` event.
    /// Callback contract has to declare public `__beaconCallback(uint256)`
    /// function that is going to be executed with the result, once ready.
    /// It is recommended to implement `IRandomBeaconConsumer` interface to
    /// ensure the correct callback function signature.
    ///
    /// @dev Beacon does not support concurrent relay requests. No new requests
    /// should be made while the beacon is already processing another request.
    /// Requests made while the beacon is busy will be rejected and the
    /// transaction reverted.
    ///
    /// @param callbackContract Callback contract address. Callback is called
    /// once a new relay entry has been generated. Must declare public
    /// `__beaconCallback(uint256)` function. It is recommended to implement
    /// `IRandomBeaconConsumer` interface to ensure the correct callback function
    /// signature.
    /// @param callbackGas Gas required for the callback.
    /// The customer needs to ensure they provide a sufficient callback gas
    /// to cover the gas fee of executing the callback. Any surplus is returned
    /// to the customer. If the callback gas amount turns to be not enough to
    /// execute the callback, callback execution is skipped.
    /// @return An uint256 representing uniquely generated relay request ID
    function requestRelayEntry(address callbackContract, uint256 callbackGas)
        external
        payable
        returns (uint256);

    /// @notice Submits a request to generate a new relay entry. Emits
    /// `RelayEntryGenerated(uint256 requestId, uint256 entry)` event for the
    /// generated entry.
    ///
    /// @dev Beacon does not support concurrent relay requests. No new requests
    /// should be made while the beacon is already processing another request.
    /// Requests made while the beacon is busy will be rejected and the
    /// transaction reverted.
    ///
    /// @return An uint256 representing uniquely generated relay request ID
    function requestRelayEntry() external payable returns (uint256);
}

/// @title Keep Random Beacon Consumer
///
/// @notice Receives Keep Random Beacon relay entries with `__beaconCallback`
/// function. Contract implementing this interface does not have to be the one
/// requesting relay entry but it is the one receiving the requested relay entry
/// once it is produced.
///
/// @dev Use this interface to indicate the contract receives relay entries from
/// the beacon and to ensure the correctness of callback function signature.
interface IRandomBeaconConsumer {
    /// @notice Receives relay entry produced by Keep Random Beacon. This function
    /// should be called only by Keep Random Beacon.
    ///
    /// @param relayEntry Relay entry (random number) produced by Keep Random
    /// Beacon.
    function __beaconCallback(uint256 relayEntry) external;
}

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract GroupSelectionSeed is IRandomBeaconConsumer {
    using SafeMath for uint256;

    IRandomBeacon randomBeacon;

    // Gas required for a callback from the random beacon. The value specifies
    // gas required to call `__beaconCallback` function in the worst-case
    // scenario with all the checks and maximum allowed uint256 relay entry as
    // a callback parameter.
    uint256 public constant callbackGas = 30000;

    // Random beacon sends back callback surplus to the requestor. It may also
    // decide to send additional request subsidy fee. What's more, it may happen
    // that the beacon is busy and we will not refresh group selection seed from
    // the beacon. We accumulate all funds received from the beacon in the
    // reseed pool and later use this pool to reseed using a public reseed
    // function on a manual request at any moment.
    uint256 public reseedPool;

    uint256 public groupSelectionSeed;

    constructor(address _randomBeacon) public {
        randomBeacon = IRandomBeacon(_randomBeacon);

        // Initial value before the random beacon updates the seed.
        // https://www.wolframalpha.com/input/?i=pi+to+78+digits
        groupSelectionSeed = 31415926535897932384626433832795028841971693993751058209749445923078164062862;
    }

    /// @notice Adds any received funds to the reseed pool.
    function() external payable {
        reseedPool += msg.value;
    }

    /// @notice Sets a new group selection seed value.
    /// @dev The function is expected to be called in a callback by the random
    /// beacon.
    /// @param _relayEntry Beacon output.
    function __beaconCallback(uint256 _relayEntry) external onlyRandomBeacon {
        groupSelectionSeed = _relayEntry;
    }

    /// @notice Gets a fee estimate for a new random entry.
    /// @return Uint256 estimate.
    function newEntryFeeEstimate() public view returns (uint256) {
        return randomBeacon.entryFeeEstimate(callbackGas);
    }

    /// @notice Calculates the fee requestor has to pay to reseed the factory
    /// for signer selection. Depending on how much value is stored in the
    /// reseed pool and the price of a new relay entry, returned value may vary.
    function newGroupSelectionSeedFee() public view returns (uint256) {
        uint256 beaconFee = randomBeacon.entryFeeEstimate(callbackGas);
        return beaconFee <= reseedPool ? 0 : beaconFee.sub(reseedPool);
    }

    /// @notice Reseeds the value used for a signer selection. Requires enough
    /// payment to be passed. The required payment can be calculated using
    /// reseedFee function. Factory is automatically triggering reseeding after
    /// opening a new keep but the reseed can be also triggered at any moment
    /// using this function.
    function requestNewGroupSelectionSeed() public payable {
        uint256 beaconFee = randomBeacon.entryFeeEstimate(callbackGas);

        reseedPool = reseedPool.add(msg.value);
        require(reseedPool >= beaconFee, "Not enough funds to trigger reseed");

        (bool success, bytes memory returnData) = requestRelayEntry(beaconFee);
        if (!success) {
            revert(string(returnData));
        }

        reseedPool = reseedPool.sub(beaconFee);
    }

    /// @notice Updates group selection seed.
    /// @dev The main goal of this function is to request the random beacon to
    /// generate a new random number. The beacon generates the number asynchronously
    /// and will call a callback function when the number is ready. In the meantime
    /// we update current group selection seed to a new value using a hash function.
    /// In case of the random beacon request failure this function won't revert
    /// but add beacon payment to factory's reseed pool.
    function newGroupSelectionSeed() internal {
        // Calculate new group selection seed based on the current seed.
        // We added address of the factory as a key to calculate value different
        // than sortition pool RNG will, so we don't end up selecting almost
        // identical group.
        groupSelectionSeed = uint256(
            keccak256(abi.encodePacked(groupSelectionSeed, address(this)))
        );

        // Call the random beacon to get a random group selection seed.
        (bool success, ) = requestRelayEntry(msg.value);
        if (!success) {
            reseedPool += msg.value;
        }
    }

    /// @notice Requests for a relay entry using the beacon payment provided as
    /// the parameter.
    function requestRelayEntry(uint256 payment)
        internal
        returns (bool, bytes memory)
    {
        return
            address(randomBeacon).call.value(payment)(
                abi.encodeWithSignature(
                    "requestRelayEntry(address,uint256)",
                    address(this),
                    callbackGas
                )
            );
    }

    /// @notice Checks if the caller is the random beacon.
    /// @dev Throws an error if called by any account other than the random beacon.
    modifier onlyRandomBeacon() {
        require(
            address(randomBeacon) == msg.sender,
            "Caller is not the random beacon"
        );
        _;
    }
}
