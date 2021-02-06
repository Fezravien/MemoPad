//
//  JoinVC.swift
//  MemoPad
//
//  Created by 윤재웅 on 2021/02/06.
//

import UIKit
import Alamofire

class JoinVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submit: UIBarButtonItem!
    
    // 테이블 뷰에 들어갈 텍스트 필드들
    var fieldAccount: UITextField! // 계정
    var fieldPassword: UITextField! // 비밀번호
    var fieldName: UITextField! // 이름 필드
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        
        // 테이블 뷰의 dataSource, delegate 속성 지정
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        // 각 테이블 뷰 셀 모두에 공동으로 적용될 프레임 객체
        let tfFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 38)
        
        switch indexPath.row {
        case 0:
            self.fieldAccount = UITextField(frame: tfFrame)
            self.fieldAccount.placeholder = "계정(이메일)"
            self.fieldAccount.borderStyle = .none
            self.fieldAccount.autocapitalizationType = .none
            self.fieldAccount.font = UIFont.systemFont(ofSize: 15)
            
            cell.addSubview(self.fieldAccount)
            
        case 1:
            self.fieldPassword = UITextField(frame: tfFrame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.isSecureTextEntry = true
            self.fieldPassword.autocapitalizationType = .none
            self.fieldPassword.font = UIFont.systemFont(ofSize: 15)
            
            cell.addSubview(self.fieldPassword)
            
        case 2:
            self.fieldName = UITextField(frame: tfFrame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.autocapitalizationType = .none
            self.fieldName.font = UIFont.systemFont(ofSize: 15)
            
            cell.addSubview(self.fieldName)
        default:
            ()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
}
