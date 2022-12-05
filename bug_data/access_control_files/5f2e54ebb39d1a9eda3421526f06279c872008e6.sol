pragma solidity ^0.4.18;

contract db {
    // owner of contract itself
    address private owner;

    /**
      * data holds the string data for a user.
      * The first keys are owner addresses. Values are mappings. Where keys
      * are data categories, and values are string blobs.
      */
    mapping (address => mapping (string => string)) data;

    /**
      * editAccess holds grants to edit data categories.
      * The first keys are user addresses. Values are mappings. Where keys
      * are categories, and values are booleans.
      *
      * If an address and category have a true boolean value, then the address
      * can edit to that category
      */
    mapping (address => mapping (string => bool)) editAccess;

    /**
      * viewAccess holds grants for other addresses to view all data categories.
      * The keys are user addresses and values are booleans.
      *
      * If an address has a true boolean value, then the address
      * can view to that category
      */
    mapping (address => bool) viewAccess;

    // db is the constructor
    function db() public {
        // Save owner for kill method
        owner = msg.sender;
    }

    // deletes the contract
    function kill() public {
        // Ensure owner is calling
        require(msg.sender == owner);

        // Kill
        selfdestruct(owner);
    }

    /**
      * canView determines if the message sender can view the specified
      * address's information.
      * @param addr Address to check view access to
      * @return bool indicating if the message sender has view access
      */
    function canView(address addr) public view returns (bool) {
        // Check if owner
        if (msg.sender == addr) {
            return true;
        }

        // Check viewAccess var
        if (viewAccess[addr]) {
            return true;
        }

        // Otherwise no access
        return false;
    }

    /**
      * canEdit determines if the message sender can edit an address's data for
      * a specified category.
      * @param addr Address to check edit access to
      * @param category Data category to check edit access to
      * @return bool indicating if the message sender has edit access
      */
    function canEdit(address addr, string category) public view returns (bool) {
        // Check if owner
        if (msg.sender == addr) {
            return true;
        }

        // Check editAccess var
        if (editAccess[addr][category]) {
            return true;
        }

        // Otherwise no access
        return false;
    }

    /**
      * grantView gives view access to the message sender's data
      * @param addr Address to grant view access to
      */
    function grantView(address addr) public {
        viewAccess[addr] = true;
    }

    /**
      * revokeView removes view access to the message sender's data
      * @param addr Address to remove view access from
      */
    function revokeView(address addr) public {
        delete viewAccess[addr];
    }

    /**
      * grantEdit gives edit access to the message sender's data
      * @param addr Address to grant edit access to
      * @param category string Data category to grant edit access to
      */
    function grantEdit(address addr, string category) public {
        editAccess[addr][category] = true;
    }

    /**
      * revokeEdit removes edit access to the message sender's data
      * @param addr Address to remove edit access from
      * @param category Data category to remove edit access from
      */
    function revokeEdit(address addr, string category) public {
        delete editAccess[addr][category];
    }

    /**
      * get retrieves information for the specified address and category.
      * @param addr Address to get data for
      * @param category Data category to retrieve data for
      * @return string Blob of data
      */
    function get(address addr, string category) public view returns (string) {
        // Ensure owner or person with access
        require(canView(addr));

        // Return data
        return data[addr][category];
    }

    /**
      * set sets a data category's value
      * @param addr Address to edit data for
      * @param category Data category to set
      * @param blob String data blob to store
      */
    function set(address addr, string category, string blob) public {
        // Ensure message sender can edit address's information
        require(canEdit(addr, category));

        // Set
        data[msg.sender][category] = blob;
    }
}
