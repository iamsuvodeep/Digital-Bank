// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Bank{
    address public onwer;
    uint256 public collatralSiezeTime;

    constructor(){
        onwer = msg.sender;
        loanRepayTime = 1 minutes;
        interestRate = 3;
        collateralRate = 2;
        loanApprovalThreshold = 20 ether;
        collatralSiezeTime = 2 minutes;

    }

    mapping(address=>mapping(address=>uint256)) public collateralMoneyCollection;

    

    mapping(address=>uint256) public accountBalance;
    mapping(address=>uint256) public loanAppliedAmmount;
    mapping(address=>uint256) public currentLoan;
    mapping(address=>uint256) public loanRepaymentTime;
    mapping(address=>bool) public hasAppliedLoan;
    mapping(address=>bool) public isAllowed;
    mapping(address=>uint256) public colletralSieze;
    mapping(address=>uint256) public numDeposits;
    mapping(address=>bool) public hasLoan;
    //
    // mapping(address=>uint) public 
    mapping(address=>uint) public cibilScore;



    uint256 public interestRate;
    uint256 public loanRepayTime;
    uint256 public collateralRate;
    uint public loanApprovalThreshold;
    address [] public loanApplicant;

    



    


    //Users can Apply for a Loan

    function applyLoan(uint256 loanAmmount) public {
        require(!hasLoan[msg.sender],"You've already an outstanding Loan");
        require(!hasAppliedLoan[msg.sender],"You've already an outstanding Loan");
        require(loanAmmount <= loanApprovalThreshold,"We don't have these much money to make a loan");
        require(isAllowed[msg.sender],"Deposit some money first!");
        require(loanAppliedAmmount[msg.sender]  == 0,"You already have outstanding loan amount");

        require(accountBalance[msg.sender] >= loanAmmount/2,"You're not eligibile for this much amount");
        require(numDeposits[msg.sender] >=2,"You don't have enough deposits number");
        require(currentLoan[msg.sender] == 0,"Clear your first loan first");
        
        hasAppliedLoan[msg.sender] = true;
        loanAppliedAmmount[msg.sender] = loanAmmount;   

        ////////
        loanApplicant.push(msg.sender);

    }


    //Only Onwers can use
    modifier onlyOnwer(){
        require(msg.sender == onwer,"Only Onwers are eligible to do these sort of task");
        _;
    }


    //Get Pending loan Approval addresses 
    function getPendingLoanRequest() onlyOnwer public view returns(address){
        address latestAddress;
        for (uint i = 0; i<loanApplicant.length ; i++){
            if (!hasLoan[loanApplicant[i]]){
                 latestAddress = loanApplicant[i];
                return latestAddress;
            }
        }
        //return latestAddress;
    }

    //Deposit amount
    function deposit(uint256 ammount)private {
        require(ammount >= 0, "Deposit ammount can't be zero");
        accountBalance[msg.sender] += ammount;
        isAllowed[msg.sender] = true;
        numDeposits[msg.sender]++;
        cibilScore[msg.sender]++;

    }

    receive() external payable{
        require(msg.value >= 0, "Deposit ammount can't be zero");
        accountBalance[msg.sender] += msg.value;
        isAllowed[msg.sender] = true;
        numDeposits[msg.sender]++;
        cibilScore[msg.sender]++;

    }


    

    //mapping(address=>bool) public shoulSiezeCollatral;
  
    //Repay User's Loan 
    function rePayLoan() public  payable{
        require(currentLoan[msg.sender] > 0,"You don't have any active loan");
        uint256 userLoan = currentLoan[msg.sender];
        uint256 intrest = userLoan*interestRate/100; 
        uint256 totalLoan = (userLoan + intrest) ;

        require(accountBalance[msg.sender] >= totalLoan,"Not Enough Funds in your Account");
        //require(isAllowed[msg.sender],"Your're not Allowed!");
        uint totalTimeElipsed = block.timestamp - loanRepaymentTime[msg.sender];
        require(totalTimeElipsed > loanRepayTime,"You can't repay your loan within this tenure");
        accountBalance[msg.sender] -= totalLoan;
        accountBalance[onwer] += intrest;

        
        loanRepaymentTime[msg.sender] = 0;
        hasAppliedLoan[msg.sender] = false;
        //cibilScore[msg.sender]++;
        hasLoan[msg.sender] = false;

//
        if (totalTimeElipsed  > 2 minutes){
           
            uint256 _sizeMoney = currentLoan[msg.sender]/2;
            payable(onwer).transfer(_sizeMoney);
            collatralMoney[onwer] += _sizeMoney;
            accountBalance[msg.sender] -= _sizeMoney;
            accountBalance[onwer] += _sizeMoney;
            cibilScore[msg.sender]--;
            currentLoan[msg.sender] = 0;
            
        } else{
            collateralMoneyCollection[msg.sender][onwer] = 0;
            cibilScore[msg.sender]++;
            currentLoan[msg.sender] = 0;
            
        }

//
    }

    



    //Approve Loan 
     function approveLoan(address id) onlyOnwer public {
        require(id != address(0),"Id can't be invalid address");
        require(hasAppliedLoan[id],"This peroson haven't apply for any loan");
        //uint totalLoan = loanAppliedAmmount[id]*(loanAppliedAmmount[id] * (interestRate /100));
        uint256 appliedLoan = loanAppliedAmmount[id];
        require(accountBalance[id] >= appliedLoan,"This user doesn't have thresold balance");
        require(loanAppliedAmmount[id] > 0, "This user haven't taken any loan");
        
        colletralSieze[id] += appliedLoan / 2;

        accountBalance[id] += appliedLoan;
        loanRepaymentTime[id] = block.timestamp;
        //accountBalance[onwer] -= appliedLoan;
        currentLoan[id] = appliedLoan;
        hasAppliedLoan[id] = false;
        loanAppliedAmmount[id] = 0;
        hasLoan[id] = true;
        //sizeMoneyTime[id] = block.timestamp;
        

        collateralMoneyCollection[id][onwer] += colletralSieze[id];



    
    }
    

    mapping(address=>uint256) public collatralMoney;
    
    mapping(address=>uint256) public sizeMoneyTime; 

    //Get User's balance

    function getBalance() public view returns(uint256){

        return accountBalance[msg.sender];

    }

}