//
//  ViewController.swift
//  scantest
//
//  Created by Brandon Stakenborg on 6/21/19.
//  Copyright © 2019 Brandon Stakenborg. All rights reserved.
//

import UIKit
import IDScan

class ViewController: UIViewController, ScanDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start Scanner", for: .normal)
        button.addTarget(self, action: #selector(startScanner), for: .touchUpInside)
        
        view.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func startScanner() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self
        present(scanViewController, animated: true, completion: nil)
    }
    
    func scanSucceeded(onScanViewController scanViewController: ScanViewController, scanResult: ScanResult) {
        dismiss(animated: true, completion: nil)
        print("Success")
    }
    
    func scanCancelled(onScanViewController scanViewController: ScanViewController) {
        dismiss(animated: true, completion: nil)
        print("Cancel")
    }
}
