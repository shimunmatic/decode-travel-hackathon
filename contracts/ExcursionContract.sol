// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ExcursionContract {
    uint256 public tourId;
    address payable public operator;
    address payable public guide;
    ERC20 public token;
    Customer[] customers;
    Checkpoint[] checkpoints;
    bool joruneyEnded;
    uint256 unitPrice;

    struct Checkpoint {
        uint256 id;
        address[] checkedInUsers;
        bool endingCheckpoint;
    }

    struct Customer {
        address id;
        bool checkedIn;
    }

    event Log(string message);
    event Log(uint256 message);

    mapping(address => bool) public isValidCustomer;

    constructor(
        address _guide,
        uint256 _tourId,
        uint256[] memory _checkpoints,
        uint256 _endingCheckpoint,
        uint256 _unitPrice
    ) {
        operator = payable(msg.sender);
        token = ERC20(0xE3Ca443c9fd7AF40A2B5a95d43207E763e56005F);
        guide = payable(_guide);
        tourId = _tourId;
        unitPrice = _unitPrice;
        for (uint256 i = 0; i < _checkpoints.length; i++) {
            checkpoints.push(
                Checkpoint(
                    _checkpoints[i],
                    new address[](0),
                    _checkpoints[i] == _endingCheckpoint
                )
            );
        }
    }

    function data()
        external
        view
        returns (
            uint256,
            address payable,
            address payable,
            ERC20,
            Checkpoint[] memory,
            bool
        )
    {
        return (tourId, operator, guide, token, checkpoints, joruneyEnded);
    }

    function getCustomers() external view returns (Customer[] memory) {
        return customers;
    }

    modifier isOperator() {
        require(operator == msg.sender, "Not the operator");
        _;
    }

    modifier isCustomer() {
        require(isValidCustomer[msg.sender], "Not a customer");
        _;
    }

    modifier isCheckedInCustomer() {
        require(isValidCustomer[msg.sender], "Not a customer");
        int256 customerIndex = getCustomerIndexByAddress(msg.sender);
        require(customers[uint256(customerIndex)].checkedIn, "Not checked in");
        _;
    }

    function addCustomer(address _customer) public isOperator {
        require(
            !isValidCustomer[_customer] ||
                _customer == operator ||
                _customer == guide,
            "Customer invalid"
        );
        customers.push(Customer(_customer, false));
        isValidCustomer[_customer] = true;
    }

    function balance() public view returns (uint256) {
        return token.allowance(operator, address(this));
    }

    function neededBalance() public view returns (uint256) {
        return customers.length * unitPrice;
    }

    function checkIn(uint256 id) public isCustomer {
        // check there are enough funds
        if (id > 0) {
            checkpoint(id);
            return;
        }
        require(
            balance() >= neededBalance(),
            "Not enough funds in the contract"
        );

        int256 customerIndex = getCustomerIndexByAddress(msg.sender);
        require(
            !customers[uint256(customerIndex)].checkedIn,
            "Already checked in"
        );
        customers[uint256(customerIndex)].checkedIn = true;
    }

    function getCustomerIndexByAddress(address _customer)
        internal
        view
        returns (int256)
    {
        int256 customerIndex = -1;

        for (uint256 i = 0; i < customers.length; i++) {
            if (customers[i].id == _customer) {
                customerIndex = int256(i);
                break;
            }
        }
        return customerIndex;
    }

    function checkpoint(uint256 checkpointId) internal isCheckedInCustomer {
        // get the checkpoint
        int256 id = getCheckpointIndexById(checkpointId);
        require(id >= 0, "Checkpoint not found");
        // check that the customer is not already checked in on the checkpoint
        bool checkedIn = false;
        for (
            uint256 i = 0;
            i < checkpoints[uint256(id)].checkedInUsers.length;
            i++
        ) {
            if (checkpoints[uint256(id)].checkedInUsers[i] == msg.sender) {
                checkedIn = true;
                break;
            }
        }

        require(!checkedIn, "Already checked in at the checkpoint");
        // check in to the checkpoint
        checkpoints[uint256(id)].checkedInUsers.push(msg.sender);
        // if it is the last checkpoint and the number of the checked in users is equal to number of the users checked in for the tour - initiate the automatic end of the journey
        if (
            checkpoints[uint256(id)].endingCheckpoint &&
            checkpoints[uint256(id)].checkedInUsers.length ==
            getNumberOfCheckedInUsers()
        ) {
            endJourney();
        }
    }

    function endJourney() internal {
        joruneyEnded = true;
        payTheGuide();
    }

    function payTheGuide() internal {
        uint256 valueToBeTransfered = getNumberOfCheckedInUsers() * unitPrice;
        token.transferFrom(operator, guide, valueToBeTransfered);
    }

    function getNumberOfCheckedInUsers() internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < customers.length; i++) {
            if (customers[i].checkedIn) {
                count++;
            }
        }
        return count;
    }

    function getCheckpointIndexById(uint256 id) internal view returns (int256) {
        int256 index = -1;

        for (uint256 i = 0; i < checkpoints.length; i++) {
            if (checkpoints[i].id == id) {
                index = int256(i);
                break;
            }
        }
        return index;
    }
}
