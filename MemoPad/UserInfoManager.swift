//
//  UserInfoManager.swift
//  MemoPad
//
//  Created by 윤재웅 on 2021/01/17.
//

import UIKit
import Alamofire

// 사용자 정보를 원할하게 다루기 위한 전담 관리 전용 객체
// 사용자가 설정한 개인 정보를 UserDefault 객체에 저장하고, 필요할 떄 이를 꺼내 주는 역할 을 담당

struct UserInfoKey {
    // 저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
    }

class UserInfoManager {
    
    // 연산 프로퍼티 loginId 정의
    var loginId: Int {
        
        get { // 읽기
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        
        set(v) { // 쓰기
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    // 개정 정보를 저장하는 역할
    var account:String? {
        
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    var name:String? {
        
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    var profile:UIImage? {
        
        get {
            let ud = UserDefaults.standard
            
            if let _profile = ud.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account.jpg") // 이미지가 없다면 기본 이미지
            }
        }
        
        set(v) {
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v!.pngData(), forKey: UserInfoKey.profile)
                ud.synchronize()
            }
        }
    }
    
    // 로그인 상태를 판별
    var isLogin:Bool {
        
        // 로그인 아이디가 0이거나 계정이 비어 있으면
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
    
    
//    func login(_ account:String, _ passwd:String) -> Bool {
//
//        if account.isEqual("a@naver.com") && passwd.isEqual("1234") {
//            let ud = UserDefaults.standard
//            ud.set(100, forKey: UserInfoKey.loginId)
//            ud.set(account, forKey: UserInfoKey.account)
//            ud.set("윤재웅", forKey: UserInfoKey.name)
//
//            ud.synchronize()
//            return true
//        } else {
//            return false
//        }
//    }
    
    func login(account: String, passwd: String, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        
        // URL과 전송할 값 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account": account,
            "passwd": passwd
        ]
        
        // API 호출
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        // API 호출 결과 처리
        call.responseJSON { (res) in
            
            // JSON 형식으로 응답했는지 확인
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("잘못된 응답 형식입니다. \(result)")
                return
            }
            
            // 응답 코드 확인. 0이면 성공
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 { // 로그인 성공
                
                // user_info 이하 항목을 딕셔너리 형태로 추출하여 저장
                let user = jsonObject["user_info"] as! NSDictionary
                
                self.loginId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
                
                // user_info 항목 중에서 프로필 이미지 처리
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                }
                
                // 토큰 정보 추출
                let accessToken = jsonObject["access_token"] as! String // 액세스 토큰 추출
                let refreshToken = jsonObject["refresh_token"] as! String // 리프레시 토큰 추출
                
                // 토큰 정보 저장
                let tk = TokenUtils()
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
                tk.save("kr.co.rubypaper.MyMemory", account: "refresh_token", value: refreshToken)
                
                // 인자값으로 입력된 success 클로저 블록을 실행한다.
                success?()
                
            } else {
                let msg = (jsonObject["error_msg"] as? String) ?? "로그인이 실패했습니다."
                fail?(msg)
            }
        }
        
    }
    
    func logout() -> Bool {
        let ud = UserDefaults.standard
        // removePersistentDomain(forName:) - 프로퍼티 리스트에 저장된 모든 값 일괄 삭제
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        
        return true
    }

    
}
