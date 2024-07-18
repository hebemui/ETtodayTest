//
//  MainViewController.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/12.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    // MARK: - Properties
    // UI
    private let textField = UITextField()
    private let searchButton = UIButton()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // Data
    private let viewModel: MainViewModel = MainViewModel()
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureViews()
        
        viewModel.$results
            .receive(on: RunLoop.main) // 确保在主线程上更新 UI
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "jason mars"
    }

    // MARK: - Configuration
    private func configureViews() {
        view.backgroundColor = .white
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textField)
        view.addSubview(searchButton)
        view.addSubview(collectionView)
        
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        textField.leadingAnchor.constraint(equalTo: textField.superview!.leadingAnchor, constant: 12).isActive = true
        textField.trailingAnchor.constraint(equalTo: textField.superview!.trailingAnchor, constant: -12).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        searchButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 12).isActive = true
        searchButton.leadingAnchor.constraint(equalTo: searchButton.superview!.leadingAnchor, constant: 12).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: searchButton.superview!.trailingAnchor, constant: -12).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 12).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: collectionView.superview!.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: collectionView.superview!.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: collectionView.superview!.bottomAnchor).isActive = true
        
        textField.placeholder = "Enter keyword here"
        textField.layer.cornerRadius = 6
        textField.layer.masksToBounds = true
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        searchButton.setTitle("Search", for: .normal)
        searchButton.backgroundColor = .black
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = 8
        searchButton.layer.masksToBounds = true
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackCell.self, forCellWithReuseIdentifier: "TrackCell")
    }
    
    // MARK: - Events
    @objc private func searchButtonTapped() {
        guard let text = textField.text else { return }
        viewModel.searchText = text
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.searchText = text
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as? TrackCell else {
            return UICollectionViewCell()
        }
        let result = viewModel.results[indexPath.item]
        let trackStatus = viewModel.getTrackStatus(result)
        cell.status = trackStatus
        cell.updateCell(result)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let track = viewModel.results[indexPath.item]
        let oldTrackIndexPath = viewModel.currentTrackIndexPath
        viewModel.currentTrackIndexPath = indexPath
        viewModel.currentTrack = track
        collectionView.reloadItems(at: [indexPath])
        if let oldIndexPath = oldTrackIndexPath {
            collectionView.reloadItems(at: [oldIndexPath])
        }
    }
}
