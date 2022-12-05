// IGNORE_LICENSE-Identifier: AGPL-3.0
pragma solidity ^0.8.9;

// IGNORE_LICENSE-Identifier: AGPL-3.0
pragma solidity ^0.8.9;

// IGNORE_LICENSE-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// IGNORE_LICENSE-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        (_name, _symbol, _decimals) = (name_, symbol_, decimals_);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, to, amount);

        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = allowance(from, to);
        require(currentAllowance >= amount, "transfer exceeds allowance");

        _approve(from, to, currentAllowance - amount);
        _transfer(from, to, amount);

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "owner is zero address");
        require(spender != address(0), "spender is zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "transfer from zero address");
        require(to != address(0), "transfer to zero address");
        uint256 balanceFrom = _balances[from];
        require(balanceFrom >= amount, "transfer amount exceeds balance");

        _balances[from] = balanceFrom - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }
}
// IGNORE_LICENSE-Identifier: AGPL-3.0
pragma solidity ^0.8.9;

interface ITradable {
    event Buy(address indexed account, uint256 tokenAmount, uint256 amount);
    event Sell(address indexed account, uint256 amount, uint256 tokenAmount);
    event LiquidityChanged(
        address indexed account,
        uint256 tokenAmount,
        uint256 amount
    );

    function price() external view returns (uint256);

    function liquidity()
        external
        view
        returns (uint256 amount, uint256 tokenAmount);

    function addLiquidity(uint256 tokenAmount) external payable returns (bool);

    function buy() external payable returns (bool);

    function sell(uint256 tokenAmount) external returns (bool);

    /**
     * @dev send surplus of token and eth to recipient
     */
    function release(address recipient) external returns (bool);
}

contract ERC20Tradable is ITradable, ERC20 {
    uint256 public immutable divider;

    uint256 internal _token0;
    uint256 internal _token1;
    uint256 internal _price;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 price_
    ) ERC20(name_, symbol_, decimals_) {
        divider = 10**decimals_;
        _price = price_;
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    function price() public view virtual returns (uint256) {
        return _price * divider;
    }

    function liquidity()
        public
        view
        returns (uint256 amount, uint256 tokenAmount)
    {
        (amount, tokenAmount) = (_token0, _token1);
    }

    function addLiquidity(uint256 tokenAmount) external payable returns (bool) {
        uint256 amount = msg.value;
        require(amount > 0, "amount must be positive");
        require(tokenAmount > 0, "tokenAmount must be positive");

        _changeLiquidity(amount, tokenAmount, _add, _add);

        transferFrom(msg.sender, address(this), tokenAmount);

        return true;
    }

    function buy() external payable returns (bool) {
        uint256 amount = msg.value;
        require(amount > 0, "amount must be positive");
        uint256 tokenAmount = amount / (price() / divider);
        require(tokenAmount > 0, "tokenAmount must be positive");
        require(
            int256(_token1) - int256(tokenAmount) > 0,
            "not enough liquidity"
        );

        _changeLiquidity(amount, tokenAmount, _add, _sub);

        address sender = msg.sender;
        _transfer(address(this), sender, tokenAmount);

        emit Buy(sender, tokenAmount, amount);

        return true;
    }

    function sell(uint256 tokenAmount) external returns (bool) {
        require(tokenAmount > 0, "tokenAmount must be positive");
        uint256 amount = (tokenAmount * price()) / divider;
        require(amount > 0, "amount must be positive");
        require(int256(_token0) - int256(amount) > 0, "not enough liquidity");

        _changeLiquidity(amount, tokenAmount, _sub, _add);

        address sender = msg.sender;
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = sender.call{value: amount}("");
        require(success, "transfer failed");

        transferFrom(sender, address(this), tokenAmount);

        emit Sell(sender, amount, tokenAmount);

        return true;
    }

    function release(address recipient) external returns (bool) {
        require(recipient != address(0), "recipient is zero address");
        address addr = address(this);
        uint256 freeAmount = addr.balance - _token0;
        uint256 freeTokenAmount = balanceOf(addr) - _token1;
        require(freeAmount > 0 || freeTokenAmount > 0, "nothing to transfer");

        if (freeAmount > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = recipient.call{value: freeAmount}("");
            require(success, "transfer failed");
        }

        if (freeTokenAmount > 0) {
            _transfer(addr, recipient, freeTokenAmount);
        }

        return true;
    }

    function _changeLiquidity(
        uint256 amount,
        uint256 tokenAmount,
        function(uint256, uint256) pure returns (uint256) op0,
        function(uint256, uint256) pure returns (uint256) op1
    ) internal {
        _token0 = op0(_token0, amount);
        _token1 = op1(_token1, tokenAmount);

        emit LiquidityChanged(msg.sender, _token1, _token0);
    }

    function _add(uint256 first, uint256 second)
        private
        pure
        returns (uint256)
    {
        return first + second;
    }

    function _sub(uint256 first, uint256 second)
        private
        pure
        returns (uint256)
    {
        return first - second;
    }
}
