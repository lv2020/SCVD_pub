pragma solidity ^0.5.0;

pragma solidity ^0.5.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * NOTE: This call _does not revert_ if the signature is invalid, or
     * if the signer is otherwise unable to be retrieved. In those scenarios,
     * the zero address is returned.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract QuickWallet {

    using ECDSA for bytes32;

    // Used to prevent execution of already executed txs
    uint256 public txCount;

    // QuickWallet owner address
    address public _owner;

    /**
     * @dev Constructor
     * @param owner The address of the wallet owner
     */
    constructor(address owner) public {
        _owner = owner;
    }

    /**
     * @dev Call a external contract and pay a fee for the call
     * @param txData encoded data that contains:
       * receiver The address of the contract to call
       * data ABI-encoded contract call to call `_to` address
       * value Amount of ETH in wei to be sent in the call
       * feeToken The token used for the fee, use this wallet address for ETH
       * feeValue The amount to be payed as fee
       * beforeTime timetstamp of the time where this tx cant be executed
       * once it passed
     * @param txSignature The signature of the wallet owner
     * @param feeReceiver The receiver of the fee payment
     */
    function call(bytes memory txData, bytes memory txSignature, address feeReceiver) public payable {
        (address receiver, bytes memory data, uint256 value, address feeToken, uint256 feeValue, uint256 beforeTime) =
          abi.decode(txData, (address, bytes, uint256, address, uint256, uint256));
        require(beforeTime > block.timestamp, "QuickWallet: Invalid beforeTime value");
        require(feeToken != address(0), "QuickWallet: Invalid fee token");

        address _signer = keccak256(abi.encodePacked(
            address(this), txData, txCount
        )).toEthSignedMessageHash().recover(txSignature);
        require(owner() == _signer, "QuickWallet: Signer is not wallet owner");

        _call(receiver, data, value);

        if (feeValue > 0) {
          bytes memory feePaymentData = abi.encodeWithSelector(
              bytes4(keccak256("transfer(address,uint256)")), feeReceiver, feeValue
          );
          _call(feeToken, feePaymentData, 0);
        }

        txCount++;
    }

    /**
     * @dev ERC20 transfer of ETH, can only be called from this contract
     * @param receiver The address to transfer the eth
     * @param value The amount of eth in wei to be transfered
     */
    function transfer(address payable receiver, uint256 value) public {
        require(msg.sender == address(this), "QuickWallet: Transfer cant be called outside contract");
        receiver.transfer(value);
    }

    /**
     * @dev Get QuickWallet owner address
     */
    function owner() public view returns (address) {
      return _owner;
    }

    /**
     * @dev Call a external contract
     * @param _to The address of the contract to call
     * @param _data ABI-encoded contract call to call `_to` address.
     * @param _value The amount of ETH in wei to be sent in the call
     */
    function _call(address _to, bytes memory _data, uint256 _value) internal {
        // solhint-disable-next-line avoid-call-value
        (bool success, bytes memory data) = _to.call.value(_value)(_data);
        require(success, "QuickWallet: Call to external contract failed");
    }

}
