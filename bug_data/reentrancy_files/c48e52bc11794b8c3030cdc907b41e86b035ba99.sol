pragma solidity ^0.4.2;

contract ContractSplitEther {
  // Addresses to split ether over
  address private recipient1;
  address private recipient2;

  function ContractSplitEther(address _recipient1, address _recipient2)
    validateAddress(_recipient1)
    validateAddress(_recipient2) 
  {
    recipient1 = _recipient1;
    recipient2 = _recipient2;
  }

  function () {
    sendTo(recipient1, this.balance / 2);
    sendTo(recipient2, this.balance);
  }

  // Public
  function getRecipients() returns (address[2]) {
    return [recipient1, recipient2];
  }

  // Private
  function sendTo(address recipient, uint bal) private {
    if (!recipient.send(bal)) throw;
  }

  // Modifiers
  modifier validateAddress (address recipient) {
    if (recipient == 0) throw;
    _;
  }    

}

/*
Also try
 1 using msg.value instead
 2 making payments asynchronous.
*/
