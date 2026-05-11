# Creating Maps
Learn how to locate other devices and create maps with them

## Locating Other Signals

To create a map, you first need two signal references. Since most of the time you'll be mapping to signals that aren't in the same process, you'll have to search the graph for them.

To do this, we'll use a ``MapperGraph`` object. We'll also be creating a device, so we can save some memory by letting the device re-use the ``MapperGraph`` for network communication by passing it to ``MapperDevice/init(_:withGraph:)``

Note that it is very important to call ``MapperGraph/subscribe(to:onDevice:)``, as without subscribing to the types you want to query you'll only be able to see local devices and signals.

@Snippet(path: "maps", slice: "init")

> Devices created with a graph should not be polled directly, always poll the ``MapperGraph`` object instead.

Now that we have our device and signal, we can start looking for another signal on the shared graph. In this example, we're going to map the first scalar floating point signal named "expr".

First, since signals are owned by devices we need to search every device on the graph. We can use function ``MapperGraph/getDevices()`` to do this:

@Snippet(path: "maps", slice: "searchSetup")

Next, we need to loop through each device and its signals. We can skip some work by specifying we're only looking for outgoing signals in ``MapperDevice/getSignals(inDirection:)``

@Snippet(path: "maps", slice: "searchLoop")

> ``GenericSignal/getSignalType()`` will return the equivalent Swift primitive metatype for the signal type, but if the signal's length is greater than one it will return the metatype of
> an array of that primitive instead.
> 
> For example, if we were instead looking for a float vector signal with a length of three, the following code would be appropriate:
> ```swift
> // ...
> let length = sig.getProperty(withName: .Length, as: Int32.self)!;
> if type == [Float].self && length == 3 && name == "expr" {
>   // ...
> }
> ```

## Creating Maps

Now that we've found our signal, we can create a map using it!

The initializer ``MapperMap/init(from:to:)-(GenericSignal,_)`` lets you create a simple map with two endpoints. After initializing the object, you can set the expression via ``MapperObject/setProperty(withId:to:publish:)`` and publish the map using ``MapperObject/push()``. You can wait for ``MapperMap/ready`` to become true to indicate the map has become successfully established.

@Snippet(path: "maps", slice: "map")

### Map Ownership

Since maps are not "owned" by any single device, this presents challenges with the automatic resource management provided by Swiftmapper's wrappers. By default any map you create locally will
be marked as owned, and will be deleted once the Swift object is deinitialized. This may not be desirable in many cases, and so you may use the method ``MapperMap/forget()`` to release ownership of the map.

``MapperMap`` references obtained by querying the graph are unowned by default, but you can take ownership of them via ``MapperMap/take()`` if you would like their lifetime to be bound to the wrapper object. Once the wrapper's reference count reaches zero and Swift calls `deinit` the map will be removed from the graph.