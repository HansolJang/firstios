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
            imageView.image = newValue
            // set intrinsic size
            imageView.sizeToFit()
            // set scrollview's contentsize to scroll
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // imageURL 이 바뀌고 화면이 보여졌을 경우
        if image == nil {
            fetchImage()
        }
    }

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
            if let urlContents = try? Data(contentsOf: url) {
                image = UIImage(data: urlContents)
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
