import Swiftmapper

// snippet.init
let graph = MapperGraph();
graph.subscribe(to: [.devices, .signals])

let device = MapperDevice("MyDevice", withGraph: graph);
while !device.ready {
    graph.poll(andBlockFor: 10);
}

let signal = device.createSignal(named: "MySignal", inDirection: .In, ofType: Float.self);

// snippet.searchSetup
let devices = graph.getDevices();
var targetSignal: GenericSignal? = nil;

// snippet.searchLoop
for dev in devices {
    let devName = dev.getProperty(withId: .Name, as: String.self)!;
    print("Searching device " + devName)
    let signals = dev.getSignals(inDirection: .Out);

    for sig in signals {
        let type = sig.getSignalType();
        let name = sig.getProperty(withId: .Name, as: String.self)!;

        print("\tSearching signal: " + name + " with type " + type.debugDescription);

        if type == Double.self && name == "expr" {
            targetSignal = sig;
            break;
        }
    }

    if targetSignal != nil {
        break;
    }
}

// snippet.searchEnd
if targetSignal == nil {
    fatalError("Could not find a signal to map!");
}

// snippet.map
let map = MapperMap(from: targetSignal!, to: signal);
map.setProperty(withId: .Expression, to: "y=x+1");
map.push();

while !map.ready {
    graph.poll(andBlockFor: 10)
}
// map is now established
// snippet.end
while true {
    graph.poll(andBlockFor: 10);

    let flags = signal.getStatus();
    if flags.contains(.newValue) {
        print(signal.getValue()!);
    }
}