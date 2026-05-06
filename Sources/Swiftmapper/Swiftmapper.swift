// The Swift Programming Language
// https://docs.swift.org/swift-book
import libmapper

/// Get the loaded version of libmapper
/// 
/// - Returns: The current version of libmaapper, or nil if there was an error
public func getLibmapperVersion() -> String? {
    let vers = mpr_get_version();

    if vers == nil {
        return nil;
    }

   return String(cString: vers!);
}