// Submitted to Etherscan.io for verification for contract at 0x8494F777d13503BE928BB22b1F4ae3289E634FD3

/* rfikki was here in 2015 */

contract currency {
    
    struct Account {
        uint balance;
        mapping ( address => uint) withdrawers;
    }

    mapping ( address => Account ) accounts;

    event CoinSent(address indexed from, uint256 value, address indexed to);
    
/* Set Currency Maximum Balance */
    function currency() {
        accounts[msg.sender].balance = 1000000000000;  /* There will forever be a maximum one trillion tokens */
    }
    
/* Send _value amount of coins to address _to */
    function sendCoin(uint _value, address _to) returns (bool _success) {
        if (accounts[msg.sender].balance >= _value && _value < 340282366920938463463374607431768211456) {
            accounts[msg.sender].balance -= _value;
            accounts[_to].balance += _value;
            CoinSent(msg.sender, _value, _to);
            _success = true;
        }
        else _success = false;
    }
    
/* Send _value amount of coins from address _from to address _to */
    function sendCoinFrom(address _from, uint _value, address _to) returns (bool _success) {
        uint auth = accounts[_from].withdrawers[msg.sender];
        if (accounts[_from].balance >= _value && auth >= _value && _value < 340282366920938463463374607431768211456) {
            accounts[_from].withdrawers[msg.sender] -= _value;
            accounts[_from].balance -= _value;
            accounts[_to].balance += _value;
            CoinSent(_from, _value, _to);
            _success = true;
            _success = true;
        }
        else _success = false;
    }
    
/* Get your coin balance */
    function coinBalance() constant returns (uint _r) {
        _r = accounts[msg.sender].balance;
    }
    
/* Get the coin balance of another account with address _addr */
    function coinBalanceOf(address _addr) constant returns (uint _r) {
        _r = accounts[_addr].balance;
    }

 /* Allow _addr to direct debit from your account with full custody. Only implement if absolutely required and use carefully. See approveOnce below for a more limited method. */
    function approve(address _addr) {
        accounts[msg.sender].withdrawers[_addr] = 340282366920938463463374607431768211456;
    }

/* Returns 1 if _proxy is allowed to direct debit from your account */
    function isApproved(address _proxy) returns (bool _r) {
        _r = (accounts[msg.sender].withdrawers[_proxy] > 0);
    }

/* Makes a one-time approval for _addr to send a maximum amount of currency equal to _maxValue */
    function approveOnce(address _addr, uint256 _maxValue) {
        accounts[msg.sender].withdrawers[_addr] += _maxValue;
    }

/* Disapprove address _addr to direct debit from your account if it was previously approved. Must reset both one-time and full custody approvals. */
    function disapprove(address _addr) {
        accounts[msg.sender].withdrawers[_addr] = 0;  /* We Disapprove - 2015 - Aug - 24  Proposed ERC20 Standard - Not Final*/
    }
}
