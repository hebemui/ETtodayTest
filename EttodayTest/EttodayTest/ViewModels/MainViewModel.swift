//
//  MainViewModel.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/16.
//

import Foundation
import Combine

class MainViewModel {
    
    var cancellables = Set<AnyCancellable>()
    @Published var results: [Track] = []
    
    func seatch(item: String) {
        fetch(item: item)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished successfully")
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            }, receiveValue: { searchResult in
                self.results.append(contentsOf: searchResult.results)
            })
            .store(in: &cancellables)
    }
    
    private func fetch(item: String) -> AnyPublisher<SearchResult, Error> {
        let urlString = "https://itunes.apple.com/search?term=\(item)"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResult.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
