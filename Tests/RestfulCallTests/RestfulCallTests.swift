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
		let gridcopTest = RestfulCall(baseAddress: "https://test.gridcop.com", token: "fakeTOKEN")
		let result = try await gridcopTest.execute(.GET, endpoint: "/")
		let info = try JSONDecoder().decode(EchoResponse.self, from: result)

		XCTAssertEqual(info.method, "GET")
		XCTAssertTrue(info.ip.count > 0)
	}

	func testIncompatibleMIME() async throws {
		let gridcopTest = RestfulCall(baseAddress: "https://test.gridcop.com", token: "fakeTOKEN")
		do {
			_ = try await gridcopTest.execute(.GET, endpoint: "/", expecting: "text/html")
		}
		catch let callError as RestfulCall.CallError {
			switch callError {
			case let .invalidMIMEType(mime):
				print("MIME: \(mime)")
			default:
				XCTFail("Wrong exception thrown")
			}
		}
	}

	func testWithoutMIME() async throws {
		let gridcopTest = RestfulCall(baseAddress: "https://test.gridcop.com", token: "fakeTOKEN")
		do {
			_ = try await gridcopTest.execute(.GET, endpoint: "/", expecting: nil)
		}
		catch let callError as RestfulCall.CallError {
			switch callError {
			case let .invalidMIMEType(mime):
				print("MIME: \(mime)")
			default:
				XCTFail("Wrong exception thrown")
			}
		}
	}
}
