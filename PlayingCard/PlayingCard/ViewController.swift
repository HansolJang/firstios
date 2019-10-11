//
//  ViewController.swift
//  PlayingCard
//
//  Created by Hansol Jang on 11/10/2019.
//  Copyright © 2019 Hansol Jang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var deck = PlayingCardDeck()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 1...10 {
            if let card = deck.draw() {
                print("\(card)")
            }
        }
    }
}
