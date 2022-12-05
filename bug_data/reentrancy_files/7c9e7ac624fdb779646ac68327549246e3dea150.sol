pragma solidity ^0.4.2;
pragma solidity ^0.4.2;

/*
 * Rejector
 * Base contract for rejecting direct deposits.
 * Fallback function throws immediately.
 */
contract Rejector {
  function() { throw; }
}
pragma solidity ^0.4.2;
/*
 * Ownable
 * Base contract with an owner
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }
}
pragma solidity ^0.4.2;


/*
 * Killable
 * Base contract that can be killed by owner
 */
contract Killable is Ownable {
  function kill() {
    if (msg.sender == owner) suicide(owner);
  }
}

contract Conference is Rejector, Killable {
	string public name;
	uint256 public totalBalance;
	uint256 public deposit;
	uint public limitOfParticipants;
	uint public registered;
	uint public attended;
	bool public ended;
	uint public endedAt;
	uint public coolingPeriod;

	mapping (address => Participant) public participants;
	mapping (uint => address) public participantsIndex;
	bool paid;
	uint256 _payout;

	struct Participant {
		string participantName;
		address addr;
		bool attended;
		uint256 payout;
		bool paid;
	}

	event Register(string participantName, address addr, uint256 balance, uint256 value);
	event Attend(address addr, uint256 balance);
	event Payback(address addr, uint256 _payout, uint256 balance, bool paid);

	/* Modifiers */
	modifier sentDepositOrReturn {
		if (msg.value == deposit) {
			_;
		}else{
			if(msg.sender.send(msg.value)){/* not much you can do */}
		}
	}

	modifier onlyActive {
		if (ended == false) {
			_;
		}
	}

	modifier onlyActiveOrReturn {
		if (ended == false) {
			_;
		}else{
			if(msg.sender.send(msg.value)){/*not much you can do*/}
		}
	}

	modifier withinLimitOrReturn {
		if (registered < limitOfParticipants ) {
			_;
		}else{
			if(msg.sender.send(msg.value)){/* not much you can do */}
		}
	}

	modifier isEnded {
		if (ended){
			_;
		}
	}

	modifier onlyAfter(uint _time) {
		if (now > _time){
			_;
		}
	}

	modifier onlyPayable {
		Participant participant = participants[msg.sender];
		if (participant.payout > 0){
			_;
		}
	}

	modifier notPaid {
		Participant participant = participants[msg.sender];
		if (participant.paid == false){
			_;
		}
	}

	/* Public functions */

	function Conference(uint _coolingPeriod) {
		name = 'Edcon Post conference lunch';
		deposit = 1 ether;
		totalBalance = 0;
		registered = 0;
		attended = 0;
		limitOfParticipants = 10;
		ended = false;
		if (_coolingPeriod != 0) {
			coolingPeriod = _coolingPeriod;
		} else {
			coolingPeriod = 1 weeks;
		}
	}

	function register(string _participant) public sentDepositOrReturn withinLimitOrReturn onlyActiveOrReturn payable{
		Register(_participant, msg.sender, msg.sender.balance, msg.value);
		if (isRegistered(msg.sender)) throw;
		registered++;
		participantsIndex[registered] = msg.sender;
		participants[msg.sender] = Participant(_participant, msg.sender, false, 0, false);
		totalBalance = totalBalance + (deposit * 1);
	}

	function withdraw() public onlyPayable notPaid {
		Participant participant = participants[msg.sender];
		if (msg.sender.send(participant.payout)) {
			participant.paid = true;
			totalBalance -= participant.payout;
		}
	}

	/* Constants */
	function isRegistered(address _addr) constant returns (bool){
		return participants[_addr].addr != 0x0;
	}

	function isAttended(address _addr) constant returns (bool){
		return isRegistered(_addr) && participants[_addr].attended;
	}

	function isPaid(address _addr) constant returns (bool){
		return isRegistered(_addr) && participants[_addr].paid;
	}

	function payout() constant returns(uint256){
		if (attended == 0) return 0;
		return uint(totalBalance) / uint(attended);
	}

	/* Admin only functions */

	function payback() onlyOwner{
		for(uint i=1;i<=registered;i++){
			if(participants[participantsIndex[i]].attended){
				participants[participantsIndex[i]].payout = payout();
			}
		}
		ended = true;
		endedAt = now;
	}

	function cancel() onlyOwner onlyActive{
		for(uint i=1;i<=registered;i++){
			participants[participantsIndex[i]].payout = deposit;
		}
		ended = true;
		endedAt = now;
	}

	/* return the remaining of balance if there are any unclaimed after cooling period */
	function clear() public onlyOwner isEnded onlyAfter(endedAt + coolingPeriod) {
		if(owner.send(totalBalance)){
			totalBalance = 0;
		}
	}

	function setLimitOfParticipants(uint _limitOfParticipants) public onlyOwner{
		limitOfParticipants = _limitOfParticipants;
	}

	function attend(address[] _addresses) public onlyOwner{
		for(uint i=0;i<_addresses.length;i++){
			var _addr = _addresses[i];
			if (isRegistered(_addr) != true) throw;
			if (isAttended(_addr)) throw;
			Attend(_addr, msg.sender.balance);
			participants[_addr].attended = true;
			attended++;
		}
	}
}
