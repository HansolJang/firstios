//
//  ImageViewController.swift
//  Cassini
//
//  Created by HansolJang on 19. 11. 10..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: URL? {
        didSet {
            image = nil
            // 뷰가 화면에 보이고 있음
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            // 무조건 main 에서 일어나야 하는 일
            imageView.image = newValue
            // set intrinsic size
            imageView.sizeToFit()
            // set scrollview's contentsize to scroll
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // imageURL 이 바뀌고 화면이 보여졌을 경우
        if image == nil {
            fetchImage()
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1/25
            scrollView.maximumZoomScale = 1.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    // scrollview's delegate
    // zooming 시 보여질 뷰를 반환
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    var imageView = UIImageView()

    private func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            // 사용자가 이미지를 바꿔서 일어나는 일이기 때문에 userInitiated 사용
            // 뷰컨트롤러가 사라지고 나서도 클로저의 self 때문에 힙에 남아있을 수 있으므로 weak 사용
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    // 중간에 다른 이미지를 또 요청했을 수도 있으므로 요청과 결과가 같은 url 인지 검사
                    if let imageData = urlContents, url == self?.imageURL {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageURL == nil {
            imageURL = URL(fileURLWithPath: "https://static.scientificamerican.com/sciam/cache/file/E65E7E11-0308-4BA4-B74F3C99804E0648_source.jpeg?w=590&h=800&9F17384F-E50D-4D83-BB30F09099691D11")
        }
    }
}
