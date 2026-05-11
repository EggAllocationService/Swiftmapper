//snippet.setup
import Swiftmapper

let device = MapperDevice("My_Device");

// snippet.poll
while !device.ready {
    device.poll(andBlockFor: 10)
}
print("Device is ready!")

// snippet.signal
let signal = device.createSignal(named: "Signal", inDirection: .Out, ofType: Float.self)

// snippet.signalSet
while true {
    signal.setValue(to: Float.random(in: -10...10))

    // Must poll device for things to happen!
    device.poll(andBlockFor: 50)
}