# Swiftmapper

Swiftmapper provides an ideomatic swift wrapper for [libmapper](https://github.com/libmapper/libmapper). It also provides raw access to the libmapper C api, in case new or unwrapped functionality is needed.

## Examples

### Creating a device

```swift
let device = MapperDevice("Swift Device");

while true {
    device.poll(andBlockFor: 10);
    if device.ready {
        break;
    }
}

print("Device is ready!");
```

### Creating a scalar signal

```swift
let signal: MapperSignal<Int> = device.createSignal("My Signal", .Out);

signal.setValue(13);
```


### Creating a vector signal

```swift
let signal: MapperSignal<[Float]> = device.createSignal("My Signal", .Out, length: 3);
signal.setValue([1.2, 2.3, 3.4];)
```

### Setting object properties
```swift
let device = MapperDevice("Swift Device");

// set the name to something else
device.setProperty(withId: .Name, to: "Other Name");

// set a custom property
device.setProperty(withName: "color.hue", to: 0.35);

// set a signal's max value
let signal: MapperSignal<Float> = device.createSignal("My Signal", .Out);
signal.setProperty(withId: .Max, to: 100.0)
```

### Getting object properties
```swift
func getDeviceName(dev: MapperDevice) -> String {
    return dev.getProperty(withId: .Name) ?? "Unknown Name";
}

func isDeviceHueValid(dev: MapperDevice) -> Bool {
    let hue: Float? = dev.getProperty(withName: "color.hue");

    return hue != nil && hue! > 0.0 && hue! < 1.0;
}
```