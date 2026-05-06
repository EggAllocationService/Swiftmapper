import libmapper 

public protocol GenericSignal: MapperObject {
    func getStatus(forInstance: UInt64?) -> SignalStatus
}

public enum MapperSignalDirection: UInt32 {
    case In = 0x01
    case Out = 0x02
}

public class MapperSignal<T: MappableType>: MapperObject, GenericSignal {
    internal private(set) var handle: mpr_sig;
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

    public func setValue(to: T, onInstance: UInt64 = 0) {
        var val = to;

        val.withUnsafeRawPointer {ptr in 
            mpr_sig_set_value(handle, onInstance, to.length(), T.asMapperType(), ptr)
        }
    }

    public func getValue(fromInstance: UInt64 = 0) -> T? {
        let val = mpr_sig_get_value(handle, fromInstance, UnsafeMutablePointer.init(bitPattern: 0));
        if val == nil {
            return nil;
        }
        return T.fromRawPointer(ptr: val!, length: length);
    }

    public func getStatus(forInstance: UInt64? = nil) -> SignalStatus {
        let value: Int32 = mpr_sig_get_inst_status(handle, forInstance ?? 0, 1)
        return SignalStatus(rawValue: UInt32(value))
    }

    public func getHandle() -> mpr_obj {
        return handle;
    }
}

/// Wraps signals returned from internal libmapper API calls
/// 
/// Since we don't know the type, or there could be signals of mixed types, we cannot return a list of generic instantiations
public class UnknownSignal : GenericSignal {
    private var handle: mpr_sig;

    internal init(handle: mpr_sig) {
        self.handle = handle;
    }

    public func getHandle() -> mpr_obj {
        return handle;
    }

    public func getStatus(forInstance: UInt64?) -> SignalStatus {
        let value: Int32 = mpr_sig_get_inst_status(handle, forInstance ?? 0, 1)
        return SignalStatus(rawValue: UInt32(value))
    }

    public func wrap<T>() -> MapperSignal<T> {
        let length: Int32 = getProperty(withId: .Length)!;
        let instances: Int32 = getProperty(withId: .NumInstances)!;
        return MapperSignal(handle: handle, owned: false, length: Int(length), instances: Int(instances));
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