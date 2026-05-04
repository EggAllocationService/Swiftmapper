import Swiftmapper
import Foundation

let device = MapperDevice("Swift Device");

while true {
    device.poll()
    if device.ready {
        break;
    }
}

print("Device is ready!")

let signal: MapperSignal<[Float]> = device.createSignal("Test float signal", .Out, length: 2);
let inSignal: MapperSignal<[Float]> = device.createSignal("Input float", .In, length: 2);

let start = Date.now;

while true {
    device.poll(andBlockFor: 10);

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