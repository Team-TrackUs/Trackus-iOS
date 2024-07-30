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

## Trouble Shooting 🔥
<details>
  <summary><h3>인피니티 스크롤 구현 중 생긴 고민 거리와 문제점 - 선구</h3></summary>
🤔 문제 상황
 
인피니티 스크롤 구현 중 DB에서 전체 데이터를 가져온것이 아닌 데이터를 부분부분 쪼개서 가져오도록 해야 했습니다.

✨ 해결 방법

해결방법으로 데이터를 가져올 때 limit(한번에 가져올 데이터의 개수), startAfter(마지막으로 가져온 데이터)를 뷰 컨트롤러에서 정해준뒤
뷰가 로드될 때 처음부터 10개의 데이터를 가져오게 startAfter을 nil로 설정하여 데이터를 가져오면서 lastDocumentSnapshot을 저장하도록 하였습니다.

![스크린샷 2024-07-30 오전 10 46 29](https://github.com/user-attachments/assets/e479e18a-f883-4f13-9502-4dd74af3c868)

그다음부터는 lastDocumentSnapshot부터 데이터를 가져오게 하여 테이블의 스크롤이 마지막 Cell을 볼 때, fetchPosts를 호출하도록 하였습니다.

구현한뒤에 다른 문제점들이 발생했는데
- 스크롤이 마지막 셀을 볼 때마다 데이터를 계속 불러오는 문제
- 이미 불러온(테이블에 올라간) 데이터가 delete 되었을 경우

스크롤이 마지막 셀을 볼 때마다 데이터를 계속 불러오는 문제는
뷰컨트롤러에 fetchPosts()와 fetchMorePosts() 함수를 따로 만들어 fetchPosts는 새로고침하거나 Refresh를 할 때만 호출하고 fetchMorePosts는 스크롤이 마지막Cell을 볼 때만 호출하게 하였습니다. fetchMorePosts는 페이지가 완료되었는지 확인하는 변수와 데이터를 가져올지 안가져올지 확인하는 변수를 만들어 파이어스토어에서 더 이상 불러올 데이터가 없는 경우에 fetch가 되지 않도록 하였습니다.

이미 불러온(테이블에 올라간) 데이터가 delete 되었을 경우의 문제는
무한 스크롤을 하는 경우에는 새로운 데이터만 가져오게 하고, 새로고침을 하거나 Refresh를 하는 경우에는 현재 테이블에 있는 데이터 중 삭제된 데이터를 제외하고 새로 생긴 데이터를 불러오도록 처리하여 문제를 해결할 수 있었습니다.
</details>

<details>
  <summary><h3>UITableViewCell 상황별 재사용 시 레이아웃 충돌 문제 - 주원</h3></summary>
 
🤔 문제 상황 

UITableView에서 하나의 UITableViewCell을 상황에 따라 재사용 할 때, 기존 레이아웃과 충돌하여 셀을 새로 불러올 때마다 다른 레이아웃이 적용되는 문제가 발생.

해결 과정

1. 문제 분석
2. 셀을 재사용할 때, 이전에 설정된 오토레이아웃 제약 조건이 남아 있어 새로운 제약 조건과 충돌.
3. 조건에 맞는 UI 요소들을 조건문에 따라 숨기거나 보이게 할 때, 이전에 적용된 제약 조건이 여전히 활성화되어 있어 예상치 못한 레이아웃이 발생.
4. 기존 방식의 문제점으로 확인
5. 조건문에 따라 제약 조건을 추가하였으나, 조건에 해당하지 않는 경우에도 여전히 제약 조건이 적용되어 기종 제약 조건과 충돌.

✨ 해결 방법

1. 제약 조건 초기화
2. NSLayoutConstraint.deactivate(contentView.constraints)를 사용하여 셀이 재사용될 때 기존의 모든 제약 조건을 비활성화.
3. 제약 조건 재설정
4. 필요한 제약 조건을 조건에 맞게 다시 추가하고 활성화.
5. 관련 없는 UI 요소들은 isHidden = true로 처리하여, 불필요한 제약 조건이 적용되지 않도록 적용.

```swift
func configure(messageMap: MessageMap) {
    // 모든 제약 조건 비활성화
    NSLayoutConstraint.deactivate(contentView.constraints)

    // 새로운 제약 조건 배열 선언
    var constraints = [NSLayoutConstraint]()

    // 조건에 따른 UI 요소와 제약 조건 설정
    if messageMap.sameData {
        dateLabel.isHidden = true
    } else {
        dateLabel.isHidden = false
        constraints.append(contentsOf: [
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    // 기타 UI 요소와 제약 조건 설정
    constraints.append(contentsOf: [
        messageLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
        messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
    ])

    // 제약 조건 활성화
    NSLayoutConstraint.activate(constraints)
```

정리

- UITableViewCell 재사용 시 오토레이아웃 제약 조건 충돌로 인해 레이아웃이 예상대로 작동하지 않음. 
- 셀이 재사용될 때 이전 제약 조건이 제대로 초기화되지 않아 새로운 제약 조건과 충돌함.
- 셀이 재사용될 때 기존 제약 조건을 모두 비활성화하고, 조건에 맞는 제약 조건만 다시 추가하여 활성화함.
- 각 셀의 UI 요소와 제약 조건이 정확하게 적용되어 레이아웃이 정상 작동
</details>

<details>
  <summary><h3>Firestore에서 특정 날짜의 데이터를 UI에 반영 - 소희</h3></summary>
 🤔 문제 상황

 캘린더의 날짜에 맞는 데이터를 보여주는 기능을 구현하는 과정에서 여러 문제가 발생했습니다. 사용자가 특정 날짜를 선택하면 그 날짜에 맞는 러닝 기록과 게시물을 정확히 불러와서 보여줘야 했습니다. 하지만 Firestore 쿼리를 사용하여 특정 날짜의 데이터를 정확히 필터링하고, UI에 반영하는 과정이 쉽지 않았습니다.

 ✨ 해결 방법
1. 날짜 필터링 쿼리 작성: Firestore에서 특정 날짜의 데이터를 가져오기 위해 날짜 필터링 쿼리를 작성했습니다. 현재 날짜를 기준으로 시작 시간과 종료 시간을 계산하여 그 사이에 포함되는 데이터를 가져오도록 했습니다.

```swift
func fetchRecords() {
        let db = Firestore.firestore()
        let startTimeField = "startTime"
        
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("records")
            .whereField(startTimeField, isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField(startTimeField, isLessThan: Timestamp(date: endOfDay))
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.records = querySnapshot?.documents.compactMap { document in
                        do {
                            let record = try document.data(as: Running.self)
                            return record
                        } catch {
                            print("Error decoding record: \(error)")
                            return nil
                        }
                    } ?? []
                    
                    DispatchQueue.main.async {
                        self.recordsTableView.reloadData()
                    }
                }
            }
    }
```
2. UI 업데이트: 사용자가 날짜를 선택하면 currentDate를 업데이트하고, 그에 맞는 데이터를 다시 불러와서 테이블 뷰를 갱신했습니다.
```swift
private var currentDate: Date = Date() {
    didSet {
        updateDateButton()
        fetchPosts()
        fetchRecords()
    }
}

private func updateDateButton() {
    dateButton.setTitle("\(dateFormatter.string(from: currentDate))", for: .normal)
}
```

3. 캘린더 뷰와 상호작용: 캘린더 뷰에서 날짜를 선택했을 때 currentDate를 업데이트하고, 필요한 데이터를 다시 불러와서 UI에 반영했습니다.
```swift
@objc private func dateButtonTapped() {
    let calendarVC = CalendarVC()
    if #available(iOS 13.0, *) {
        calendarVC.modalPresentationStyle = .pageSheet
    }
    calendarVC.didSelectDate = { [weak self] selectedDate in
        self?.currentDate = selectedDate
        self?.updateDateButton()
    }
    present(calendarVC, animated: true, completion: nil)
}
```
Firestore 쿼리문을 적절하게 활용하여 UI와 데이터베이스를 적절하게 연동하고 문제를 해결할 수 있었습니다.
 
</details>

<details>
  <summary><h3>이동경로를 한눈에 보이도록 zoom레벨을 동적으로 설정하기 - 석기</h3></summary>

🤔 문제 상황

사용자가 이동한 경로를 보여주는 과정에서 이동경로가 잘려서 나오는 현상이 발생 했습니다. 또한 맵뷰에서 화면의 절반만큼만 맵뷰가 보여지도록 처리가 필요했습니다.

✨ 해결 과정

**맵뷰에 추가적인 여백 지정 🗺️**

실제로 맵뷰가 보여져야 하는 부분은 스크린사이즈의 절반정도로 화면의 절반 영역만 맵뷰의 기준을 적용하기 위해서 
setVisibleMapRect(_:edgePadding:animated:) 메서드를 이용하여 화면의 추가적인 여백공간을 지정해줬습니다.

![스크린샷 2024-07-30 오후 12 00 09](https://github.com/user-attachments/assets/b6cc2e28-ce92-4b33-9f0e-1b32358eeb4f)
UIEdgeInsets에 하단의 slideView와 상단의 stackView에 좌표값에 추가적인 여백을 지정하여 맵뷰가 UI에 가려지는 문제도 해결할 수 있었습니다.

**좌표값을 이용하여 zoom레벨을 조정 📍**

정확히 이동경로 전체를 보여주기 위해서 이동한 거리가 아닌 `위도, 경도에 대한 최대, 최솟값을 구하여 거리 편차` 를 구한뒤에 구해진 거리만큼 여백을 주는 방식으로 문제에 접근하였습니다.


거리 편차만큼 여백을 주고 새로운 좌표를 생성하기 위해서 latitudinalMeters, longitudinalMeters에 구해진 위도, 경도의 거리 편차를 대입하여 새로운 좌표값을 반환하는 메서드를 구현했습니다.

![스크린샷 2024-07-30 오후 12 01 08](https://github.com/user-attachments/assets/56f771a9-b5f6-4928-9c57-9dc0ffa629cc)

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
