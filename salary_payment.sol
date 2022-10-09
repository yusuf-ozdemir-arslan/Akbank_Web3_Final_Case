// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract salary_payment {
    // Employer address is defined.
    address employer;

    // Log event is defined.
    event log(address addr, uint amount, uint contract_balance);

    // Constructor only runs once. 
    // When the smart contract is deployed the employer will be the owner of the contract.
    constructor() {
        employer = msg.sender;
    }

    // The employee is defined as struct.
    struct Employee {
        address payable wallet_address;
        string first_name;
        string last_name;
        uint release_time;
        uint amount;
        bool can_withdraw;
    }

    // Array of employee is defined as Employees.
    Employee[] public Employees;

    // Require has been used because only the employer can add new employees.
    modifier only_employer() {
        require(msg.sender == employer, "Employer can add new Employees");
        _;  // This line means rest of the given function.
    }

    // This particular function is used to add employees to the smart contract.
    function add_employee(address payable wallet_address, string memory first_name, string memory last_name, uint release_time, uint amount, bool can_withdraw) public only_employer {
        Employees.push(Employee(
            wallet_address,
            first_name,
            last_name,
            release_time,
            amount,
            can_withdraw
        ));
    }

    // Employees can check their balances with this function.
    function balance_of() public view returns(uint) {
        return address(this).balance;
    }

    // Deposit funds to smart contract. 
    function deposit(address wallet_address) payable public {
        add_employee_balance(wallet_address);
    }

    // This function can add balance to employees address.
    function add_employee_balance(address wallet_address) private {
        for(uint i = 0; i < Employees.length; i++) {
            if(Employees[i].wallet_address == wallet_address) {
                Employees[i].amount += msg.value;
                emit log (wallet_address, msg.value, balance_of());
            }
        }
    }
    
    //This function can only return index of an employee using their address.
    function find_index(address wallet_address) view private returns(uint) {
        for(uint i = 0; i < Employees.length; i++) {
            if (Employees[i].wallet_address == wallet_address) {
                return i;
            }
        }
        return 9999; // this return value limits the total number of employees
    }

    // Employee checks if they can withdraw.
    function withdraw_check(address wallet_address) public returns(bool) {
        uint i = find_index(wallet_address);
        require(block.timestamp > Employees[i].release_time, "You cannot withdraw yet");
        if (block.timestamp > Employees[i].release_time) {
            Employees[i].can_withdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // This function allows employees to withdraw the amount if they are not eligible to withdraw function will show an error message.
    function withdraw(address payable wallet_address) payable public {
        uint i = find_index(wallet_address);
        require(msg.sender == Employees[i].wallet_address, "Be an Employee to withdraw");
        require(Employees[i].can_withdraw == true, "You are not able to withdraw at this time");
        Employees[i].wallet_address.transfer(Employees[i].amount);
    }
}

