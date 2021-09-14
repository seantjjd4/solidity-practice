// SPDX-License-Identifier: GPL 3.0

pragma solidity >=0.7.0 <0.9.0;

contract Company{
    
    event event_performance(address sales_address, uint256 profit);
    event event_add_sales(string name, address sales_address);
    event event_withdraw(address sales_address, uint256 amount);
    event event_receive(address donor, uint256 amount);
    
    string public boss_name;
    address payable public boss_address;
    address[] all_address;
    struct Sales{
        string name;
        address payable sales_address;
        uint256 performance;
        uint256 salary;
        uint256 withdrawn;
    }
    mapping(address => string) address_to_name;
    mapping(string => Sales) name_to_sales;
    
    modifier is_boss(){
        require(msg.sender == boss_address, "You are not the owner");
        _;
    }
    
    constructor(string memory name){
        boss_name = name;
        boss_address = payable(msg.sender);
    }
    
    function add_performance(string memory salesman , uint256 profit) public is_boss{
        name_to_sales[salesman].performance += profit;
        name_to_sales[salesman].salary += profit/10;
        emit event_performance(name_to_sales[salesman].sales_address, profit);
    }
    
    function add_sales(string memory salesman , address payable sales_address ) public is_boss{
        all_address.push(sales_address);
        address_to_name[sales_address] = salesman;
        name_to_sales[salesman].name = salesman;
        name_to_sales[salesman].sales_address = sales_address;
        name_to_sales[salesman].performance = 0;
        name_to_sales[salesman].salary = 0;
        name_to_sales[salesman].withdrawn = 0;
        
        emit event_add_sales(salesman, sales_address);
    }
    
    function check_balance(address payable sales_address) public view returns(uint256){
        Sales memory s = name_to_sales[address_to_name[sales_address]];
        return s.salary - s.withdrawn;
    }
    
    function my_balance () external view returns(uint256) {
        Sales memory s = name_to_sales[address_to_name[msg.sender]];
        return s.salary - s.withdrawn;
    }
    
    function get_all_performance() public view returns(uint256){
        uint256 sum = 0;
        for(uint i = 0; i < all_address.length; i++){
            address temp = all_address[i];
            sum += name_to_sales[address_to_name[temp]].performance;
        }
        return sum;
    }
    
    function withdraw() external returns(uint256){
        address payable user = payable(msg.sender);
        uint balance = check_balance(user);
        require(balance > 0, "balance not enough");
        user.transfer(balance);
        name_to_sales[address_to_name[user]].withdrawn += balance;
        emit event_withdraw(msg.sender, balance);
        return balance;
    }
    
    receive() external payable{
        emit event_receive(msg.sender, msg.value);
    
    }
    
    fallback() external payable{
        
    }
    
    function destroy() external is_boss{
        selfdestruct(boss_address);
    }
}