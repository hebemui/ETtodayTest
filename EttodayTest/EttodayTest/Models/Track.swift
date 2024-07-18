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
    let previewUrl: URL?
    
    func getTimeString() -> String {
        guard let trackTimeMillis else { return "" }
        let seconds = trackTimeMillis / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
