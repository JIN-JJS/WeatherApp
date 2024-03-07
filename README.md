# **1. WeatherKit이란?**
\- [WWDC2022](https://developer.apple.com/videos/play/wwdc2022/10003/)
\
\- [Apple Developer WeahterKit](https://developer.apple.com/kr/weatherkit/)
\
<img width="900" alt="img" src="https://github.com/JIN-JJS/WeatherApp/assets/114235515/bce3ea48-306c-4357-b9a2-e259fbec3480">
<img width="900" alt="img (1)" src="https://github.com/JIN-JJS/WeatherApp/assets/114235515/b267cea6-873c-4891-a5fe-8a8e5bd17629">
<br>
​
### **(1) WeatherKit의 장점**
\- 오픈 API를 사용하지 않아도 Apple 날씨 서비스에 의해 구동
​\
\- 앱에 시기적절하게 사용자 생활권의 날씨 정보를 제공하는 데 필요한 모든 데이터를 제공
​\
\- Swift의 현대적인 구문을 활용하는 Swift API가 포함
​\
\- Swift 동시 실행을 통해 코드 몇 줄로 날씨 데이터를 손쉽게 요청
​\
\- 사용자 정보를 침해하지 않고 위치정보는 일기 예보 제공 목적으로만 사용됨
<br>

### **(2) WeatherKit의 단점**
\- Apple 개발자 계정이 있어야 함
​\
\- 개발자 계정이더라도 매달 50만 API 호출 건수까지만 제공
​<br>
<br>
<br>

# **2. WeaherKit 세팅** 
### **(1) App ID 생성**
\- [인증서 페이지로 이동](https://developer.apple.com/account/resources/certificates/list)
​\
\- 현재 생성하는 Bundle ID는 프로젝트의 Bundle ID와 동일해야 합니다.
​\
![img (2)](https://github.com/JIN-JJS/WeatherApp/assets/114235515/798e128a-7ca3-4b68-95ec-58fdca59aae5)
<br>
​
### **(2) Key 생성**
<img width="900" alt="img (3)" src="https://github.com/JIN-JJS/WeatherApp/assets/114235515/9a7eba25-e290-46d6-bdbb-e644bbb4404e">
<br>

### **(3) Xcode 설정**
\- (1)에서 생성했던 Bundle ID는 프로젝트의 Bundle ID와 동일해야 합니다.
​\
\- Capability에서 WeatherKit을 추가합니다.
​\
<img width="900" alt="img (4)" src="https://github.com/JIN-JJS/WeatherApp/assets/114235515/20b88a9f-e696-4c44-9774-fbffe528bf65">
<br>
<br>
<br>

# **3\. 날씨 정보 가져오기**
### **(1) WeatherKitManager**
```
import WeatherKit
​
@MainActor class WeatherKitManager: ObservableObject {
    @Published var weather: Weather?
        
    func getWeather(latitude: Double, longitude: Double) {
            Task {
                do {
                    weather = try await Task.detached(priority: .userInitiated) {
                        return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))  
                    }.value
                } catch {
                  fatalError("\(error)")
                }
            }
        }
        
        var symbol: String {
            weather?.currentWeather.symbolName ?? "xmark"
        }
        
        var temp: String {
            let temp = weather?.currentWeather.temperature
            let convertedTemp = temp?.converted(to: .celsius).description
            return convertedTemp ?? "Loading Weather Data"
        }
    
}
```
​
\- **getWeather** : 위도/경도의 정보를 넘겨주어 날씨 정보를 가져오는 함수 
​\
\- **temp** : 섭씨 변환 후 return 값으로 삼항연산자를 이용한 온도 표기 혹은 "Loading Weather Data"를 띄워줌
​\
\
**참고한 코드 Warning 수정(현재 수정함)**
​\
\- **Warning** : 'async(priority:operation:)' is deprecated: \`async\` was replaced by \`Task.init\` and will be removed shortly.
​\
\- **Fix** : async -> Task
​<br>

### **(2) LocationManager**
```
import CoreLocation
​
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus?
    
    var latitude: Double {
        locationManager.location?.coordinate.latitude ?? 37.596970
    }
    
    var longitude: Double {
        locationManager.location?.coordinate.longitude ?? -127.036119
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            // location services available
            authorisationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            break
            
        case .restricted:
            authorisationStatus = .restricted
            break
            
        case .denied:
            authorisationStatus = .denied
            break
            
        case .notDetermined:
            authorisationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error.localizedDescription)")
    }
    
}
```
<br>​

### **(3) ContentView**
```
struct ContentView: View {
    @ObservedObject var weatherKitManager = WeatherKitManager()
    
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        
        if locationManager.authorisationStatus == .authorizedWhenInUse {
            // Create your view
            VStack {
                Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
            }
            .task {
                 weatherKitManager.getWeather(latitude: locationManager.latitude, longitude: locationManager.longitude)
            }
        } else {
            // Create your alternate view
            Text("Error loading location")
        }
        
    }
}
```
​
\- 삼항연산자(if/else)로 위치 정보 승인 화면과 거절한 화면을 나눔
\
\
**참고한 코드 Warning 수정(현재 수정함)**
​\
\- **Warning** : No 'async' operations occur within 'await' expression
​\
\- **Fix** : await weatherKitManager.getWeather(latitude: --.--, longitude: --.--)
​\
           -> weatherKitManager.getWeather(latitude: --.--, longitude: --.--)
​<br>
<br>
<br>

# **4\. 결과**
### **(1) 테스트 화면**
​
<img width="900" alt="img (5)" src="https://github.com/JIN-JJS/WeatherApp/assets/114235515/6756c23e-c725-4d47-a948-71c6c7207e6e">
​\
\- 가져온 날씨 정보는 날씨 기본앱의 날씨와 비교했는데 동일하게 잘 출력되고 있다.(값은 반올림)
​
### **(2) 참고 영상**
​\
https://github.com/JIN-JJS/WeatherApp
https://youtu.be/Awis63z1el0?si=e0d2c4zM9Z18eFa6
<br>
<br>
<br>
