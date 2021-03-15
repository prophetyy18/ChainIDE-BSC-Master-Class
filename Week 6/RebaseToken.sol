pragma solidity 0.7.6;

import "./SafeMath.sol";
import "./SafeMathInt.sol";

contract RebaseToken {
    string public name = "Rebase Token";
    string public symbol = "RT";
    address owner_;

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 50 * 10 ** 6 * 10 ** DECIMALS;

    // TOTAL_GONS is a multiple of INITIAL_FRAGMENTS_SUPPLY so that _gonsPerFragment is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // MAX_SUPPLY = maximum integer < (sqrt(4*TOTAL_GONS + 1) - 1) / 2
    uint256 private constant MAX_SUPPLY = type(uint128).max; // (2^128) - 1

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    // This is denominated in Fragments, because the gons-fragments conversion might change before
    // it's fully paid.
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    modifier onlyOwner() {
        require(msg.sender == owner_,"It's not use by owner.");
        _;
    }

    constructor() public  {
        owner_ = msg.sender;
    }

    function initialize() public onlyOwner {

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner_] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    function rebase(uint256 epoch, int256 supplyDelta)
            external
            onlyOwner
            returns (uint256)
        {
            if (supplyDelta == 0) {
                emit LogRebase(epoch, _totalSupply);
                return _totalSupply;
            }

            if (supplyDelta < 0) {
                _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
            } else {
                _totalSupply = _totalSupply.add(uint256(supplyDelta));
            }

            if (_totalSupply > MAX_SUPPLY) {
                _totalSupply = MAX_SUPPLY;
            }

            _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

            // From this point forward, _gonsPerFragment is taken as the source of truth.
            // We recalculate a new _totalSupply to be in agreement with the _gonsPerFragment
            // conversion rate.
            // This means our applied supplyDelta can deviate from the requested supplyDelta,
            // but this deviation is guaranteed to be < (_totalSupply^2)/(TOTAL_GONS - _totalSupply).
            //
            // In the case of _totalSupply <= MAX_UINT128 (our current supply cap), this
            // deviation is guaranteed to be < 1, so we can omit this step. If the supply cap is
            // ever increased, it must be re-included.
            // _totalSupply = TOTAL_GONS.div(_gonsPerFragment)

            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

    /**
     * @return The balance of the specified address.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }


    /**
     * @param who The address to query.
     * @return The balance of the specified address.
     */
    function balanceOf(address who) external view  returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }


    /**
     * @param who The address to query.
     * @return The gon balance of the specified address.
     */
    function scaledBalanceOf(address who) external view returns (uint256) {
        return _gonBalances[who];
    }


    /**
     * @return the total number of gons.
    */
    function scaledTotalSupply() external pure returns (uint256) {
        return TOTAL_GONS;
    }


    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
     */
    function transfer(address to, uint256 value)
        external
        returns (bool)
    {
        uint256 gonValue = value.mul(_gonsPerFragment);

        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);

        emit Transfer(msg.sender, to, value);
        return true;
    }
    

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external  returns (bool) {

        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint256 gonValue = value.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonValue);
        _gonBalances[to] = _gonBalances[to].add(gonValue);

        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance - if they are both greater than zero - if a transfer
     * transaction is mined before the later approve() call is mined.
     *
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) external  returns (bool) {
        _allowedFragments[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }
    
}

