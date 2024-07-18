//
//  MainViewModel.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/16.
//

import Foundation
import Combine

class MainViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var results: [Track] = []
    @Published var searchText = ""
    
    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [weak self] text -> AnyPublisher<SearchResult, Error> in
                guard !text.isEmpty else { return
                    Just(SearchResult(resultCount: self?.results.count ?? 0, results: self?.results ?? [])).setFailureType(to: Error.self).eraseToAnyPublisher() }
                return self?.fetch(item: text) ?? Empty().eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Search completed successfully")
                    case .failure(let error):
                        print("Search failed with error: \(error)")
                    }
                },
                receiveValue: { [weak self] searchResult in
                    self?.results = searchResult.results
                }
            )
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
