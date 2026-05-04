import libmapper 

public enum MapperSignalDirection: UInt32 {
    case In = 0x01
    case Out = 0x02
}


public class Signal<T: MappableType> {
    private var handle: mpr_sig;
    private var owned: Bool;

    init(handle: mpr_sig, owned: Bool) {
        self.handle = handle;
        self.owned = owned;
    }

    deinit {
        if self.owned {
            mpr_sig_free(handle)
        }
    }
}