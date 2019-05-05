# XZKit/Networking

## 安装

```ruby
pod "XZKit/Networking"
```

## 特性

- 规范网络层架构。
    
    框架主要由APIManger、APIRequest、APIResponse三个协议组成，分别代表网络层的逻辑处理、接口请求、数据处理。通过协议来约定网络层对象所具有的特性，但是不并不限制使用何种实现方式。例如，可以用结构体来定义接口请求，也可以用枚举来定义。

- 支持多种并发策略。

    在具体的业务逻辑中，某些网络请求可能与其它网络请存在依赖或互斥关系，现在不再需要单独去处理这些逻辑，而是仅仅通过一个属性就可以控制了。

- 支持失败自动重试。

    满足某些网络请求需要自动重试的需求。

## 效果


## 也谈网络层架构

### 集约型还是离散型

搜索关键字，不少大神都分享了他们的网络层架构思想。不论网络层怎么设计，它们要么是离散型要么是集约型，或者是两者混合。在实际开发过程中，单独的离散型或单独的集约型，都能满足大部分需求，但是在某些时候，却让人很抓狂。根据个人开发经验，我更偏向于在整体使用离散型架构，而局部使用集约型架构。
例如在设计购物车时，将购物车相关的接口设计成集约型的，所有与购物车相关的操作，都通过一个统一的对象来处理。而购物车和用户中心，在接口上可能没有多少联系，因此就使用离散型的架构，将它们设计成两个独立的对象来负责。

### 数据怎么处理

网络请求数据处理一直是个问题，因为需要把数据解析成模型，而且，怎么解析、何时解析都需要认真设计。然而说个实话，从事iOS开发多年，还没有发现特别好的方法来处理这一块的逻辑。所以框架在数据处理这块，几乎没有做什么要求，开发者完全可以按照自己的思路去设计。
不过也有些基本的流程是可以规范的，比如基本格式验证。因此框架对于数据的处理，大致分为三个步骤。

#### 原始数据的处理

由于框架自身不负责网络请求，这些工作交给其他第三方框架去做就好，比如AFNetworking，所以第一个获取到数据的地方，就在网络请求回调的中。
如果你使用的是AFNetwoking，基本上这块你不需要做什么，AFN会根据数据类型自动解析原始数据。但是如果你使用的是其他的框架，那么对于原始数据的处理，你就可以在这里处理了。

#### 数据基本验证

一般情况下，为了数据安全和有效性，服务端设计人员对数据结构都有固定的格式，还有的会一些验证机制，而且这些是全局通用的规则。那么在生成请求结果的方法里，你就可以做一些这样的操作。

#### 数据模型

网络层到底应不应该将数据解析成模型，一直存在争议，而且也没有特别的优势来证明哪一种观点更符合设计。所以，框架没有要求把数据解析成模型，但是建议可以将一些基本的解析放这里，例如套了多层的字典，可以提前取出来。

## 示例

```swift
enum CartAPIRequest: APIRequest {
    case detail(timeInterval: TimeInterval)
    case add(id: String)
    case update(id: String, count: Int)
    case delete(id: String)
    
    var url: URL {
        switch self {
        case .detail: return URL.init(string: "https://api.host.com/cart/detail")!
        case .add:    return URL.init(string: "https://api.host.com/cart/add")!
        case .update: return URL.init(string: "https://api.host.com/cart/update")!
        case .delete: return URL.init(string: "https://api.host.com/cart/delete")!
        }
    }
    
    var method: APIMethod { ... }
    
    var data: Any? { ... }
}
```

也可以使用结构体来设计你的接口：

```swift
struct WeatherAPIRequest: APIRequest {

    let url: URL = URL.init(string: "https://api.seniverse.com/v3/weather/now.json")!
    
    var data: Any? {
        return [
            "key": "z3plmlbgvez2ab2w",
            "language": "zh-Hans",
            "unit": "c",
            "location": city
        ]
    }

    let city: String;

    init(city: String = "beijing") {
        self.city = city;
    }

}
```

解析请求结果。

```swift
struct WeatherAPIResponse: APIResponse {
    
    typealias Request = WeatherAPIRequest

    let date: String
    let weather: (id: String, text: String, temperature: String)
    let location: (id: String, name: String)

    init(request: WeatherAPIRequest, data: Any?) throws {
        guard let result = (data as? [[String : Any]])?.first else { throw APIError.unexpectedResponse }

        guard let date = result["last_update"] as? String else { throw APIError.unexpectedResponse }
        
        guard let weatherDict = result["now"] as? [String: Any] else { throw APIError.unexpectedResponse }
        guard let weatherID = weatherDict["code"] as? String else { throw APIError.unexpectedResponse }
        guard let weatherText = weatherDict["text"] as? String else { throw APIError.unexpectedResponse }
        guard let weatherTemperature = weatherDict["temperature"] as? String else { throw APIError.unexpectedResponse }
        
        guard let locationDict = result["location"] as? [String: Any] else { throw APIError.unexpectedResponse }
        guard let locationID = locationDict["id"] as? String else { throw APIError.unexpectedResponse }
        guard let locationName = locationDict["name"] as? String else { throw APIError.unexpectedResponse }
        
        self.date = date
        self.weather = (weatherID, weatherText, weatherTemperature)
        self.location = (locationID, locationName)
    }

}
```

定义代理协议。

```swift
protocol WeatherAPIManagerDelegate: NSObjectProtocol  {

    func apiManager(_ apiManager: WeatherAPIManager, request: WeatherAPIRequest, didFailWith error: Error);
    func apiManager(_ apiManager: WeatherAPIManager, request: WeatherAPIRequest, didFinishWith apiResponse: WeatherAPIResponse);

}
```

定义APIManger，关联已定义的接口和结果，并转发代理事件，具体请参考Demo。

```swift
class WeatherAPIManager: APIManager {

    typealias Request   = WeatherAPIRequest
    typealias Response  = WeatherAPIResponse

    weak var delegate: WeatherAPIManagerDelegate?

    ...
}
```

## 技巧

其实也算不上技巧，就是运用Swift语言的特性，为协议提供默认实现来处理一些公共的逻辑。例如框架本身不处理网络请求，但是在每个接口中重写一半网络请求的方法显然是愚蠢的。这个时候，使用协议的默认实现就好了，而且框架的协议提供的功能也是通过默认实现提供的。

```swift
import XZKit
import AFNetworking

extension APINetworking {
    
    public func dataTask(for apiRequest: APIRequest, progress: @escaping ProgressHandler, completion: @escaping CompletionHandler) throws -> URLSessionDataTask? {
        let manager = AFHTTPSessionManager.init()
        
        ....
        
        manager.completionQueue = DispatchQueue.global(qos: .background)
        
        switch apiRequest.method {
        case .GET: ...
        case .POST: ...
        default: ...
        }
        
        throw APIError.invalidRequest
    }
    
}
```


## 作者

mlibai, mlibai@163.com

## 授权

XZKit is available under the MIT license. See the LICENSE file for more info.
