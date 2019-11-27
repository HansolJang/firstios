//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by HansolJang on 19. 11. 26..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate {

    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    // UIDropInteractionDelegate
    // 어떤 드롭만 OK 할 것인지 정의
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // URL이고 UIImage 형식이 드롭되었을 경우에만 true
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    // UIDropInteractionDelegate
    // OK한 드롭으로 무엇을 할 것인지 정의 (copy, move, cancel 중에)
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    var imageFetcher: ImageFetcher!
    
    // UIDropInteractionDelegate
    // OK한 드롭에 대해 드래그에서 session을 받아 데이터 꺼내기
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                self.emojiArtView.backgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
    
    @IBOutlet weak var emojiArtView: EmojiArtView!

}
