import libmapper 

public protocol GenericSignal: MapperObject {
    /// Get the signal status flags
    /// 
    /// - Parameter forInstance: The instance to get flag information for, or nil for the default
    func getStatus(forInstance: UInt64?) -> SignalStatus
    
    /// Get the signal type
    /// 
    /// If the signal has a length greater than 1, it will return the type of an array of the primitive type
    func getSignalType() -> (any MappableType.Type)? 
}

public extension GenericSignal {
    func getSignalType() -> (any MappableType.Type)? {
        let mpr: mpr_type? = getProperty(withId: .MapperType);
        if mpr == nil {
            return nil;
        }
        let len: Int32 = getProperty(withId: .Length)!;
        let vector = len > 0;

        switch Int(mpr!) {
            case MPR_INT32: 
                return vector ? [Int32].self : Int32.self;
            case MPR_DBL: 
                return vector ? [Double].self : Double.self;
            case MPR_FLT: 
                return vector ? [Float].self : Float.self;
            default: 
                return nil;
        }
    }
}

public enum MapperSignalDirection: UInt32 {
    case In = 0x01
    case Out = 0x02
}


/// A strongly typed signal wrapper
public class MapperSignal<T: MappableType>: MapperObject, GenericSignal {
    internal private(set) var handle: mpr_sig;
    private var owned: Bool;

    /// Vector length
    public private(set) var length: Int;

    /// Number of instances
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

    /// Update the signal value
    ///
    /// - Parameters:
    ///   - to: the new value
    ///   - onInstance: the instance number to update, or 0 for the default instance
    public func setValue(to: T, onInstance: UInt64 = 0) {
        var val = to;

        val.withUnsafeRawPointer {ptr in 
            mpr_sig_set_value(handle, onInstance, to.length(), T.asMapperType(), ptr)
        }
    }

    /// Get the current value of the signal
    /// 
    /// 
    /// - Parameter fromInstance: The instance to get the value from, or 0 for the default instance
    /// - Returns: The current signal value, or nil if there is no value yet
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

    /// Binds this signal to a type
    /// 
    /// If you know for certain the type of the `UnknownSignal`, you can convert it to a `MapperSignal<T>` using this method
    /// - Returns: A strongly typed non-owning wrapper for the same signal handle
    public func bind<T>() -> MapperSignal<T> {
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

    /// The signal value was updated remotely since last status check
    public static let setRemote = SignalStatus(rawValue: MPR_STATUS_UPDATE_REM.rawValue)

    /// The signal value was updated locally since last status check
    public static let setLocal = SignalStatus(rawValue: MPR_STATUS_UPDATE_LOC.rawValue)

    /// The signal has had a value set at least once
    public static let hasValue = SignalStatus(rawValue: MPR_STATUS_HAS_VALUE.rawValue)

    /// The signal instance is active
    public static let isActive = SignalStatus(rawValue: MPR_STATUS_ACTIVE.rawValue)

    /// A new value has been set since last status check
    public static let newValue = SignalStatus(rawValue: MPR_STATUS_NEW_VALUE.rawValue)
}