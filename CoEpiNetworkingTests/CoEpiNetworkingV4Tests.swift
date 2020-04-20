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
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        NSLog("⚡️ Response Received (unserialized): \(response.debugDescription)")
    }
    
    func requestDidFinish(_ request: Request){
        NSLog("⚡️ Request did finish: \(request.response.debugDescription)")
    }
}

class CoEpiNetworkingV4Tests: XCTestCase {
    
    let apiV4 = "https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4"

    
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
        
        //Fix for error message: "CredStore - performQuery - Error copying matching creds.  Error=-25300" See: https://stackoverflow.com/a/54100650
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil

        let session = Session(configuration: configuration,  eventMonitors: [ AlamofireLogger()])
        let _ = session.request(url)
            .cURLDescription { description in
                print(description)
            }
            .responseJSON { response in
             let statusCode = response.response?.statusCode
            NSLog("⚡️ statusCode : [\(statusCode!)]")
            expect.fulfill()
            switch response.result {
            case .success(let JSON):
                print("\n Success value and JSON: \(JSON)")
                XCTAssertNotNil(JSON)

            case .failure(let error):
                print("\n Request failed with error: \(error)")
                XCTFail()
            }
            
        }
        
        waitForExpectations(timeout: 10)

    }
    
    /**
     curl -X GET https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport?date=2020-04-19
     */
    func testV4GetTcnReportWithDate() {
        
        let dateString = "2020-04-19"
        guard let date = getDateForString(dateString) else
        {
                XCTFail("Date conversion failed for [\(dateString)]")
                return
        }
        
        getTcnForDate(date)
    }
    
    private func getTcnForDate(_ date: Date){
        let intervalLengthMillis : Int64 = 6 * 3600 * 1000
        let millis = Int64(date.timeIntervalSince1970 * 1000)
        let intervalNumber = millis / intervalLengthMillis
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd HH:mm:ss ZZZ"
        dateformater.timeZone = TimeZone(abbreviation: "UTC")
        let formatedDate = dateformater.string(from: date)
        
        print("intervalLengthMillis : [\(intervalLengthMillis)]")
        print("millis : [\(millis)]")
        print("intervalNumber : [\(intervalNumber)]")
        print("formatedDate : [\(formatedDate)]")
        
        //Single date has 4 6h long intervals:
        for var i : Int64 in 0...3 {
            let url: String = apiV4 + "/tcnreport?date=\(formatedDate)&intervalNumber=\(intervalNumber+i)&intervalLengthMs=\(intervalLengthMillis)"
            print("url : [\(url)]")
            executeGet(url: url)
            
        }

    }
    
    /**
     GET /tcnreport?date={report_date}?intervalNumber={interval}?intervalLengthMs={interval_length_ms}
     */
    
    /**
     formatedDate : [2020-04-20 01:28:04 +0200]
     formatedUtcDate : [2020-04-19 23:28:04 +0000]
     */
    func testV4GetTcnReportWithIntervalNumber() {
        let currentDate = Date()
        let intervalLengthMillis : Int64 = 6 * 3600 * 1000
        let currentMillis = Int64(currentDate.timeIntervalSince1970 * 1000)
        let intervalNumber = currentMillis / intervalLengthMillis
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd HH:mm:ss ZZZ"
        dateformater.timeZone = TimeZone(abbreviation: "UTC")
        let formatedDate = dateformater.string(from: currentDate)
        let url: String = apiV4 + "/tcnreport?date=\(formatedDate)&intervalNumber=\(intervalNumber)&intervalLengthMs=\(intervalLengthMillis)"
        
        print("intervalLengthMillis : [\(intervalLengthMillis)]")
        print("currentMillis : [\(currentMillis)]")
        print("intervalNumber : [\(intervalNumber)]")
        print("formatedDate : [\(formatedDate)]")
        print("url : [\(url)]")

        executeGet(url: url)
    }
    
    private func getDateForString(_ dateString: String) -> Date?{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        dateformater.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateformater.date(from: dateString)!
        return date
    }
    
    
    /**
     curl -X POST https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport -d "ZXlKMFpYTjBJam9pWW05a2VTSjk="
     */
    
    func testV4PostTcnReport() {
        let urlString: String = apiV4 + "/tcnreport"
        let expect = expectation(description: "POST request complete")
        let session = Session(eventMonitors: [ AlamofireLogger() ])
        let paramsString = "Test payload \(Date().timeIntervalSince1970)"
        let paramsStringEncoded = Data(paramsString.utf8).base64EncodedString()
        //https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#urlrequestconvertible
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
