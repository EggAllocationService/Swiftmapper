import libmapper

public class MapperDevice: MapperObject {
    private var handle: mpr_dev

    deinit {
        mpr_dev_free(handle);
    }

    public init(_ name: String, withGraph: MapperGraph? = nil) {    
        handle = name.withCString { ptr in
            return mpr_dev_new(ptr, withGraph?.handle);
        }
    }

    public func poll(andBlockFor: Int32? = nil) {
        mpr_dev_poll(handle, andBlockFor ?? -1);
    }

    public func createSignal<T: MappableType>(_ name: String, _ direction: MapperSignalDirection, length: Int = 1) -> MapperSignal<T> {
        let sig_handle: mpr_sig = name.withCString { ptr in
            return mpr_sig_new(self.handle, .init(direction.rawValue), ptr, Int32(length), T.asMapperType(), nil, nil, nil, nil, nil, 0)
        };

        return MapperSignal<T>(handle: sig_handle, owned: true, length: length);
    }

    public var ready: Bool {
        get {
            mpr_dev_get_is_ready(handle) != 0
        }
    }

    public func getHandle() -> mpr_obj {
        return handle;
    }
}