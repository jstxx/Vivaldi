//
//  VivaldiAPIClientTests.swift
//  VivaldiAPIClient
//
//  Created by Justin SL on 8/16/25.
//

import XCTest
@testable import Vivaldi

final class VivaldiAPIClientTests: XCTestCase {
    
    var apiClient: VivaldiAPIClient!
    var mockSession: URLSession!
    let apiKey = "dummy_api_key"
    
    override func setUpWithError() throws {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        apiClient = VivaldiAPIClient(apiKey: apiKey, urlSession: mockSession)
    }
    
    override func tearDownWithError() throws {
        apiClient = nil
        mockSession = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testFetchWeather_Success() async throws {
        // Given
        let city = City(name: "Miami", countryCode: "US")
        let expectedResponseData = """
            {
                "coord": {"lon": 139.69, "lat": 35.69},
                "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
                "main": {"temp": 285.55, "feels_like": 284.99, "temp_min": 284.26, "temp_max": 286.37, "pressure": 1012, "humidity": 70},
                "wind": {"speed": 2.6, "deg": 280},
                "name": "Tokyo",
                "cod": 200
            }
            """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.queryContains(param: "q", value: "Miami,US"), true)
            XCTAssertEqual(request.url?.queryContains(param: "appid", value: self.apiKey), true)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, expectedResponseData, nil)
        }
        
        // When
        let weatherResponse = try await apiClient.fetchWeather(for: city)
        
        // Then
        XCTAssertEqual(weatherResponse.name, "Miami")
        XCTAssertEqual(weatherResponse.weatherConditions.first?.description, "clear sky")
        XCTAssertEqual(weatherResponse.atmosphericData.temperature, 285.55)
    }
    
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?, Error?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Request handler not set")
            return
        }
        
        do {
            let (response, data, error) = try handler(request)
            
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
