pragma solidity ^0.5.9;

contract KYC_Customer {

    address adminAddress;
    constructor() public{
        adminAddress = msg.sender;
    }

    // Structs of Smart Contracts ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Customer Struct. It defines a custom type to be used to store customer data recieved.
	struct Customer {
		bytes32 customerName;                                                                               // The username is Provided by the Customer and is used to track the customer details.
		bytes32 customerData;                                                                               // This is the hash of the data or identity documents provided by the Customer.
		uint256 customerRating;                                                                             // This is the rating given the customer based on the regularity by other banks.
		uint256 customerUpvotes;                                                                            // This is the number of upvotes received from other banks over the Customer data.
		address bankAddress;                                                                                // This is a unique address of the bank that validated the customer account.
	  bytes32 password;                                                                                   // This is the password needed if the customer requests his data to not share with other banks.
	  bool shareData;                                                                                     // If customer wants to share data then true.
	}

	// Bank Struct. It defines a custom type to be used to store bank data.
	struct Bank {
		bytes32 bankName;                                                                                   // The name of the bank.
		address ethAddress;                                                                                 // This variable specifies the unique Ethereum address of the bank.
		uint256 bankRating;                                                                                 // This is the rating received from other banks or admin based on number of valid/invalid KYC verifications.
		uint256 kycCount;                                                                                   // These are the number of KYC requests initiated by the bank.
		address bankAddress;                                                                                // The registration number for the bank.
		uint256 bankUpvotes;                                                                                // This is the number of upvotes received from other banks to the bank.
	  bool isAllowed;                                                                                     // IsAllowed is used to specify if the request is added by a trusted bank or not. If a bank is not secure, then the IsAllowed is set to false by admin.
	  bytes32 bankRegistrationNumber;
	}

	// KYC_Request Struct. It defines a custom type to be used to store KYC Requests.
	struct KYC_Request {
		bytes32 customerName;                                                                               // The username is Provided by the Customer and is used to track the customer details.
		bytes32 customerData;                                                                               // This is the hash of the data or identity documents provided by the Customer.
		address bankAddress;                                                                                // This is a unique address of the bank that initiated the KYC request.
	  bool shareData;                                                                                     // If customer wants to share data then true.
	}

	// State Variables of Smart Contract //
	mapping(bytes32 => Customer) public customersList;                                                       // The main Customer state variable of the type 'mapping'. This will be like a hash-map of all customers.
	mapping(address => Bank) public banksList;                                                               // The main Bank state variable of the type 'mapping'. This will be like a hash-map of all banks.
	mapping(address => KYC_Request) public kycList;                                                          // The main KYC_Requests state variable of the type 'mapping'. This will be like a hash-map of all KYC_Requests.

	// Events of Smart Contract ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	event AddRequest (bytes32 customerName, bytes32 customerData, address indexed bankAddress);              // To add the KYC request to the requests list.
	event RemoveRequest (bytes32 customerName, address bankAddress);                                         // To remove the requests from the requests list.
	event AddCustomer (bytes32 customerName, bytes32 customerData, address indexed bankAddress);             // To add a customer to the customer list.
	event RemoveCustomer (bytes32 customerName, address bankAddress);                                        // To remove the customer from the customer list.
	event UpvoteCustomer (bytes32 customerName, address bankAddress);                                        // To allow a bank to cast an upvote for a customer. ADDITIONAL: Added bankAddress to keep log.
	event ModifyCusomterData (bytes32 customerName, address bankAddress);                                    // To allow a bank to modify a customer's data. Only applicable for validated customers present in the customer list. ADDITIONAL: Added bankAddress to keep log.
  event UpvoteBank (bytes32 upvotedBankName, address voter);                                               // To upvote a bank by another bank or admin.
  event AddBank (bytes32 bankName);                                                                        // To add a new bank in the network. Only by admin.
  event BankRemoved (address bankAddress);                                                                 // To remove a bank from the network. Only by admin.


  // Bank Functions of Smart Contract //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// This function is used to add the KYC request to the requests list.
	function addRequest(bytes32 customerName, bytes32 customerData, bool shareData) external returns(uint256) {
		kycList[msg.sender].customerName = customerName;
		kycList[msg.sender].customerData = customerData;
		kycList[msg.sender].shareData = shareData;
		kycList[msg.sender].bankAddress = msg.sender;
		emit AddRequest(customerName, customerData, msg.sender);
		return 1;
	}

	// This function will add a customer to the customer list.
	function addCustomer(bytes32 newCustomerName, bytes32 newCustomerData, uint256 firstRating, bytes32 password) external returns(uint256) {
	    customersList[newCustomerName].customerName = newCustomerName;
	    customersList[newCustomerName].customerData = newCustomerData;
	    customersList[newCustomerName].customerRating = firstRating;
		  if (kycList[msg.sender].shareData == false){
		     customersList[newCustomerData].password = password;
		}
		emit AddCustomer(newCustomerName, newCustomerData, msg.sender);
		return 1;
	}

    // This function will remove the requests from the requests list.
    function removeRequest(bytes32 customerName) external returns(uint256) {
        delete kycList[msg.sender];
        emit RemoveRequest(customerName, msg.sender);
        return 1;
	}

	// This function will remove the customer from the customer list.
	function removeCustomer(bytes32 customerName) external returns(uint256) {
		delete customersList[customerName];
		emit RemoveCustomer(customerName, msg.sender);
		return 1;
	}

	// This function allows a bank to view details of a customer.
	function viewCustomer(bytes32 customerName) external view returns(bytes32 customerData) {
		return customersList[customerName].customerData;
	}

    // This function allows a bank to cast an upvote for a customer.
	function upvoteCustomer(bytes32 customerName) external returns(uint256) {
		customersList[customerName].customerUpvotes += 1;
		emit UpvoteCustomer(customerName, msg.sender);
		return 1;
	}

	// This function allows a bank to modify a customer's data.
	function modifyCusomter(bytes32 customerName, bytes32 customerData) external returns(uint256) {
		if (banksList[msg.sender].isAllowed == true) {
		    customersList[customerName].customerName = customerName;
		    customersList[customerName].customerData = customerData;
		    customersList[customerName].bankAddress = msg.sender;
		    emit ModifyCusomterData(customerName, msg.sender);
		    return 1;
		} else return 0;
	}

	// This function will return a list of all the requests initiated by the bank which are yet to be validated.
	function getBankRequest(address bankAddress) external view returns (bytes32 customers) {
	return kycList[bankAddress].customerName;
    }

    // This function is used to add and update votes for the banks.
	function upvoteBank(bytes32 upvotedBankName, address upvotedBankAddress) external returns(uint256) {
		if(banksList[msg.sender].bankName != upvotedBankName){
		    banksList[upvotedBankAddress].bankUpvotes += 1;
		    emit UpvoteBank(upvotedBankName, msg.sender);
		    return 1;
		} else return 0;
	}

	// This function is used to fetch customer rating from the smart contract.
	function getCustomerRating(bytes32 customerName) external view returns(uint256 customerRating) {
		return customersList[customerName].customerRating;
	}

	// This function is used to fetch Bank rating from the smart contract.
	function getBankRating(address bankAddress) external view returns(uint256 bankRating) {
		return banksList[bankAddress].bankRating;
	}

	// This function is used to fetch the bank details which made the last changes to the customer data.
	function getAccessHistory(bytes32 customerName) external view returns(address lastBankAddress){
	    return customersList[customerName].bankAddress;
	}

  // This function is used to set a password for customer data, which can be later be unlocked by using the password.
  function setPassword(bytes32 customerName, bytes32 password) external returns(bool){
     if(customersList[customerName].shareData == false){
        customersList[customerName].password = password;
          return true;
     } else return false;
  }

  // This function is used to fetch the bank details.
  function getBankDetails(address bankAddress) external view returns(bytes32 bankName){       //This function should have return type of bank - but IDK how to do it
      return banksList[bankAddress].bankName;                                                 //using string[] memory as return type gives warning. Hence letting it go.
  }


  // Admin Functions of Smart Contract //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// This function is used by the admin to add a bank to the KYC Contract. You need to verify if the user trying to call this function is admin or not.
	function addBank(bytes32 newBankName, address newBankAddress, bytes32 newBankRegistrationNumber) external returns(uint256){
	    if(banksList[msg.sender].bankAddress == adminAddress){
	        banksList[newBankAddress].bankName = newBankName;
	        banksList[newBankAddress].bankAddress = newBankAddress;
	        banksList[newBankAddress].bankRegistrationNumber = newBankRegistrationNumber;
	        banksList[newBankAddress].isAllowed = true;
	        emit AddBank(newBankName);
	        return 1;
	    } else return 0;
	}

	// This function is used by the admin to remove a bank from the KYC Contract.  You need to verify if the user trying to call this function is admin or not.
	function removeBank(address bankAddress) external returns(uint256){
	    if(banksList[msg.sender].bankAddress == adminAddress){
	        delete banksList[bankAddress];
	        emit BankRemoved (bankAddress);
	        return 1;
	    } else return 0;
	}

}
