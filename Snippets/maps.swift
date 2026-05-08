import Swiftmapper

// snippet.init
let graph = MapperGraph();
let device = MapperDevice("MyDevice", withGraph: graph);
while !device.ready {
    graph.poll(andBlockFor: 10);
}

let signal: MapperSignal<Float> = device.createSignal("MySignal", .In);

// snippet.searchSetup
let devices = graph.getDevices();
var targetSignal: GenericSignal? = nil;

// snippet.searchLoop
for dev in devices {
    let signals = dev.getSignals(inDirection: .Out);

    for sig in signals {
        let type = sig.getSignalType();
        let name: String = sig.getProperty(withId: .Name)!;

        if type == Float.self && name == "expr" {
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