## DYFStoreReceiptVerifier_Swift

An open source receipt verification program for iOS. 

It is recommended that use your own server to obtain the parameters uploaded from the client to verify the receipt from the App Store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C, C: client, S: server).

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;

[Chinese Instructions (中文说明)](README-zh.md)


## Group (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/chenxing640/DYFStoreReceiptVerifier_Swift/raw/master/images/g614799921.jpg" width="30%" />
</div>


## Installation

Using [CocoaPods](https://cocoapods.org):

```
use_frameworks!
target 'Your target name'

pod 'DYFStoreReceiptVerifier_Swift'
Or
pod 'DYFStoreReceiptVerifier_Swift', '~> 1.1.0'
```


## Usage

- URL for verification

1. Sandbox URL: `https://sandbox.itunes.apple.com/verifyReceipt` <br />
2. Production URL: `https://buy.itunes.apple.com/verifyReceipt`

- Reference verifier

You create and return a receipt verifier(`DYFStoreReceiptVerifier`) by using lazy loading.

```
lazy var receiptVerifier: DYFStoreReceiptVerifier = {
    let verifier = DYFStoreReceiptVerifier()
    verifier.delegate = self
    return verifier
}()
```

- The verifier delegates receipt verification

1. Using the `DYFStoreReceiptVerifierDelegate` protocol:

```
@objc func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any])

@objc func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError)
```

2. You provide your own implementation.

```
public func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any]) {
    // Writes the implementation codes.
}

public func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError) {
    // Writes the implementation codes.
}
````

- Verify the receipt

- Step1:

Fetches the data of the bundle’s App Store receipt. 

```
// receiptData: the data of the bundle’s App Store receipt. 
let receiptData = DYFStore.receiptURL()
let data = receiptData
```

- Step2:

Verifies the in-app purchase receipt.

```
self.receiptVerifier.verifyReceipt(data)
```

Your app’s shared secret (a hexadecimal string). Only used for receipts that contain auto-renewable subscriptions.

```
self.receiptVerifier.verifyReceipt(data, sharedSecret: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```

- The status code and description

```
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
@objc public func matchMessage(withStatus status: Int) -> String {
    let (_, msg) = matchMessage(withStatus: status)
    return msg
}
```


## Requirements

`DYFStoreReceiptVerifier_Swift` requires `iOS 8.0` or above and `ARC`.


## Demo

To learn more, please check out [Demo](https://github.com/chenxing640/DYFStore/blob/master/DYFStoreDemo/DYFStoreManager.swift).


## Feedback is welcome

If you notice any issue, got stuck to create an issue. I will be happy to help you.
