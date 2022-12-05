pragma solidity ^0.4.24;

pragma solidity ^0.4.24;

// Import the library 'Roles'
pragma solidity ^0.4.24;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}

// Define a contract 'FarmerRole' to manage this role - add, remove, check
contract FarmerRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event FarmerAdded(address indexed account);
    event FarmerRemoved(address indexed account);

    // Define a struct 'farmers' by inheriting from 'Roles' library, struct Role
    Roles.Role private farmers;

    // In the constructor make the address that deploys this contract the 1st farmer
    constructor() public {
        _addFarmer(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyFarmer() {
        require(isFarmer(msg.sender));
        _;
    }

    // Define a function 'isFarmer' to check this role
    function isFarmer(address account) public view returns (bool) {
        return farmers.has(account);
    }

    // Define a function 'addFarmer' that adds this role
    function addFarmer(address account) public onlyFarmer {
        _addFarmer(account);
    }

    // Define a function 'renounceFarmer' to renounce this role
    function renounceFarmer() public {
        _removeFarmer(msg.sender);
    }

    // Define an internal function '_addFarmer' to add this role, called by 'addFarmer'
    function _addFarmer(address account) internal {
        farmers.add(account);
        emit FarmerAdded(account);
    }

    // Define an internal function '_removeFarmer' to remove this role, called by 'removeFarmer'
    function _removeFarmer(address account) internal {
        farmers.remove(account);
        emit FarmerRemoved(account);
    }
}
pragma solidity ^0.4.24;

// Import the library 'Roles'

// Define a contract 'DistributorRole' to manage this role - add, remove, check
contract DistributorRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event DistributorAdded(address indexed account);
    event DistributorRemoved(address indexed account);

    // Define a struct 'distributors' by inheriting from 'Roles' library, struct Role
    Roles.Role private distributors;

    // In the constructor make the address that deploys this contract the 1st distributor
    constructor() public {
        _addDistributor(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyDistributor() {
        require(isDistributor(msg.sender));
        _;
    }

    // Define a function 'isDistributor' to check this role
    function isDistributor(address account) public view returns (bool) {
        return distributors.has(account);
    }

    // Define a function 'addDistributor' that adds this role
    function addDistributor(address account) public onlyDistributor {
        _addDistributor(account);
    }

    // Define a function 'renounceDistributor' to renounce this role
    function renounceDistributor() public {
        _removeDistributor(msg.sender);
    }

    // Define an internal function '_addDistributor' to add this role, called by 'addDistributor'
    function _addDistributor(address account) internal {
        distributors.add(account);
        emit DistributorAdded(account);
    }

    // Define an internal function '_removeDistributor' to remove this role, called by 'removeDistributor'
    function _removeDistributor(address account) internal {
        distributors.remove(account);
        emit DistributorRemoved(account);
    }
}
pragma solidity ^0.4.24;

// Import the library 'Roles'

// Define a contract 'RetailerRole' to manage this role - add, remove, check
contract RetailerRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event RetailerAdded(address indexed account);
    event RetailerRemoved(address indexed account);

    // Define a struct 'retailers' by inheriting from 'Roles' library, struct Role
    Roles.Role private retailers;

    // In the constructor make the address that deploys this contract the 1st retailer
    constructor() public {
        _addRetailer(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyRetailer() {
        require(isRetailer(msg.sender));
        _;
    }

    // Define a function 'isRetailer' to check this role
    function isRetailer(address account) public view returns (bool) {
        return retailers.has(account);
    }

    // Define a function 'addRetailer' that adds this role
    function addRetailer(address account) public onlyRetailer {
        _addRetailer(account);
    }

    // Define a function 'renounceRetailer' to renounce this role
    function renounceRetailer() public {
        _removeRetailer(msg.sender);
    }

    // Define an internal function '_addRetailer' to add this role, called by 'addRetailer'
    function _addRetailer(address account) internal {
        retailers.add(account);
        emit RetailerAdded(account);
    }

    // Define an internal function '_removeRetailer' to remove this role, called by 'removeRetailer'
    function _removeRetailer(address account) internal {
        retailers.remove(account);
        emit RetailerRemoved(account);
    }
}
pragma solidity ^0.4.24;

// Import the library 'Roles'

// Define a contract 'ConsumerRole' to manage this role - add, remove, check
contract ConsumerRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event ConsumerAdded(address indexed account);
    event ConsumerRemoved(address indexed account);

    // Define a struct 'consumers' by inheriting from 'Roles' library, struct Role
    Roles.Role private consumers;

    // In the constructor make the address that deploys this contract the 1st retailer
    constructor() public {
        _addConsumer(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyConsumer() {
        require(isConsumer(msg.sender));
        _;
    }

    // Define a function 'isConsumer' to check this role
    function isConsumer(address account) public view returns (bool) {
        return consumers.has(account);
    }

    // Define a function 'addConsumer' that adds this role
    function addConsumer(address account) public onlyConsumer {
        _addConsumer(account);
    }

    // Define a function 'renounceConsumer' to renounce this role
    function renounceConsumer() public {
        _removeConsumer(msg.sender);
    }

    // Define an internal function '_addConsumer' to add this role, called by 'addConsumer'
    function _addConsumer(address account) internal {
        consumers.add(account);
        emit ConsumerAdded(account);
    }

    // Define an internal function '_removeConsumer' to remove this role, called by 'removeConsumer'
    function _removeConsumer(address account) internal {
        consumers.remove(account);
        emit ConsumerRemoved(account);
    }
}
pragma solidity ^0.4.24;

/// Provides basic authorization control
contract Ownable {
    address private origOwner;

    // Define an Event
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// Assign the contract to an owner
    constructor() internal {
        origOwner = msg.sender;
        emit TransferOwnership(address(0), origOwner);
    }

    /// Look up the address of the owner
    function owner() public view returns (address) {
        return origOwner;
    }

    /// Define a function modifier 'onlyOwner'
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /// Check if the calling address is the owner of the contract
    function isOwner() public view returns (bool) {
        return msg.sender == origOwner;
    }

    /// Define a function to renounce ownerhip
    function renounceOwnership() public onlyOwner {
        emit TransferOwnership(origOwner, address(0));
        origOwner = address(0);
    }

    /// Define a public function to transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /// Define an internal function to transfer ownership
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit TransferOwnership(origOwner, newOwner);
        origOwner = newOwner;
    }
}

// Define a contract 'Supplychain'
contract SupplyChain is RetailerRole, FarmerRole, ConsumerRole, DistributorRole {
    // Define a variable called 'upc' for Universal Product Code (UPC)
    uint256 upc;

    // Define a variable called 'sku' for Stock Keeping Unit (SKU)
    uint256 sku;

    // Define a public mapping 'items' that maps the UPC to an Item.
    mapping(uint256 => Item) items;

    // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash,
    // that track its journey through the supply chain -- to be sent from DApp.
    mapping(uint256 => string[]) itemsHistory;

    // Define enum 'State' with the following values:
    enum State {
        Harvested, // 0
        Processed, // 1
        Packed, // 2
        ForSale, // 3
        Sold, // 4
        Shipped, // 5
        Received, // 6
        Purchased // 7
    }

    State constant defaultState = State.Harvested;

    // Define a struct 'Item' with the following fields:
    struct Item {
        uint256 sku; // Stock Keeping Unit (SKU)
        uint256 upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
        address ownerID; // Metamask-Ethereum address of the current owner as the product moves through 8 stages
        address originFarmerID; // Metamask-Ethereum address of the Farmer
        string originFarmName; // Farmer Name
        string originFarmInformation; // Farmer Information
        string originFarmLatitude; // Farm Latitude
        string originFarmLongitude; // Farm Longitude
        uint256 productID; // Product ID potentially a combination of upc + sku
        string productNotes; // Product Notes
        uint256 productPrice; // Product Price
        State itemState; // Product State as represented in the enum above
        address distributorID; // Metamask-Ethereum address of the Distributor
        address retailerID; // Metamask-Ethereum address of the Retailer
        address consumerID; // Metamask-Ethereum address of the Consumer
    }

    // Define 8 events with the same 8 state values and accept 'upc' as input argument
    event Harvested(uint256 upc);
    event Processed(uint256 upc);
    event Packed(uint256 upc);
    event ForSale(uint256 upc);
    event Sold(uint256 upc);
    event Shipped(uint256 upc);
    event Received(uint256 upc);
    event Purchased(uint256 upc);

    // Define a modifer that verifies the Caller
    modifier verifyCaller(uint256 _upc) {
        require(msg.sender == items[_upc].ownerID);
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    // Define a modifier that checks the price and refunds the remaining balance
    modifier checkValue(uint256 _upc) {
        _;
        uint256 _price = items[_upc].productPrice;
        uint256 amountToReturn = msg.value - _price;
        items[_upc].consumerID.transfer(amountToReturn);
    }

    // Define a modifier that checks if an item.state of a upc is Harvested
    modifier harvested(uint256 _upc) {
        require(items[_upc].itemState == State.Harvested);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Processed
    modifier processed(uint256 _upc) {
        require(items[_upc].itemState == State.Processed);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Packed
    modifier packed(uint256 _upc) {
        require(items[_upc].itemState == State.Packed);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is ForSale
    modifier forSale(uint256 _upc) {
        require(items[_upc].itemState == State.ForSale);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Sold
    modifier sold(uint256 _upc) {
        require(items[_upc].itemState == State.Sold);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Shipped
    modifier shipped(uint256 _upc) {
        require(items[_upc].itemState == State.Shipped);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Received
    modifier received(uint256 _upc) {
        require(items[_upc].itemState == State.Received);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Purchased
    modifier purchased(uint256 _upc) {
        require(items[_upc].itemState == State.Purchased);
        _;
    }

    // Set 'sku' to 1
    // Set 'upc' to 1
    constructor() public payable {
        sku = 1;
        upc = 1;
    }

    // Define a function 'kill' if required
    //function kill() public onlyOwner {
    //    selfdestruct(owner());
    //}

    // Define a function 'harvestItem' that allows a farmer to mark an item 'Harvested'
    function harvestItem(
        uint256 _upc,
        address _originFarmerID,
        string _originFarmName,
        string _originFarmInformation,
        string _originFarmLatitude,
        string _originFarmLongitude,
        string _productNotes
    ) public {
        // Add the new item as part of Harvest
        uint256 productID = _upc + sku;
        Item memory newItem = Item(
            sku,
            upc,
            msg.sender,
            _originFarmerID,
            _originFarmName,
            _originFarmInformation,
            _originFarmLatitude,
            _originFarmLongitude,
            productID,
            _productNotes,
            0,
            defaultState,
            0x0,
            0x0,
            0x0
        );
        items[_upc] = newItem;

        // Add new farmer
        addFarmer(_originFarmerID);

        // Increment sku
        sku = sku + 1;

        // Emit the appropriate event
        emit Harvested(_upc);
    }

    // Define a function 'processtItem' that allows a farmer to mark an item 'Processed'
    function processItem(uint256 _upc)
        public
        onlyFarmer
        harvested(_upc)
    {
        // Update the appropriate fields
        Item memory item = items[_upc];
        item.itemState = State.Processed;
        items[_upc] = item;

        // Emit the appropriate event
        emit Processed(_upc);
    }

    // Define a function 'packItem' that allows a farmer to mark an item 'Packed'
    function packItem(uint256 _upc)
        public
        onlyFarmer
        processed(_upc)
    {
        // Update the appropriate fields
        Item memory item = items[_upc];
        item.itemState = State.Packed;
        items[_upc] = item;

        // Emit the appropriate event
        emit Packed(_upc);
    }

    // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
    function sellItem(uint256 _upc, uint256 _price)
        public
        onlyFarmer
        packed(_upc)
    {
        // Update the appropriate fields
        Item memory item = items[_upc];
        item.itemState = State.ForSale;
        item.productPrice = _price;
        items[_upc] = item;

        // Emit the appropriate event
        emit ForSale(_upc);
    }

    // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
    // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough,
    // and any excess ether sent is refunded back to the buyer
    function buyItem(uint256 _upc)
        public
        payable
        forSale(_upc)
        paidEnough(_upc)
        checkValue(_upc)
    {
        // Update the appropriate fields - ownerID, distributorID, itemState
        Item memory item = items[_upc];
        item.itemState = State.Sold;
        item.ownerID = msg.sender;
        item.distributorID = msg.sender;
        items[_upc] = item;

        // Add Distributor
        //addDistributor(msg.sender);

        // Transfer money to farmer
        item.originFarmerID.transfer(item.productPrice);

        // emit the appropriate event
        emit Sold(_upc);
    }

    // Define a function 'shipItem' that allows the distributor to mark an item 'Shipped'
    // Use the above modifers to check if the item is sold
    function shipItem(uint256 _upc)
        public
        onlyDistributor
        sold(_upc)
    {
        // Update the appropriate fields
        Item memory item = items[_upc];
        item.itemState = State.Shipped;
        items[_upc] = item;

        // emit the appropriate event
        emit Shipped(_upc);
    }

    // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
    // Use the above modifiers to check if the item is shipped
    function receiveItem(uint256 _upc)
        public
        shipped(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    {
        // Update the appropriate fields - ownerID, distributorID, itemState
        Item memory item = items[_upc];
        item.itemState = State.Received;
        item.ownerID = msg.sender;
        item.retailerID = msg.sender;
        items[_upc] = item;

        // Add Retailer
        addRetailer(msg.sender);

        // emit the appropriate event
        emit Received(_upc);
    }

    // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
    // Use the above modifiers to check if the item is received
    function purchaseItem(uint256 _upc)
        public
        received(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    {
        // Update the appropriate fields - ownerID, distributorID, itemState
        Item memory item = items[_upc];
        item.itemState = State.Purchased;
        item.ownerID = msg.sender;
        item.consumerID = msg.sender;
        items[_upc] = item;

        // Add Consumer
        addConsumer(msg.sender);

        // emit the appropriate event
        emit Purchased(upc);
    }

    // Define a function 'fetchItemBufferOne' that fetches the data
    function fetchItemBufferOne(uint256 _upc)
        public
        view
        returns (
            uint256 itemSKU,
            uint256 itemUPC,
            address ownerID,
            address originFarmerID,
            string originFarmName,
            string originFarmInformation,
            string originFarmLatitude,
            string originFarmLongitude
        )
    {
        // Assign values to the 8 parameters
        Item memory item = items[_upc];

        return (
            item.sku,
            item.upc,
            item.ownerID,
            item.originFarmerID,
            item.originFarmName,
            item.originFarmInformation,
            item.originFarmLatitude,
            item.originFarmLongitude
        );
    }

    // Define a function 'fetchItemBufferTwo' that fetches the data
    function fetchItemBufferTwo(uint256 _upc)
        public
        view
        returns (
            uint256 itemSKU,
            uint256 itemUPC,
            uint256 productID,
            string productNotes,
            uint256 productPrice,
            uint256 itemState,
            address distributorID,
            address retailerID,
            address consumerID
        )
    {
        // Assign values to the 9 parameters
        Item memory item = items[_upc];

        return (
            item.sku,
            item.upc,
            item.productID,
            item.productNotes,
            item.productPrice,
            uint256(item.itemState),
            item.distributorID,
            item.retailerID,
            item.consumerID
        );
    }
}
