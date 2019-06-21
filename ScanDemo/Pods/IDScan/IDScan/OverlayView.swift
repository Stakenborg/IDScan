//
//  OverlayView.swift
//  scantest
//
//  Created by Brandon Stakenborg on 6/17/19.
//  Copyright © 2019 Brandon Stakenborg. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    let backButton = UIButton(type: .system)
    private let fadedBackground = UIView()
    private let instructionsLabel = UILabel()
    private let cornersView = CornersView()
    let captureButton = UIButton(type: .system)
    private var captureButtonFadeTimer: Timer?
    private var cornersViewHeightConstraint: NSLayoutConstraint?
    var scanType: ScanType {
        didSet {
            guard scanType != oldValue else { return }
            instructionsLabel.text = scanType.instructions
            setupCornerViewHeightConstraint()
        }
    }

    init(scanType: ScanType) {
        self.scanType = scanType
        super.init(frame: .zero)
        
        fadedBackground.translatesAutoresizingMaskIntoConstraints = false
        fadedBackground.backgroundColor = .black
        fadedBackground.alpha = 0.7
        
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.textColor = .white
        instructionsLabel.textAlignment = .center
        instructionsLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        instructionsLabel.text = scanType.instructions
        
        let darkBackgroundLabel = UILabel()
        darkBackgroundLabel.translatesAutoresizingMaskIntoConstraints = false
        darkBackgroundLabel.textColor = .white
        darkBackgroundLabel.textAlignment = .center
        darkBackgroundLabel.numberOfLines = 2
        darkBackgroundLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        darkBackgroundLabel.text = "Use a dark background\nfor best results"
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = .white
        backButton.setImage(UIImage(named: "back-arrow", in: Bundle(for: OverlayView.self), compatibleWith: nil), for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        cornersView.translatesAutoresizingMaskIntoConstraints = false
        cornersView.backgroundColor = .clear
        
        let overlayLabel = UILabel()
        overlayLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayLabel.textColor = .white
        overlayLabel.textAlignment = .center
        overlayLabel.numberOfLines = 2
        overlayLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        overlayLabel.text = "Text should face\nthis way"
        overlayLabel.transform = CGAffineTransform(rotationAngle: .pi/2)
        overlayLabel.alpha = 0.75
        
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.tintColor = .white
        captureButton.setImage(UIImage(named: "camera-icon", in: Bundle(for: OverlayView.self), compatibleWith: nil), for: .normal)
        
        addSubview(fadedBackground)
        addSubview(backButton)
        addSubview(cornersView)
        addSubview(instructionsLabel)
        addSubview(overlayLabel)
        addSubview(darkBackgroundLabel)
        addSubview(captureButton)
        
        fadedBackground.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        fadedBackground.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        fadedBackground.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        fadedBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        instructionsLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        instructionsLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        darkBackgroundLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        darkBackgroundLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        darkBackgroundLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 10).isActive = true
        darkBackgroundLabel.bottomAnchor.constraint(equalTo: cornersView.topAnchor, constant: -10).isActive = true
        cornersView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        cornersView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cornersView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        overlayLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        overlayLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        captureButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            captureButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        } else {
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
            captureButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        }
        
        setupCornerViewHeightConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = CGMutablePath()
        path.addRect(fadedBackground.bounds)
        path.addRect(fadedBackground.convert(cornersView.bounds, from: cornersView))
        
        let mask = CAShapeLayer()
        mask.path = path
        mask.fillRule = .evenOdd
        
        fadedBackground.layer.mask = mask
    }
    
    private func setupCornerViewHeightConstraint() {
        if let cornersViewHeightConstraint = cornersViewHeightConstraint {
            removeConstraint(cornersViewHeightConstraint)
        }
        
        cornersViewHeightConstraint = cornersView.heightAnchor.constraint(equalTo: cornersView.widthAnchor, multiplier: scanType.docHeightRatio)
        addConstraint(cornersViewHeightConstraint!)
    }
    
    func fadeInCaptureButton() {
        captureButtonFadeTimer?.invalidate()
        captureButton.alpha = 0.0
        captureButtonFadeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.captureButton.alpha = 1.0
            })
        }
    }
}
