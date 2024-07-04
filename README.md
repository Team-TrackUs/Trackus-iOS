# 🏃 트랙어스
> 러닝을 사랑하는 이들을 위한 지도 기반 모바일 앱으로. 사용자들은 다양한 지역에서 함께 러닝을 즐길 수 있으며, 개인의 성장과 목표 달성을 위해 러닝 데이터를 추적할 수 있습니다.

[📱 앱스토어 링크]() <br/>
<img src="https://github.com/Team-TrackUs/Trackus-iOS/assets/101062450/5b3b591b-b647-4b9e-afb6-887c3f135cf6" width = 19%/>
<img src="https://github.com/Team-TrackUs/Trackus-iOS/assets/101062450/8baac104-ee2d-4249-96db-d66a07ca5b9c" width = 19%/>
<img src="https://github.com/Team-TrackUs/Trackus-iOS/assets/101062450/53d4fdf0-79bb-4662-b2b6-490002f2e191" width = 19%/>
<img src="https://github.com/Team-TrackUs/Trackus-iOS/assets/101062450/cb2ac504-ec62-4150-b5df-6d9ffcb0ef70" width = 19%/>
<img src="https://github.com/Team-TrackUs/Trackus-iOS/assets/101062450/c14e964d-2070-4a8d-a100-f58602e015a2" width = 19%/>

## Development Stack & Tools

- 📚 Framework & Library

도구 | 사용 목적 | Keyowrd
:---------:|:----------:|:---------:
 UIKit | build UI | UI
 firebase-ios-sdk | Database | Data
 KakaoOpenSDK | SocialLogin | Authentication
 CoreMotion | Live Tracking | Live Tracking
 ActivityKit | build widget | widget

Architecture
- Cocoa MVC

## Trouble Shooting
<details>
  <summary><h3>인피니티 스크롤 구현 중 생긴 고민 거리와 문제점 - 선구</h3></summary>
  문제상황
인피니티 스크롤 구현 중 생긴 고민 거리와 문제점, 해결

해결방법
DB에서 데이터를 전체 가져오는것이 아닌 부분부분 쪼개서 가져오도록 해야 했습니다.

func fetchPosts(startAfter: DocumentSnapshot?, limit: Int, completion: @escaping ([Post]?, DocumentSnapshot?, Error?) -> Void) {
        
        var query = Firestore.firestore().collection("posts").order(by: "createdAt", descending: true).limit(to: limit)
        
        if let startAfter = startAfter {
            query = query.start(afterDocument: startAfter)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch post = \(error.localizedDescription)")
                completion(nil,nil,error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([], nil, nil)
                return
            }

그래서 데이터를 가져올 때 limit(한번에 가져올 데이터의 개수), startAfter(마지막으로 가져온 데이터)를 뷰 컨트롤러에서 정하고
호출시 뷰가 로드될 때 처음부터 10개의 데이터를 가져오게 startAfter을 nil로 하여 데이터를 가져오면서 lastDocumentSnapshot을 저장하도록 하였습니다.

그 다음부터는 lastDocumentSnapshot부터 데이터를 가져오게 하여 테이블의 스크롤이 마지막 Cell을 볼 때, fetchPosts를 호출하도록 하였습니다.

구현한뒤에 다른 문제점들이 생겼는데
스크롤이 마지막 셀을 볼 때마다 데이터를 계속 불러오는 문제
이미 불러온(테이블에 올라간) 데이터가 delete 되었을 경우
두 가지의 문제가 발생하였습니다.

스크롤이 마지막 셀을 볼 때마다 데이터를 계속 불러오는 문제는
뷰컨트롤러에 fetchPosts()와 fetchMorePosts() 함수를 따로 만들어 fetchPosts는 새로고침하거나 Refresh를 할 때만 호출하고 fetchMorePosts는 스크롤이 마지막Cell을 볼 때만 호출하게 하였습니다. fetchMorePosts는 페이지가 완료되었는지 확인하는 변수와 데이터를 가져올지 안가져올지 확인하는 변수를 만들어 파이어스토어에서 더 이상 불러올 데이터가 없는 경우에 fetch가 되지 않도록 하였습니다.

이미 불러온(테이블에 올라간) 데이터가 delete 되었을 경우의 문제는
무한 스크롤을 하는 경우에는 새로운 데이터만 가져오게 하고, 새로고침을 하거나 Refresh를 하는 경우에는 현재 테이블에 있는 데이터 중 삭제된 데이터를 제외하고 새로 생긴 데이터를 불러오도록 하였습니다
</details>

## Coding Convention
### Git Convention

Branch Naming <br/>
- 추가: feature 
- 버그수정: fix 
- 리팩터링: refactor 
- 긴급수정: hotfix
- 배포: release


`[prefix]/description` <br/>
 

Commit Message
| Title     | Description  |
|----------|---|
| Feat     | 새로운 기능추가  |
| Fix      |  버그수정 |
| Refactor | 코드 리팩터링  |
| Style    |  코드스타일 변경 |
| Build    |  빌드 관련 파일 수정 |
| Docs     | 문서(문서 추가, 수정, 삭제)  |
| Test     |  테스트(테스트 코드 추가, 수정, 삭제: 비즈니스 로직에 변경 없는 경우) |
| Chore    |  기타 변경사항(빌드 스크립트 수정 등) |

`[Feat] message #issue-number`

### Code Convention Rule
- 파일, 클래스에서  약어 사용 가능
  - ViewController -> VC
  - ViewModel -> VM
- 기본 명명규칙은 Swift Style Guide, API Design Guidelines , Swift Style Guide를 참고한다.
- 함수, 메서드, 변수, 상수의 경우 **lowerCamelCase** 사용
- 클래스, extension은 **UpserCamelCase**

## Q&A
If you would like to contact us please enter the URL
- https://forms.gle/drvCZV4kHdgZJonRA
