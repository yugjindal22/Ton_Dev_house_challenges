{/*
    Create a Simple DAO contract that allows user to vote yes or no
    The SimpleDao struct is the main storage of the contract.
    It contains:
    - queryId: uint32
    - yesVotes: uint32
    - noVotes: uint32
    - totalVotes: uint32

    The contract has 2 functionalities :
    - Record a vote
    - Reset the votes
    The contract has a yesVotes that is used to identify the yes votes.
    The contract has a noVotes that is used to identify the no votes.
    The contract has a totalVotes that is used to identify the total votes.

    There will be 2 structs :
    - RecordVote : This struct is used to record a vote.
    - ResetVotes : This struct is used to reset the votes.

    The struct definitions are :
    - RecordVote(queryId: uint32, vote: bool) : 0xF4A2B1C9
    - ResetVotes(queryId: uint32) : 0xD4E7B328

    There will be 1 getter function :
    - getVotes : This function is used to get the votes. (yesVotes, noVotes, totalVotes)

    Helpful Blueprint sdk commands:
    - npx blueprint build - To build the contract
    - npx blueprint test tests/SimpleDao.spec.ts - To test the contract
*/}

tolk 1.1

fun onInternalMessage(in: InMessage) {
}
