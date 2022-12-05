// IGNORE_LICENSE-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract SimpleBank {
    //
    // State variables
    //

    /* We want to protect our users balance from other contracts */
    mapping(address => uint) balances;

    /* We want to create a getter function and allow
    contracts to be able to see if a user is enrolled.  */
    mapping(address => bool) enrolled;

    /* Let's make sure everyone knows who owns the bank. */
    address immutable public owner;

    //
    // Events
    //

    event LogEnrolled(address indexed newCustomer);

    event LogDepositMade(address indexed customer, uint indexed amount);

    event LogWithdraw(address indexed customer, uint indexed amount, uint indexed balance);



    //
    // Functions
    //

    constructor() {
        owner = msg.sender;
    }


    // Function to receive Ether
    receive() external payable {}


    /// @notice Get balance
    /// @return The balance of the user
    function getBalance() external view isEnrolled returns(uint){
      return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool) {
        require(!enrolled[msg.sender], "User already enrolled");
        emit LogEnrolled(msg.sender);
        enrolled[msg.sender] = true;

        return true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // This function can receive ether
    // Users should be enrolled before they can make deposits
    function deposit()
      external
      payable
      isEnrolled
      amountIsGreaterZero(msg.value)
      returns (uint)
    {
      emit LogDepositMade(msg.sender, msg.value);
      balances[msg.sender] += msg.value;

      return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @param _withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event
    function withdraw(uint _withdrawAmount)
      external
      isEnrolled
      amountIsGreaterZero(_withdrawAmount)
      hasAmountForWithdraw(_withdrawAmount)
      returns (uint)
    {
      bool result = _withdraw(_withdrawAmount);
      require(result, "Failed withdraw amount");

      return balances[msg.sender];
    }

    /// @notice Withdraw remaining ether from bank
    /// @return bool transaction success
    // Emit the appropriate event
    function withdrawAll()
      external
      isEnrolled
      amountIsGreaterZero(balances[msg.sender])
      returns (bool)
    {
      bool result = _withdraw(balances[msg.sender]);
      require(result, "Failed withdraw all amount");
      return result;
    }

    function _withdraw(uint _withdrawAmount)
      private
      isEnrolled
      hasAmountForWithdraw(_withdrawAmount)
      amountIsGreaterZero(_withdrawAmount)
      returns(bool)
    {
      uint newBalance = balances[msg.sender] - _withdrawAmount;
      emit LogWithdraw(msg.sender, _withdrawAmount, newBalance);
      balances[msg.sender] = newBalance;
      (bool result,) = msg.sender.call{value: _withdrawAmount}("");
      require(result, "Failed withdraw amount");
      return result;
    }

    modifier isEnrolled() {
      require(enrolled[msg.sender], 'need enrollment');
      _;
    }

    modifier hasAmountForWithdraw(uint _withdrawAmount) {
      require(balances[msg.sender] >= _withdrawAmount, "Insufficient balance");
      _;
    }
    
    modifier amountIsGreaterZero(uint _amount) {
      require(_amount > 0, "Amount must be > 0");
      _;
    }

}
