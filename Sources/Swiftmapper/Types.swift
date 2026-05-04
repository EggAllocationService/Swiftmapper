import libmapper

public protocol MappableType {
    static func asMappableType() -> mpr_type

    func length() -> Int32

    mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()); 
}


extension Int32: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_INT32));
    }

    public func length() -> Int32 {
        return 1
    }

    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        body(&self);
    }
}

extension Float32: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_FLT));
    }
    
    public func length() -> Int32 {
        return 1
    }

    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        body(&self);
    }
}

extension Float64: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_DBL))
    }

    public func length() -> Int32 {
        return 1
    }

    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        body(&self);
    }
}

extension [Int32]: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_INT32));
    }

    public func length() -> Int32 {
        return Int32(self.count)
    }

    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        self.withUnsafeBytes {ptr in 
            body(ptr.baseAddress!);
        }
    }
}