//
//  YTSearchResponse.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 25.06.2025.
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}


struct VideoElement: Codable {
    let id: IdVideoElement
}


struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
