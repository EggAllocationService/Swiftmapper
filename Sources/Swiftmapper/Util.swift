import libmapper

internal func readLibmapperList<T>(list: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, constuctor: (UnsafeMutableRawPointer) -> T) -> [T] {
    var cur = list;
    
    var result: [T] = [];
    while cur != nil {
        let item = constuctor(cur!.pointee!);
        result.append(item);

        cur = mpr_list_get_next(cur);
    }

    return result;
}
