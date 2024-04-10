import XCTest
@testable import RestfulCall

final class RestfulCallTests: XCTestCase {
	func testExample() throws {
		// XCTest Documentation
		// https://developer.apple.com/documentation/xctest

		// Defining Test Cases and Test Methods
		// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
	}

	func testFetchIPfromGridcop() async throws {
		struct TimeListEntry: Decodable {
			let timeReceived: Int
			let timeVariation: Int
			let timeElapsed: Int
			let hostName: String
			let hostTime: Date
		}

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
