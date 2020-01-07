//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Hansol Jang on 2019/12/16.
//  Copyright © 2019 HansolJang. All rights reserved.
//

import Foundation

// Codable 를 상속하여 Model -> Json File 한 후 UIDocument 에 저장
struct EmojiArt: Codable {
    
    var url: URL?
    var image: Data?
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo: Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    // json -> instance
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    // instance -> json
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
    
    init(imageData: Data, emojis: [EmojiInfo]) {
        self.image = imageData
        self.emojis = emojis
    }
    
}
