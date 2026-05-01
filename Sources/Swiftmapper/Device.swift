import libmapper

public class MapperDevice {
    private var handle: mpr_dev

    public init(_ name: String) {    
        handle = name.withCString { ptr in
            return mpr_dev_new(ptr, nil)
        }
    }

    public func poll() {
        mpr_dev_poll(handle, 10)
    }

    public func createSignal(_ name: String) {
        name.withCString { ptr in
            mpr_sig_new(handle, MPR_DIR_OUT, ptr, 1, 0x69, nil, nil, nil, nil, nil, 0)
        }
    }

    public var ready: Bool {
        get {
            mpr_dev_get_is_ready(handle) != 0
        }
    }
}