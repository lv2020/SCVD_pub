//IGNORE_LICENSE-Identifier: Unlicense
pragma solidity ^0.8.0;

// IGNORE_LICENSE-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
  function mint(address to, uint256 amount) external;
  function decimals() external returns (uint256);
}

/// @title A Minter contract for Splinterlands
/// @author Splinterlands Team (@fbslo)

contract Minter {
  using SafeMath for uint256;

  /// @notice Address that can change pools
  address public admin;
  /// @notice Address of the token to mint
  address public token;
  /// @notice Block number when mint() was last called
  uint256 public lastMintBlock;
  /// @notice Total number of tokens already minted
  uint256 public totalMinted;
  /// @notice Maximum number of tokens minted, 3B (with 18 decimal places)
  uint256 public cap = 3000000000000000000000000000;

  /// @notice Struct to store information about each pool
  struct Pool {
    address receiver;
    uint256 amountPerBlock;
  }
  /// @notice Array to store all pools
  Pool[] public pools;

  /// @notice Emitted when mint() is called
  event Mint(address receiver, uint256 amount);
  /// @notice Emitted when pool is added
  event PoolAdded(address newReceiver, uint256 newAmount);
  /// @notice Emitted when pool is updated
  event PoolUpdated(uint256 index, address newReceiver, uint256 newAmount);
  /// @notice Emitted when pool is removed
  event PoolRemoved(uint256 index, address receiver, uint256 amount);
  /// @notice Emitted when admin address is updated
  event UpdateAdmin(address admin, address newAdmin);

  /// @notice Modifier to allow only admin to call certain functions
  modifier onlyAdmin(){
    require(msg.sender == admin, '!admin');
    _;
  }

  /**
   * @notice Constructor of new minter contract
   * @param newToken Address of the token to mint
   * @param startBlock Initial lastMint block
   * @param newAdmin Initial admin address
   */
  constructor(address newToken, uint256 startBlock, address newAdmin){
    require(startBlock >= block.number, "Start block must be above current block");
    require(newToken != address(0), 'Token cannot be address 0');

    token = newToken;
    lastMintBlock = startBlock;
    admin = newAdmin;

    emit UpdateAdmin(address(0), newAdmin);
  }

  /**
   * @notice Mint tokens to all pools, can be called by anyone
   */
  function mint() public {
    uint256 mintDifference = block.number - lastMintBlock;

    for (uint256 i = 0; i < pools.length; i++){
      uint256 amount = pools[i].amountPerBlock.mul(mintDifference);

      if(totalMinted + amount >= cap && totalMinted != cap){
        amount = cap.sub(totalMinted);
      }
      require(totalMinted.add(amount) <= cap, "Cap reached");

      IERC20(token).mint(pools[i].receiver, amount);

      totalMinted = totalMinted.add(amount);
      emit Mint(pools[i].receiver, amount);
    }

    lastMintBlock = block.number;
  }

  /**
   * @notice Add new pool, can be called by admin
   * @param newReceiver Address of the receiver
   * @param newAmount Amount of tokens per block
   */
  function addPool(address newReceiver, uint256 newAmount) external onlyAdmin {
    pools.push(Pool(newReceiver, newAmount));
    emit PoolAdded(newReceiver, newAmount);
  }

  /**
   * @notice Update pool, can be called by admin
   * @param index Index in the array of the pool
   * @param newReceiver Address of the receiver
   * @param newAmount Amount of tokens per block
   */
  function updatePool(uint256 index, address newReceiver, uint256 newAmount) external onlyAdmin {
    mint();
    pools[index] = Pool(newReceiver, newAmount);
    emit PoolUpdated(index, newReceiver, newAmount);
  }

  /**
   * @notice Remove pool, can be called by admin
   * @param index Index in the array of the pool
   */
  function removePool(uint256 index) external onlyAdmin {
    mint();
    address oldReceiver = pools[index].receiver;
    uint256 oldAmount = pools[index].amountPerBlock;

    pools[index] = pools[pools.length - 1];
    pools.pop();
    emit PoolRemoved(index, oldReceiver, oldAmount);
  }

  /**
   * @notice Update admin address
   * @param newAdmin Address of the new admin
   */
  function updateAdmin(address newAdmin) external onlyAdmin {
    emit UpdateAdmin(admin, newAdmin);
    admin = newAdmin;
  }

  /**
   * @notice View function to get details about certain pool
   * @param index Index in the array of the pool
   */
  function getPool(uint256 index) external view returns (Pool memory pool) {
    return pools[index];
  }

  /// @notice View function to get the length of `pools` array
  function getPoolLength() external view returns (uint256 poolLength) {
    return pools.length;
  }
}
