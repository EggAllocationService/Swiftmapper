import libmapper

public class MapperGraph: MapperObject {
    internal private(set) var handle: mpr_graph
    public init() {
        handle = mpr_graph_new(0);
    }

    deinit {
        mpr_graph_free(handle);
    }

    public func getHandle() -> mpr_obj {
        return handle;
    }

    public func poll(andBlockFor: Int = -1) {
        mpr_graph_poll(handle, Int32(andBlockFor));
    }

    /// Gets the network interface used by the graph
    public func getInterface() -> String {
        return String(cString: mpr_graph_get_interface(handle))
    }

    /// Sets the graph network interface to the given string
    /// Returns true if successful, false otherwise
    public func setInterface(to: String) -> Bool {
        to.withCString {
            mpr_graph_set_interface(handle, $0)
        } == 0
    }
}