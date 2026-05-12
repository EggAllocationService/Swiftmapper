
internal class CallbackWrapper<T> {
    internal var ref: T;
    internal var callback: (any MapperObject) -> ();

    internal init(obj: T, cb: (any MapperObject) -> ()) {

    }
}