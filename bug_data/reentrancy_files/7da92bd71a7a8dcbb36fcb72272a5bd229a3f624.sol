pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

library Warehouse {

  /*
    State: status of item listed for ForSale
    Status: privileges granted to a user
  */

  enum State {ForSale, Sold}
  enum Status {Shopper, Admin, Storeowner}

  struct Store {
    address storeowner;
    uint[] items;
  }

  struct Item {
    uint place;
    uint sku;
    string name;
    uint price;
    State state;
    address seller;
    address buyer;
  }

  /** @dev Update item status to Sold
    * @param self The item that was sold
    */
  function updateItemSold(Item storage self)
    public
  {
    self.state = State.Sold;
  }

}

contract Marketplace {

  // set owner
  address public owner;

  // circuit breaker

  bool public stopped = false;

  /*
    storeId: total number of stores opened
    itemId: total number of items listed
  */
  uint public storeId;
  uint public itemId;

  /*
    userStatus: privileges granted to addresses
    storeOwnerList: stores owned by each address
    storeList: storeId mapped to Store
    itemList: itemId mapped to Item
  */
  mapping (address => Warehouse.Status) public userStatus;
  mapping (address => uint[]) public storeownerList;
  mapping (uint => Warehouse.Store) public storeList;
  mapping (uint => Warehouse.Item) public itemList;

  event AdminAdded(address newAdmin);
  event StoreownerAdded(address storeOwner);

  event StoreOpened(address storeowner, uint storeId);
  event StoreClosed(address storeowner, uint storeId);

  event ItemListed(uint storeId, uint itemId);
  event ItemSold(uint storeId, uint itemId);
  event ItemUnlisted(uint storeId, uint itemId);

  modifier verifyOwner { require(msg.sender == owner); _;}
  modifier verifyAdmin { require(userStatus[msg.sender] == Warehouse.Status.Admin); _;}
  modifier verifyAdminOrStoreowner { require(userStatus[msg.sender] == Warehouse.Status.Admin || userStatus[msg.sender] == Warehouse.Status.Storeowner); _;}
  modifier verifyBuyerIsNotSeller (uint _sku) { require(itemList[_sku].seller != msg.sender); _;}

  modifier forSale (uint _sku) {require(itemList[_sku].state == Warehouse.State.ForSale); _;}

  modifier paidEnough(uint _price) {require(msg.value >= _price); _;}
  modifier checkValue(uint _sku) {
    _;
    uint _price = itemList[_sku].price;
    uint amountToRefund = msg.value - _price;
    itemList[_sku].buyer.transfer(amountToRefund);
  }

  modifier stopInEmergency { require(!stopped); _;}

  constructor() public {
    owner = msg.sender;
    storeId = 0;
    itemId = 0;

    // initialise contract creator as admin
    userStatus[msg.sender] = Warehouse.Status.Admin;
  }

  /** @dev Sets an address as Admin
    * @param _address Address to be set as Admin
    */
  function addAdmin(address _address) public verifyOwner {
    // ensure address to be added is not already an admin
    require(userStatus[_address] != Warehouse.Status.Admin);

    userStatus[_address] = Warehouse.Status.Admin;
    emit AdminAdded(_address);
  }

  /** @dev Sets an address as storeOwner
    * @param _address Address to be set as Storeowner
    */
  function addStoreowner(address _address)
    public
    stopInEmergency
    verifyAdmin
  {
    // ensure address to be added is not already an admin
    require(userStatus[_address] != Warehouse.Status.Admin);

    // ensure address to be added is not already a storeowner
    require(userStatus[_address] != Warehouse.Status.Storeowner);

    userStatus[_address] = Warehouse.Status.Storeowner;
    emit StoreownerAdded(_address);
  }

  /** @dev Opens a store for the current address
    */

  function openStore()
    public
    stopInEmergency
    verifyAdminOrStoreowner
  {

    Warehouse.Store memory newStore;
    newStore.storeowner = msg.sender;
    storeList[storeId] = newStore;
    storeownerList[msg.sender].push(storeId);

    emit StoreOpened(msg.sender, storeId);

    storeId += 1;

  }

  /** @dev Lists an item for sale
    * @param _storeId The store to list the item
    * @param _name The name of the item
    * @param _price The price of the item
    */
  function listItem(uint _storeId, string _name, uint _price)
    public
    stopInEmergency
    verifyAdminOrStoreowner
  {
    // ensure address is storeowner of the store where item is to be listed
    require(storeList[_storeId].storeowner == msg.sender);

    // ensure name is not empty
    bytes memory tempName = bytes(_name);
    require(tempName.length > 0);

    // ensure price is positive
    require(_price > 0);

    itemList[itemId] = Warehouse.Item({place: _storeId, sku: itemId, name: _name,  price: _price, state: Warehouse.State.ForSale,
      seller: msg.sender, buyer: 0});
    emit ItemListed(_storeId, itemId);
    itemId += 1;
  }

  /** @dev Buys an item listed for sale
    * @param sku The id of the item to be bought
    */
  function buyItem(uint sku)
    public
    payable
    stopInEmergency
    forSale(sku)
    verifyBuyerIsNotSeller(sku)
    paidEnough(itemList[sku].price)
    checkValue(sku)
  {
    itemList[sku].seller.transfer(itemList[sku].price);
    itemList[sku].buyer = msg.sender;
    Warehouse.updateItemSold(itemList[sku]);
    emit ItemSold(itemList[sku].place, sku);
  }

  /** @dev Sets an address as storeOwner
    * @param sku The id of the item which details are sought
    * @return place The store where the item is Listed
    * @return sku The item ID
    * @return name The name of the item
    * @return state Whether the item has been sold
    * @return seller The address of the Seller
    * @return buyer The address of the Buyer (if any)
    */
  function fetchItem(uint _sku)
    public
    view
    returns (uint place, uint sku, string name, uint price, uint state, address seller, address buyer)
  {
    place = itemList[_sku].place;
    sku = itemList[_sku].sku;
    name = itemList[_sku].name;
    price = itemList[_sku].price;
    state = uint(itemList[_sku].state);
    seller = itemList[_sku].seller;
    buyer = itemList[_sku].buyer;
    return (place, sku, name, price, state, seller, buyer);
  }

  /** @dev Return the stores opened by an address
    * @param _address Storeowner address to look up
    * @return stores A list of stores opened by the address given
    */
  function fetchStoresByAddress(address _address)
    public
    view
    returns (uint[] stores)
  {
    stores = storeownerList[_address];
  }

  /** @dev Return the storeowner of a stored
    * @param _storeId The Store to look up
    * @return _storeowner The address of the storeowner
    */
  function fetchStoreowner(uint _storeId)
    public
    view
    returns (address _storeowner)
  {
    _storeowner = storeList[_storeId].storeowner;
  }

  /** @dev Destroy the contract
    */
  function kill()
    public
    verifyOwner
  {
    selfdestruct(owner);
  }

  /** @dev Stop the contract
    */
  function toggleContractActive()
    public
    verifyOwner
  {
    stopped = !stopped;
  }

}
