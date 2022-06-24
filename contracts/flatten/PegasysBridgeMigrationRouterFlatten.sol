// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File contracts/pegasys-core/interfaces/IPegasysERC20.sol

// SPDX-License-Identifier: GNU
pragma solidity >=0.5.0;

interface IPegasysERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File contracts/pegasys-lib/libraries/TransferHelper.sol

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending SYS that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferSYS(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: SYS_TRANSFER_FAILED");
    }
}

// File contracts/pegasys-periphery/interfaces/IBridgeToken.sol

pragma solidity >=0.5.0;

interface IBridgeToken is IPegasysERC20 {
    function swap(address token, uint256 amount) external;

    function swapSupply(address token) external view returns (uint256);
}

// File contracts/pegasys-periphery/libraries/Roles.sol

pragma solidity ^0.7.0;

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File contracts/pegasys-core/interfaces/IPegasysFactory.sol

pragma solidity >=0.5.0;

interface IPegasysFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// File contracts/pegasys-core/interfaces/IPegasysPair.sol

pragma solidity >=0.5.0;

interface IPegasysPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// File contracts/pegasys-periphery/libraries/SafeMath.sol

pragma solidity >=0.6.6 <0.8.0;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

// File contracts/pegasys-periphery/libraries/PegasysLibrary.sol

pragma solidity >=0.5.0;

library PegasysLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PegasysLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PegasysLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"85c9b07c539b322c33da730d88df8396983c35a411da73d3d6c2278474890833" // init code hash
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPegasysPair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "PegasysLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PegasysLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "PegasysLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PegasysLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "PegasysLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PegasysLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PegasysLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PegasysLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File contracts/pegasys-periphery/PegasysBridgeMigrationRouter.sol

pragma solidity ^0.7.6;

contract PegasysBridgeMigrationRouter {
    using SafeMath for uint256;
    using Roles for Roles.Role;

    Roles.Role private adminRole;
    mapping(address => address) public bridgeMigrator;

    constructor() {
        adminRole.add(msg.sender);
    }

    // safety measure to prevent clear front-running by delayed block
    modifier ensure(uint256 deadline) {
        require(
            deadline >= block.timestamp,
            "PegasysBridgeMigrationRouter: EXPIRED"
        );
        _;
    }

    // makes sure the admin is the one calling protected methods
    modifier onlyAdmin() {
        require(
            adminRole.has(msg.sender),
            "PegasysBridgeMigrationRouter: Unauthorized"
        );
        _;
    }

    /**
     * @notice Given an address, this address is added to the list of admin.
     * @dev Any admin can add or remove other admins, careful.
     * @param account The address of the account.
     */
    function addAdmin(address account) external onlyAdmin {
        require(
            account != address(0),
            "PegasysBridgeMigrationRouter: Address 0 not allowed"
        );
        adminRole.add(account);
    }

    /**
     * @notice Given an address, this address is added to the list of admin.
     * @dev Any admin can add or remove other admins, careful.
     * @param account The address of the account.
     */
    function removeAdmin(address account) external onlyAdmin {
        require(
            msg.sender != account,
            "PegasysBridgeMigrationRouter: You can't demote yourself"
        );
        adminRole.remove(account);
    }

    /**
     * @notice Given an address, returns whether or not he's already an admin
     * @param account The address of the account.
     * @return Whether or not the account address is an admin.
     */
    function isAdmin(address account) external view returns (bool) {
        return adminRole.has(account);
    }

    /**
     * @notice Given an token, and it's migrator address, it configures the migrator for later usage
     * @param tokenAddress The ERC20 token address that will be migrated using the migrator
     * @param migratorAddress The WrappedERC20 token address that will be migrate the token
     */
    function addMigrator(address tokenAddress, address migratorAddress)
        external
        onlyAdmin
    {
        require(
            tokenAddress != address(0),
            "PegasysBridgeMigrationRouter: tokenAddress 0 not supported"
        );
        require(
            migratorAddress != address(0),
            "PegasysBridgeMigrationRouter: migratorAddress 0 not supported"
        );
        uint256 amount = IBridgeToken(migratorAddress).swapSupply(tokenAddress);
        require(
            amount > 0,
            "The migrator doesn't have swap supply for this token"
        );
        _allowToken(tokenAddress, migratorAddress);
        bridgeMigrator[tokenAddress] = migratorAddress;
    }

    /**
     * @notice Internal function to manage approval, allows an ERC20 to be spent to the maximum
     * @param tokenAddress The ERC20 token address that will be allowed to be used
     * @param spenderAddress Who's going to spend the ERC20 token
     */
    function _allowToken(address tokenAddress, address spenderAddress)
        internal
    {
        IPegasysERC20(tokenAddress).approve(spenderAddress, type(uint256).max);
    }

    /**
     * @notice Internal function add liquidity on a low level, without the use of a router
     * @dev This function will try to maximize one of the tokens amount and match the other
     * one, can cause dust so consider charge backs
     * @param pairToken The pair that will receive the liquidity
     * @param token0 The first token of the pair
     * @param token1 The second token of the pair
     * @param amountIn0 The amount of first token that can be used to deposit liquidity
     * @param amountIn1 The amount of second token that can be used to deposit liquidity
     * @param to The address who will receive the liquidity
     * @return amount0 Charge back from token0
     * @return amount1 Charge back from token1
     * @return liquidityAmount Total liquidity token amount acquired
     */
    function _addLiquidity(
        address pairToken,
        address token0,
        address token1,
        uint256 amountIn0,
        uint256 amountIn1,
        address to
    )
        private
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 liquidityAmount
        )
    {
        (uint112 reserve0, uint112 reserve1, ) = IPegasysPair(pairToken)
            .getReserves();
        uint256 quote0 = amountIn0;
        uint256 quote1 = PegasysLibrary.quote(amountIn0, reserve0, reserve1);
        if (quote1 > amountIn1) {
            quote1 = amountIn1;
            quote0 = PegasysLibrary.quote(amountIn1, reserve1, reserve0);
        }
        TransferHelper.safeTransfer(token0, pairToken, quote0);
        TransferHelper.safeTransfer(token1, pairToken, quote1);
        amount0 = amountIn0 - quote0;
        amount1 = amountIn1 - quote1;
        liquidityAmount = IPegasysPair(pairToken).mint(to);
    }

    /**
     * @notice Internal function to remove liquidity on a low level, without the use of a router
     * @dev This function requires the user to approve this contract to transfer the liquidity pair on it's behalf
     * @param liquidityPair The pair that will have the liquidity removed
     * @param amount The amount of liquidity token that you want to rescue
     * @return amountTokenA The amount of token0 from burning liquidityPair token
     * @return amountTokenB The amount of token1 from burning liquidityPair token
     */
    function _rescueLiquidity(address liquidityPair, uint256 amount)
        internal
        returns (uint256 amountTokenA, uint256 amountTokenB)
    {
        TransferHelper.safeTransferFrom(
            liquidityPair,
            msg.sender,
            liquidityPair,
            amount
        );
        (amountTokenA, amountTokenB) = IPegasysPair(liquidityPair).burn(
            address(this)
        );
    }

    /**
     * @notice Internal function that checks if the minimum requirements are met to accept the pairs to migrate
     * @dev This function makes the main function(migrateLiquidity) cleaner, this function can revert the transaction
     * @param pairA The pair that is going to be migrated from
     * @param pairB The pair that is going to be migrated to
     */
    function _arePairsCompatible(address pairA, address pairB) internal view {
        require(
            pairA != address(0),
            "PegasysBridgeMigrationRouter: liquidityPairFrom address 0"
        );
        require(
            pairA != address(0),
            "PegasysBridgeMigrationRouter: liquidityPairTo address 0"
        );
        require(
            pairA != pairB,
            "PegasysBridgeMigrationRouter: Cant convert to the same liquidity pairs"
        );
        require(
            IPegasysPair(pairA).token0() == IPegasysPair(pairB).token0() ||
                IPegasysPair(pairA).token0() == IPegasysPair(pairB).token1() ||
                IPegasysPair(pairA).token1() == IPegasysPair(pairB).token0() ||
                IPegasysPair(pairA).token1() == IPegasysPair(pairB).token1(),
            "PegasysBridgeMigrationRouter: Pair does not have one token matching"
        );
    }

    /**
     * @notice Internal function that implements the token migration
     * @dev This function only checks if the expected balance was received, it doesn't check for migrator existance
     * @param tokenAddress The ERC20 token address that will be migrated
     * @param amount The amount of the token to be migrated
     */
    function _migrateToken(address tokenAddress, uint256 amount) internal {
        require(
            tokenAddress != address(0),
            "PegasysBridgeMigrationRouter: tokenAddress 0 not supported"
        );
        IBridgeToken(bridgeMigrator[tokenAddress]).swap(tokenAddress, amount);
        require(
            IBridgeToken(bridgeMigrator[tokenAddress]).balanceOf(
                address(this)
            ) == amount,
            "PegasysBridgeMigrationRouter: Didn't yield the correct amount"
        );
    }

    /**
     * @notice Front facing function that migrates the token
     * @dev This function includes important checks
     * @param token The ERC20 token address that will be migrated
     * @param to The address of who's receiving the token
     * @param amount The amount of the token to be migrated
     * @param deadline The deadline limit that should be met, otherwise revert to prevent front-run
     */
    function migrateToken(
        address token,
        address to,
        uint256 amount,
        uint256 deadline
    ) external ensure(deadline) {
        require(
            bridgeMigrator[token] != address(0),
            "PegasysBridgeMigrationRouter: migrator not registered"
        );
        TransferHelper.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            amount
        );
        _migrateToken(token, amount);
        TransferHelper.safeTransfer(bridgeMigrator[token], to, amount);
    }

    /**
     * @notice Front facing function that migrates the liquidity, with permit
     * @param liquidityPairFrom The pair address to be migrated from
     * @param liquidityPairTo The pair address to be migrated to
     * @param to The address that will receive the liquidity and the charge backs
     * @param amount The amount of token liquidityPairFrom that will be migrated
     * @param deadline The deadline limit that should be met, otherwise revert to prevent front-run
     * @param v by passing param for the permit validation
     * @param r by passing param for the permit validation
     * @param s by passing param for the permit validation
     */
    function migrateLiquidityWithPermit(
        address liquidityPairFrom,
        address liquidityPairTo,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external ensure(deadline) {
        IPegasysPair(liquidityPairFrom).permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        _migrateLiquidity(liquidityPairFrom, liquidityPairTo, to, amount);
    }

    /**
     * @notice Front facing function that migrates the liquidity
     * @dev This function assumes sender already gave approval to move the assets
     * @param liquidityPairFrom The pair address to be migrated from
     * @param liquidityPairTo The pair address to be migrated to
     * @param to The address that will receive the liquidity and the charge backs
     * @param amount The amount of token liquidityPairFrom that will be migrated
     * @param deadline The deadline limit that should be met, otherwise revert to prevent front-run
     */
    function migrateLiquidity(
        address liquidityPairFrom,
        address liquidityPairTo,
        address to,
        uint256 amount,
        uint256 deadline
    ) external ensure(deadline) {
        _migrateLiquidity(liquidityPairFrom, liquidityPairTo, to, amount);
    }

    /**
     * @notice This was extracted into a internal method to use with both migrateLiquidity and with permit
     * @dev This function includes important checks
     * @param liquidityPairFrom The pair address to be migrated from
     * @param liquidityPairTo The pair address to be migrated to
     * @param to The address that will receive the liquidity and the charge backs
     * @param amount The amount of token liquidityPairFrom that will be migrated
     */
    function _migrateLiquidity(
        address liquidityPairFrom,
        address liquidityPairTo,
        address to,
        uint256 amount
    ) internal {
        _arePairsCompatible(liquidityPairFrom, liquidityPairTo);
        address tokenToMigrate = IPegasysPair(liquidityPairFrom).token0();
        if (
            IPegasysPair(liquidityPairFrom).token0() ==
            IPegasysPair(liquidityPairTo).token0() ||
            IPegasysPair(liquidityPairFrom).token0() ==
            IPegasysPair(liquidityPairTo).token1()
        ) {
            tokenToMigrate = IPegasysPair(liquidityPairFrom).token1();
        }
        address newTokenAddress = bridgeMigrator[tokenToMigrate];
        require(
            newTokenAddress != address(0),
            "PegasysBridgeMigrationRouter: Migrator not registered for the pair"
        );
        require(
            newTokenAddress == IPegasysPair(liquidityPairTo).token0() ||
                newTokenAddress == IPegasysPair(liquidityPairTo).token1(),
            "PegasysBridgeMigrationRouter: Pair doesn't match the migration token"
        );

        (uint256 amountTokenA, uint256 amountTokenB) = _rescueLiquidity(
            liquidityPairFrom,
            amount
        );
        {
            uint256 amountToSwap = amountTokenA;
            if (tokenToMigrate != IPegasysPair(liquidityPairFrom).token0()) {
                amountToSwap = amountTokenB;
            }
            _migrateToken(tokenToMigrate, amountToSwap);
        }
        if (
            IPegasysPair(liquidityPairFrom).token0() !=
            IPegasysPair(liquidityPairTo).token0() &&
            IPegasysPair(liquidityPairFrom).token1() !=
            IPegasysPair(liquidityPairTo).token1()
        ) {
            (amountTokenA, amountTokenB) = (amountTokenB, amountTokenA);
        }

        (uint256 changeAmount0, uint256 changeAmount1, ) = _addLiquidity(
            liquidityPairTo,
            IPegasysPair(liquidityPairTo).token0(),
            IPegasysPair(liquidityPairTo).token1(),
            amountTokenA,
            amountTokenB,
            to
        );
        if (changeAmount0 > 0) {
            TransferHelper.safeTransfer(
                IPegasysPair(liquidityPairTo).token0(),
                to,
                changeAmount0
            );
        }
        if (changeAmount1 > 0) {
            TransferHelper.safeTransfer(
                IPegasysPair(liquidityPairTo).token1(),
                to,
                changeAmount1
            );
        }
    }

    /**
     * @notice Internal function that simulates the amount received from the liquidity burn
     * @dev This function is a support function that can be used by the front-end to show possible charge back
     * @param pairAddress The pair address that will be burned(simulated)
     * @param amount The amount of the liquidity token to be burned(simulated)
     * @return amount0 Amounts of token0 acquired from burning the pairAddress token
     * @return amount1 Amounts of token1 acquired from burning the pairAddress token
     */
    function _calculateRescueLiquidity(address pairAddress, uint256 amount)
        internal
        view
        returns (uint256 amount0, uint256 amount1)
    {
        (uint112 reserves0, uint112 reserves1, ) = IPegasysPair(pairAddress)
            .getReserves();
        uint256 totalSupply = IPegasysPair(pairAddress).totalSupply();
        amount0 = amount.mul(reserves0) / totalSupply;
        amount1 = amount.mul(reserves1) / totalSupply;
    }

    /**
     * @notice Front facing function that computes the possible charge back from the migration
     * @dev No need to be extra careful as this is only a view function
     * @param liquidityPairFrom The pair address that will be migrated from(simulated)
     * @param liquidityPairTo The pair address that will be migrated to(simulated)
     * @param amount The amount of the liquidity token to be migrated(simulated)
     * @return amount0 Amount of token0 will be charged back after the migration
     * @return amount1 Amount of token1 will be charged back after the migration
     */
    function calculateChargeBack(
        address liquidityPairFrom,
        address liquidityPairTo,
        uint256 amount
    ) external view returns (uint256 amount0, uint256 amount1) {
        require(
            liquidityPairFrom != address(0),
            "PegasysBridgeMigrationRouter: liquidityPairFrom address 0 not supported"
        );
        require(
            liquidityPairTo != address(0),
            "PegasysBridgeMigrationRouter: liquidityPairTo address 0 not supported"
        );
        (uint256 amountIn0, uint256 amountIn1) = _calculateRescueLiquidity(
            liquidityPairFrom,
            amount
        );
        if (
            IPegasysPair(liquidityPairFrom).token0() !=
            IPegasysPair(liquidityPairTo).token0() &&
            IPegasysPair(liquidityPairFrom).token1() !=
            IPegasysPair(liquidityPairTo).token1()
        ) {
            (amountIn0, amountIn1) = (amountIn1, amountIn0);
        }
        (uint112 reserve0, uint112 reserve1, ) = IPegasysPair(liquidityPairTo)
            .getReserves();
        uint256 quote0 = amountIn0;
        uint256 quote1 = PegasysLibrary.quote(amountIn0, reserve0, reserve1);
        if (quote1 > amountIn1) {
            quote1 = amountIn1;
            quote0 = PegasysLibrary.quote(amountIn1, reserve1, reserve0);
        }
        amount0 = amountIn0 - quote0;
        amount1 = amountIn1 - quote1;
    }
}
