import libmapper

public class MapperMap: MapperObject {
    private var handle: mpr_map
    private var owned: Bool

    /// Create a map from a signal to another one
    public init(from: GenericSignal, to: GenericSignal) {
        var fromHandle: mpr_sig? = from.getHandle();
        var toHandle: mpr_sig? = to.getHandle();
        handle = mpr_map_new(1, &fromHandle, 1, &toHandle);
        mpr_obj_push(self.handle)

        owned = true;
    }

    /// Create a many-to-one map
    public init(from: [GenericSignal], to: GenericSignal) {
        let fromHandles: [mpr_sig?] = from.map {$0.getHandle()}
        var toHandle: mpr_sig? = to.getHandle();
        handle = fromHandles.withUnsafeBufferPointer {fromPtr in 
            mpr_map_new(Int32(from.count), UnsafeMutablePointer(mutating: fromPtr.baseAddress!), 1, &toHandle)
        }

        owned = true;
    }
    
    internal init(withHandle: mpr_map) {
        handle = withHandle;

        owned = false;
    }

    deinit {
        if self.owned {
            mpr_graph_free(handle);
        }
    }

    /// `true` if the map has been published
    public var ready: Bool {
        get {
            return mpr_map_get_is_ready(self.handle) != 0
        }
    }

    /// Marks this map as non-owned, so that when the Swift object is garbage-collected the underlying map will not be destroyed
    public func forget() {
        owned = false
    }

    /// Takes ownership of this map, so that when the Swift object is garbage-collected the underlying map will be destroyed
    public func take() {
        owned = true;
    }

    public func getHandle() -> mpr_obj {
        return handle;
    }

    /// Returns the list of source signals and the destination signal for this map
    public func getSignals() -> ([UnknownSignal], UnknownSignal) {
        let fromList = mpr_map_get_sigs(handle, MPR_LOC_SRC);
        let toList = mpr_map_get_sigs(handle, MPR_LOC_DST);

        return (
            readLibmapperList(list: fromList) {UnknownSignal(handle: $0)},
            UnknownSignal(handle: toList!.pointee!)
        )
    }
}
