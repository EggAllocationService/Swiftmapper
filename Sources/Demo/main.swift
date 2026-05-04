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

let signal: Signal<Float> = device.createSignal("Test float signal", .Out);

while true {
    device.poll()
}