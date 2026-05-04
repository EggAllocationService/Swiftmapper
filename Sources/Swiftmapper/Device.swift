import libmapper

public class MapperDevice {
    private var handle: mpr_dev

    deinit {
        mpr_dev_free(handle);
    }

    public init(_ name: String) {    
        handle = name.withCString { ptr in
            return mpr_dev_new(ptr, nil);
        }
    }

    public func poll(block_for: Int32? = nil) {
        mpr_dev_poll(handle, block_for ?? -1);
    }

    public func createSignal<T: MappableType>(_ name: String, _ direction: MapperSignalDirection, length: Int = 1) -> Signal<T> {
        let sig_handle: mpr_sig = name.withCString { ptr in
            return mpr_sig_new(self.handle, .init(direction.rawValue), ptr, Int32(length), T.asMapperType(), nil, nil, nil, nil, nil, 0)
        };

        return Signal<T>(handle: sig_handle, owned: true, length: length);
    }

    public var ready: Bool {
        get {
            mpr_dev_get_is_ready(handle) != 0
        }
    }
}