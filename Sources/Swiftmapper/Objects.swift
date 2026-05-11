import libmapper

public enum MapperNamedProperty: Int32 {
    case Ephemeral = 0x0500
    case Muted = 0x1000
    case Max = 0x0E00
    case Min = 0x0F00
    case Unit = 0x2500
    case Length = 0x0B00
    case Name = 0x1100
    case Status = 0x2100
    case Id = 0x0800
    case Expression = 0x0600
    case NumInstances = 0x1200
    case MapperType = 0x2400
    case Direction = 0x0400
}

/// Common interface for Libmapper object wrappers
public protocol MapperObject {
    /// Get the raw libmapper handle
    /// 
    /// Useful in case you need to work with the api directly while still 
    func getHandle() -> mpr_obj;
}

extension MapperObject {
    /// Get the value of a libmapper object property
    /// - Parameter withId: An identifier for a specific named property
    /// - Parameter as: The type to access the property as
    /// - Returns: The value of the property, or nil if it does not exist or the type is mismatched
    public func getProperty<T: MapperType>(withId: MapperNamedProperty, as: T.Type) -> T? {
        var ptr: UnsafeRawPointer? = nil;
        var type: mpr_type = .init();
        var length: Int32 = 1;
        mpr_obj_get_prop_by_idx(getHandle(), withId.rawValue, nil, &length, &type, &ptr, nil);
        if ptr == nil {
            return nil;
        }
        if type != T.asMapperType() {
            return nil;
        }

        return T.fromRawPointer(ptr: ptr!, length: Int(length));
    }

    /// Get the value of a libmapper object property
    /// - Parameter withName: The string identifier of a custom property 
    /// - Parameter as: The type to access the property as
    /// - Returns: The value of the property, or nil if it does not exist or the type is mismatched
    public func getProperty<T: MapperType>(withName: String, as: T.Type) -> T? {
        return withName.withCString { str in 
            var ptr: UnsafeRawPointer? = nil;
            var length: Int32 = 1;
            mpr_obj_get_prop_by_key(getHandle(), str, &length, nil, &ptr, nil);
            if ptr == nil {
                return nil;
            }

            return T.fromRawPointer(ptr: ptr!, length: Int(length));
        }
    }

    /// Set the value of a libmapper object property
    /// - Parameters:
    ///   - withId: An identifier for a specific named property
    ///   - to: The new value
    ///   - publish: Whether this value should be replicated to other devices
    public func setProperty<T: MapperType>(withId: MapperNamedProperty, to: T, publish: Bool = true) {
        var copy = to;
        copy.withUnsafeRawPointer { ptr in 
            mpr_obj_set_prop(getHandle(), .init(UInt32(withId.rawValue)), nil, to.length(), T.asMapperType(), ptr, publish ? 1 : 0)
        }
    }

    /// Set the value of a libmapper object property
    /// - Parameters:
    ///   - withName: The string identifier of a custom property 
    ///   - to: The new value
    ///   - publish: Whether this value should be replicated to other devices
    public func setProperty<T: MapperType>(withName: String, to: T, publish: Bool = true) {
        var copy = to;
        copy.withUnsafeRawPointer { ptr in 
            withName.withCString {str in 
                mpr_obj_set_prop(getHandle(), MPR_PROP_UNKNOWN, str, to.length(), T.asMapperType(), ptr, publish ? 1 : 0);
                return;
            }
        }
    }

    /// Push this object and its properties to the distributed graph
    public func push() {
        mpr_obj_push(getHandle());
    }
}