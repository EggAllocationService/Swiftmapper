# Getting Started With Devices

Create a device and a signal

## Overview

Devices are the top of libmappers object heirarchy, with the exception of Graphs. Devices manage Signals, which in turn manage Instances. Devices can also have custom properties that are replicated across the distributed graph, so you can store metadata to be used by your application. 

How you organize your devices and signals is up to you, but we recommend a Device map to a single entity - e.g. a game world or a gyroscope.

## Creating a device

First, you create a ``MapperDevice`` object. The device name may not contain spaces
@Snippet(path: "create-device", slice: "setup")

Next, we need to wait for the device to be ready. We can poll the device in a loop until it is ready, and ``MapperDevice/poll(andBlockFor:)`` allows you to configure an amount of time in milliseconds to sleep.
@Snippet(path: "create-device", slice: "poll")
At this point, the device is ready and we can use it for anything!

### A note on polling

Devices must be polled periodically to send and recieve signal values. If you have a main loop somewhere in your program, simply call ``MapperDevice/poll(andBlockFor:)`` instead of sleeping. You can also omit the block time parameter to have libmapper process all pending messages and immediately return

## Creating a signal

Signals are how you can expose interesting values or controls to the libmapper graph. In Swiftmapper, signals are strongly typed; you must specify the data type you want to transport when constructing it:
@Snippet(path: "create-device", slice: "signal")

> Supported types are `Int`, `Float`, and `Double`. If you want to create a vector signal, include the `withLength` parameter when calling `createSignal` and use an array type:
> ```swift
> let signal = device.createSignal(named: "Signal", inDirection: .Out, ofType: [Float].self, withLength: 2);
> ```

Now that we have a signal, we can start emitting data. ``MapperSignal/setValue(to:onInstance:)`` lets you update signal instance data - we'll be ignoring the `onInstance` parameter for now.
@Snippet(path: "create-device", slice: "signalSet")
