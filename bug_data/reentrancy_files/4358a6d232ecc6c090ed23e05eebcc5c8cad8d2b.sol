pragma solidity ^0.4.24;

pragma solidity ^0.4.24;

contract Ownable {
    event LogChangeOfOwnership(
      address indexed owner,
      address newOwner
    );

    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;

        emit LogChangeOfOwnership(owner, newOwner);
    }
}
pragma solidity ^0.4.24;

library SafeMathLib {
    function multiply(uint a, uint b) public pure returns (uint) {
        if (a == 0) {
          return 0;
        }
        
        uint c = a * b;
        require(c / a == b);

        return c;
    }

    function subtract(uint a, uint b) public pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) public pure returns (uint) {
        uint c = a + b;
        require(c >= a && c >= b);
        return c;
    }
    
    function divide(uint a, uint b) public pure returns (uint256) {
        uint c = a / b;
        return c;
    }
}

contract Marketplace is Ownable {
    event LogUserRegistration(
      address indexed userAddress,
      uint role,
      string contactEmail,
      string contactNumber
    );
    event LogItemForSaleAddition(
      address indexed sellerAddress,
      string name,
      string description,
      uint price
    );
    event LogItemForSaleImageAddition(
      address indexed sellerAddress,
      uint index,
      string imageIpfsHash
    );
    event LogItemForSaleUpdate(
      address indexed sellerAddress,
      uint index,
      string name,
      string description,
      uint price
    );
    event LogItemForSaleDeletion(
      address indexed userAddress,
      string name,
      string description,
      uint price
    );
    event LogItemForSaleImageDeletion(
      address indexed sellerAddress,
      string imageIpfsHash
    );
    event LogItemPurchase(
      address indexed buyerAddress,
      address sellerAddress,
      string name,
      string description,
      uint cutPrice,
      uint commission
    );

    enum Role { Buyer, Seller }
    uint private commission;
    string[] public roles;
    address[] public userAddressIndices;
    mapping (address => User) private users;
    
    constructor() public payable {
        roles.push("Buyer");
        roles.push("Seller");
    }
    
    struct User {
        bool isExist;
        Role role;
        Contact contact;
        Item[] itemsBought;
        Item[] itemsForSale;
    }
    
    struct Contact {
        string email;
        string number;
    }
    
    struct Item {
        string name;
        string description;
        string[] imageIpfsHashes;
        uint price;
    }
    
    modifier onlySeller() {
        require(users[msg.sender].role == Role.Seller,
            "Error: Seller only");
        _;
    }
    
    modifier onlyBuyer() {
        require(users[msg.sender].isExist
          && users[msg.sender].role == Role.Buyer,
            "Error: Buyer only");
        _;
    }
    
    modifier onlyRegistered() {
        require(users[msg.sender].isExist,
            "Error: Registered users only");
        _;
    }
    
    function registerUser(Role role, string email, string number) public {
        users[msg.sender].role = role;
        users[msg.sender].isExist = true;
        users[msg.sender].contact.email = email;
        users[msg.sender].contact.number = number;
        userAddressIndices.push(msg.sender);
        
        emit LogUserRegistration(msg.sender, uint(role), email, number);
    }

    function getUserAddress(uint index) public view returns (address) {
      return userAddressIndices[index];
    }

    function getUserAddressIndicesCount() public view returns (uint) {
      return userAddressIndices.length;
    }
    
    function addItemForSale(string name, string description, uint price)
        public
        onlySeller
    {
        string[] memory imageIpfsHashes;

        require(price > 0,
          "Item price should be at least 1");

        Item memory item = Item({
            name: name,
            description: description,
            imageIpfsHashes: imageIpfsHashes,
            price: price
        });

        users[msg.sender].itemsForSale.push(item);

        emit LogItemForSaleAddition(
          msg.sender,
          name,
          description,
          price
        );
    }
    
    function addImageForItemForSale(uint index, string imageIpfsHash)
        public
        onlySeller
    {
        users[msg.sender].itemsForSale[index].imageIpfsHashes.push(imageIpfsHash);

        emit LogItemForSaleImageAddition(
          msg.sender,
          index,
          imageIpfsHash
        );
    }
    
    function getItemForSaleCount(address sellerAddress)
        public
        view
        returns (uint)
    {
        return users[sellerAddress].itemsForSale.length;
    }
    
    function getItemForSale(address sellerAddress, uint index)
        public
        view
        returns (string, string, uint)
    {
        return (
            users[sellerAddress].itemsForSale[index].name,    
            users[sellerAddress].itemsForSale[index].description,
            users[sellerAddress].itemsForSale[index].price
        );
    }
    
    function getItemForSaleImageCount(
        address sellerAddress,
        uint itemIndex
    )
        public
        view
        returns (uint)
    {
        return (users[sellerAddress].itemsForSale[itemIndex].imageIpfsHashes.length);
    }
    
    function getItemForSaleImage(
        address sellerAddress,
        uint itemIndex,
        uint imageIndex
    )
        public
        view
        returns (string)
    {
        return (users[sellerAddress].itemsForSale[itemIndex].imageIpfsHashes[imageIndex]);
    }

    function purchaseItem(
        address sellerAddress,
        uint itemIndex
    )
        public
        payable
        onlyBuyer
    {
        Item memory item = users[sellerAddress].itemsForSale[itemIndex];

        require(msg.value == item.price,
            "Input exact amount of item price to purchase");
        
        uint cutPrice = SafeMathLib.divide(SafeMathLib.multiply(item.price, 95), 100);
        uint itemCommission = SafeMathLib.subtract(item.price, cutPrice);
        commission = SafeMathLib.add(commission, itemCommission);
        sellerAddress.transfer(cutPrice);
        removeItemForSale(sellerAddress, itemIndex);
        users[msg.sender].itemsBought.push(item);

        emit LogItemPurchase(
          msg.sender,
          sellerAddress,
          item.name,
          item.description,
          cutPrice,
          commission
        );
    }
    
    function cashoutCommission() public payable onlyOwner {
        owner.transfer(commission);
        commission = 0;
    }
    
    function viewCommission() public view onlyOwner returns (uint) {
        return commission;
    }
    
    function removeItemForSaleBySeller(uint index) public onlySeller {
        removeItemForSale(msg.sender, index);
    }
    
    function removeItemForSale(address sellerAddress, uint index)
        private
    {
        Item memory item = users[sellerAddress].itemsForSale[index];

        emit LogItemForSaleDeletion(
          msg.sender,
          item.name,
          item.description,
          item.price
        );

        uint arrLength = users[sellerAddress].itemsForSale.length;
        users[sellerAddress].itemsForSale[index] = users[sellerAddress].itemsForSale[arrLength - 1];
        users[sellerAddress].itemsForSale.length--;
    }
    
    function updateItemForSale(
        uint index,
        string name,
        string description,
        uint price
    ) public onlySeller {
        users[msg.sender].itemsForSale[index].name = name;
        users[msg.sender].itemsForSale[index].description = description;
        users[msg.sender].itemsForSale[index].price = price;
    
        emit LogItemForSaleUpdate(
          msg.sender,
          index,
          name,
          description,
          price
        );
    }
    
    function removeItemForSaleImage(uint itemIndex, uint imageIndex)
        public
        onlySeller
    {
        string memory imageIpfsHash = users[msg.sender].itemsForSale[itemIndex].imageIpfsHashes[imageIndex];

        emit LogItemForSaleImageDeletion(msg.sender, imageIpfsHash);

        uint arrLength = users[msg.sender].itemsForSale[itemIndex].imageIpfsHashes.length;
        string memory lastImageHash = users[msg.sender].itemsForSale[itemIndex].imageIpfsHashes[arrLength - 1];
        users[msg.sender].itemsForSale[itemIndex].imageIpfsHashes[imageIndex] = lastImageHash;
        users[msg.sender].itemsForSale[itemIndex].imageIpfsHashes.length--;
    }
    
    function getSellerContact(address sellerAddress)
        public
        view
        onlyRegistered
        returns (string, string)
    {
        Contact memory sellerContact = users[sellerAddress].contact;
        return (sellerContact.email, sellerContact.number);
    }
    
    function getItemBought(uint index)
        public
        view
        returns (string, string, uint)
    {
        return (
            users[msg.sender].itemsBought[index].name,    
            users[msg.sender].itemsBought[index].description,
            users[msg.sender].itemsBought[index].price
        );
    }

    function itemsBoughtCount()
      public
      view
      returns (uint)
    {
      return users[msg.sender].itemsBought.length;
    }
    
    function getItemBoughtImageCount(
        uint itemIndex
    )
        public
        view
        returns (uint)
    {
        return (users[msg.sender].itemsBought[itemIndex].imageIpfsHashes.length);
    }
    
    function getItemBoughtImage(
        uint itemIndex,
        uint imageIndex
    )
        public
        view
        returns (string)
    {
        return (users[msg.sender].itemsBought[itemIndex].imageIpfsHashes[imageIndex]);
    }
}
