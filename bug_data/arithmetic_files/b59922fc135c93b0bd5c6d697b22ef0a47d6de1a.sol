pragma solidity ^0.4.18;

pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
pragma solidity ^0.4.18;

pragma solidity ^0.4.18;

pragma solidity ^0.4.18;

pragma solidity ^0.4.18;


pragma solidity ^0.4.18;


pragma solidity ^0.4.18;


pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
    assert(msg.data.length == size + 4);
    _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}
pragma solidity ^0.4.18;




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3 * 32) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public onlyPayloadSize(2 * 32) returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public onlyPayloadSize(2 * 32) returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
pragma solidity ^0.4.18;

contract Owners {

  mapping (address => bool) public owners;
  uint public ownersCount;
  uint public minOwnersRequired = 2;

  event OwnerAdded(address indexed owner);
  event OwnerRemoved(address indexed owner);

  /**
   * @dev initializes contract
   * @param withDeployer bool indicates whether deployer is part of owners
   */
  function Owners(bool withDeployer) public {
    if (withDeployer) {
      ownersCount++;
      owners[msg.sender] = true;
    }
    owners[0x23B599A0949C6147E05C267909C16506C7eFF229] = true;
    owners[0x286A70B3E938FCa244208a78B1823938E8e5C174] = true;
    ownersCount = ownersCount + 2;
  }

  /**
   * @dev adds owner, can only by done by owners only
   * @param _address address the address to be added
   */
  function addOwner(address _address) public ownerOnly {
    owners[_address] = true;
    ownersCount++;
    OwnerAdded(_address);
  }

  /**
   * @dev removes owner, can only by done by owners only
   * @param _address address the address to be removed
   */
  function removeOwner(address _address) public ownerOnly notOwnerItself(_address) minOwners {
    owners[_address] = false;
    OwnerRemoved(_address);
  }

  /**
   * @dev checks if sender is owner
   */
  modifier ownerOnly {
    require(owners[msg.sender]);
    _;
  }

  modifier notOwnerItself(address _owner) {
    require(msg.sender != _owner);
    _;
  }

  modifier minOwners {
    require(ownersCount > minOwnersRequired);
    _;
  }

}



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Owners(true) {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event MintStarted();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) ownerOnly canMint onlyPayloadSize(2 * 32) public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() ownerOnly canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /**
   * @dev Function to start minting new tokens.
   * @return True if the operation was successful.
   */
  function startMinting() ownerOnly public returns (bool) {
    mintingFinished = false;
    MintStarted();
    return true;
  }
}

contract REIDAOMintableToken is MintableToken {

  uint public decimals = 8;

  bool public tradingStarted = false;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public canTrade returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint _value) public canTrade returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev modifier that throws if trading has not started yet
   */
  modifier canTrade() {
    require(tradingStarted);
    _;
  }

  /**
   * @dev Allows the owner to enable the trading. Done only once.
   */
  function startTrading() public ownerOnly {
    tradingStarted = true;
  }
}

contract REIDAOMintableLockableToken is REIDAOMintableToken {

  struct TokenLock {
    uint256 value;
    uint lockedUntil;
  }

  mapping (address => TokenLock[]) public locks;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public canTransfer(msg.sender, _value) returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint _value) public canTransfer(msg.sender, _value) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Allows authorized callers to lock `_value` tokens belong to `_to` until timestamp `_lockUntil`.
   * This function can be called independently of transferAndLockTokens(), hence the double checking of timestamp.
   * @param _to address The address to be locked.
   * @param _value uint The amout of tokens to be locked.
   * @param _lockUntil uint The UNIX timestamp tokens are locked until.
   */
  function lockTokens(address _to, uint256 _value, uint256 _lockUntil) public ownerOnly {
    require(_value <= balanceOf(_to));
    require(_lockUntil > now);
    locks[_to].push(TokenLock(_value, _lockUntil));
  }

  /**
   * @dev Allows authorized callers to mint `_value` tokens for `_to`, and lock them until timestamp `_lockUntil`.
   * @param _to address The address to which tokens to be minted and locked.
   * @param _value uint The amout of tokens to be minted and locked.
   * @param _lockUntil uint The UNIX timestamp tokens are locked until.
   */
  function mintAndLockTokens(address _to, uint256 _value, uint256 _lockUntil) public ownerOnly {
    require(_lockUntil > now);
    mint(_to, _value);
    lockTokens(_to, _value, _lockUntil);
  }

  /**
   * @dev Checks the amount of transferable tokens belongs to `_holder`.
   * @param _holder address The address to be checked.
   */
  function transferableTokens(address _holder) public constant returns (uint256) {
    uint256 lockedTokens = getLockedTokens(_holder);
    if (lockedTokens==0) {
      return balanceOf(_holder);
    } else {
      return balanceOf(_holder).sub(lockedTokens);
    }
  }

  /**
   * @dev Retrieves the amount of locked tokens `_holder` has.
   * @param _holder address The address to be checked.
   */
  function getLockedTokens(address _holder) public constant returns (uint256) {
    uint256 numLocks = getTokenLocksCount(_holder);

    // shortcut for holder without locks
    if (numLocks == 0) return 0;

    // Iterate through all the locks the holder has
    uint256 lockedTokens = 0;
    for (uint256 i = 0; i < numLocks; i++) {
      if (locks[_holder][i].lockedUntil >= now) {
        lockedTokens = lockedTokens.add(locks[_holder][i].value);
      }
    }

    return lockedTokens;
  }

  /**
   * @dev Retrieves the number of token locks `_holder` has.
   * @param _holder address The address the token locks belongs to.
   * @return A uint256 representing the total number of locks.
   */
  function getTokenLocksCount(address _holder) internal constant returns (uint256 index) {
    return locks[_holder].length;
  }

  /**
   * @dev Modifier that throws if `_value` amount of tokens can't be transferred.
   * @param _sender address the address of the sender
   * @param _value uint the amount of tokens intended to be transferred
   */
  modifier canTransfer(address _sender, uint256 _value) {
    uint256 transferableTokensAmt = transferableTokens(_sender);
    require (_value <= transferableTokensAmt);
    // delete locks if all locks are cleared
    if (transferableTokensAmt == balanceOf(_sender) && getTokenLocksCount(_sender)>0) {
      delete locks[_sender];
    }
    _;
  }
}
pragma solidity ^0.4.18;

pragma solidity ^0.4.18;


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

contract REIDAOBurnableToken is BurnableToken {

  mapping (address => bool) public hostedWallets;

  /**
   * @dev burns tokens, can only be done by hosted wallets
   * @param _value uint256 the amount of tokens to be burned
   */
  function burn(uint256 _value) public hostedWalletsOnly {
    return super.burn(_value);
  }

  /**
   * @dev adds hosted wallet
   * @param _wallet address the address to be added
   */
  function addHostedWallet(address _wallet) public {
    hostedWallets[_wallet] = true;
  }

  /**
   * @dev removes hosted wallet
   * @param _wallet address the address to be removed
   */
  function removeHostedWallet(address _wallet) public {
    hostedWallets[_wallet] = false;
  }

  /**
   * @dev checks if sender is hosted wallets
   */
  modifier hostedWalletsOnly {
    require(hostedWallets[msg.sender]==true);
    _;
  }
}

contract REIDAOMintableBurnableLockableToken is REIDAOMintableLockableToken, REIDAOBurnableToken {

  /**
   * @dev adds hosted wallet, can only be done by owners.
   * @param _wallet address the address to be added
   */
  function addHostedWallet(address _wallet) public ownerOnly {
    return super.addHostedWallet(_wallet);
  }

  /**
   * @dev removes hosted wallet, can only be done by owners.
   * @param _wallet address the address to be removed
   */
  function removeHostedWallet(address _wallet) public ownerOnly {
    return super.removeHostedWallet(_wallet);
  }
}

contract CrowdvillaTokenSale is Owners(true) {
  using SafeMath for uint256;
  //TODO use safemath for all

  uint public totalFund;
  uint public uniqueContributors;
  uint public currentStretchGoal;
  uint public minContribution;
  uint public crvPerEth;
  uint public reiPerEth;
  uint public mgmtFeePercentage;
  uint public saleEndBlock;
  uint public totalReferralMultisig;
  uint[] public stretchGoals;

  address public deployer;
  address public opsAdmin;
  address public crowdvillaWallet;
  address public reidaoWallet;
  address public crvTokenAddr;
  address public crpTokenAddr;
  address public reiTokenAddr;
  mapping (address => Whitelist) public whitelist;
  mapping (bytes32 => address) public referralMultisig;
  mapping (uint => mapping (uint => uint)) public contributionsPerStretchGoal; //earlyRegistrant => stretch-goals => value
  mapping (address => uint) public contributionsPerAddress;
  mapping (address => mapping (uint => uint)) public contributions;
  mapping (address => uint) public contributorIndex;
  mapping (uint => address) public reversedContributorIndex;
  mapping (address => bool) public tokensCollected;
  mapping (bytes32 => uint) public referralContribution;

  event Contribute(uint blkNo, uint blkTs, address indexed contributor, address indexed tokensale, uint amount, bytes32 referralCode);
  event Whitelisted(uint blkNo, uint blkTs, address indexed contributor, bool isEarlyRegistrant, bytes32 referralCode);
  event WhitelistChanged(address indexed _old, address indexed _new);

  enum State { TokenSale, End, Collection }
  State public state;

  REIDAOMintableBurnableLockableToken crvToken;
  REIDAOMintableBurnableLockableToken crpToken;
  REIDAOMintableToken reiToken;

  struct Whitelist {
    bool whitelisted;
    bool isEarlyRegistrant;
    bytes32 referralCode;
  }

  /**
   * @dev initializes contract
   * @param _stretchGoal1 uint the stretch goal 1 amount in ETH
   * @param _stretchGoal2 uint the stretch goal 2 amount in ETH
   * @param _stretchGoal3 uint the stretch goal 3 amount in ETH
   * @param _opsAdmin address the address of operation admin
   * @param _crowdvillaWallet address the address of Crowdvilla's wallet
   * @param _reidaoWallet address the address of REIDAO's wallet
   * @param _crvTokenAddr address the address of CRVToken contract
   * @param _crpTokenAddr address the address of CRPToken contract
   * @param _reiTokenAddr address the address of REIToken contract
   */
  function CrowdvillaTokenSale(
      uint _stretchGoal1,
      uint _stretchGoal2,
      uint _stretchGoal3,
      address _opsAdmin,
      address _crowdvillaWallet,
      address _reidaoWallet,
      address _crvTokenAddr,
      address _crpTokenAddr,
      address _reiTokenAddr) public {
    deployer = msg.sender;
    state = State.TokenSale;

    opsAdmin = address(_opsAdmin);
    crowdvillaWallet = address(_crowdvillaWallet);
    reidaoWallet = address(_reidaoWallet);
    crvTokenAddr = address(_crvTokenAddr);
    crpTokenAddr = address(_crpTokenAddr);
    reiTokenAddr = address(_reiTokenAddr);
    crvToken = REIDAOMintableBurnableLockableToken(crvTokenAddr);
    crpToken = REIDAOMintableBurnableLockableToken(crpTokenAddr);
    reiToken = REIDAOMintableToken(reiTokenAddr);

    minContribution = 1 ether;
    crvPerEth = 400 * (10**crvToken.decimals());
    reiPerEth = 5 * (10**reiToken.decimals());
    mgmtFeePercentage = 20;
    saleEndBlock = 5280000; //appox end of Mar 2018
    stretchGoals = [_stretchGoal1 * 1 ether, _stretchGoal2 * 1 ether, _stretchGoal3 * 1 ether];
  }


  // public - START ------------------------------------------------------------
  /**
   * @dev accepts ether, records contributions, and splits payment if referral code exists.
   *   contributor must be whitelisted, and sends the min ETH required.
   */
  function () public payable {
    if (msg.value>0) {
      // for accepting fund
      require(isInWhitelist(msg.sender));
      require(msg.value >= minContribution);
      require(state == State.TokenSale);
      require(block.number < saleEndBlock);
      require(currentStretchGoal < stretchGoals.length);

      totalFund = totalFund.add(msg.value);

      uint earlyRegistrantIndex = 0;
      if (whitelist[msg.sender].isEarlyRegistrant) {
        earlyRegistrantIndex = 1;
      }

      contributions[msg.sender][currentStretchGoal] = contributions[msg.sender][currentStretchGoal].add(msg.value);

      contributionsPerStretchGoal[earlyRegistrantIndex][currentStretchGoal] = contributionsPerStretchGoal[earlyRegistrantIndex][currentStretchGoal].add(msg.value);
      contributionsPerAddress[msg.sender] = contributionsPerAddress[msg.sender].add(msg.value);
      bytes32 referralCode = whitelist[msg.sender].referralCode;
      referralContribution[referralCode] = referralContribution[referralCode].add(msg.value);
      logContributeEvent(msg.sender, msg.value, referralCode);

      if (referralCode == bytes32(0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563)) {
        //no referral code
        crowdvillaWallet.transfer(msg.value);
      } else {
        //referral code exist, sending 99% to our wallet. 1% to multisig with arbiter
        uint crowdvillaAmount = (msg.value.mul(99)).div(100);
        crowdvillaWallet.transfer(crowdvillaAmount);
        referralMultisig[referralCode].transfer(msg.value.sub(crowdvillaAmount));
      }

      // to increase the currentStrechGoal targetted if the current one has been reached.
      //  also safe-guard if multiple stretch goals reached with a single contribution.
      // to end the token sale if it has reached the last stretch goal.
      for (uint currGoal = currentStretchGoal; currGoal < stretchGoals.length; currGoal++) {
        if (totalFund >= stretchGoals[currGoal] && currentStretchGoal != stretchGoals.length) {
          currentStretchGoal++;
        }
      }

      if (contributorIndex[msg.sender]==0) {
        uniqueContributors++;
        contributorIndex[msg.sender] = uniqueContributors;
        reversedContributorIndex[uniqueContributors] = msg.sender;
      }
    } else {
      // for tokens collection
      require(state == State.Collection);
      require(!tokensCollected[msg.sender]);
      uint promisedCRVToken = getPromisedCRVTokenAmount(msg.sender);
      require(promisedCRVToken>0);
      require(crvToken.mint(msg.sender, promisedCRVToken));
      require(crpToken.mint(msg.sender, promisedCRVToken));
      require(reiToken.mint(msg.sender, getPromisedREITokenAmount(msg.sender)));
      tokensCollected[msg.sender] = true;
    }
  }

  /**
   * @dev calculates the amount of CRV tokens allocated to `_contributor`, with
   *   stretch goal calculation.
   * @param _contributor address the address of contributor
   */
  function getPromisedCRVTokenAmount(address _contributor) public constant returns (uint) {
    uint val;

    uint earlyRegistrantBonus = 0;
    if (whitelist[_contributor].isEarlyRegistrant)
      earlyRegistrantBonus = 1;

    for (uint i=0; i<=currentStretchGoal; i++) {
      val += (contributions[_contributor][i] * crvPerEth * (100 + ((currentStretchGoal-i + earlyRegistrantBonus) * 10))/100) / 1 ether;
    }
    return val;
  }

  /**
   * @dev calculates the amount of tokens allocated to `_contributor. 5 REI per ETH.
   * @param _contributor address the address of contributor
   */
  function getPromisedREITokenAmount(address _contributor) public constant returns (uint) {
    uint val;
    uint totalEthContributions;
    for (uint i=0; i<=currentStretchGoal; i++) {
      totalEthContributions = totalEthContributions.add(contributions[_contributor][i]);
    }
    val = (totalEthContributions.mul(reiPerEth)).div(1 ether);

    return val;
  }

  /**
   * @dev calculates the amount of tokens allocated to REIDAO
   */
  function getREIDAODistributionTokenAmount() public constant returns (uint) {
    //contributionsPerStretchGoal index 0 is for non-earlyRegistrant
    //contributionsPerStretchGoal index 1 is for earlyRegistrant
    uint val;
    for (uint i=0; i<=currentStretchGoal; i++) {
      val += (contributionsPerStretchGoal[0][i] * crvPerEth * (100 + ((currentStretchGoal-i) * 10))/100) / 1 ether;
    }
    for (i=0; i<=currentStretchGoal; i++) {
      val += (contributionsPerStretchGoal[1][i] * crvPerEth * (100 + ((currentStretchGoal-i + 1) * 10))/100) / 1 ether;
    }
    uint total = (val.mul(100)).div(100 - mgmtFeePercentage);
    val = total.sub(val);
    return val;
  }

  /**
   * @dev Checks if `_contributor` is in the whitelist.
   * @param _contributor address The address of contributor.
   */
  function isInWhitelist(address _contributor) public constant returns (bool) {
    return (whitelist[_contributor].whitelisted == true);
  }
  // public - END --------------------------------------------------------------


  // ownerOnly - START ---------------------------------------------------------
  /**
   * @dev collects tokens distribution allocated to REIDAO
   */
  function collectREIDAODistribution() public ownerOnly {
    require(!tokensCollected[reidaoWallet]);
    uint tokenAmount = getREIDAODistributionTokenAmount();
    require(crvToken.mint(reidaoWallet, tokenAmount));
    require(crpToken.mint(reidaoWallet, tokenAmount));
    tokensCollected[reidaoWallet] = true;
  }

  /**
   * @dev updates sale end block
   * @param _saleEndBlock uint block number denotes end of sale
   */
  function updateSaleEndBlock(uint _saleEndBlock) public ownerOnly {
    saleEndBlock = _saleEndBlock;
  }

  /**
   * @dev ends token sale
   */
  function endTokenSale() public ownerOnly {
    setEndState();
  }

  /**
   * @dev sets state as Collection
   */
  function startCollection() public ownerOnly {
    state = State.Collection;
  }

  /**
   * @dev Allows owners to update `_opsAdmin` as new opsAdmin.
   * @param _opsAdmin address The address of new opsAdmin.
   */
  function updateOpsAdmin(address _opsAdmin) public ownerOnly {
    opsAdmin = _opsAdmin;
  }

  /**
   * @dev Allows authorized signatories to update contributor address.
   * @param _old address the old contributor address.
   * @param _new address the new contributor address.
   */
  function updateContributorAddress(address _old, address _new) public ownerOnly {
    require (state != State.Collection);
    whitelist[_new] = Whitelist(whitelist[_old].whitelisted, whitelist[_old].isEarlyRegistrant, whitelist[_old].referralCode);
    uint currentContribution;

    bool contributionFound;
    for (uint i=0; i<=currentStretchGoal; i++) {
      currentContribution = contributions[_old][i];
      if (currentContribution > 0) {
        contributions[_old][i] = 0;
        contributions[_new][i] += currentContribution;
        contributionsPerAddress[_old] -= currentContribution;
        contributionsPerAddress[_new] += currentContribution;
        logContributeEvent(_new, currentContribution, whitelist[_old].referralCode);

        contributionFound = true;
      }
    }
    removeFromWhitelist(_old);

    if (contributionFound) {
      if (contributorIndex[_new]==0) {
        uniqueContributors++;
        contributorIndex[_new] = uniqueContributors;
        reversedContributorIndex[uniqueContributors] = _new;
      }
    }
    WhitelistChanged(_old, _new);
  }
  // ownerOnly - END -----------------------------------------------------------


  // opsAdmin - START ----------------------------------------------------------
  /**
   * @dev Allows opsAdmin to add `_contributor` to the whitelist.
   * @param _contributor address The address of contributor.
   * @param _earlyRegistrant bool If contributor is early registrant (registered before public sale).
   * @param _referralCode bytes32 The referral code. Empty String if not provided.
   */
  function addToWhitelist(address _contributor, bool _earlyRegistrant, bytes32 _referralCode) public opsAdminOnly {
    whitelist[_contributor] = Whitelist(true, _earlyRegistrant, keccak256(_referralCode));
    Whitelisted(block.number, block.timestamp, _contributor, _earlyRegistrant, keccak256(_referralCode));
  }

  /**
   * @dev Allows opsAdmin to register `_multisigAddr` as multisig wallet address for referral code `_referralCode`.
   * @param _referralCode bytes32 The referral code. Should not be empty since it should have value.
   * @param _multisigAddr address The address of multisig wallet.
   */
  function registerReferralMultisig(bytes32 _referralCode, address _multisigAddr) public opsAdminOnly {
    referralMultisig[keccak256(_referralCode)] = _multisigAddr;
    totalReferralMultisig++;
  }
  // opsAdmin - END ------------------------------------------------------------


  // internal - START ----------------------------------------------------------
  /**
   * @dev sets state as End
   */
  function setEndState() internal {
    state = State.End;
  }

  /**
   * @dev Allows authorized signatories to remove `_contributor` from the whitelist.
   * @param _contributor address address of contributor.
   */
  function removeFromWhitelist(address _contributor) internal {
    whitelist[_contributor].whitelisted = false;
    whitelist[_contributor].isEarlyRegistrant = false;
  }

  /**
   * @dev logs contribution event
   * @param _contributor address address of contributor
   * @param _amount uint contribution amount
   * @param _referralCode bytes32 referral code from the contribution. Empty string if none.
   */
  function logContributeEvent(address _contributor, uint _amount, bytes32 _referralCode) internal {
    Contribute(block.number, block.timestamp, _contributor, this, _amount, _referralCode);
  }
  // internal - END ------------------------------------------------------------


  // modifier - START ----------------------------------------------------------
  /**
   * @dev throws if sender is not opsAdmin.
   */
  modifier opsAdminOnly {
    require(msg.sender == opsAdmin);
    _;
  }
  // modifier - END ------------------------------------------------------------
}
