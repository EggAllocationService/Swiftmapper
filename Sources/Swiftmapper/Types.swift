import libmapper

public protocol MappableType {
    static func asMappableType() -> mpr_type

    func length() -> UInt32
}


extension Int32: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_INT32));
    }

    public func length() -> UInt32 {
        return 1
    }
}

extension Float32: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_FLT));
    }
    
    public func length() -> UInt32 {
        return 1
    }
}

extension Float64: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_DBL))
    }

    public func length() -> UInt32 {
        return 1
    }
}

extension [Int32]: MappableType {
    public static func asMappableType() -> mpr_type {
        return .init(UInt8(MPR_INT32));
    }

    public func length() -> UInt32 {
        return UInt32(self.count)
    }
}