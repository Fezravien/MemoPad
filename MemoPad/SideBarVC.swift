//
//  SideBarVC.swift
//  MemoPad
//
//  Created by 윤재웅 on 2021/01/15.
//

import UIKit

class SideBarVC: UITableViewController {
    
    let titles = ["  새글 작성하기", "  친구 새글", "  달력으로 보기", "  공지사항", "  통계", "  계정 관리"]
    
    // 아이콘 데이터 배열
    let icons = [
        UIImage(named: "icon01.png"),
        UIImage(named: "icon02.png"),
        UIImage(named: "icon03.png"),
        UIImage(named: "icon04.png"),
        UIImage(named: "icon05.png"),
        UIImage(named: "icon06.png")
    ]
    
    let nameLable = UILabel() // 이름 레이블
    let emailLable = UILabel() // 이메일 레이블
    let profileImage = UIImageView() // 프로필 이미지
    
    override func viewDidLoad() {
        
        // 테이블 뷰의 헤더 역할을 할 뷰를 정의한다.
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        
        headerView.backgroundColor = .darkGray
        
        // 테이블 뷰의 헤더 뷰로 지정한다.
        self.tableView.tableHeaderView = headerView
        
        // 이름 레이블의 속성을 정의하고, 헤더 뷰에 추가한다.
        self.nameLable.frame = CGRect(x: 72, y: 15, width: 100, height: 30) // 위치와 크기를 정의
        self.nameLable.text = "안녕하세요!" // 기본 텍스트
        self.nameLable.textColor = .white
        self.nameLable.font = UIFont.boldSystemFont(ofSize: 15) // 폰트 사이즈
        self.nameLable.backgroundColor = .clear // 배경 색상
        
        headerView.addSubview(self.nameLable)
        
        // 이메일 레이블의 속성을 정의하고, 헤더 뷰에 추가한다.
        self.emailLable.frame = CGRect(x: 72, y: 32, width: 150, height: 30) // 위치와 크기를 정의
        self.emailLable.text = "kaineus94@gmail.com" // 기본 텍스트
        self.emailLable.textColor = .white // 텍스트 색상
        self.emailLable.font = UIFont.systemFont(ofSize: 12) // 폰트 사이즈
        self.emailLable.backgroundColor = .clear // 배경 색상
        
        headerView.addSubview(self.emailLable) // 헤더 뷰에 추가
        
        // 헤더 기본 이미지를 구현한다.
        let defaultProfile = UIImage(named: "account.jpg")
        self.profileImage.image = defaultProfile // 이미지 등록
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50) // 위치와 크기를 정의
        
        // 프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width / 2)
        
        self.profileImage.layer.borderWidth = 0 // 테두리 두꼐 0
        self.profileImage.layer.masksToBounds = true // 마스크 효과
        
        headerView.addSubview(self.profileImage) // 헤더 뷰에 추가
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 재사용 큐에서 테이블 셀을 꺼내 온다. 없으면 새로 생성한다.
        let id = "menucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        // 타이틀과 이미지를 대입한다.
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        
        // 폰트 설정
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { // 새글 작성
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            let target = self.revealViewController()?.frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true)
            self.revealViewController()?.revealToggle(self)
        } else if indexPath.row == 5 { // 계정 관리
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            self.present(uv!, animated: true){
                self.revealViewController()?.revealToggle(self)
            }
            
        }
    }
    
}
