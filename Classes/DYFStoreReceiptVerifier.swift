//
//  DYFStoreReceiptVerifier.swift
//
//  Created by Tenfay on 2016/11/28. (https://github.com/itenfay/DYFStoreReceiptVerifier_Swift)
//  Copyright © 2016 Tenfay. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

/// The class is used to verify in-app purchase receipts.
open class DYFStoreReceiptVerifier {
    
    /// Callbacks the result of the request that verifies the in-app purchase receipt.
    public weak var delegate: DYFStoreReceiptVerifierDelegate?
    
    /// The url for sandbox in the test environment.
    private let sandboxUrl = "https://sandbox.itunes.apple.com/verifyReceipt"
    /// The url for production in the production environment.
    private let productUrl = "https://buy.itunes.apple.com/verifyReceipt"
    
    /// The data for a POST request.
    private var requestData: Data?
    
    /// A configuration object that defines behavior and policies for a URL session.
    private var urlSessionConfig: URLSessionConfiguration?
    
    /// An object that coordinates a group of related network data transfer tasks.
    private var urlSession: URLSession?
    
    /// A URL session task that returns downloaded data directly to the app in memory.
    private var dataTask: URLSessionDataTask?
    
    /// Whether all outstanding tasks have been cancelled and the session has been invalidated.
    private var isSessionInvalid: Bool = false
    
    /// Instantiates an `DYFStoreReceiptVerifier` object.
    public init() {
        self.setup()
    }
    
    private func setup() {
        self.urlSessionConfig = URLSessionConfiguration.default
        self.urlSessionConfig!.allowsCellularAccess = true
        self.urlSessionConfig!.timeoutIntervalForRequest = 15.0
        self.urlSessionConfig!.requestCachePolicy = .reloadIgnoringCacheData
        self.urlSession = URLSession(configuration: urlSessionConfig!)
        self.isSessionInvalid = false
    }
    
    /// Cancels the task.
    public func cancel() {
        self.dataTask?.cancel()
    }
    
    /// Cancels all outstanding tasks and then invalidates the session.
    public func invalidateAndCancel() {
        self.urlSession?.invalidateAndCancel()
        self.isSessionInvalid = true
    }
    
    /// Verifies the in-app purchase receipt, but it is not recommended to use. It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C).
    /// If the receipts are verified by your own server, the client needs to upload these parameters, such as: "transaction identifier, bundle identifier, product identifier, user identifier, shared sceret(Subscription), receipt(Safe URL Base64), original transaction identifier(Optional), original transaction time(Optional) and the device information, etc.".
    ///
    /// - Parameter base64Receipt: A signed receipt that records all information about a successful payment transaction.
    public func verifyReceipt(_ base64Receipt: String?) {
        verifyReceipt(base64Receipt, sharedSecret: nil)
    }
    
    /// Verifies the in-app purchase receipt, but it is not recommended to use. It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C).
    /// If the receipts are verified by your own server, the client needs to upload these parameters, such as: "transaction identifier, bundle identifier, product identifier, user identifier, shared sceret(Subscription), receipt(Safe URL Base64), original transaction identifier(Optional), original transaction time(Optional) and the device information, etc.".
    ///
    /// - Parameters:
    ///   - base64Receipt: A signed receipt that records all information about a successful payment transaction.
    ///   - secretKey: Your app’s shared secret (a hexadecimal string). Only used for receipts that contain auto-renewable subscriptions.
    public func verifyReceipt(_ base64Receipt: String?, sharedSecret secretKey: String? = nil) {
        guard let receipt = base64Receipt else {
            let messae = "The base64 receipt is null."
            let error  = NSError(domain: "RVErrorDomain.receipt.verifying",
                                 code: -12,
                                 userInfo: [NSLocalizedDescriptionKey : messae])
            
            self.delegate?.verifyReceipt(self, didFailWithError: error)
            return
        }
        
        // Creates the JSON object that describes the request.
        var requestContents: [String: Any] = [String: Any]()
        requestContents["receipt-data"] = receipt
        if let key = secretKey {
            requestContents["password"] = key
        }
        
        do {
            self.requestData = try JSONSerialization.data(withJSONObject: requestContents)
            self.connect(withUrl: productUrl)
        } catch let error {
            self.delegate?.verifyReceipt(self, didFailWithError: error as NSError)
        }
    }
    
    // Make a connection to the iTunes Store on a background queue.
    private func connect(withUrl url: String) {
        let aURL: URL = URL(string: url)!
        
        // Creates a POST request with the receipt data.
        var request = URLRequest(url: aURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.httpBody = self.requestData
        
        if self.isSessionInvalid {
            self.setup()
        }
        
        self.dataTask = self.urlSession?.dataTask(with: request) { [weak self] (data, response, error) in
            self?.didReceiveData(data, response: response, error: error)
        }
        self.dataTask?.resume()
    }
    
    private func didReceiveData(_ data: Data?, response: URLResponse?, error: Error?) {
        if let err = error {
            let nsError = err as NSError
            DispatchQueue.main.async {
                self.delegate?.verifyReceipt(self, didFailWithError: nsError)
            }
        } else {
            self.processResult(data!)
        }
    }
    
    private func processResult(_ data: Data) {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: data)
            let dict = jsonObj as! Dictionary<String, Any>
            
            let status = dict["status"] as! Int
            if status == 0 {
                DispatchQueue.main.async {
                    self.delegate?.verifyReceiptDidFinish(self, didReceiveData: dict)
                }
            } else if status == 21007 { // sandbox
                self.connect(withUrl: sandboxUrl)
            } else {
                let (code, message) = matchMessage(withStatus: status)
                let nsError = NSError(domain: "RVErrorDomain.receipt.verifying",
                                      code: code,
                                      userInfo: [NSLocalizedDescriptionKey : message])
                
                DispatchQueue.main.async {
                    self.delegate?.verifyReceipt(self, didFailWithError: nsError)
                }
            }
        } catch let error {
            let nsError = error as NSError
            DispatchQueue.main.async {
                self.delegate?.verifyReceipt(self, didFailWithError: nsError)
            }
        }
    }
    
    /// Matches the message with the status code.
    ///
    /// - Parameter status: The status code of the request response. More, please see [Receipt Validation Programming Guide](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1)
    /// - Returns: A tuple that contains status code and the description of status code.
    public func matchMessage(withStatus status: Int) -> (Int, String) {
        var message: String = ""
        switch status {
        case 0:
            message = "The receipt as a whole is valid."
            break
        case 21000:
            message = "The App Store could not read the JSON object you provided."
            break
        case 21002:
            message = "The data in the receipt-data property was malformed or missing."
            break
        case 21003:
            message = "The receipt could not be authenticated."
            break
        case 21004:
            message = "The shared secret you provided does not match the shared secret on file for your account."
            break
        case 21005:
            message = "The receipt server is not currently available."
            break
        case 21006:
            message = "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions."
            break
        case 21007:
            message = "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."
            break
        case 21008:
            message = "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."
            break
        case 21010:
            message = "This receipt could not be authorized. Treat this the same as if a purchase was never made."
            break
        default: /* 21100-21199 */
            message = "Internal data access error."
            break
        }
        return (status, message)
    }
    
    /// Matches the message with the status code.
    ///
    /// - Parameter status: The status code of the request response. More, please see [Receipt Validation Programming Guide](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1)
    /// - Returns: A string that contains the description of status code.
    public func matchMessage(withStatus status: Int) -> String {
        let (_, msg) = matchMessage(withStatus: status)
        return msg
    }
    
}

/// The delegate is used to callback the result of verifying the in-app purchase receipt.
public protocol DYFStoreReceiptVerifierDelegate: AnyObject {
    
    /// Tells the delegate that an in-app purchase receipt verification has completed.
    ///
    /// - Parameters:
    ///   - verifier: A `DYFStoreReceiptVerifier` object.
    ///   - data: The data received from the server, is converted to a dictionary of key-value pairs.
    func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any])
    
    /// Tells the delegate that an in-app purchase receipt verification occurs an error.
    ///
    /// - Parameters:
    ///   - verifier: A `DYFStoreReceiptVerifier` object.
    ///   - error: The error that caused the receipt validation to fail.
    func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError)
    
}
