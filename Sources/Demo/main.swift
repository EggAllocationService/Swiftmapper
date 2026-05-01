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

device.createSignal("TestSignal")

while true {
    device.poll()
}