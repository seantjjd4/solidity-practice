// SPDX-License-Identifier: GPL 3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bank{
    
    event event_add_balance(address customer_address, uint256 amount);
    event event_add_loan(address customer_address, uint256 amount);
    event event_withdraw(address customer_address, uint256 amount);
    event event_receive(address donor, uint256 amount);
    
    address payable owner;
    string public bank_name;
    uint8 day_interest_rate;
    uint8 day_lending_rate;
    address[] all_address;
    uint256 total_costomers = 0;
    struct Customers{
        uint256 customer_number;
        string customer_name;
        uint256 customer_balance;
        uint256 customer_lending_amount;
    }
    mapping(address => Customers) address_to_customers;
    
    modifier is_onwer(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor(string memory name){
        bank_name = name;
    }
    
    function add_customer(string memory customer_name, address payable customer_address) public {
        all_address.push(customer_address);
        total_costomers += 1;
        address_to_customers[customer_address].customer_number = total_costomers;
        address_to_customers[customer_address].customer_name = customer_name;
        address_to_customers[customer_address].customer_balance = 0;
        address_to_customers[customer_address].customer_lending_amount = 0;
    }   
    
    function add_balance(address payable customer_address, uint256 value) public is_onwer{
        address_to_customers[customer_address].customer_balance += value;
        emit event_add_balance(customer_address, value);
        
    }
    
    function add_loan(address payable customer_address , uint256 value) public is_onwer{
        address_to_customers[customer_address].customer_lending_amount += value;
        emit event_add_loan(customer_address, value);
    }
    function check_balance (address payable customer_address) public view returns(uint256) {
        return address_to_customers[customer_address].customer_balance - address_to_customers[customer_address].customer_lending_amount;
    }
    
    function check_loan (address payable customer_address) public view returns(uint256){
        return address_to_customers[customer_address].customer_lending_amount;
    }
    
    function my_balance () external view returns(uint256) {
        Customers memory b = address_to_customers[msg.sender];
        return b.customer_balance;
    }
    
    function get_all_balance() public view returns(uint256){
        uint256 sum = 0;
        for(uint i = 0; i < all_address.length; i++){
            address temp = all_address[i];
            sum += address_to_customers[temp].customer_balance;
            sum -= address_to_customers[temp].customer_lending_amount;
        }
        return sum;
    }
    
    receive() external payable{
        emit event_receive(msg.sender, msg.value);
    }
    
    fallback() external payable{
        
    }
    
    function destroy() external is_onwer{
        selfdestruct(owner);
    }
    
    function withdraw() external returns(uint256){
        address user = payable(msg.sender);
        uint256 balance = address_to_customers[user].customer_balance - address_to_customers[user].customer_lending_amount;
        require(balance > 0, "balance not enough");
        address_to_customers[user].customer_balance -= balance;
        return balance;
    }
}