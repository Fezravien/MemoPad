//
//  ProfileVC.swift
//  MemoPad
//
//  Created by 윤재웅 on 2021/01/15.
//

import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let profileImage = UIImageView() // 프로필 사진 이미지
    let tv = UITableView() // 프로필 목록
    
    let uinfo = UserInfoManager() // 개인 정보 관리 매니저
    
    // API 호출 상태값을 관리할 변수
    var isCalling = false
    
    @IBOutlet weak var indicatiorView: UIActivityIndicatorView!
    
    // MARK: - View life Cycle
    override func viewDidLoad() {
        self.navigationItem.title = "프로필"
        
        // 뒤로 가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        backBtn.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = backBtn
        //self.navigationController?.navigationBar.isHidden = true
        
        // 배경 이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)
        
        bgImg.frame.size = CGSize(width: bgImg.frame.size.width, height: bgImg.frame.size.height)
        bgImg.center = CGPoint(x: self.view.frame.width / 2, y: 50)
        
        bgImg.layer.cornerRadius = bgImg.frame.size.width / 2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
        self.view.addSubview(bgImg)
        
        self.view.bringSubviewToFront(self.tv)
        self.view.bringSubviewToFront(self.profileImage)
        
        
        // 프로필 사진에 들어갈 기본 이미지
        //let image = UIImage(named: "account.jpg")
        let image = self.uinfo.profile
        
        // 프로필 이미지 처리
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 280)
        
        // 프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        
        // 루트 뷰에 추가
        self.view.addSubview(self.profileImage)
        
        
        // 테이블 뷰
        self.tv.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 25, width: self.view.frame.width, height: 100)
        self.tv.dataSource = self
        self.tv.delegate = self
        
        self.view.addSubview(self.tv)
        
        self.drawBtn()
        
        // 프로필 이미지 뷰 객체에 탭 제스처 등록
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        
        // 객체가 사용자와 상호반을할 수 있도록 허락
        // UIControl을 상속받지 않은 객체는 기본적으로 사용자와 반응하지 않도록 하기 위해 .isUserInteractionEnabled 속성의 값이 false로 설정
        self.profileImage.isUserInteractionEnabled = true
        
        // 인디케이터 뷰를 화면 맨 앞으로
        self.view.bringSubviewToFront(self.indicatiorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 토큰 인증 여부 체크
        self.tokenValidate()
    }
    
    // MARK: - Action
    // 로그인 창 표시
    @objc func doLogin(_ sender:Any) {
        
        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다. \n잠시만 기다려 주세요.")
            return
        } else {
            self.isCalling = true
        }
        
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        // 알림창에 들어갈 입력폼 추가
        loginAlert.addTextField {
            $0.placeholder = "Your Account"
        }
        
        loginAlert.addTextField {
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
        }
        
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel){ _ in
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive){ _ in
            
            // 인디케이터 실행
            self.indicatiorView.startAnimating()
            
            let account = loginAlert.textFields?[0].text ?? "" // 첫 번째 필드 : 계정
            let passwd = loginAlert.textFields?[1].text ?? "" // 두 번째 필드 : 비밀번호
            
            // 비동기 방식으로 변경되는 부분
            self.uinfo.login(account: account, passwd: passwd, success: {
                
                // 인디케이터 종료
                self.indicatiorView.stopAnimating()
                self.isCalling = false
                
                // UI 갱신
                self.tv.reloadData() // 테이블 뷰를 갱신한다.
                self.profileImage.image = self.uinfo.profile // 이미지 프로필을 갱신한다.
                self.drawBtn()
                
                // 서버와 데이터 동기화
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData() // 서버에 저장된 데이터가 있으면 내려받는다.
                }
                
            }, fail: {msg in
                // 인디케이터 종료
                self.indicatiorView.stopAnimating()
                self.isCalling = false
                
                self.alert(msg)
            })
            
        })
        
        self.present(loginAlert, animated: false)
  
    }
    
    // 로그아웃 처리
    @objc func doLogout(_ sender: Any) {
        
        let msg = "로그아웃을 하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive){_ in
            
            // 인디케이터 실행
            self.indicatiorView.startAnimating()
            
             self.uinfo.logout() {
                // Logout API 호출과 logout() 실행이 모두 끝나면 인디케이터도 중지
                self.indicatiorView.stopAnimating()
                
                self.tv.reloadData() // 테이블 뷰를 갱신한다.
                self.profileImage.image = self.uinfo.profile // 이미지 프로필을 갱신한다.
                self.drawBtn()
            }
    })
        self.present(alert, animated: false)
        
    }
    
    @objc func close(_ sender: Any) {
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // 프로필 사진의 소스 타입을 선택하는 액션 메소드
    @objc func profile(_ sender: UIButton) {
        
        // 로그인되어 있지 않을 경우에는 프로필 이미지 등록을 막고 대신 로그인 창을 띄워 준다.
        guard self.uinfo.account != nil else {
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요.", preferredStyle: .actionSheet)
        
        // 카메라를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { (_) in
                self.imgPicker(.camera)
            }))
        }
        
        // 저장된 앨범을 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default, handler: { (_) in
                self.imgPicker(.savedPhotosAlbum)
            }))
        }
        
        // 포토 라이브러리를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default, handler: { (_) in
                self.imgPicker(.photoLibrary)
            }))
        }
        
        // 취소 버튼 추가
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // 액션 시트 창 실행
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func drawBtn() {
        
        // 버튼을 감쌀 뷰를 정의한다.
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        self.view.addSubview(v)
        
        // 버튼을 정의한다.
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        // 로그인 상태일 때는 로그아웃 버튼을, 로그아웃 상태일 때에는 로그인 버튼을 만든다.
        if self.uinfo.isLogin == true {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        
        v.addSubview(btn)
    }
    
    // MARK: - PickerVIew
    func imgPicker(_ source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        
        self.present(picker, animated: true)
        
    }
    
    // 이미지를 선택하면 이 메소드가 자동으로 호출
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 인디케이터 실행
        self.indicatiorView.startAnimating()
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uinfo.newProfile(img, success: {
                // 인디케이터 종료
                self.indicatiorView.stopAnimating()
                self.profileImage.image = img
            }, fail: { msg in
                // 인디케이터 종료
                self.indicatiorView.stopAnimating()
                self.alert(msg)
            })
        }
        
        // 이 구문을 누락하면 이미지 피커 컨트롤러 창은 닫히지 않는다.
        picker.dismiss(animated: true)
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "이름"
            //cell.detailTextLabel?.text = "윤재웅"
            cell.detailTextLabel?.text = self.uinfo.name ?? "Login please"
        case 1:
            cell.textLabel?.text = "계정"
            //cell.detailTextLabel?.text = " kaineus94@gmail.com"
            cell.detailTextLabel?.text = self.uinfo.account ?? "Login please"
        default:
            ()
        }
        // 여기에 셀 구현 내용이 들갈 예정
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uinfo.isLogin == false {
            // 로그인되어 있지 않다면 로그인 창을 띄워 준다.
            self.doLogin(self.tv)
        }
    }
    
    // Unwind
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        // 프로필 화면으로 되돌아오기 위한 표식 역할
        // 아무 내용도 작성하지 않음
    }
}


extension ProfileVC {
    
    // 토큰 인증 메소드
    // 토큰을 체크하고 갱신하는 역할
    func tokenValidate() {
        // 응답 캐시를 사용하지 않도록
        URLCache.shared.removeAllCachedResponses()
        
        // 키 체인에 액세스 토큰이 없을 경우 유효성 검증을 진행하지 않음
        let tk = TokenUtils()
        guard let header = tk.getAuthorizationHeader() else {
            return
        }
        
        // 로딩 인디케이터 시작
        self.indicatiorView.startAnimating()
        
        // tokenValidate API를 호출한다.
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        validate.responseJSON { (res) in
            self.indicatiorView.stopAnimating()
            
            let responseBody = try! res.result.get()
            print(responseBody)
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            // 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 { // 응답 결과가 실패일 떄, 즉 토큰이 만료되었을 떄
                // 로컬 인증 실행
                self.touchID()
                
            }
        }
    }
    
    // 터치 아이디 인증 메소드
    func touchID() {
        
        // LAContext 인스턴스 생성
        let context =  LAContext()
        
        // 로컬 인증에 사용할 변수 정의
        var error: NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics // 인증 정책
        
        // 로컬 인증이 사용 가능한지 여부 확인
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            // 터치 아이디 인증창 실행
            context.evaluatePolicy(deviceAuth, localizedReason: msg) { (success, e) in
                if success {
                    // 토큰 갱신 로직
                    self.refresh()
                    
                } else { // 인증 실패
                    // 인증 실패 원인에 대한 대응 로직
                    print((e?.localizedDescription)!)
                    
                    switch (e!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소되었습니다.")
                        
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다.") {
                            self.commonLogout(true)
                        }
                        
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation() {
                            self.commonLogout(true)
                        }
                    
                    default:
                        OperationQueue.main.addOperation() {
                            self.commonLogout(true)
                        }
                    }
                    
                }
                
            }
            
        } else { // 인증창이 실행되지 못한 경우
            // 인증창 실행 불가 원인에 대한 대응 로직
            print(error!.localizedDescription)
            
            switch error!.code {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디가 등록되어 있지 않습니다.")
                
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다.")
                
            default: // LAError.touchIDNotAvailable 포함
                print("터치 아이디를 사용할 수 없습니다.")
                OperationQueue.main.addOperation() {
                    self.commonLogout(true)
                }
            }
            
        }
        
    }
    
    // 토큰 갱신 메소드
    func refresh() {
        self.indicatiorView.startAnimating() // 로딩 시작
        
        // dlswmd gpej
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        // 리프레시 토큰 전달 준비
        let refreshToken = tk.load("kr.co.rubypaper.MyMemory", account: "refreshToken")
        let param: Parameters = ["refresh_token" : refreshToken!]
        
        // 호출 및 응답
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        refresh.responseJSON { (res) in
            self.indicatiorView.stopAnimating() // 로딩 중지
            
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            // 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 { // 성공 : 액세스 토큰이 갱신되었다는 의미
                // 키 체인에 저장된 액세스 토큰 교체
                let accessToken = jsonObject["access_token"] as! String
                tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
                                
            } else { // 실패 : 액세스 토큰 만료
                self.alert("인증이 만료되었으므로 다시 로그인해야 합니다.") {
                    // 로그아웃 처리
                    OperationQueue.main.addOperation() {
                        self.commonLogout(true)
                    }
                }
            }
        }
    }

    
    func commonLogout(_ isLogin: Bool = false) {
        
        // 저장된 기존 개인 정보 & 키 체인 데이터를 삭제하며 로그아웃 상태로 전환
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()
        
        // 현재의 화면이 프로필 화면이라면 바로 UI를 갱신한다.
        self.tv.reloadData()
        self.profileImage.image = userInfo.profile
        self.drawBtn()
        
        // 기본 로그인 창 실행 여무
        if isLogin {
            self.doLogin(self)
        }
    }
}
