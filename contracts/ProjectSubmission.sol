// Step 1
pragma solidity ^0.5.0;

// Step 1
contract ProjectSubmission {

    // Step 1 (state variable)
    address payable public owner = msg.sender;

    // Step 4 (state variable)
    uint public ownerBalance; 
    
    // Step 1
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
    
    // Step 1
    struct University {
        bool available;
        uint balance;
    }

    // Step 1 (state variable)
    mapping(address => University) public universities;
    
    // Step 2
    enum ProjectStatus { Waiting, Rejected, Approved, Disabled }

    // Step 2
    struct Project {
        address payable author;
        address payable university;
        ProjectStatus status;
        uint balance;
    }
    
    // Step 2 (state variable)
    mapping(bytes32 => Project) public projects;

    // Step 1
    function registerUniversity(address payable universityAddress) public onlyOwner {
         universities[universityAddress].available = true;
    }
    
    // Step 1
    function disableUniversity(address payable universityAddress) public onlyOwner {
        universities[universityAddress].available = false;
    }
    
    // Step 2 and 4
    function submitProject(bytes32 projectHash, address payable universityAddress) public payable {
        require(msg.value == 1 ether, "The submission fee is 1 ether");
        require(projects[projectHash].author == address(0), "A project with this hash already exists.");
        require(universities[universityAddress].available == true, "The university does not accept submissions.");
        projects[projectHash] = Project(msg.sender, universityAddress, ProjectStatus.Waiting, 0);
        ownerBalance += 1 ether;      
    }
    
    // Step 3
    function disableProject(bytes32 projectHash) public onlyOwner {
        projects[projectHash].status = ProjectStatus.Disabled;
    }
    
    // Step 3
    function reviewProject(bytes32 projectHash, ProjectStatus status) public onlyOwner {
        require(status == ProjectStatus.Approved || status == ProjectStatus.Rejected, "The new status must be Approved or Rejected.");
        require(projects[projectHash].status == ProjectStatus.Waiting, "The current project status needs to be Waiting.");
        projects[projectHash].status = status;
    }
    
    // Step 4
    function donate(bytes32 projectHash) public payable {
        require(projects[projectHash].status == ProjectStatus.Approved, "Donations can only be received by projects with status Approved");
        projects[projectHash].balance += msg.value * 7 / 10;
        universities[projects[projectHash].university].balance +=  msg.value * 2 / 10;
        ownerBalance += msg.value * 1 / 10;
    }
    
    // Step 5
    function withdraw() public payable {
        require(msg.sender == owner || universities[msg.sender].balance > 0);
        if (msg.sender == owner) {
            uint amount = ownerBalance;
            ownerBalance = 0;
            msg.sender.transfer(amount);
        }
        else {
            uint amount = universities[msg.sender].balance;
            universities[msg.sender].balance = 0;
            msg.sender.transfer(amount);
        }
    }
    
    // Step 5 (Overloading Function)
    function withdraw(bytes32 projectHash) public payable {
        require(msg.sender == projects[projectHash].author, "Only the author can withdraw funds from a project.");
        uint amount = projects[projectHash].balance;
        projects[projectHash].balance = 0;
        msg.sender.transfer(amount);
    }    
       
}
