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
    
}
