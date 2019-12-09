//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by HansolJang on 19. 12. 9..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    // 뷰컨트롤러에서 클로저 구현
    var resignationHandler: (() -> Void)?
    
    // text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }

    // 키보드에서 리턴키 눌렸을 때 키보드 숨기기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
