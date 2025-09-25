tolk 1.1

struct Storage {
    owner: address
    recipient: address
    amount: uint64
    isReleased: bool
    isRequested: bool
}

fun Storage.load() {
    return Storage.fromCell(contract.getData());
}

fun Storage.save(self) {
    contract.setData(self.toCell());
}

struct (0xE3D2C1B4) InitializeEscrow {
    queryId: uint32
    recipient: address
    amount: uint64
}

struct (0xF4E3D2C1) RequestFunds {
    queryId: uint32
}

struct (0xA1B2C3D4) ReleaseFunds {
    queryId: uint32
}

struct (0xB1C2D3E4) CancelEscrow {
    queryId: uint32
}

type AllowedMessage = RequestFunds | ReleaseFunds | CancelEscrow | InitializeEscrow

fun onInternalMessage(in: InMessage) {
    val msg = lazy AllowedMessage.fromSlice(in.body);

    match (msg) {
        InitializeEscrow => {
            var storage = lazy Storage.load();
            storage.owner = in.senderAddress;
            storage.recipient = msg.recipient;
            storage.amount = msg.amount;
            storage.isReleased = false;
            storage.isRequested = false;
            storage.save();
        }

        RequestFunds => {
            var storage = lazy Storage.load();
            assert (in.senderAddress == storage.recipient) throw 0x65;
            assert (!storage.isRequested) throw 0x66;
            storage.isRequested = true;
            storage.save();
        }

        ReleaseFunds => {
            var storage = lazy Storage.load();
            assert (storage.isRequested) throw 0x6C;
            assert (!storage.isReleased) throw 0x6D;
            storage.isReleased = true;
            storage.save();
            val res = createMessage({
                bounce: false,
                dest: storage.recipient,
                value: contract.getOriginalBalance() - 100000000,
            });
            res.send(SEND_MODE_CARRY_ALL_BALANCE);
        }

        CancelEscrow => {
            var storage = lazy Storage.load();
            assert (in.senderAddress == storage.owner) throw 0x6A;
            assert (!storage.isReleased) throw 0x6B;
            storage.isReleased = true;
            storage.save();
            val res = createMessage({
                bounce: false,
                dest: storage.owner,
                value: contract.getOriginalBalance() - 100000000,
            });
            res.send(SEND_MODE_CARRY_ALL_BALANCE);
        }

        else => {
            assert (in.body.isEmpty()) throw 0xFFFF;
        }
    }
}

fun onBouncedMessage(in: InMessageBounced) {}

get fun getEscrowDetails(): (address, address, int, int, int) {
    val storage = lazy Storage.load();
    return (
        storage.owner,
        storage.recipient,
        storage.amount as int,
        storage.isReleased as int,
        storage.isRequested as int
    );
}
