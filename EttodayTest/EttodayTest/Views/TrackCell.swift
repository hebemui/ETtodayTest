//
//  TrackCell.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/17.
//

import UIKit
import Combine

class TrackCell: UICollectionViewCell {
    
    // MARK: - Properties
    // UI
    private let artworkImageView = UIImageView()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let descriptoinLabel = UILabel()
    private let statusImageView = UIImageView()
    
    // Data
    private var cancellable: AnyCancellable?
    private var loader = ImageLoader()
    var status: Status = .play {
        didSet {
            statusImageView.image = status.image
        }
    }
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    // MARK: - Configuration
    private func configureViews() {
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptoinLabel.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(artworkImageView)
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(descriptoinLabel)
        addSubview(statusImageView)
        
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        artworkImageView.leadingAnchor.constraint(equalTo: artworkImageView.superview!.leadingAnchor, constant: 10).isActive = true
        artworkImageView.topAnchor.constraint(greaterThanOrEqualTo: artworkImageView.superview!.topAnchor, constant: 35).isActive = true
        artworkImageView.bottomAnchor.constraint(lessThanOrEqualTo: artworkImageView.superview!.bottomAnchor, constant: -35).isActive = true
        artworkImageView.centerYAnchor.constraint(equalTo: artworkImageView.superview!.centerYAnchor).isActive = true
        artworkImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        artworkImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 18).isActive = true
        nameLabel.topAnchor.constraint(equalTo: nameLabel.superview!.topAnchor, constant: 22).isActive = true
        
        timeLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: timeLabel.superview!.trailingAnchor, constant: -10).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        descriptoinLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        descriptoinLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 18).isActive = true
        descriptoinLabel.trailingAnchor.constraint(equalTo: descriptoinLabel.superview!.trailingAnchor, constant: -10).isActive = true
        descriptoinLabel.bottomAnchor.constraint(equalTo: descriptoinLabel.superview!.bottomAnchor, constant: -10).isActive = true
        
        statusImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        statusImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        statusImageView.centerXAnchor.constraint(equalTo: artworkImageView.centerXAnchor).isActive = true
        statusImageView.bottomAnchor.constraint(equalTo: artworkImageView.topAnchor, constant: -10).isActive = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        nameLabel.numberOfLines = 2
        nameLabel.textColor = .black
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        timeLabel.numberOfLines = 1
        timeLabel.textColor = .black.withAlphaComponent(0.5)
        
        descriptoinLabel.font = UIFont.systemFont(ofSize: 12)
        descriptoinLabel.numberOfLines = 0
        descriptoinLabel.textColor = .black.withAlphaComponent(0.5)
    }
    
    func updateCell(_ track: Track) {
        nameLabel.text = track.trackName
        timeLabel.text = track.getTimeString()
        descriptoinLabel.text = track.longDescription == nil ? " " : track.longDescription
        if let url = track.artworkUrl100 {
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        cancellable = loader.$image
            .sink { [weak self] image in
                self?.artworkImageView.image = image
            }
        loader.loadImage(from: url)
    }
}


class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?

    func loadImage(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

    deinit {
        cancellable?.cancel()
    }
}
