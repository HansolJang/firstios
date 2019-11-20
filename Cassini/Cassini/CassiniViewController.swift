//
//  CassiniViewController.swift
//  Cassini
//
//  Created by HansolJang on 19. 11. 19..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if let url = DemoURLs.NASA[identifier] {
                if let imageVC = segue.destination.contents as? ImageViewController {
                    imageVC.imageURL = url
                    imageVC.title = (sender as? UIButton)?.currentTitle
                }
            }
        }
    }
}

extension UIViewController {
    // 원래 self 를 반환
    // 네비게이션일 경우에만 현재 보이는 뷰컨트롤러 반환하도록 수정
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
