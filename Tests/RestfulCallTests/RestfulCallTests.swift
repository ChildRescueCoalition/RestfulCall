import XCTest
@testable import RestfulCall

struct EchoResponse: Decodable {
	let headers: [String: String]
	let method: String
	let `protocol`: String
	let path: String
	let body: String
	let hostname: String
	let ip: String
	let ips: [String]
	let xhr: Bool
	let fresh: Bool
}

final class RestfulCallTests: XCTestCase {
	func testFetchIPfromGridcop() async throws {
		do {
			let gridcopTest = RestfulCall(baseAddress: "https://test.gridcop.com", token: "fakeTOKEN")
			let result = try await gridcopTest.execute(.GET, endpoint: "/")
			let info = try JSONDecoder().decode(EchoResponse.self, from: result)

			XCTAssertEqual(info.method, "GET")
			print("My IP is \(info.ip)")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
