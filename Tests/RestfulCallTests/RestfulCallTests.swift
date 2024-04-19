import XCTest
@testable import RestfulCall

struct HTTPBinResponse: Decodable {
	// let args: [:]
	let headers: [String: String]
	let origin: String
	let url: String
}

final class RestfulCallTests: XCTestCase {
	func testHTTPBinGet() async throws {
		let httpBin = RestfulCall(baseAddress: "https://httpbin.org", token: "fakeTOKEN")
		let result = try await httpBin.execute(.GET, endpoint: "/get")
		let response = try JSONDecoder().decode(HTTPBinResponse.self, from: result)

		XCTAssertEqual(response.url, "https://httpbin.org/get")
		XCTAssertTrue(response.headers.count > 0)
		XCTAssertEqual(response.headers["Host"], "httpbin.org")
	}

	func testIncompatibleMIME() async throws {
		let httpBin = RestfulCall(baseAddress: "https://httpbin.org", token: "fakeTOKEN")
		do {
			_ = try await httpBin.execute(.GET, endpoint: "/get", expecting: "text/html")
		}
		catch let callError as RestfulCall.CallError {
			switch callError {
			case let .invalidMIMEType(mime):
				XCTAssertEqual("application/json", mime)
			default:
				XCTFail("Wrong exception thrown")
			}
		}
	}

	func testWithoutMIME() async throws {
		let httpBin = RestfulCall(baseAddress: "https://httpbin.org", token: "fakeTOKEN")
		do {
			_ = try await httpBin.execute(.GET, endpoint: "/get", expecting: nil)
		}
		catch let callError as RestfulCall.CallError {
			switch callError {
			case let .invalidMIMEType(mime):
				XCTAssertEqual("application/json", mime)
			default:
				XCTFail("Wrong exception thrown")
			}
		}
	}
}
