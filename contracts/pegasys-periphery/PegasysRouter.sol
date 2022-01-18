pragma solidity =0.6.6;

import "../pegasys-core/interfaces/IPegasysFactory.sol";
import "../pegasys-lib/libraries/TransferHelper.sol";

import "./interfaces/IPegasysRouter.sol";
import "./libraries/PegasysLibrary.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IWSYS.sol";

contract PegasysRouter is IPegasysRouter {
    using SafeMath for uint256;

    address public immutable override factory;
    address public immutable override WSYS;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "PegasysRouter: EXPIRED");
        _;
    }

    constructor(address _factory, address _WSYS) public {
        factory = _factory;
        WSYS = _WSYS;
    }

    receive() external payable {
        assert(msg.sender == WSYS); // only accept SYS via fallback from the WSYS contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (IPegasysFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IPegasysFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = PegasysLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = PegasysLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "PegasysRouter: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = PegasysLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "PegasysRouter: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = PegasysLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IPegasysPair(pair).mint(to);
    }

    function addLiquiditySYS(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountSYSMin,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountSYS,
            uint256 liquidity
        )
    {
        (amountToken, amountSYS) = _addLiquidity(
            token,
            WSYS,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountSYSMin
        );
        address pair = PegasysLibrary.pairFor(factory, token, WSYS);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWSYS(WSYS).deposit{value: amountSYS}();
        assert(IWSYS(WSYS).transfer(pair, amountSYS));
        liquidity = IPegasysPair(pair).mint(to);
        // refund dust SYS, if any
        if (msg.value > amountSYS)
            TransferHelper.safeTransferSYS(msg.sender, msg.value - amountSYS);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = PegasysLibrary.pairFor(factory, tokenA, tokenB);
        IPegasysPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IPegasysPair(pair).burn(to);
        (address token0, ) = PegasysLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(amountA >= amountAMin, "PegasysRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "PegasysRouter: INSUFFICIENT_B_AMOUNT");
    }

    function removeLiquiditySYS(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountSYSMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountSYS)
    {
        (amountToken, amountSYS) = removeLiquidity(
            token,
            WSYS,
            liquidity,
            amountTokenMin,
            amountSYSMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWSYS(WSYS).withdraw(amountSYS);
        TransferHelper.safeTransferSYS(to, amountSYS);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountA, uint256 amountB) {
        address pair = PegasysLibrary.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IPegasysPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    function removeLiquiditySYSWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountSYSMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        virtual
        override
        returns (uint256 amountToken, uint256 amountSYS)
    {
        address pair = PegasysLibrary.pairFor(factory, token, WSYS);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IPegasysPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountSYS) = removeLiquiditySYS(
            token,
            liquidity,
            amountTokenMin,
            amountSYSMin,
            to,
            deadline
        );
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquiditySYSSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountSYSMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountSYS) {
        (, amountSYS) = removeLiquidity(
            token,
            WSYS,
            liquidity,
            amountTokenMin,
            amountSYSMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(
            token,
            to,
            IERC20(token).balanceOf(address(this))
        );
        IWSYS(WSYS).withdraw(amountSYS);
        TransferHelper.safeTransferSYS(to, amountSYS);
    }

    function removeLiquiditySYSWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountSYSMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountSYS) {
        address pair = PegasysLibrary.pairFor(factory, token, WSYS);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IPegasysPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        amountSYS = removeLiquiditySYSSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountSYSMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PegasysLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2
                ? PegasysLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IPegasysPair(PegasysLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        amounts = PegasysLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "PegasysRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PegasysLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        amounts = PegasysLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "PegasysRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PegasysLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactSYSForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WSYS, "PegasysRouter: INVALID_PATH");
        amounts = PegasysLibrary.getAmountsOut(factory, msg.value, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "PegasysRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWSYS(WSYS).deposit{value: amounts[0]}();
        assert(
            IWSYS(WSYS).transfer(
                PegasysLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactSYS(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WSYS, "PegasysRouter: INVALID_PATH");
        amounts = PegasysLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "PegasysRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PegasysLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWSYS(WSYS).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferSYS(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForSYS(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WSYS, "PegasysRouter: INVALID_PATH");
        amounts = PegasysLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "PegasysRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PegasysLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWSYS(WSYS).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferSYS(to, amounts[amounts.length - 1]);
    }

    function swapSYSForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WSYS, "PegasysRouter: INVALID_PATH");
        amounts = PegasysLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= msg.value,
            "PegasysRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        IWSYS(WSYS).deposit{value: amounts[0]}();
        assert(
            IWSYS(WSYS).transfer(
                PegasysLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
        // refund dust SYS, if any
        if (msg.value > amounts[0])
            TransferHelper.safeTransferSYS(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PegasysLibrary.sortTokens(input, output);
            IPegasysPair pair = IPegasysPair(
                PegasysLibrary.pairFor(factory, input, output)
            );
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(
                    reserveInput
                );
                amountOutput = PegasysLibrary.getAmountOut(
                    amountInput,
                    reserveInput,
                    reserveOutput
                );
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2
                ? PegasysLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PegasysLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >=
                amountOutMin,
            "PegasysRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactSYSForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        require(path[0] == WSYS, "PegasysRouter: INVALID_PATH");
        uint256 amountIn = msg.value;
        IWSYS(WSYS).deposit{value: amountIn}();
        assert(
            IWSYS(WSYS).transfer(
                PegasysLibrary.pairFor(factory, path[0], path[1]),
                amountIn
            )
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >=
                amountOutMin,
            "PegasysRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function swapExactTokensForSYSSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WSYS, "PegasysRouter: INVALID_PATH");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PegasysLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WSYS).balanceOf(address(this));
        require(
            amountOut >= amountOutMin,
            "PegasysRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWSYS(WSYS).withdraw(amountOut);
        TransferHelper.safeTransferSYS(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return PegasysLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountOut) {
        return PegasysLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountIn) {
        return PegasysLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return PegasysLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return PegasysLibrary.getAmountsIn(factory, amountOut, path);
    }
}
