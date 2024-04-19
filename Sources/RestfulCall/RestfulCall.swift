//
//  RestfulCall.swift
//  Created by Roberto Machorro on 4/10/24.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class RestfulCall: NSObject {
	public enum RequestMethod: String {
		case GET
		case POST
		case PUT
		case DELETE
	}

	public enum CallError: Error {
		case invalidParameters
		case invalidResponse
		case invalidMIMEType(String)
		case invalidHTTPStatus(Int)
	}

	var baseAddress: String?
	var token: String?
	var session: URLSession?

	public init(baseAddress: String, ignoreSSL: Bool = false, token: String? = nil) {
		super.init()
		self.baseAddress = baseAddress
		self.token = token
		self.session = ignoreSSL ?
			URLSession(configuration: .default, delegate: self, delegateQueue: nil) :
			URLSession(configuration: .default)
	}

	public func execute(_ operation: RequestMethod = .GET, endpoint path: String, body: Data? = nil, expecting mime: String? = "application/json") async throws -> Data {
		var request = try makeRequest(endpoint: path)
		request.httpMethod = operation.rawValue
		if let body {
			request.httpBody = body
		}
		return try await sessionData(with: request, expecting: mime)
	}
}

extension RestfulCall {
	func makeRequest(endpoint path: String) throws -> URLRequest {
		guard let baseAddress, let url = URL(string: baseAddress + path) else {
			throw CallError.invalidParameters
		}

		var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		if let token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		return request
	}

	func sessionData(with request: URLRequest, expecting mimeType: String?) async throws -> Data {
		guard let session else {
			throw CallError.invalidParameters
		}

		let result = try await session.data(for: request)
		guard let response = result.1 as? HTTPURLResponse else {
			throw CallError.invalidResponse
		}
		guard (200...299).contains(response.statusCode) else {
			throw CallError.invalidHTTPStatus(response.statusCode)
		}
		guard response.mimeType == mimeType else {
			throw CallError.invalidMIMEType(response.mimeType ?? "")
		}

		return result.0
	}
}

extension RestfulCall: URLSessionDelegate {
	// swiftlint:disable:next line_length
	public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
			guard let serverTrust = challenge.protectionSpace.serverTrust else {
				return (.useCredential, nil)
			}
			return (.useCredential, URLCredential(trust: serverTrust))
		}
		return (.performDefaultHandling, nil)
	}
}
