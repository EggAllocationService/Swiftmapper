# Working with Properties

Manipulating and querying properties on libmapper objects

## Overview

All libmapper objects have a set of properties that can be queried and modified. Libmapper also supports adding your own custom properties which can optionally be replicated over the network, alowing metadata to be queried along with objects. For example, Webmapper uses the property `color.hue` to color the UI elements for a device.

## Supported Objects

Any class implementing the protocol ``MapperObject`` supports property access. This includes:

- ``MapperGraph``
- ``MapperDevice``
- ``GenericSignal``
  - ``MapperSignal``
  - ``UnknownSignal``
- ``MapperMap``

## Accessing Properties

The `getProperty` and `setProperty` methods allow you to get and set property values on objects. For each, there are two variants.

### Via ID

Built-in properties are accessed via a unique identifier rather than a string, for space efficency. To access or set things like a device name or a signal's min/max, use 
``MapperObject/getProperty(withId:as:)`` and ``MapperObject/setProperty(withId:to:publish:)``

@Snippet(path: "properties", slice: "device")

Some built-in properties can provide useful metadata for session managers or other devices. For example, we can use the property `Max` to indicate what we expect the maximum value for a signal to be.

@Snippet(path: "properties", slice: "setSignal")

### Via Name

The built in properties provide a standard framework for simple metadata that you'll likely find useful - but sometimes you need more flexibility. 
Libmapper supports adding your own custom properties to any object, with any type. To work with these custom properties, you'll 
use the functions ``MapperObject/getProperty(withName:as:)`` and ``MapperObject/setProperty(withName:to:publish:)``

For example, Webmapper looks for a custom property `color.hue` to determine how to color the UI elements for a device. 
You can set that yourself to match some real-world equivalent - for example the physical color of your device or an indicator light on it.

@Snippet(path: "properties", slice: "setDevice")

You can even use arrays in these properties - for example to store the real-world position of a device obtained via some local positioning system

```swift
device.setProperty(withName: "position", to: [10.5, 11, 0.03]);
```

## Replication

By default, all property values (custom or otherwise) are replicated across the network to other libmapper peers. But sometimes you may not want this behaviour, like if you're storing a pointer value or other local identifier. You can set `publish` to false to prevent property changes from being broadcast:
```swift
let myObjects = [device];
device.setProperty(withName: "objectIndex", to: 0, publish: false);
```