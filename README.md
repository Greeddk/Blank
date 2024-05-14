

# 프로젝트 소개
<img width="40%" src="https://github.com/Greeddk/Blank/assets/116425551/7cc7e6e6-7b28-4f53-affe-54cba625cc92"/>


# 스크린샷
<img src="https://github.com/Greeddk/Blank/assets/116425551/c50ed8a7-2772-4cc6-9245-eb2bdaa7bfb1"/>

# 앱 소개 & 기획
## ‎Blank - 이미지의 글자를 인식한 후 해당 부분을 빈칸으로 만들어 암기를 도와주는 앱 
<div align="center">
  <a target="_blank" href="https://apps.apple.com/kr/app/%EB%B8%94%EB%9E%AD%ED%81%AC-blank-%EB%B9%88%EC%B9%B8%EC%9C%BC%EB%A1%9C-%EC%95%94%EA%B8%B0%ED%95%98%EA%B8%B0/id6471817064"><img width="300px" height="auto" src="https://github.com/DeveloperAcademy-POSTECH/MacC-Team13-SplitIt/assets/91787174/a9d5c9f2-3959-41f2-8783-dae29383f560" /></a>
  <br/>
</div>

## 개발 기간과 v1.0 버전 기능
### 개발 기간
- 2023.09.08 ~ 2023.12.01 (85일)
<br>

### 개발 인원
- iOS 개발자 4명
<br>

### Configuration
- 최소버전 16.0 / 라이트 모드 / 세로모드 / iPadOS전용
<br>

### v1.0 기능
1. PDF 관리 기능
  - PDF 가져오기, 삭제
  - 이미지 여러개 선택 시 pdf으로 변환 기능
<br>

2. 빈칸 만들기
  - 드레그 / 선택으로 글자 선택 기능
  - 지우개 버튼으로 글자 선택 해지 기능
  - 내가 원하는 영역 빈칸 만들기 기능
  - 빈칸에 애플팬슬로 글자를 쓰면 인식
  - 채점 기능
  - 이전 회차 시험 설정 그대로 시험 보기 기능
<br>

3. 통계 기능
  - 시험 본 회차별 정 오답 표시 기능
  - 전체 회차 통계 기능
<br>

### 기술 스택
- SwiftUI / MVVM
- UIKit / UIViewControllerRepresentable
- CoreData
- PDFKit
- VisionKit
<br>

### 담당 구현 기술
- **PDFKit**을 사용하여, 모든 페이지들을 **썸네일**로 한눈에 볼 수 있게 구현
- **UIGraphicsImageRenderer**를 사용해 PDF를 이미지로 변환하는 기능 구현
- **연산 프로퍼티**로 뷰를 **나눠서** 한 눈에 뷰 구조를 파악할 수 있도록 구현
- Zstack과 ForEach를 사용해 이미지 위에 **정답 통계 / 회차별 정,오답 표시 기능 구현**
- 앱의 특성을 고려하여 심플한 UI 구현
- ScrollView를 활용한 이미지 **줌 & 드래그** 기능 구현
- GridView를 사용해 하단 **페이지 네비게이션 뷰** 구현

<br>

# ⚒️트러블 슈팅

## 1. 런타임 에러로 종료되는 버그
문제를 다 푼 상태(ResultPageView)에서 페이지 선택 화면(OverView)으로 넘어가는 과정에서 불규칙적으로 런타임 에러가 발생


### 상황
- 아이패드OS 16, 17버전의 두기기로 테스트를 한 결과, 16은 미묘하게 navigationStack을 이용한 Navigationbar의 크기가 작고, 앱이 강제종료 되지 않았음. 그러나 17버전의 iPad에선 앱이 종료되는 버그가 발생
- 또한, 코어데이터나 다른 부분의 문제는 아니였음
- 테스트 결과 현재 네비게이션스텍을 사용했을때, destination에 isPresented로 쌓인 네비게이션 스택을 pop하는 방식이 에러라는 것을 발견
  
<details>
<summary>코드 보기</summary>
  원본코드
  
```
  .navigationDestination(isPresented: $isLinkActive) {
            if !goToTestPage {
                if let page = overViewModel.selectedPage {
                    let wordSelectViewModel = WordSelectViewModel(page: page, basicWords: overViewModel.basicWords)
                    WordSelectView(isLinkActive: $isLinkActive, generatedImage: $generatedImage, wordSelectViewModel: wordSelectViewModel)
                } else {
                    
                    Text("Error")
                }
                
            } else {
            
            }
        }
```

해결방안
- SwiftUI에서 UINavigationController를 백그라운드에서 사용하고 있다는 점을 알게되었고, 이를 이용하여 해결함.
- rootView 로 pop할 수도 있고, 설정에 따라서 내가 원하는 페이지로 pop 가능
  
```
 import SwiftUI

struct NavigationUtil {
    static func popToRootView(animated: Bool = false) {
        findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController)?.popToRootViewController(animated: animated)
    }
    
    static func popToOverView(animated: Bool = false) {
            guard let navigationController = findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController) else {
                return
            }
            
            if navigationController.viewControllers.count > 1 {
                let overViewController = navigationController.viewControllers[1]  // 루트 뷰 바로 다음에 있는 뷰 컨트롤러를 가져옵니다.
                navigationController.popToViewController(overViewController, animated: animated)
            }
        }
    
    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UITabBarController {
            return findNavigationController(viewController: navigationController.selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}
```

</details>

[TroubleShooting 이슈](https://github.com/DeveloperAcademy-POSTECH/MacC-Afternoon-Team11-FoursTech-Blank/issues/83)
<br>
<br>
