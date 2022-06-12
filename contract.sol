// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;



import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
} 

contract Locker  {
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    mapping (address => mapping (address => uint256)) private _allowances;
    
    

    constructor() {
        address owner;
        owner = msg.sender;
    }
    


    struct LockedLiquidity{
        uint[] balances;
        uint[] withdrawtimes;
        bool isLocker;
        int quantity;
        address[] tokens;

        
    }

    mapping(address=>LockedLiquidity) public users;


       function getBalance(address _addr) public view returns(uint[] memory){
        
        return users[_addr].balances;
    }

      function gettxs() public view returns(uint,uint,int){
        LockedLiquidity storage user = users[msg.sender];
            return (user.balances.length,user.withdrawtimes.length,user.quantity);
        }


    
    function lockLiq(address dest, uint lockamount, uint time) payable external{
        LockedLiquidity storage user = users[msg.sender];
        
        uint withdrawday = block.timestamp + time * 1 seconds;
        user.balances.push(lockamount);
        user.withdrawtimes.push(withdrawday);
        user.isLocker = true;
        user.tokens.push(dest);
        user.quantity += 1;

        IERC20 _tokenContract = IERC20(dest);        
        
        _tokenContract.transferFrom(msg.sender, address(this), lockamount);

       
    }

    function unlockLiq(uint _index) public returns(bool){
            LockedLiquidity storage user = users[msg.sender];
            
            require(block.timestamp >= user.withdrawtimes[_index],"You can't take your tokens until time is done.");
            require(user.isLocker == true,"If you havent locked anything , you cant use withdraw function.");

            uint value = user.balances[_index];
            
            uint erc20balance = IERC20(user.tokens[_index]).balanceOf(address(this));
            require(value <= erc20balance, "balance is low");
            IERC20(user.tokens[_index]).transfer(msg.sender, value);


            user.quantity -= 1;

            if(user.quantity > 0){
                user.isLocker = true;
            }
            else{
                user.isLocker = false;
            }
                    
                    if (_index < 0 || _index >= user.balances.length) {
                return false;
            } else if(user.balances.length == 1) {
                user.balances.pop();
                user.withdrawtimes.pop();
                user.tokens.pop();
                return true;
            } else if (_index == user.balances.length - 1) {
                user.balances.pop();
                user.withdrawtimes.pop();
                user.tokens.pop();
                return true;
            } else {
                for (uint i = _index; i < user.balances.length - 1; i++) {
                    user.balances[i] = user.balances[i + 1];
                    user.withdrawtimes[i] = user.withdrawtimes[i+1];
                    user.tokens[i] = user.tokens[i+1];
                }
                
                user.balances.pop();
                user.withdrawtimes.pop();
                user.tokens.pop();
                return true;
            }

            
            
            

          

            

            
    }
    

 
}