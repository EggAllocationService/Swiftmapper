import libmapper 

public enum MapperSignalDirection: UInt32 {
    case In = 0x01
    case Out = 0x02
}


public class Signal<T: MappableType> {
    private var handle: mpr_sig;
    private var owned: Bool;

    public private(set) var length: Int;

    init(handle: mpr_sig, owned: Bool, length: Int) {
        self.handle = handle;
        self.owned = owned;
        self.length = length;
    }

    deinit {
        if self.owned {
            mpr_sig_free(handle)
        }
    }

    public func setValue(new_value: T) {
        var val = new_value;

        val.withUnsafeRawPointer {ptr in 
            mpr_sig_set_value(handle, 0, new_value.length(), T.asMapperType(), ptr)
        }
    }

    public func getValue() -> T? {
        let val = mpr_sig_get_value(handle, 0, UnsafeMutablePointer.init(bitPattern: 0));
        if val == nil {
            return nil;
        }
        return T.fromRawPointer(ptr: val!, length: length);
    }
}