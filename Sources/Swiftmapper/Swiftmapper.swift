// The Swift Programming Language
// https://docs.swift.org/swift-book
import libmapper

public func getLibmapperVersion() -> String? {
    let vers = mpr_get_version();

    if vers == nil {
        return nil;
    }

   return String(cString: vers!);
}