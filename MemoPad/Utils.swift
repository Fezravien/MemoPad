//
//  Utils.swift
//  MemoPad
//
//  Created by 윤재웅 on 2021/01/20.
//

import UIKit

extension UIViewController {
    
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialVC(_ name:String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    func alert(_ message: String, completion: (() -> Void)? = nil) {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { _ in
                // completion 매개변수의 값이 nil이 아닐 때만 실행되도록
                completion?()
            }
            
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}
