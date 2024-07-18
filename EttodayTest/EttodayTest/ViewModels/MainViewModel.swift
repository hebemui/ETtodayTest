//
//  MainViewModel.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/16.
//

import UIKit
import Combine
import AVFoundation

enum Status {
    case play
    case pause
    case idle
    
    var image: UIImage? {
        switch self {
        case .play:
            UIImage(systemName: "pause.fill")
        case .pause:
            UIImage(systemName: "play.fill")
        case .idle:
            nil
        }
    }
    
    var next: Status {
        switch self {
        case .play:
            return .pause
        case .pause:
            return .play
        case .idle:
            return .play
        }
    }
}

class MainViewModel {
    
    var currentTrack: Track? {
        didSet {
            handlePlayer(oldValue)
        }
    }
    var currentTrackIndexPath: IndexPath?
    var currentPlayerStatus: Status = .idle
    @Published var results: [Track] = []
    @Published var searchText = ""
    private var cancellables = Set<AnyCancellable>()
    
    private var audioPlayer: AVAudioPlayer?
    
    private func handlePlayer(_ oldTrack: Track?) {
        
        if currentTrack?.previewUrl == oldTrack?.previewUrl {
            currentPlayerStatus = currentPlayerStatus.next
            if currentPlayerStatus == .play {
                audioPlayer?.play()
            } else if currentPlayerStatus == .pause {
                audioPlayer?.pause()
            }
        } else if let url = currentTrack?.previewUrl {
            audioPlayer?.stop()
            currentPlayerStatus = .play
            downloadAndPlayAudio(from: url)
        }
    }
    
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
    
    private func downloadAndPlayAudio(from url: URL) {
            let task = URLSession.shared.downloadTask(with: url) { (localURL, response, error) in
                if let localURL = localURL {
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                        self.audioPlayer?.prepareToPlay()
                        self.audioPlayer?.play()
                    } catch {
                        print("Error playing audio: \(error.localizedDescription)")
                    }
                } else {
                    if let error = error {
                        print("Error downloading audio: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
    
    func getTrackStatus(_ track: Track) -> Status {
        if track.previewUrl == currentTrack?.previewUrl {
            return currentPlayerStatus
        } else {
            return .idle
        }
    }
}
