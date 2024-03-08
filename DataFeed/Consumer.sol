// SPDX-License-Identifier:MIT
pragma solidity ^0.7.6;

import "https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.7/dev/AggregatorProxy.sol";

contract Consumer {
    AggregatorV3Interface public feed;

    constructor() {
        feed = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
    }

    function getLatestRoundData()
        public
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint80 roundID,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint256 answeredInRound
        ) = feed.latestRoundData();
        return (roundID, answer, startedAt, updatedAt, answeredInRound);
    }

    function getTheDecimals() public view returns (uint8) {
        uint8 getDecimals = feed.decimals();
        return getDecimals;
    }

    function getDerivedPrice(
        address _base,
        address _quote,
        uint8 _decimals
    )
        public
        view
        returns (
            int256,
            int256,
            int256
        )
    {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid decimals"
        );
        int256 decimals = int256(10 * uint256(_decimals));
        (, int256 basePrice, , , ) = AggregatorV3Interface(_base)
            .latestRoundData();
        uint8 baseDecimal = AggregatorV3Interface(_base).decimals();
        basePrice = scalePrice(basePrice, baseDecimal, _decimals);
        (, int256 quotePrice, , , ) = AggregatorV3Interface(_quote)
            .latestRoundData();
        uint8 quoteDecimal = AggregatorV3Interface(_quote).decimals();
        quotePrice = scalePrice(quotePrice, quoteDecimal, _decimals);
        return ((basePrice * decimals) / quotePrice, basePrice, quotePrice);
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) public pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10**uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10**uint256(_priceDecimals - _decimals));
        }
        return _price;
    }
}
