import Swiftmapper

// snippet.device
let device = MapperDevice("MyDevice");
// snippet.hide

while !device.ready {
    device.poll(andBlockFor:10)
}

//snippet.show
let name: String? = device.getProperty(withId: .Name, as: String.self); // = "MyDevice"
print("Name: " + name!)

// snippet.setDevice
device.setProperty(withName: "color.hue", to: 0.5);

// snippet.setSignal
let signal = device.createSignal(named: "MySignal", inDirection: .Out, ofType: Float.self);
signal.setProperty(withId: .Max, to: 10.5)