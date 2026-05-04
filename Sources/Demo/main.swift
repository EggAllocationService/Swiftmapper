import Swiftmapper
import Foundation

let graph = MapperGraph()

let device = MapperDevice("Swift Device", withGraph: graph);

while true {
    graph.poll()
    if device.ready {
        break;
    }
}

print("Network interface: " + graph.getInterface())

print("Device is ready!")

let signal: MapperSignal<[Float]> = device.createSignal("Test float signal", .Out, length: 2);
let inSignal: MapperSignal<[Float]> = device.createSignal("Input float", .In, length: 2);

let start = Date.now;

while true {
    graph.poll(andBlockFor: 10);

    let diff = Float(Date.now.timeIntervalSince(start));

    let hue = modf(Float64(diff * 180) / 360)
    device.setProperty(withName: "color.hue", to: hue.1)
    
    signal.setValue(new_value: [sin(diff), cos(diff)]);
    let status = inSignal.getStatus();
    if status.contains(.setRemote) {
        let val = inSignal.getValue();
        print(val!);
    }
}