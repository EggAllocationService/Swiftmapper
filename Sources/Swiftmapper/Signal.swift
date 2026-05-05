import libmapper 

public enum MapperSignalDirection: UInt32 {
    case In = 0x01
    case Out = 0x02
}

public class MapperSignal<T: MappableType>: MapperObject {
    private var handle: mpr_sig;
    private var owned: Bool;

    public private(set) var length: Int;
    public private(set) var instances: Int; 

    init(handle: mpr_sig, owned: Bool, length: Int, instances: Int) {
        self.handle = handle;
        self.owned = owned;
        self.length = length;
        self.instances = instances;
    }

    deinit {
        if self.owned {
            mpr_sig_free(handle)
        }
    }

    public func setValue(new_value: T, onInstance: UInt64 = 0) {
        var val = new_value;

        val.withUnsafeRawPointer {ptr in 
            mpr_sig_set_value(handle, onInstance, new_value.length(), T.asMapperType(), ptr)
        }
    }

    public func getValue(fromInstance: UInt64 = 0) -> T? {
        let val = mpr_sig_get_value(handle, fromInstance, UnsafeMutablePointer.init(bitPattern: 0));
        if val == nil {
            return nil;
        }
        return T.fromRawPointer(ptr: val!, length: length);
    }

    public func getStatus(forInstance: UInt64 = 0) -> SignalStatus {
        let value: Int32 = mpr_sig_get_inst_status(handle, forInstance, 1)
        return SignalStatus(rawValue: UInt32(value))
    }

    public func getHandle() -> mpr_obj {
        return handle;
    }
}

public struct SignalStatus: OptionSet, Sendable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue;
    }

    public static let setRemote = SignalStatus(rawValue: MPR_STATUS_UPDATE_REM.rawValue)
    public static let setLocal = SignalStatus(rawValue: MPR_STATUS_UPDATE_LOC.rawValue)
    public static let hasValue = SignalStatus(rawValue: MPR_STATUS_HAS_VALUE.rawValue)
    public static let isActive = SignalStatus(rawValue: MPR_STATUS_ACTIVE.rawValue)
    public static let newValue = SignalStatus(rawValue: MPR_STATUS_NEW_VALUE.rawValue)
}