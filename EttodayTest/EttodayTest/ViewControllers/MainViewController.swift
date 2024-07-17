//
//  MainViewController.swift
//  EttodayTest
//
//  Created by Hebe Mui on 2024/7/12.
//

import UIKit

class MainViewController: UIViewController {
    
    private let viewModel: MainViewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        viewModel.seatch(item: "jason")
    }


}

