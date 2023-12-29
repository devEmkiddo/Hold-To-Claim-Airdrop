// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
.
.
.

    MADE BY devEMKIDDO 
    check out my github https://github.com/devEmkiddo

*/

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                 assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

//MUST HOLD X TOKEN TO BE ABLE TO CLAIM AIRDROP

contract Airdrop{
   using SafeMath for uint;
   using Address for address;
   address public owner;
   address public burnAddress = 0x000000000000000000000000000000000000dEaD;
   uint256 public airdropAmount = 2000 *10**9;
   uint256 public airdropFee = 5000000000000000 wei;
   IERC20 public token;
   IERC20 public tokenHold;

    event Airdropped(
        address indexed to,
        uint256 amount
        );

    event ChangedOwnership(
        address oldOwner,
        address newOwner
    );
    event Withdrawal(
        address indexed from,
         address indexed to,
          uint256 value
          );
     event TokenAirdropped(
      address indexed to,
       uint256 amount
    );

    bool private locked;

    modifier noReentrancy() {
        require(!locked, "Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token, address _tokenHold){
        token = IERC20(_token);
        tokenHold = IERC20(_tokenHold);
        owner = payable(msg.sender);
    }

    function claimAirdrop() public payable noReentrancy{
        require(tokenHold.balanceOf(msg.sender) > 0, "Must hold X token to be eligible for this airdrop");
        require(token.balanceOf(address(this)) >= airdropAmount, "Insufficient contract balance");
        require(msg.value == airdropFee, "Invalid Fee Amount");
        token.transfer(msg.sender, airdropAmount);
        emit Airdropped(msg.sender, airdropAmount);
    }

    function withdrawEth() public onlyOwner noReentrancy{
        uint256 contractBal = address(this).balance;
        require(contractBal > 0, "Insufficient contract balance");
        (bool success, ) = payable(owner).call{value: contractBal}("");
        require(success, "Failed");
        emit Withdrawal(address(this), msg.sender, contractBal);
    }
    function withdrawToken() public onlyOwner noReentrancy{
        uint contractBal = token.balanceOf(address(this));
         require(contractBal > 0, "Insufficient contract balance");
         token.transfer(owner, contractBal);
         emit Withdrawal(address(this), msg.sender, contractBal);
    }
     function burnTokens(uint256 amount) external onlyOwner{
       require(amount > 0, "Balance must be greater than 0");
        token.transfer(burnAddress, amount);
    }

    function changeOwner(address _newOwner) public onlyOwner{
        require(owner != address(0), "Owner cannot be the dead address");
      owner = payable(_newOwner);
      emit ChangedOwnership(msg.sender, _newOwner);
    }

    function emergencyExit() public onlyOwner{
        withdrawEth();
        withdrawToken();
    }
    function airdroppedBalance(address account) public view returns(uint256){
       return token.balanceOf(account);
    }
    function tokenHoldBalance(address account) public view returns (uint256){
       return tokenHold.balanceOf(account);
    }
}

/*This Solidity smart contract, named Airdrop, facilitates an airdrop distribution 
of a specified token to users who hold another designated token. The contract is designed 
to be simple, secure, and transparent. Additionally, it includes features for the contract 
owner to manage withdrawals, change ownership, and handle emergency situations.

MADE BY devEMKIDDO 
check out my github https://github.com/devEmkiddo
*/
