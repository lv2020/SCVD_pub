//IGNORE_LICENSE-Identifier: Unlicense
pragma solidity ^0.8.0;

contract ChequeBank {
    struct ChequeInfo {
        uint256 amount;
        bytes32 chequeId;
        uint32 validFrom;
        uint32 validThru;
        address payee;
        address payer;
    }

    struct SignOverInfo {
        uint8 counter;
        bytes32 chequeId;
        address oldPayee;
        address newPayee;
    }

    struct Cheque {
        ChequeInfo chequeInfo;
        bytes sig;
    }

    struct SignOver {
        SignOverInfo signOverInfo;
        bytes sig;
    }

    mapping(address => uint256) _balances;

    modifier hasEnoughBalance(uint256 amount) {
        require(
            amount <= _balances[msg.sender],
            "not enough balance to withdraw"
        );
        _;
    }

    function deposit() external payable {
        if (msg.value > 0) {
            _balances[msg.sender] += msg.value;
        }
    }

    function withdraw(uint256 amount) external hasEnoughBalance(amount) {
        payable(msg.sender).transfer(amount);
        _balances[msg.sender] -= amount;
    }

    function withdrawTo(uint256 amount, address payable recipient)
        external
        hasEnoughBalance(amount)
    {
        recipient.transfer(amount);
        _balances[msg.sender] -= amount;
    }

    function balanceOf() external view returns (uint256) {
        return _balances[msg.sender];
    }

    function redeem(Cheque memory chequeData) external {}

    function revoke(bytes32 chequeId) external {}

    function notifySignOver(SignOver memory signOverData) external {}

    function redeemSignOver(
        Cheque memory chequeData,
        SignOver[] memory signOverData
    ) external {}

    function isChequeValid(
        address payee,
        Cheque memory chequeData,
        SignOver[] memory signOverData
    ) public view returns (bool) {}
}
