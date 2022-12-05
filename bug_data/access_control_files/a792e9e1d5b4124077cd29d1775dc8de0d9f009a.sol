pragma solidity <=0.7.0;

pragma solidity <=0.7.0;

contract Gravity {
    mapping(uint256=>address[]) public rounds;
    uint256 public bftValue;
    uint256 public lastRound;

    constructor(address[] memory consuls, uint256 newBftValue) public {
        rounds[0] = consuls;
        bftValue = newBftValue;
    }

    function getConsuls() external view returns(address[] memory) {
        return rounds[lastRound];
    }

    function getConsulsByRoundId(uint256 roundId) external view returns(address[] memory) {
        return rounds[roundId];
    }

    function updateConsuls(address[] memory newConsuls, uint8[] memory v, bytes32[] memory r, bytes32[] memory s, uint256 roundId) public {
        uint256 count = 0;

        require(roundId > lastRound, "round less last round");

        bytes32 dataHash = hashNewConsuls(newConsuls, roundId);

        address[] memory consuls = rounds[lastRound];
        for(uint i = 0; i < consuls.length; i++) {
            count += ecrecover(dataHash, v[i], r[i], s[i]) == consuls[i] ? 1 : 0;
        }
        require(count >= bftValue, "invalid bft count");

        rounds[roundId] = newConsuls;
        lastRound = roundId;
    }

    function hashNewConsuls(address[] memory newConsuls, uint256 roundId) public pure returns(bytes32) {
        bytes memory data;
        for(uint i = 0; i < newConsuls.length; i++) {
            data = abi.encodePacked(data, newConsuls[i]);
        }
        

        return keccak256(abi.encodePacked(data, roundId));
    }

}
pragma solidity <=0.7;

library QueueLib {
    struct Queue {
        bytes32 first;
        bytes32 last;
        mapping(bytes32 => bytes32) nextElement;
        mapping(bytes32 => bytes32) prevElement;
    }

    function drop(Queue storage queue, bytes32 rqHash) public {
        bytes32 prevElement = queue.prevElement[rqHash];
        bytes32 nextElement = queue.nextElement[rqHash];

        if (prevElement != bytes32(0)) {
            queue.nextElement[prevElement] = nextElement;
        } else {
            queue.first = nextElement;
        }

        if (nextElement != bytes32(0)) {
            queue.prevElement[nextElement] = prevElement;
        } else {
            queue.last = prevElement;
        }
    }

    // function next(Queue storage queue, bytes32 startRqHash) public view returns(bytes32) {
    //     if (startRqHash == 0x000)
    //         return queue.first;
    //     else {
    //         return queue.nextElement[startRqHash];
    //     }
    // }

    function push(Queue storage queue, bytes32 elementHash) public {
        if (queue.first == 0x000) {
            queue.first = elementHash;
            queue.last = elementHash;
        } else {
            queue.nextElement[queue.last] = elementHash;
            queue.prevElement[elementHash] = queue.last;
            queue.nextElement[elementHash] = bytes32(0);
            queue.last = elementHash;
        }
    }
}
pragma solidity <=0.7.0;

library NModels {
    uint8 constant oracleCountInEpoch = 5;

    enum DataType {
        Int64,
        String,
        Bytes
    }

    struct Subscription {
        address owner;
        address payable contractAddress;
        uint8 minConfirmations;
        uint256 reward;
    }

    struct Pulse {
        bytes32 dataHash;
        uint256 height;
    }

    struct Oracle {
        address owner;
        bool isOnline;
        bytes32 idInQueue;
    }
}
pragma solidity <=0.7.0;

interface ISubscriberBytes {
    function attachValue(bytes calldata value) external;
}
pragma solidity <=0.7.0;

interface ISubscriberInt {
    function attachValue(int64 value) external;
}
pragma solidity <=0.7.0;

interface ISubscriberString {
    function attachValue(string calldata value) external;
}


contract Nebula {
    event NewPulse(uint256 pulseId, uint256 height, bytes32 dataHash);
    event NewSubscriber(bytes32 id);

    mapping(uint256=>bool) public rounds;

    QueueLib.Queue public oracleQueue;
    QueueLib.Queue public subscriptionsQueue;
    QueueLib.Queue public pulseQueue;

    address[] public oracles;
    uint256 public bftValue;
    address public gravityContract;
    NModels.DataType public dataType;

    bytes32[] public subscriptionIds;
    uint256 public lastPulseId;
    mapping(bytes32 => NModels.Subscription) public subscriptions;
    mapping(uint256 => NModels.Pulse) public pulses;
    mapping(uint256 => mapping(bytes32 => bool)) public isPulseSubSent;

    constructor(NModels.DataType newDataType, address newGravityContract, address[] memory newOracle, uint256 newBftValue) public {
        dataType = newDataType;
        oracles = newOracle;
        bftValue = newBftValue;
        gravityContract = newGravityContract;
    }
    
    receive() external payable { } 

    //----------------------------------public getters--------------------------------------------------------------

    function getOracles() public view returns(address[] memory) {
        return oracles;
    }

    function getSubscribersIds() public view returns(bytes32[] memory) {
        return subscriptionIds;
    }

    function hashNewOracles(address[] memory newOracles) public pure returns(bytes32) {
        bytes memory data;
        for(uint i = 0; i < newOracles.length; i++) {
            data = abi.encodePacked(data, newOracles[i]);
        }

        return keccak256(data);
    }

    //----------------------------------public setters--------------------------------------------------------------

    function sendHashValue(bytes32 dataHash, uint8[] memory v, bytes32[] memory r, bytes32[] memory s) public {
        uint256 count = 0;

        for(uint i = 0; i < oracles.length; i++) {
            count += ecrecover(dataHash,
                v[i], r[i], s[i]) == oracles[i] ? 1 : 0;
        }

        require(count >= bftValue, "invalid bft count");
        
        uint256 newPulseId = lastPulseId + 1;
        pulses[newPulseId] = NModels.Pulse(dataHash, block.number);

        emit NewPulse(newPulseId, block.number, dataHash);
        lastPulseId = newPulseId;
    }

    function updateOracles(address[] memory newOracles, uint8[] memory v, bytes32[] memory r, bytes32[] memory s, uint256 newRound) public {
        uint256 count = 0;
        bytes32 dataHash = hashNewOracles(newOracles);
        address[] memory consuls = Gravity(gravityContract).getConsuls();

        for(uint i = 0; i < consuls.length; i++) {
            count += ecrecover(dataHash, v[i], r[i], s[i]) == consuls[i] ? 1 : 0;
        }
        require(count >= bftValue, "invalid bft count");

       oracles = newOracles;
       rounds[newRound] = true;
    }
    
    function validateDataProvider() internal view returns(bool) {
        for(uint i = 0; i < oracles.length; i++) {
            if (oracles[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function sendValueToSubByte(bytes memory value, uint256 pulseId, bytes32 subId) public {
        require(validateDataProvider(), "caller is not one of the oracles");
        sendValueToSub(pulseId, subId);
        ISubscriberBytes(subscriptions[subId].contractAddress).attachValue(value);
    }

    function sendValueToSubInt(int64 value, uint256 pulseId, bytes32 subId) public {
        require(validateDataProvider(), "caller is not one of the oracles");
        sendValueToSub(pulseId, subId);
        ISubscriberInt(subscriptions[subId].contractAddress).attachValue(value);
    }

    function sendValueToSubString(string memory value, uint256 pulseId, bytes32 subId) public {
        require(validateDataProvider(), "caller is not one of the oracles");
        sendValueToSub(pulseId, subId);
        ISubscriberString(subscriptions[subId].contractAddress).attachValue(value);
    }

    //----------------------------------internals---------------------------------------------------------------------

    function sendValueToSub(uint256 pulseId, bytes32 subId) internal {
        require(isPulseSubSent[pulseId][subId] == false, "sub sent");

        isPulseSubSent[pulseId][subId] = true;
    }
    
    function subscribe(address payable contractAddress, uint8 minConfirmations, uint256 reward) public {
        bytes32 id = keccak256(abi.encodePacked(abi.encodePacked(msg.sig, msg.sender, contractAddress, minConfirmations)));
        require(subscriptions[id].owner == address(0x00), "rq exists");
        subscriptions[id] = NModels.Subscription(msg.sender, contractAddress, minConfirmations, reward);
        QueueLib.push(subscriptionsQueue, id);
        subscriptionIds.push(id);
        emit NewSubscriber(id);
    }
}
