import libmapper

/// Wrapper for a libmapper Device object
public class MapperDevice: MapperObject {
    private var handle: mpr_dev

    /// Indicates if wrapper is the owner of the underlying handle
    /// If true, the device is disposed when the Swift object is garbage collected
    public private(set) var owned: Bool;

    deinit {
        if (owned) {
            mpr_dev_free(handle);
        }
    }

    /// Create a new device
    /// - Parameters:
    ///   - name: The display name of the device
    ///   - withGraph: Optionally, the `MapperGraph` to use
    public init(_ name: String, withGraph: MapperGraph? = nil) {    
        handle = name.withCString { ptr in
            return mpr_dev_new(ptr, withGraph?.handle);
        }

        owned = true;
    }

    internal init(handle: mpr_dev) {
        self.handle = handle;
        owned = false;
    }

    /// Poll the device 
    /// 
    /// Can optionally block for a specified amount of time. By default, it will process any pending events and return immediately.
    /// - Parameter andBlockFor: Time to block for, in milliseconds
    public func poll(andBlockFor: Int32? = nil) {
        mpr_dev_poll(handle, andBlockFor ?? -1);
    }

    /// Create a new signal on this device. This method will only work if the device is owned locally
    /// - Parameters:
    ///   - name: Name of the signals. Spaces are prohibited
    ///   - direction: Whether this signal is incoming or outgoing
    ///   - length: Specifies the vector length of the signal. If greater than one, use an array type for `T`
    ///   - withInstances: How many instances to allocate. Set to 0 if a non-instanced signal is desired.
    /// - Returns: The newly created signal
    public func createSignal<T: MappableType>(named: String, inDirection: MapperSignalDirection, ofType: T.Type, withLength: Int = 1, withInstances: Int = 0) -> MapperSignal<T> {
        let sig_handle: mpr_sig = named.withCString { ptr in
            var instances = Int32(withInstances)
            if instances == 0 {
                return mpr_sig_new(self.handle, .init(inDirection.rawValue), ptr, Int32(withLength), T.asMapperType(), nil, nil, nil, nil, nil, 0)
            } else {
                return mpr_sig_new(self.handle, .init(inDirection.rawValue), ptr, Int32(withLength), T.asMapperType(), nil, nil, nil, &instances, nil, 0)
            }
        };

        return MapperSignal<T>(handle: sig_handle, owned: true, length: withLength, instances: withInstances);
    }

    /// If this device is ready
    /// 
    /// This should be true before any methods are called
    public var ready: Bool {
        get {
            mpr_dev_get_is_ready(handle) != 0
        }
    }

    public func getHandle() -> mpr_obj {
        return handle;
    }

    /// Get a list of signals on this device
    /// 
    /// - Parameter inDirection: Allows filtering by signal direction, or nil for no filtering
    /// - Returns: Array of signal wrappers
    public func getSignals(inDirection: MapperSignalDirection? = nil) -> [UnknownSignal] {
        let list = mpr_dev_get_sigs(handle, .init(inDirection?.rawValue ?? MPR_DIR_ANY.rawValue))

        return readLibmapperList(list: list) {
            UnknownSignal(handle: $0)
        }
    }
}