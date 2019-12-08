//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by HansolJang on 19. 11. 26..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
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
    
    var emojiArtView = EmojiArtView()
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    var emojiArtBackgroundImage: UIImage? {
        get {
            return emojiArtView.backgroundImage
        }
        set {
            scrollView?.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewWidth?.constant = size.width
            scrollViewHeight?.constant = size.height
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max (dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    var emojis = "😀🥊💎🥑🐯🦄🧚‍♀️🦢🎄🍬🎉🥺❄️".map{ String($0) }
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }

    
    // return collection view's item view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font:font])
            emojiCell.label.attributedText = text
        }
        return cell
    }
    
    // collection view's drag delegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // 다시 드래그할 경우 복사가 아니라 이동하기 위해 저장
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    // collection view's drag delegate (multi touch)
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    // drag item 만들기
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label?.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            return []
        }
    }
    
    // collection view's drop
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    // drop's action
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    // collection view's drop
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    // 여러개를 수정할 때는 한번에 배치를 돌리도록
                    // 컬렉션뷰에서의 삭제/추가
                    collectionView.performBatchUpdates({
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    // 드롭이 된 곳에 추가하기
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                // 외부에서 드롭한 텍스트 아이템 비동기로 추가하기
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    
    
    // UIDropInteractionDelegate
    // OK한 드롭에 대해 드래그에서 session을 받아 데이터 꺼내기
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                self.emojiArtBackgroundImage = image
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

}
