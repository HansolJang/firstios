//
//  Concentration.swift
//  CardGame
//
//  Created by HansolJang on 19. 9. 23..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import Foundation

struct Concentration {
    
    private(set) var cards = [Card]()
    
    var flipCount = 0
    
    var gameScore = 0
    
    init(numberOfPairOfCards: Int) {
        assert(numberOfPairOfCards > 0, "Concentration.init(\(numberOfPairOfCards)): you must have at least one pair of cards")
        for _ in 0..<numberOfPairOfCards {
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(\(index)): IndexOutOfBoundsException")
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    gameScore += 2
                } else {
                    if cards[index].isFaceUpMoreThanOnce {
                        gameScore -= 1
                    }
                    if cards[matchIndex].isFaceUpMoreThanOnce {
                        gameScore -= 1
                    }
                }
                cards[index].isFaceUp = true
                cards[index].isFaceUpMoreThanOnce = true
                cards[matchIndex].isFaceUpMoreThanOnce = true
            } else {
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
        flipCount += 1
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
