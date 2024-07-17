//
//  SearchResult.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/17.
//

import Foundation

struct SearchResult: Codable {
    let resultCount: Int
    let results: [Track]
}
