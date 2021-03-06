//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by HansolJang on 19. 11. 26..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit
import MobileCoreServices

// UILabel -> EmojiArt.EmojiInfo
// 뷰 -> 모델이기 때문에 뷰컨트롤러에 위치
extension EmojiArt.EmojiInfo {
    // ?: 실패할 수 있는 생성자
    init?(label: UILabel) {
        if let attributedText = label.attributedText, let font = attributedText.font {
            x = Int(label.center.x)
            y = Int(label.center.y)
            text = attributedText.string
            size = Int(font.pointSize)
        } else {
            return nil
        }
    }
}

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Camera
    
    @IBOutlet weak var cameraButton: UIBarButtonItem! {
        didSet {
            cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    @IBAction func takeBackgroundPhoto(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = ((info[UIImagePickerController.InfoKey.editedImage]
            ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage)?.scaled(by: 0.25) {
//            let url = image.storeLocallyAsJPEG(named: String(Date.timeIntervalSinceReferenceDate))
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                emojiArtBackgroundImage = .local(imageData, image)
                documentChanged()
            } else {
                // TODO: alert
            }
        }
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Document Info" {
            if let destination = segue.destination.contents as? DocumentInfoViewController {
                document?.thumbnail = emojiArtView.snapshot
                destination.document = document
                
                if let ppc = destination.popoverPresentationController {
                    ppc.delegate = self
                }
            }
        } else if segue.identifier == "Embed Document Info" {
            embeddedDocInfo = segue.destination.contents as? DocumentInfoViewController
        }
    }
    
    private var embeddedDocInfo: DocumentInfoViewController?
    
    // popover 가 적응형이 아니도록 설정
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection)
        -> UIModalPresentationStyle {
        return .none
    }
    
    // storyboard's Document Info View Controller's exit
    @IBAction func close(bySegue: UIStoryboardSegue) {
        close()
    }
    
    @IBOutlet weak var embeddedDocInfoWidth: NSLayoutConstraint!
    @IBOutlet weak var embeddedDocInfoHeight: NSLayoutConstraint!
    
    // MARK: - Model
    
    var emojiArt: EmojiArt? {
        get {
            if let imageSource = emojiArtBackgroundImage {
                let emojis = emojiArtView.subviews
                    .compactMap { $0 as? UILabel }
                    .compactMap { EmojiArt.EmojiInfo(label: $0) }
                switch imageSource {
                case .remote(let url, _): return EmojiArt(url: url, emojis: emojis)
                case .local(let imageData, _): return EmojiArt(imageData: imageData, emojis: emojis)
                }
            }
            return nil
        }
        set {
            emojiArtBackgroundImage = nil
            emojiArtView.subviews
                .compactMap { $0 as? UILabel }
                .forEach { $0.removeFromSuperview() }
            let imageData = newValue?.image
            let image = (imageData != nil) ? UIImage(data: imageData!) : nil
            if let url = newValue?.url {
                imageFetcher = ImageFetcher(fetch: url) { (url, image) in
                    DispatchQueue.main.async {
                        if image == self.imageFetcher.backup {
                            self.emojiArtBackgroundImage = .local(imageData!, image)
                        } else {
                            self.emojiArtBackgroundImage = .remote(url, image)
                        }
                        newValue?.emojis.forEach {
                            let attributedText = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                            self.emojiArtView.addLabel(with: attributedText, centeredAt: CGPoint(x: $0.x, y: $0.y))
                        }
                    }
                }
                imageFetcher.backup = image
                imageFetcher.fetch(url)
            } else if image != nil {
                emojiArtBackgroundImage = .local(imageData!, image!)
                newValue?.emojis.forEach {
                    let attributedText = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                    self.emojiArtView.addLabel(with: attributedText, centeredAt: CGPoint(x: $0.x, y: $0.y))
                }
            }
        }
    }
    
    
    // MARK: - UIDocument
    
    var document: EmojiArtDocument?
    
    // 변화를 감지하면 자동 저장해야 하지만 강의에서 시간이 없으므로 생략
    // drop event 등 뷰가 변하는 delegate에 updateChangeCount 호출해야 함
    @IBAction func save(_ sender: UIBarButtonItem? = nil) {
        documentChanged()
    }
    
    @IBAction func close(_ sender: UIBarButtonItem? = nil) {
        
        // 이모지뷰 변경 옵저버 삭제
        if let observer = emojiArtViewObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if document?.emojiArt != nil {
            document?.thumbnail = emojiArtView.snapshot
        }
        presentingViewController?.dismiss(animated: true) {
            self.document?.close { success in
                // 문서 상태 옵저버 삭제
                if let observer = self.documentObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }
    }
    
    private var documentObserver: NSObjectProtocol?
    private var emojiArtViewObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if document?.documentState != .normal {
            // 문서 상태 옵저버 추가
            documentObserver = NotificationCenter.default.addObserver(
                forName: UIDocument.stateChangedNotification,
                object: document,
                queue: OperationQueue.main,
                using: { notification in
                    print("documentState changed to \(self.document!.documentState)")
                    // Embed 세그웨이에 모델 세팅
                    if self.document!.documentState == .normal, let docInfoVC = self.embeddedDocInfo {
                        docInfoVC.document = self.document
                        self.embeddedDocInfoWidth.constant = docInfoVC.preferredContentSize.width
                        self.embeddedDocInfoHeight.constant = docInfoVC.preferredContentSize.height
                    }
            })
            
            document?.open { success in
                if success {
                    self.title = self.document?.localizedName
                    self.emojiArt = self.document?.emojiArt
                    // 이모지뷰 변경 옵저버 추가
                    self.emojiArtViewObserver = NotificationCenter.default.addObserver(
                        forName: EmojiArtView.didChangeNotification,
                        object: self.emojiArtView,
                        queue: OperationQueue.main,
                        using: { notification in
                            self.documentChanged()
                    })
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
            .appendingPathComponent("Untitled.json") {
            document = EmojiArtDocument(fileURL: url)
        }
    }
    
    private func documentChanged() {
        document?.emojiArt = emojiArt
        if document?.emojiArt != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    // MARK: - Storyboard
    
    // 15.
    private var suppressBadURLWarning = false
    
    private func presentBadURLWarning(for url: URL?) {
        
        if !suppressBadURLWarning {
            let alert =  UIAlertController(
                title: "Image Transfer Failed",
                message: "Couldn't transfer the dropped image from its source.\nShow this warning in the future?",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(
                title: "Keep Warning",
                style: .default))
            
            alert.addAction(UIAlertAction(
                title: "Stop Warning",
                style: .destructive,
                handler: { action in
                    self.suppressBadURLWarning = true
                }
            ))
            
            present(alert, animated: true)
        }
    }
    
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
    
    // backing field
    private var _emojiArtBackgroundImageURL: URL?
    
    enum ImageSource {
        case remote(URL, UIImage)
        case local(Data, UIImage)
        
        var image: UIImage {
            switch self {
            case .remote(_, let image): return image
            case .local(_, let image): return image
            }
        }
    }
    
    var emojiArtBackgroundImage: ImageSource? {
        didSet {
            scrollView?.zoomScale = 1.0
            emojiArtView.backgroundImage = emojiArtBackgroundImage?.image
            let size = emojiArtBackgroundImage?.image.size ?? CGSize.zero
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
            // iphone's default = false
            emojiCollectionView.dragInteractionEnabled = true
        }
    }
    
    // 13.
    
    private var addingEmoji = false
    
    @IBAction func addEmoji(_ sender: Any) {
        addingEmoji = true
        emojiCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return emojis.count
            default: return 0
        }
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }

    
    // return collection view's item view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            if let emojiCell = cell as? EmojiCollectionViewCell {
                let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font:font])
                emojiCell.label.attributedText = text
            }
            return cell
        } else if addingEmoji {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiInputCell", for: indexPath)
            if let inputCell = cell as? TextFieldCollectionViewCell {
                // text field가 포커스 잃었을 때 호출
                // 뷰컨트롤러 -> 셀 -> 인풋셀 -> 클로저 -> 뷰컨트롤러 = 사이클 발생!
                // 뷰컨트롤러가 없을 경우 셀에 이모지를 추가하지 않아도 됨
                // 인풋셀 -> 클로저 -> 인풋셀 = 사이클 발생!
                // inputCell 이 nil 이라면 클로저를 생성하지 못했을 것이므로 무조건 inputCell 이 있음을 앎
                // unowned: rc 를 증가시키진 않지만 무조건 참조할 때 (프로그래머가 확신이 있어야 함)
                inputCell.resignationHandler = { [weak self, unowned inputCell] in
                    if let text = inputCell.textField.text {
                        self?.emojis = (text.map { String($0) } + self!.emojis).uniquified
                    }
                    self?.addingEmoji = false
                    self?.emojiCollectionView.reloadData()
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmojiButtonCell", for: indexPath)
            return cell
        }
    }
    
    // text field 를 넓게 보여주기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0 {
            return CGSize(width: 300, height: 80)
        } else {
            return CGSize(width: 80, height: 80)
        }
    }
    
    // text field 뷰셀이 보여지기 직전에 키보드 보이기
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let inputCell = cell as? TextFieldCollectionViewCell {
            inputCell.textField.becomeFirstResponder()
        }
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
        if !addingEmoji, let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label?.attributedText {
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
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
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
    // 15.
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                if image == self.imageFetcher.backup {
                    if let imageData = image.jpegData(compressionQuality: 1.0) {
                        self.emojiArtBackgroundImage = .local(imageData, image)
                        self.documentChanged()
                    } else {
                        self.presentBadURLWarning(for: url)
                    }
                } else {
                    self.emojiArtBackgroundImage = .remote(url, image)
                    self.documentChanged()
                }
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
