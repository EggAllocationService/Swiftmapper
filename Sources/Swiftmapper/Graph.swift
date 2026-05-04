import libmapper

public class MapperGraph {
    internal private(set) var handle: mpr_graph
    public init() {
        handle = mpr_graph_new(0);
    }

    deinit {
        mpr_graph_free(handle);
    }
}