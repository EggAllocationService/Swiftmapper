import Testing
@testable import Swiftmapper

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}


@Test func version() async throws {
    let response = getLibmapperVersion();

    assert(response != nil, "Response should not be nil")
    assert(response!.count > 3, "Length string is at least 5")

    print(response!)
}