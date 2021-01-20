//
//  TutorialMasterVC.swift
//  MemoPad
//
//  Created by 윤재웅 on 2021/01/20.
//

import UIKit

class TutorialMasterVC: UIViewController, UIPageViewControllerDataSource {
    
    
    
    // 페이지 뷰 컨트롤러의 인스턴스를 참조할 맴버 변수
    var pageVC: UIPageViewController!
    
    // 콘텐츠 뷰 컨트롤러에 들어갈 타이틀과 이미지
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["Page0", "Page1", "Page2", "Page3"]
    
    override func viewDidLoad() {
        
        // 1. 페이지 뷰 컨트롤러 객체 생성하기
        self.pageVC = self.instanceTutorialVC("PageVC") as? UIPageViewController
        self.pageVC.dataSource = self
        
        // 2. 페이지 뷰 컨트롤러의 기본 페이지 지정
        let startContentVC = self.getContentVC(atIndex: 0)! // 최초 노출될 콘텐츠 뷰 컨틀롤러
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true)
        
        // 3. 페이지 뷰 컨트롤러의 출력 영역 지정
        self.pageVC.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageVC.view.frame.size.width = self.view.frame.width
        self.pageVC.view.frame.size.height = self.view.frame.height - 60 // 페이지 인디케이터, 시작하기 버튼 자리 확보
        
        // 4. 페이지 뷰 컨트롤러를 마스터 뷰 컨트롤러의 자식 뷰 컨트롤러로 설정
        self.addChild(self.pageVC)
        self.view.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParent: self)
    }
    
    // MARK: - "시작하기" 버튼
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: UserInfoKey.tutorial)
        ud.synchronize()
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    // MARK: - 인디케이터
    // 페이지 뷰 컨트롤러가 출력할 페이지의 개수를 알려주는 역할
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }
    
    // 페이지 뷰 컨트롤러가 최초에 출력할 콘텐츠 뷰의 인덱스 번호를 알려주는 역할 (앞에서 첫 번째 페이지가 기본값으로 설정했으므로 0 으로 반환)
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    // MARK: - 컨텐츠 뷰 컨트롤러 동적 생성
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        
        // 인덱스가 데이터 배열 크기 범위를 벗어나면 nil 반환
        guard self.contentTitles.count >= idx && self.contentTitles.count > 0 else {
            return nil
        }
        
        // "ContentsVC"라는 Storyboard ID를 가진 뷰 컨트롤러의 인스턴스를 생성하고 캐스팅한다.
        guard let cvc = self.instanceTutorialVC("ContentsVC") as? TutorialContentsVC else {
            return nil
        }
        
        // 콘텐츠 뷰 컨트롤러의 내용을 구성
        cvc.titleText = self.contentTitles[idx]
        cvc.imageFile = self.contentImages[idx]
        cvc.pageIndex = idx
        
        return cvc
    }
    
    // MARK: - 이전, 다음 페이지
    // 현재의 콘텐츠 뷰 컨트롤러보다 앞쪽에 올 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        // 현재의 인덱스가 맨 앞이라면 nil을 반환하고 종료
        guard index > 0 else {
            return nil
        }
        
        index -= 1 // 현재의 인덱스에서 하나 빼기 (이전 페이지)
        
        return self.getContentVC(atIndex: index)
    }
    
    // 현재의 콘텐츠 뷰 컨트롤러보다 뒤쪽에 올 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        index += 1 // 현재의 인덱스에 하나 더함 (다음 페이지)
        
        // 인덱스는 항상 배열 데이터의 크기보다 작아야 한다.
        guard index < self.contentTitles.count else {
            return nil
        }
        
        return self.getContentVC(atIndex: index)
    }
    
}
