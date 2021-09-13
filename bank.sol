// SPDX-License-Identifier: GPL 3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bank{
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
    
    function AddBalance(address payable customer_address, uint256 value) public {
        address_to_customers[customer_address].customer_balance += value;
    }
    
    function AddLoan(address payable customer_address , uint256 value) public {
        address_to_customers[customer_address].customer_lending_amount += value;
    }
    function CheckBalance (address payable customer_address) public view returns(uint256) {
        return address_to_customers[customer_address].customer_balance - address_to_customers[customer_address].customer_lending_amount;
    }
    
    function CheckLoan (address payable customer_address) public view returns(uint256){
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
    
    function withdraw() external returns(uint256){
        address user = payable(msg.sender);
        uint256 balance = address_to_customers[user].customer_balance - address_to_customers[user].customer_lending_amount;
        address_to_customers[user].customer_balance -= balance;
        return balance;
    }
}