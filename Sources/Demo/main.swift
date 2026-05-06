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

for i in 0..<10 {
    graph.poll(andBlockFor:10);
}

var maps = graph.getMaps();
print("\(maps.count) Maps:")
for map in maps {
    let (srcs, dst) = map.getSignals();

    let names: [String] = srcs.map {
        $0.getProperty(withId: .Name)!
    }
    let dstName: String = dst.getProperty(withId: .Name)!;

    print("\t \(names) -> \(dstName)");
    
    let expr: String? = map.getProperty(withId: .Expression);
    print("\t\tExpression: \(expr ?? "nil")")
}

let signal: MapperSignal<[Float]> = device.createSignal("Test_float_signal", .Out, length: 2);
let inSignal: MapperSignal<Float> = device.createSignal("Input_float", .In);

let start = Date.now;

while true {
    graph.poll(andBlockFor: 10);

    let diff = Float(Date.now.timeIntervalSince(start));

    //let hue = modf(Float64(diff * 180) / 360)
    //device.setProperty(withName: "color.hue", to: hue.1)
    //device.push();
    
    signal.setValue(new_value: [sin(diff), cos(diff)]);
    let status = inSignal.getStatus();
    if status.contains(.setRemote) {
        let val = inSignal.getValue();
        print(val!);
    }
}
