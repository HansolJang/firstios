//
//  ViewController.swift
//  CardGame
//
//  Created by HansolJang on 19. 9. 23..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var game: Concentration? = nil
    
    @IBOutlet private weak var flipCountLabel: UILabel! {
        didSet { updateFlipCountLabel() }
    }
    
    @IBOutlet private weak var gameScoreLabel: UILabel! {
        didSet { updateGameScoreLabel() }
    }
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    var numberOfPairsOfCards: Int {
        return (cardButtons.count + 1) / 2
    }
    
    override func viewDidLoad() {
        startNewGame()
    }
    
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game?.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButton")
        }
    }
    
    @IBAction private func touchNewGame(_ sender: UIButton) {
        startNewGame()
    }
    
    private func startNewGame() {
        game = Concentration(numberOfPairOfCards: numberOfPairsOfCards)
        let theme = Theme.getRandomTheme()
        view.backgroundColor = theme.backgroundColor
        emojiChoices = theme.rawValue
        emoji.removeAll()
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game?.cards[index]
            if let card = card, card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card?.isMatched == true ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 1, green: 0.6015612483, blue: 0.4140183032, alpha: 1)
            }
        }
        updateFlipCountLabel()
        updateGameScoreLabel()
    }
    
    private func updateFlipCountLabel() {
        let attributes: [NSAttributedString.Key : Any] = [
            .strokeWidth : 5.0,
            .strokeColor : #colorLiteral(red: 1, green: 0.6015612483, blue: 0.4140183032, alpha: 1)
        ]
        let attributedString = NSAttributedString(string: "Flips: \(game?.flipCount ?? 0)", attributes: attributes)
        flipCountLabel.attributedText = attributedString
    }
    
    private func updateGameScoreLabel() {
        let attributes: [NSAttributedString.Key : Any] = [
            .strokeWidth: 5.0,
            .strokeColor: UIColor.white
        ]
        let attributeString = NSAttributedString(string: "Game Score: \(game?.gameScore ?? 0)", attributes: attributes)
        gameScoreLabel.attributedText = attributeString
    }
    
    private lazy var emojiChoices = Theme.getRandomTheme().rawValue
    
    private var emoji = [Card:String]()
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        return emoji[card] ?? "?"
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
