中文版 | [English Vision](README-en.md)

## DYFStoreReceiptVerifier_Swift

一个开源的iOS收据验证程序([Objective-C Version](https://github.com/itenfay/DYFStoreReceiptVerifier))。

建议使用自己的服务器获取从客户端上传的参数，以验证来自App Store服务器的收据的响应信息（C -> 上传的参数 -> S -> App Store S -> S -> 接收并解析数据 -> C，C： 客户端，S：服务器）。

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods Version](http://img.shields.io/cocoapods/v/DYFStoreReceiptVerifier_Swift.svg?style=flat)](http://cocoapods.org/pods/DYFStoreReceiptVerifier_Swift)&nbsp;
![CocoaPods Platform](http://img.shields.io/cocoapods/p/DYFStoreReceiptVerifier_Swift.svg?style=flat)&nbsp;


## QQ群 (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/itenfay/DYFStoreReceiptVerifier_Swift/raw/master/images/g614799921.jpg" width="30%" />
</div>


## 安装

Using [CocoaPods](https://cocoapods.org):

```
pod 'DYFStoreReceiptVerifier_Swift'
```


## 使用

- 验证 URL 地址

1、测试地址 (Sandbox)：`https://sandbox.itunes.apple.com/verifyReceipt` <br>
2、生产地址 (Production)：`https://buy.itunes.apple.com/verifyReceipt`

- 引用验证器

通过使用延迟加载创建并返回收据验证器（`DYFStoreReceiptVerifier`）。

```
lazy var receiptVerifier: DYFStoreReceiptVerifier = {
    let verifier = DYFStoreReceiptVerifier()
    verifier.delegate = self
    return verifier
}()
```

- 验证器代理收据验证

1、遵守`DYFStoreReceiptVerifierDelegate`协议:

```
func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any])
func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError)
```

2、实现协议

```
public func verifyReceiptDidFinish(_ verifier: DYFStoreReceiptVerifier, didReceiveData data: [String : Any]) {
    // Writes the implementation codes.
}

public func verifyReceipt(_ verifier: DYFStoreReceiptVerifier, didFailWithError error: NSError) {
    // Writes the implementation codes.
}
```

- 验证收据

- 步骤1:

获取应用商店收据的数据。 

```
// receiptData: the data of the bundle’s App Store receipt. 
let receiptData = DYFStore.receiptURL()
let data = receiptData
```

- 步骤2:

验证应用内购买收据。

```
self.receiptVerifier.verifyReceipt(data)
```

验证用于包含自动续订套餐的收据，需要应用的共享密钥(十六进制字符串)。

```
//self.receiptVerifier.verifyReceipt(data, sharedSecret: "A43512564ACBEF687924646CAFEFBDCAEDF4155125657")
```

- 状态码和描述

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
public func matchMessage(withStatus status: Int) -> String {
    let (_, msg) = matchMessage(withStatus: status)
    return msg
}
```


## 要求

`DYFStoreReceiptVerifier_Swift`需要`iOS 8.0`或更高版本和ARC。


## 演示

如需了解更多，请查看[Demo](https://github.com/itenfay/DYFStore/blob/master/DYFStoreDemo/Sample/SKIAPManager.swift)。


## 欢迎反馈

如果您发现任何问题，请创建问题。我很乐意帮助你。
