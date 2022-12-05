pragma solidity 0.5.9;

pragma solidity 0.5.9;

pragma solidity 0.5.9;

interface AdminProxy {
    function isAuthorized(address source) external view returns (bool);
}
pragma solidity 0.5.9;



contract AdminList {
    event AdminAdded(
        bool adminAdded,
        address account,
        string message
    );

    event AdminRemoved(
        bool adminRemoved,
        address account
    );

    address[] public allowlist;
    mapping (address => uint256) private indexOf; //1 based indexing. 0 means non-existent

    function size() internal view returns (uint256) {
        return allowlist.length;
    }

    function exists(address _account) internal view returns (bool) {
        return indexOf[_account] != 0;
    }

    function add(address _account) internal returns (bool) {
        if (indexOf[_account] == 0) {
            indexOf[_account] = allowlist.push(_account);
            return true;
        }
        return false;
    }

    function addAll(address[] memory accounts) internal returns (bool) {
        bool allAdded = true;
        for (uint i = 0; i<accounts.length; i++) {
            if (msg.sender == accounts[i]) {
                emit AdminAdded(false, accounts[i], "Adding own account as Admin is not permitted");
                allAdded = allAdded && false;
            } else if (exists(accounts[i])) {
                emit AdminAdded(false, accounts[i], "Account is already an Admin");
                allAdded = allAdded && false;
            }  else {
                bool result = add(accounts[i]);
                string memory message = result ? "Admin account added successfully" : "Account is already an Admin";
                emit AdminAdded(result, accounts[i], message);
                allAdded = allAdded && result;
            }
        }

        return allAdded;
    }

    function remove(address _account) internal returns (bool) {
        uint256 index = indexOf[_account];
        if (index > 0 && index <= allowlist.length) { //1-based indexing
            //move last address into index being vacated (unless we are dealing with last index)
            if (index != allowlist.length) {
                address lastAccount = allowlist[allowlist.length - 1];
                allowlist[index - 1] = lastAccount;
                indexOf[lastAccount] = index;
            }

            //shrink array
            allowlist.length -= 1; // mythx-disable-line SWC-101
            indexOf[_account] = 0;
            return true;
        }
        return false;
    }
}


contract Admin is AdminProxy, AdminList {
    modifier onlyAdmin() {
        require(isAuthorized(msg.sender), "Sender not authorized");
        _;
    }

    modifier notSelf(address _address) {
        require(msg.sender != _address, "Cannot invoke method with own account as parameter");
        _;
    }

    constructor() public {
        add(msg.sender);
    }

    function isAuthorized(address _address) public view returns (bool) {
        return exists(_address);
    }

    function addAdmin(address _address) external onlyAdmin returns (bool) {
        if (msg.sender == _address) {
            emit AdminAdded(false, _address, "Adding own account as Admin is not permitted");
            return false;
        } else {
            bool result = add(_address);
            string memory message = result ? "Admin account added successfully" : "Account is already an Admin";
            emit AdminAdded(result, _address, message);
            return result;
        }
    }

    function removeAdmin(address _address) external onlyAdmin notSelf(_address) returns (bool) {
        bool removed = remove(_address);
        emit AdminRemoved(removed, _address);
        return removed;
    }

    function getAdmins() external view returns (address[] memory){
        return allowlist; // mythx-disable-line SWC-128
    }

    function addAdmins(address[] calldata accounts) external onlyAdmin returns (bool) {
        return addAll(accounts);
    }
}
pragma solidity 0.5.9;

pragma solidity 0.5.9;

interface NodeRulesProxy {
    function connectionAllowed(
        string calldata enodeId,
        string calldata enodeHost,
        uint16 enodePort
    ) external view returns (bool);
}
pragma solidity 0.5.9;



contract Ingress {
    // Contract keys
    bytes32 public RULES_CONTRACT = 0x72756c6573000000000000000000000000000000000000000000000000000000; // "rules"
    bytes32 public ADMIN_CONTRACT = 0x61646d696e697374726174696f6e000000000000000000000000000000000000; // "administration"

    // Registry mapping indexing
    mapping(bytes32 => address) internal registry;

    bytes32[] internal contractKeys;
    mapping (bytes32 => uint256) internal indexOf; //1 based indexing. 0 means non-existent

    event RegistryUpdated(
        address contractAddress,
        bytes32 contractName
    );

    function getContractAddress(bytes32 name) public view returns(address) {
        require(name > 0, "Contract name must not be empty.");
        return registry[name];
    }

    function getSize() external view returns (uint256) {
        return contractKeys.length;
    }

    function isAuthorized(address account) public view returns(bool) {
        if (registry[ADMIN_CONTRACT] == address(0)) {
            return true;
        } else {
            return AdminProxy(registry[ADMIN_CONTRACT]).isAuthorized(account);
        }
    }

    function setContractAddress(bytes32 name, address addr) external returns (bool) {
        require(name > 0, "Contract name must not be empty.");
        require(addr != address(0), "Contract address must not be zero.");
        require(isAuthorized(msg.sender), "Not authorized to update contract registry.");

        if (indexOf[name] == 0) {
            indexOf[name] = contractKeys.push(name);
        }

        registry[name] = addr;

        emit RegistryUpdated(addr, name);

        return true;
    }

    function removeContract(bytes32 _name) external returns(bool) {
        require(_name > 0, "Contract name must not be empty.");
        require(contractKeys.length > 0, "Must have at least one registered contract to execute delete operation.");
        require(isAuthorized(msg.sender), "Not authorized to update contract registry.");

        uint256 index = indexOf[_name];
        if (index > 0 && index <= contractKeys.length) { //1-based indexing
            //move last address into index being vacated (unless we are dealing with last index)
            if (index != contractKeys.length) {
                bytes32 lastKey = contractKeys[contractKeys.length - 1];
                contractKeys[index - 1] = lastKey;
                indexOf[lastKey] = index;
            }

            //shrink contract keys array
            contractKeys.pop();
            indexOf[_name] = 0;
            registry[_name] = address(0);
            emit RegistryUpdated(address(0), _name);
            return true;
        }
        return false;
    }

    function getAllContractKeys() external view returns(bytes32[] memory) {
        return contractKeys; // mythx-disable-line SWC-128
    }
}


contract NodeIngress is Ingress {
    // version of this contract: semver eg 1.2.14 represented like 001002014
    uint private version = 1000000;

    event NodePermissionsUpdated(
        bool addsRestrictions
    );

    function getContractVersion() external view returns(uint) {
        return version;
    }

    function emitRulesChangeEvent(bool addsRestrictions) external {
        require(registry[RULES_CONTRACT] == msg.sender, "Only Rules contract can trigger Rules change events");
        emit NodePermissionsUpdated(addsRestrictions);
    }

    function connectionAllowed(
        string calldata enodeId,
        string calldata enodeHost,
        uint16 enodePort
    ) external view returns (bool) {
        if(getContractAddress(RULES_CONTRACT) == address(0)) {
            return false;
        }

        return NodeRulesProxy(registry[RULES_CONTRACT]).connectionAllowed(
            enodeId,
            enodeHost,
            enodePort
        );
    }
}


contract NodeStorage {
    event VersionChange(
        address oldAddress,
        address newAddress
    );
    // initialize this to the deployer of this contract
    address private latestVersion = msg.sender;
    address private owner = msg.sender;

    NodeIngress private ingressContract;



    // struct size = 82 bytes
    struct enode {
        string enodeId;
        string ip;
        uint16 port;
    }

    enode[] public allowlist;
    mapping (uint256 => uint256) private indexOf; //1-based indexing. 0 means non-existent

    constructor (NodeIngress _ingressContract) public {
        ingressContract = _ingressContract;
    }

    modifier onlyLatestVersion() {
        require(msg.sender == latestVersion, "only the latestVersion can modify the list");
        _;
    }

    modifier onlyAdmin() {
        if (address(0) == address(ingressContract)) {
            require(msg.sender == owner, "only owner permitted since ingressContract is explicitly set to zero");
        } else {
            address adminContractAddress = ingressContract.getContractAddress(ingressContract.ADMIN_CONTRACT());

            require(adminContractAddress != address(0), "Ingress contract must have Admin contract registered");
            require(Admin(adminContractAddress).isAuthorized(msg.sender), "Sender not authorized");
        }
        _;
    }

    function upgradeVersion(address _newVersion) public onlyAdmin {
        emit VersionChange(latestVersion, _newVersion);
        latestVersion = _newVersion;
    }

    function size() public view returns (uint256) {
        return allowlist.length;
    }

    function exists(string memory _enodeId, string memory _ip, uint16 _port) public view returns (bool) {
        return indexOf[calculateKey(_enodeId, _ip, _port)] != 0;
    }

    function add(string memory _enodeId, string memory _ip, uint16 _port) public returns (bool) {
        uint256 key = calculateKey(_enodeId, _ip, _port);
        if (indexOf[key] == 0) {
            indexOf[key] = allowlist.push(enode(_enodeId, _ip, _port));
            return true;
        }
        return false;
    }

    function remove(string memory _enodeId, string memory _ip, uint16 _port) public returns (bool) {
        uint256 key = calculateKey(_enodeId, _ip, _port);
        uint256 index = indexOf[key];

        if (index > 0 && index <= allowlist.length) { //1 based indexing
            //move last item into index being vacated (unless we are dealing with last index)
            if (index != allowlist.length) {
                enode memory lastEnode = allowlist[allowlist.length - 1];
                allowlist[index - 1] = lastEnode;
                indexOf[calculateKey(lastEnode.enodeId, lastEnode.ip, lastEnode.port)] = index;
            }

            //shrink array
            allowlist.length -= 1; // mythx-disable-line SWC-101
            indexOf[key] = 0;
            return true;
        }

        return false;
    }

    function getByIndex(uint index) external view returns (string memory enodeId, string memory ip, uint16 port) {
        if (index >= 0 && index < size()) {
            enode memory item = allowlist[index];
            return (item.enodeId, item.ip, item.port);
        }
    }

    function calculateKey(string memory _enodeId, string memory _ip, uint16 _port) public pure returns(uint256) {
        return uint256(keccak256(abi.encodePacked(_enodeId, _ip, _port)));
    }
}
