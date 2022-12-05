pragma solidity ^0.5.0;

pragma solidity ^0.5.0;

library SigUtils {
    /**
      @dev Recovers address who signed the message 
      @param _hash operation ethereum signed message hash
      @param _signature message `hash` signature  
    */
    function ecrecover2 (
        bytes32 _hash, 
        bytes memory _signature
    ) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := and(mload(add(_signature, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(_hash, v, r, s);
    }
}
pragma solidity ^0.5.0;

contract Ownable {
    event SetOwner(address _owner);

    address public owner;

    /**
      @dev Setup function sets initial storage of contract.
      @param _owner List of signer.
    */
    function _init(address _owner) internal {
        require(owner == address(0), "Owner already defined");
        owner = _owner;
        emit SetOwner(_owner);
    }

    function isOwner(address _owner) public view returns (bool) {
        return _owner != address(0) && owner == _owner;
    }
}

contract Marmo is Ownable {
    event Relayed(
        bytes32 indexed _id,
        bytes32[] _dependencies,
        address _to,
        uint256 _value,
        bytes _data,
        bytes32 _salt,
        uint256 _expiration,
        bool _success
    );

    event Canceled(
        bytes32 _id
    );

    // [1 bit (canceled) 95 bits (block) 160 bits (relayer)]
    mapping(bytes32 => bytes32) private intentReceipt;

    function init(address _owner) external {
        _init(_owner);
    }

    function relayedBy(bytes32 _id) external view returns (address _relayer) {
        (,,_relayer) = _decodeReceipt(intentReceipt[_id]);
    }

    function relayedAt(bytes32 _id) external view returns (uint256 _block) {
        (,_block,) = _decodeReceipt(intentReceipt[_id]);
    }

    function isCanceled(bytes32 _id) external view returns (bool _canceled) {
        (_canceled,,) = _decodeReceipt(intentReceipt[_id]);
    }

    function encodeTransactionData(
        bytes32[] memory _dependencies,
        address _to,
        uint256 _value,
        bytes memory _data,
        uint256 _minGasLimit,
        uint256 _maxGasPrice,
        bytes32 _salt,
        uint256 _expiration
    ) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                this,
                keccak256(abi.encodePacked(_dependencies)),
                _to,
                _value,
                keccak256(_data),
                _minGasLimit,
                _maxGasPrice,
                _salt,
                _expiration
            )
        );
    }

    function dependenciesSatisfied(bytes32[] memory _dependencies) internal view returns (bool) {
        for (uint256 i; i < _dependencies.length; i++) {
            (,, address relayer) = _decodeReceipt(intentReceipt[_dependencies[i]]);
            if (relayer == address(0)) return false;
        }
        
        return true;
    }

    function relay(
        bytes32[] memory _dependencies,
        address _to,
        uint256 _value,
        bytes memory _data,
        uint256 _minGasLimit,
        uint256 _maxGasPrice,
        bytes32 _salt,
        uint256 _expiration,
        bytes memory _signature
    ) public returns (
        bool success,
        bytes memory data 
    ) {
        bytes32 id = encodeTransactionData(_dependencies, _to, _value, _data, _minGasLimit, _maxGasPrice, _salt, _expiration);
        
        if(intentReceipt[id] != bytes32(0)) {
            (bool canceled, , address relayer) = _decodeReceipt(intentReceipt[id]);
            require(relayer == address(0), "Intent already relayed");
            require(!canceled, "Intent was canceled");
            revert("Unknown error");
        }

        require(now < _expiration, "Intent is expired");
        require(tx.gasprice <= _maxGasPrice, "Gas price too high");
        require(dependenciesSatisfied(_dependencies), "Parent relay not found");
        address _owner = owner;
        require(msg.sender == _owner || _owner == SigUtils.ecrecover2(id, _signature), "Invalid signature");
        require(gasleft() > _minGasLimit, "gasleft() too low");
        (success, data) = _to.call.value(_value)(_data);

        intentReceipt[id] = _encodeReceipt(false, block.number, msg.sender);
        
        emit Relayed(
            id,
            _dependencies,
            _to,
            _value,
            _data,
            _salt,
            _expiration,
            success
        );
    }

    function cancel(bytes32 _id) external {
        require(msg.sender == address(this), "Only wallet can cancel txs");
        if(intentReceipt[_id] != bytes32(0)) {
            (bool canceled, , address relayer) = _decodeReceipt(intentReceipt[_id]);
            require(relayer == address(0), "Intent already relayed");
            require(!canceled, "Intent was canceled");
            revert("Unknown error");
        }

        intentReceipt[_id] = _encodeReceipt(true, 0, address(0));
    }

    function _encodeReceipt(
        bool _canceled,
        uint256 _block,
        address _relayer
    ) internal pure returns (bytes32 _receipt) {
        assembly {
            _receipt := or(shl(255, _canceled), or(shl(160, _block), _relayer))
        }
    }
    
    function _decodeReceipt(bytes32 _receipt) internal pure returns (
        bool _canceled,
        uint256 _block,
        address _relayer
    ) {
        assembly {
            _canceled := shr(255, _receipt)
            _block := and(shr(160, _receipt), 0x7fffffffffffffffffffffff)
            _relayer := and(_receipt, 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }

    function() external payable {}
}
