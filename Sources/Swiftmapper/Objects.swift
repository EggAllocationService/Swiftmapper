import libmapper


public enum MapperNamedProperty: Int32 {
    case Ephemeral = 0x0500
    case Muted = 0x1000
    case Max = 0x0E00
    case Min = 0x0F00
    case Length = 0x0B00
    case Name = 0x1100


}

public protocol MapperObject {
    func getHandle() -> mpr_obj;
}

extension MapperObject {
    public func getProperty<T: MapperType>(withId: MapperNamedProperty) -> T {
        var ptr: UnsafeRawPointer? = nil;
        var length: Int32 = 1;
        mpr_obj_get_prop_by_idx(getHandle(), withId.rawValue, nil, &length, nil, &ptr, nil);

        return T.fromRawPointer(ptr: ptr!, length: Int(length));
    }

    public func getProperty<T: MapperType>(withName: String) -> T {
        return withName.withCString { str in 
            var ptr: UnsafeRawPointer? = nil;
            var length: Int32 = 1;
            mpr_obj_get_prop_by_key(getHandle(), str, &length, nil, &ptr, nil);

            return T.fromRawPointer(ptr: ptr!, length: Int(length));
        }
    }

    public func setProperty<T: MappableType>(withId: MapperNamedProperty, to: T, publish: Bool = true) {
        var copy = to;
        copy.withUnsafeRawPointer { ptr in 
            mpr_obj_set_prop(getHandle(), .init(UInt32(withId.rawValue)), nil, to.length(), T.asMapperType(), ptr, publish ? 1 : 0)
        }
    }

    public func setProperty<T: MappableType>(withName: String, to: T, publish: Bool = true) {
        var copy = to;
        copy.withUnsafeRawPointer { ptr in 
            withName.withCString {str in 
                mpr_obj_set_prop(getHandle(), MPR_PROP_UNKNOWN, str, to.length(), T.asMapperType(), ptr, publish ? 1 : 0);
                return;
            }
        }
    }
}