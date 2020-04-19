import XCTest
import Foundation
import Alamofire

final class AlamofireLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let message = """
        ⚡️ Request Started: \(request)
        ⚡️ Body Data: \(body)
        """
        NSLog(message)
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, Error>) {
        NSLog("⚡️ Response Received: \(response.debugDescription)")
    }
}

class CoEpiNetworkingV4Tests: XCTestCase {
    
    let apiV4 = "https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    /*
     curl -X GET https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport
     ["WlhsS01GcFlUakJKYW05cFdXMDVhMlZUU2prPQ=="]
     */
    func testV4GetTcnReport() {
            
        let url: String = apiV4 + "/tcnreport"
           executeGet(url: url)
    }
    
    private func executeGet(url: String){
        let expect = expectation(description: "request complete")
        let session = Session(eventMonitors: [ AlamofireLogger() ])
        
        let _ = session.request(url).responseJSON { response in
            expect.fulfill()
            switch response.result {
            case .success(let JSON):
                print("\n\n Success value and JSON: \(JSON)")
                XCTAssertNotNil(JSON)

            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
                XCTFail()
            }
            
        }
        
        waitForExpectations(timeout: 5)

    }
    
    /**
     curl -X GET https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport?date=2020-04-19
     */
    func testV4GetTcnReportWithDate() {
        let url: String = apiV4 + "/tcnreport?date=2020-04-19"
        executeGet(url: url)
    }
    
    /**
     curl -X POST https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport -d "ZXlKMFpYTjBJam9pWW05a2VTSjk="
     */
    
    func testV4PostTcnReport() {
        let urlString: String = apiV4 + "/tcnreport"
        let expect = expectation(description: "POST request complete")
        let session = Session(eventMonitors: [ AlamofireLogger() ])
        let paramsString = "Test payload 1"
        let paramsStringEncoded = Data(paramsString.utf8).base64EncodedString()
        
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post

        urlRequest.httpBody = Data(paramsStringEncoded.utf8)
        
        do {
            let _ = session.request(urlRequest)
                .cURLDescription { description in
                print(description)
            }
            .response { response in
                switch response.result {
                case .success:
                    expect.fulfill()
                case .failure(let error):
                    print("\n\n Request failed with error: \(error)")
                    XCTFail()
                }
                
            }
        }
        
        waitForExpectations(timeout: 15)
    }

}
