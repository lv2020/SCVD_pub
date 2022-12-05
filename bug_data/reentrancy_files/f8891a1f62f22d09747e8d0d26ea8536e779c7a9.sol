pragma solidity 0.4.15;

pragma solidity 0.4.15;


pragma solidity 0.4.15;

pragma solidity 0.4.15;


contract IBasicToken {

////////////////
// Events
////////////////

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount);

///////////////////
// Methods
///////////////////

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply()
        public
        constant
        returns (uint);

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner)
        public
        constant
        returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount)
        public
        returns (bool success);

}
pragma solidity 0.4.15;

contract IERC20Allowance {

////////////////
// Events
////////////////

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount);

///////////////////
// ERC20 Basic Methods
///////////////////

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256 remaining);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount)
        public
        returns (bool success);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount)
        public
        returns (bool success);

}

contract IERC20Token is IBasicToken, IERC20Allowance {

}
pragma solidity 0.4.15;


pragma solidity 0.4.15;


contract Math {

    function absDiff(uint256 v1, uint256 v2) public constant returns(uint256) {
        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

    function divRound(uint256 v, uint256 d) public constant returns(uint256) {
        // round up if % is half or more
        return (v + (d/2)) / d;
    }

    function fraction(uint256 amount, uint256 frac) public constant returns(uint256) {
        return divRound(mul(amount, frac), 10**18);
    }

    function proportion(uint256 amount, uint256 part, uint256 total) public constant returns(uint256) {
        return divRound(mul(amount, part), total);
    }

    function isSafeMultiplier(uint256 m) public constant returns(bool) {
        return m < 2**128;
    }

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
      return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is IBasicToken, Math {

  mapping(address => uint256) balances;

  uint256 public totalSupply;

  /// @dev This function makes it easy to get the total number of tokens
  /// @return The total number of tokens
  function totalSupply()
      public
      constant
      returns (uint256)
  {
      return totalSupply;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = sub(balances[msg.sender], _value);
    balances[_to] = add(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is IERC20Token, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = add(balances[_to], _value);
    balances[_from] = sub(balances[_from], _value);
    allowed[_from][msg.sender] = sub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}
pragma solidity 0.4.15;


contract ITokenWithDeposit is IERC20Token {

    function deposit(address to, uint256 amount) payable returns (bool);
    function withdraw(uint256 amount);

    event Deposit(address indexed to, uint amount);
    event Withdrawal(address indexed to, uint amount);
}
pragma solidity 0.4.15;

contract IERC667Callback {

    function receiveApproval(
        address from,
        uint256 amount,
        address token, // IERC667Token
        bytes data
    )
        public
        returns (bool success);

}

contract EtherToken is StandardToken, ITokenWithDeposit {

    // Constant token specific fields
    string public constant name = "Ether Token";
    string public constant symbol = "ETH-T";
    uint public constant decimals = 18;

    // disable default function
    function() { revert(); }

    function approveAndCall(address _spender, uint256 _amount, bytes _extraData)
        returns (bool success)
    {
        require(approve(_spender, _amount));

        success = IERC667Callback(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return success;
    }

    /// deposit 'amount' of Ether to account 'to'
    function deposit(address to, uint256 amount)
        payable
        public
        returns (bool)
    {
        // must have as much ether as declared
        require(msg.value == amount);
        balances[to] = add(balances[to], amount);
        totalSupply = add(totalSupply, amount);
        Deposit(to, amount);
        return true;
    }

    /// withdraws and sends 'amount' of ether to msg.sender
    function withdraw(uint256 amount)
        public
    {
        require(balances[msg.sender] >= amount);
        assert(msg.sender.send(amount));
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        Withdrawal(msg.sender, amount);
    }
}
