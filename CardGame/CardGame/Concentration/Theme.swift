//
//  Theme.swift
//  CardGame
//
//  Created by HansolJang on 19. 10. 11..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import Foundation
import UIKit

enum Theme: String {
    case halloween      = "Halloween"
    case animals        = "Animals"
    case faces          = "Faces"
    case foods          = "Foods"
    case sports         = "Sports"
    case nature         = "Nature"
    
    var backgroundColor: UIColor {
        switch self {
        case .halloween: return UIColor.black
        case .animals: return UIColor.blue
        case .faces: return UIColor.magenta
        case .foods: return UIColor.red
        case .sports: return UIColor.brown
        case .nature: return UIColor.yellow
        }
    }
    
    var emojiChoices: String {
        switch self {
        case .halloween: return "🎃👻😱🍭🍬🦇🍎😈🧟‍♀️👺☠️⚰️🥶🤡🙀🧛🏽‍♀️👽"
        case .animals: return "🐶🐬🦄🐥🐢🐼🐨🐯🦁🐮🦊🐵🦉🐠🦞🦜🕊"
        case .faces: return "😇🥰🥵😱🤢👿🤯🤮🤪😎🧐🥳😭😴🤠😑☺️"
        case .foods: return "🍔🌭🥗🥓🥑🍒🍎🌽🥒🍙🍻🍩🥘🍕🍌🍣🍦"
        case .sports: return "⚽️🏀⚾️🎾🥏🎱🏓🏸🏒🥌🛹🏊‍♀️🚴‍♀️🧘‍♂️🤺🎿🥊"
        case .nature: return "🌱🍂🌷🌸🌞🌛🌿🔥💨☔️🌊❄️🌻💐🌹🌾🌲"
        }
    }
    
    static var all = [
        Theme.halloween,
        .animals,
        .faces,
        .foods,
        .sports,
        .nature]
    
    static func getRandomTheme() -> Theme {
        return Theme.all[Theme.all.count.arc4random]
    }
}
