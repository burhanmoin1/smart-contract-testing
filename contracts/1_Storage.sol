// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* -------------------------
 *  BASIC ERC-20 TOKEN
 * ------------------------- */
contract MyToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(uint initialSupply) {
        totalSupply = initialSupply * 10**uint(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Not enough balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balanceOf[from] >= value, "Not enough balance");
        require(allowance[from][msg.sender] >= value, "Not approved");
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
}

/* -------------------------
 *  TOKEN SALE CONTRACT
 * ------------------------- */
contract TokenSale {
    address public owner;
    MyToken public token;
    MyToken public usdt;

    uint public ethPrice = 0.01 ether;
    uint public usdtPrice = 10 * 10**6; // USDT (6 decimals)

    event TokenPurchased(address buyer, string paymentType, uint amountPaid);

    constructor(address _token, address _usdt) {
        owner = msg.sender;
        token = MyToken(_token);
        usdt = MyToken(_usdt);
    }

    function buyWithETH() external payable {
        require(msg.value >= ethPrice, "Insufficient ETH sent");

        // Forward ETH to owner
        payable(owner).transfer(msg.value);

        // Send token to buyer
        require(token.transfer(msg.sender, 100 * 10**18), "Token transfer failed");

        emit TokenPurchased(msg.sender, "ETH", msg.value);
    }

    function buyWithUSDT() external {
        // Pull USDT from buyer to owner
        require(usdt.transferFrom(msg.sender, owner, usdtPrice), "USDT transfer failed");

        // Send token to buyer
        require(token.transfer(msg.sender, 100 * 10**18), "Token transfer failed");

        emit TokenPurchased(msg.sender, "USDT", usdtPrice);
    }
}
