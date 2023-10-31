// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract buyerAgreement{
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State{Created, Locked, Release, Inactive}
    State public state;

    constructor() payable {
 seller = payable (msg.sender);
 value = msg.value / 2;
    }
//******************Modifiers**************
error invalidState();

modifier inState(State state_){
    if (state != state_){
        revert invalidState();
    }
    _;
}
//only buyer can call this function
error OnlyBuyer();

modifier onlyBuyer(){
    if (msg.sender != buyer){
        revert OnlyBuyer();
    }
    _;
}
error OnlySeller();
modifier onlySeller(){
    if (msg.sender != seller){
        revert OnlySeller();
    }
    _;
}


//*************Functions******************
function confirmPurchase() external inState(State.Created) payable {
    if (msg.value != 2 * value) {
            revert("Please send the right value");
        }
        buyer = payable(msg.sender);
        state = State.Locked;
}
function confirmRecieved() external onlyBuyer() inState(State.Locked) {
    state = State.Release;
    buyer.transfer(value);
}
function paySeller() external onlySeller() inState(State.Release) {
state = State.Inactive;
seller.transfer (3 * value);
}
function abort() external onlySeller() inState(State.Created){
    state = State.Inactive;
    seller.transfer(address(this).balance);
}
}