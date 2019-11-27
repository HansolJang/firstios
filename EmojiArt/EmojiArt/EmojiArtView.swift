//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by HansolJang on 19. 11. 26..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    
    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }

}
