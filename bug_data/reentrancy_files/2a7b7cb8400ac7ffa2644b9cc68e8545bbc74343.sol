pragma solidity ^0.4.11;


contract ShareholderAgreement {

	struct Vote {
		uint numNewShares;
		uint salePriceWei;
		uint votesFor;
		address proposedBy;
		bool finished;
		address walletForFundraising;
		uint sharesSold;
	}

	struct ShareholderCheckpoint {
		uint atTreasuryCheckpointIndex;
		uint shares;
		bool voting;
		bool paid;
	}

	struct TreasuryCheckpoint {
		uint profits;
		uint totalSharesOutstanding;
	}

	// checkpoint of profits and shares outstanding
	TreasuryCheckpoint[] public treasuryCheckpoints;

	Vote[] public votes;

	mapping (address => uint) public shareholderVotingFor;

	// checkpoints of balances for shareholders
	mapping (address => ShareholderCheckpoint[]) public shareholderCheckpoints;

	event Transfer(address indexed from, address indexed to, uint value);
	event DividendPaid(address indexed to, uint value);
	event ProfitsAdded(uint value);
	event NewProposal(uint indexed proposalIndex, address indexed proposedBy);
	event ProposalPassed(uint indexed proposalIndex, address indexed proposedBy);
	event SharesIssued(uint indexed proposalIndex, uint indexed numNewShares, address indexed proposedBy);

	function ShareholderAgreement(
		uint _totalShares
	) {
		treasuryCheckpoints.push(TreasuryCheckpoint({
			profits: 0,
			totalSharesOutstanding: _totalShares
		}));

		shareholderCheckpoints[msg.sender].push(ShareholderCheckpoint({
			atTreasuryCheckpointIndex: 0,
			shares: _totalShares,
			paid: false,
			voting: false
		}));
		// push an initial vote that represents a safe null-vote to set for `shareholderVotingFor` (index of 0)
		votes.push(Vote({
			numNewShares: _totalShares,
			salePriceWei: 0,
			votesFor: 0,
			proposedBy: msg.sender,
			finished: true,
			walletForFundraising: 0x0,
			sharesSold: _totalShares
		}));

	}

	function transfer(address _receiver, uint _amount) returns(bool sufficient) {
		if(shareholderCheckpoints[msg.sender].length == 0) return false;

		uint senderCheckpointIndex = shareholderCheckpoints[msg.sender].length - 1;
		uint receiverCheckpointIndex;
		if(shareholderCheckpoints[_receiver].length != 0) {
			receiverCheckpointIndex = shareholderCheckpoints[_receiver].length - 1;
		}

		if (shareholderCheckpoints[msg.sender][senderCheckpointIndex].shares < _amount) return false;
		if (shareholderCheckpoints[msg.sender][senderCheckpointIndex].voting == true) return false;
		if(shareholderCheckpoints[_receiver].length != 0){
			if (shareholderCheckpoints[_receiver][receiverCheckpointIndex].voting == true) return false;
		}

		// make a new checkpoint if the shareholder's checkpoint is older than the atTreasuryCheckpointIndex
		ShareholderCheckpoint memory newCheckpoint; // this gets reused
		if (shareholderCheckpoints[msg.sender][senderCheckpointIndex].atTreasuryCheckpointIndex < treasuryCheckpoints.length - 1) {
			newCheckpoint = ShareholderCheckpoint({
				atTreasuryCheckpointIndex: treasuryCheckpoints.length - 1,
				shares: shareholderCheckpoints[msg.sender][senderCheckpointIndex].shares,
				paid: false,
				voting: false
			});

			shareholderCheckpoints[msg.sender].push(newCheckpoint);
			++senderCheckpointIndex;
		}

		// make sure the reciever has an available checkpoint that is not older than the atTreasuryCheckpointIndex
		if (shareholderCheckpoints[_receiver].length == 0){
			newCheckpoint = ShareholderCheckpoint({
				atTreasuryCheckpointIndex: treasuryCheckpoints.length - 1,
				shares: 0,
				paid: false,
				voting: false
			});

			shareholderCheckpoints[_receiver].push(newCheckpoint);
			receiverCheckpointIndex = 0;
		}
		else if (shareholderCheckpoints[_receiver][receiverCheckpointIndex].atTreasuryCheckpointIndex < treasuryCheckpoints.length - 1){
			newCheckpoint = ShareholderCheckpoint({
				atTreasuryCheckpointIndex: treasuryCheckpoints.length -1,
				shares: shareholderCheckpoints[_receiver][receiverCheckpointIndex].shares,
				paid: false,
				voting: false
			});

			shareholderCheckpoints[_receiver].push(newCheckpoint);
			++receiverCheckpointIndex;
		}

		
		shareholderCheckpoints[msg.sender][senderCheckpointIndex].shares -= _amount;
		shareholderCheckpoints[_receiver][receiverCheckpointIndex].shares += _amount;
		Transfer(msg.sender, _receiver, _amount);
		return true;
	}


	function getSharesFor(address _account) constant returns(uint) {
		if(shareholderCheckpoints[_account].length == 0) return 0;
		
		uint accountCheckpointIndex = shareholderCheckpoints[_account].length - 1;

		return shareholderCheckpoints[_account][accountCheckpointIndex].shares;
	}

	function amountOfDividendOwed(address _account) constant returns(uint) {
		if(shareholderCheckpoints[_account].length == 0) return 0;

		var checkpoints = shareholderCheckpoints[_account];
		/*
			we need to see if the shareholder has any shares in
			blocks between (& incl.) `nextShareholderIndex` and  (& not incl.) `treasuryCheckpoints.length -1`
		*/
		uint amountOwed = 0;
		for (uint index = 0; index < checkpoints.length; index++) {
			var checkpoint = checkpoints[index];
			if(
				checkpoint.paid == false && checkpoint.atTreasuryCheckpointIndex < treasuryCheckpoints.length - 1
			){
				var indexOfLatestCheckpoint = treasuryCheckpoints.length - 1; // pay until last index avail
				if(checkpoints.length - 1 > index){ // if there is a checkpoint after this one
					indexOfLatestCheckpoint = checkpoints[index + 1].atTreasuryCheckpointIndex; // then pay until the next checkpoint
				}

				// has to loop through the to make sure it account for totalSharesOutstanding
				for (uint i = checkpoint.atTreasuryCheckpointIndex; i < indexOfLatestCheckpoint; i++){
					amountOwed += checkpoint.shares * treasuryCheckpoints[i + 1].profits / treasuryCheckpoints[i + 1].totalSharesOutstanding;
				}
				// amountOwed += (
				// 	checkpoint.shares * treasuryCheckpoints[checkpoint.atTreasuryCheckpointIndex + 1].profits 
				// 	/ treasuryCheckpoints[checkpoint.atTreasuryCheckpointIndex + 1].totalSharesOutstanding);
				// calculate amount owed
			}
		}

		return amountOwed;
		// look at the current treasury checkpoint 

	}

	function payoutDividendOwed() returns (bool) {
		uint amountOwed = amountOfDividendOwed(msg.sender);
		if(amountOwed == 0) return false;
		
		msg.sender.transfer(amountOwed);

		for (uint index = 0; index < shareholderCheckpoints[msg.sender].length; index++) {
			if(
				shareholderCheckpoints[msg.sender][index].paid == false && shareholderCheckpoints[msg.sender][index].atTreasuryCheckpointIndex < treasuryCheckpoints.length - 1
			){
				shareholderCheckpoints[msg.sender][index].paid = true;
			}
		}

		var newCheckpoint = ShareholderCheckpoint({
				atTreasuryCheckpointIndex: treasuryCheckpoints.length - 1,
				shares: shareholderCheckpoints[msg.sender][shareholderCheckpoints[msg.sender].length - 1].shares,
				paid: false,
				voting: false
			});

		shareholderCheckpoints[msg.sender].push(newCheckpoint);

		// TODO make a new checkpoint
		DividendPaid(msg.sender, amountOwed);
		return true;
	}

	function () payable {
		// we set a min amount so that low value transactions cannot create extra check points needlessly
		require(msg.value >= 500 finney);
		uint totalSharesOutstanding = treasuryCheckpoints[treasuryCheckpoints.length - 1].totalSharesOutstanding;
		treasuryCheckpoints.push(TreasuryCheckpoint({
			profits: msg.value,
			totalSharesOutstanding: totalSharesOutstanding
		}));
		// we issue two checkpoints so that the second checkpoint may be used for issuing new shares
		// in the buyShares function without changing the amount of profits owed
		// could prob do this somewhere else as where (like before issuing shares, make sure the last checkpoint had no profits)
		treasuryCheckpoints.push(TreasuryCheckpoint({
			profits: 0,
			totalSharesOutstanding: totalSharesOutstanding
		}));
		ProfitsAdded(msg.value);
		// todo call event
	}

	function proposeVote (uint _numNewShares, uint _salePriceWei, address _walletForFundraising) returns (bool) {
		votes.push(Vote({
			numNewShares: _numNewShares,
			salePriceWei: _salePriceWei,
			votesFor: 0,
			proposedBy: msg.sender,
			finished: false,
			walletForFundraising: _walletForFundraising,
			sharesSold: 0
		}));
		NewProposal(votes.length - 1, msg.sender);
		return true;
	}

	function vote(uint _proposalIndex) returns (bool) {
		if(
			votes[_proposalIndex].finished == false &&
			shareholderCheckpoints[msg.sender][shareholderCheckpoints[msg.sender].length - 1].voting == false
		){
			shareholderCheckpoints[msg.sender][shareholderCheckpoints[msg.sender].length - 1].voting = true;
			votes[_proposalIndex].votesFor += shareholderCheckpoints[msg.sender][shareholderCheckpoints[msg.sender].length - 1].shares;
			shareholderVotingFor[msg.sender] = _proposalIndex;
			// see if vote is finished here
			if ((votes[_proposalIndex].votesFor * 100) / treasuryCheckpoints[treasuryCheckpoints.length - 1].totalSharesOutstanding > 51){
				uint totalSharesOutstanding = treasuryCheckpoints[treasuryCheckpoints.length - 1].totalSharesOutstanding;
				treasuryCheckpoints.push(TreasuryCheckpoint({
					profits: 0,
					totalSharesOutstanding: totalSharesOutstanding
				}));
				votes[_proposalIndex].finished = true;
				ProposalPassed(_proposalIndex, votes[_proposalIndex].proposedBy);
			}
			return true;
		}
		else {
			return false;
		}
	}
	function unvote(uint _proposalIndex) returns (bool) {
		if(
			shareholderVotingFor[msg.sender] == _proposalIndex &&
			shareholderCheckpoints[msg.sender][shareholderCheckpoints[msg.sender].length - 1].voting == true
		){
			shareholderCheckpoints[msg.sender][shareholderCheckpoints[msg.sender].length - 1].voting = false;
			if(votes[_proposalIndex].finished == false){
				votes[_proposalIndex].votesFor -= shareholderCheckpoints[msg.sender][shareholderCheckpoints[msg.sender].length - 1].shares;
				shareholderVotingFor[msg.sender] = 0;
			}
			return true;
		}
		else {
			return false;
		}
	}

	function buyShares(uint _proposalIndex, uint _numShares) payable returns (bool) {

		require(msg.value == votes[_proposalIndex].salePriceWei * _numShares);
		require(votes[_proposalIndex].numNewShares - votes[_proposalIndex].sharesSold >= _numShares);

		var senderCheckpointIndex = shareholderCheckpoints[msg.sender].length - 1;

		ShareholderCheckpoint memory newCheckpoint; // this gets reused
		if(shareholderCheckpoints[msg.sender].length == 0){
			newCheckpoint = ShareholderCheckpoint({
				atTreasuryCheckpointIndex: treasuryCheckpoints.length - 1,
				shares: _numShares,
				paid: false,
				voting: false
			});

			shareholderCheckpoints[msg.sender].push(newCheckpoint);

		}
		else if(shareholderCheckpoints[msg.sender][senderCheckpointIndex].atTreasuryCheckpointIndex < treasuryCheckpoints.length - 1) {
			
			newCheckpoint = ShareholderCheckpoint({
				atTreasuryCheckpointIndex: treasuryCheckpoints.length - 1,
				shares: shareholderCheckpoints[msg.sender][senderCheckpointIndex].shares + _numShares,
				paid: false,
				voting: false
			});

			shareholderCheckpoints[msg.sender].push(newCheckpoint);
		}
		else {
			shareholderCheckpoints[msg.sender][senderCheckpointIndex].shares += _numShares;
		}
		
		votes[_proposalIndex].sharesSold += _numShares;
		treasuryCheckpoints[treasuryCheckpoints.length - 1].totalSharesOutstanding += _numShares;

		votes[_proposalIndex].walletForFundraising.transfer(msg.value);
		SharesIssued(_proposalIndex, _numShares, votes[_proposalIndex].proposedBy);
		return true;

	}

}
