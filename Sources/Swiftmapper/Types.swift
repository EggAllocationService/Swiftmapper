import libmapper

public protocol MapperType {
    static func asMapperType() -> mpr_type
    static func fromRawPointer(ptr: UnsafeRawPointer, length: Int) -> Self;
    mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()); 
    func length() -> Int32;
}

public protocol MappableType: MapperType {}

public extension MapperType {
    // Simple types can be read directly from the pointer. Must override for complex types like arrays
    static func fromRawPointer(ptr: UnsafeRawPointer, length: Int) -> Self {
        return ptr.load(as: Self.self);
    }

    func length() -> Int32 {
        return 1;
    }
}

// Blanket implementation for arrays of mappable types
extension Array: MappableType, MapperType where Element: MappableType & Copyable {
    public static func asMapperType() -> mpr_type {
        return Element.asMapperType();
    }

    public static func fromRawPointer(ptr: UnsafeRawPointer, length: Int) -> Array<Element> {
        let typedPtr: UnsafePointer<Element> = ptr.bindMemory(to: Element.self, capacity: MemoryLayout<Element>.size * length);
        let buf = UnsafeBufferPointer(start: typedPtr, count: length)
        return Array(buf);
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

extension Int32: MappableType {
    public static func asMapperType() -> mpr_type {
        return .init(UInt8(MPR_INT32));
    }

    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        body(&self);
    }
}

extension Float32: MappableType {
    public static func asMapperType() -> mpr_type {
        return .init(UInt8(MPR_FLT));
    }
    
    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        body(&self);
    }
}

extension Float64: MappableType {
    public static func asMapperType() -> mpr_type {
        return .init(UInt8(MPR_DBL))
    }

    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        body(&self);
    }
}

extension String: MapperType {
    public static func asMapperType() -> mpr_type {
        return .init(UInt8(MPR_STR));
    }

    public mutating func withUnsafeRawPointer(body: (UnsafeRawPointer) -> ()) {
        self.withCString { ptr in 
            body(ptr)
        }
    }

    public static func fromRawPointer(ptr: UnsafeRawPointer, length: Int) -> String {
        return String(cString: ptr.assumingMemoryBound(to: CChar.self))
    }
}