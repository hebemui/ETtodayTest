//
//  Track.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/17.
//

import Foundation

struct Track: Codable {
    let trackName: String?
    let trackTimeMillis: Int?
    let longDescription: String?
    let artworkUrl100: URL?
}
