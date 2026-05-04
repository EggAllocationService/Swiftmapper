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

let signal: Signal<[Float]> = device.createSignal("Test float signal", .Out, length: 2);
let inSignal: Signal<[Float]> = device.createSignal("Input float", .In, length: 2);

let start = Date.now;

while true {
    device.poll(block_for: 10);

    let diff = Float(Date.now.timeIntervalSince(start));
    
    signal.setValue(new_value: [sin(diff), cos(diff)]);

    let val = inSignal.getValue();

    if val != nil {
        print(val!);
    }
}