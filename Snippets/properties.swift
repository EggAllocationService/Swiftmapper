import Swiftmapper

// snippet.device
let device = MapperDevice("MyDevice");
// snippet.hide

while !device.ready {
    device.poll(andBlockFor:10)
}

//snippet.show
let name: String? = device.getProperty(withId: .Name); // = "MyDevice"
print("Name: " + name!)

// snippet.setDevice
device.setProperty(withName: "color.hue", to: 0.5);

// snippet.setSignal
let signal: MapperSignal<Float> = device.createSignal("MySignal", .Out);
signal.setProperty(withId: .Max, to: 10.5)