import Swiftmapper
import Foundation

let graph = MapperGraph()
graph.subscribe(to: [.devices, .maps, .signals])

let device = MapperDevice("Swift Device", withGraph: graph);

while true {
    graph.poll()
    if device.ready {
        break;
    }
}

print("Network interface: " + graph.getInterface())

print("Device is ready!")

graph.poll(andBlockFor: 100)

let devices = graph.getDevices();
print("\(devices.count) Devices: ")
var targetDevice: MapperDevice? = nil;
for dev in devices {
    let name: String = dev.getProperty(withId: .Name)!;
    print("\t" + name)
    if name == "mathr.1" {
        targetDevice = dev;
    }
}
let signals = targetDevice!.getSignals();
var targetSignal = signals.first!;

let signal: MapperSignal<[Float]> = device.createSignal("Test float signal", .Out, length: 2);
let inSignal: MapperSignal<Float> = device.createSignal("Input float", .In);
let map = MapperMap(from: targetSignal, to: inSignal);
while true {
    graph.poll(andBlockFor: 10)
    if map.ready {
        print("Map ready!")
        break;
    }
}

let start = Date.now;

while true {
    graph.poll(andBlockFor: 10);
    device.poll()

    let diff = Float(Date.now.timeIntervalSince(start));

    let hue = modf(Float64(diff * 180) / 360)
    device.setProperty(withName: "color.hue", to: hue.1)
    
    signal.setValue(new_value: [sin(diff), cos(diff)]);
    let status = inSignal.getStatus();
    if status.contains(.newValue) {
        let val = inSignal.getValue();
        print(val!);
    }
}
