tolk 1.1

struct Storage {
    queryId: uint32
    yesVotes: uint32
    noVotes: uint32
    totalVotes: uint32
}

fun Storage.load() {
    return Storage.fromCell(contract.getData());
}

fun Storage.save(self) {
    contract.setData(self.toCell());
}

struct (0xF4A2B1C9) RecordVote {
    queryId: uint32
    vote: bool
}

struct (0xD4E7B328) ResetVotes {
    queryId: uint32
}

type AllowedMessage = RecordVote | ResetVotes

fun onInternalMessage(in: InMessage) {
    val msg = lazy AllowedMessage.fromSlice(in.body);

    match (msg) {
        RecordVote => {
            var storage = lazy Storage.load();

            storage.queryId = msg.queryId;
            storage.totalVotes += 1;

            if (msg.vote) {
                storage.yesVotes += 1;
            } else {
                storage.noVotes += 1;
            }

            storage.save();
        }

        ResetVotes => {
            var storage = lazy Storage.load();

            storage.queryId = msg.queryId;
            storage.yesVotes = 0;
            storage.noVotes = 0;
            storage.totalVotes = 0;
            storage.save();
        }

        else => {
            assert (in.body.isEmpty()) throw 0xFFFF;
        }
    }
}

fun onBouncedMessage(in: InMessageBounced) {}

get fun getVotes(): (int, int, int) {
    val storage = lazy Storage.load();
    return (storage.yesVotes, storage.noVotes, storage.totalVotes);
}
