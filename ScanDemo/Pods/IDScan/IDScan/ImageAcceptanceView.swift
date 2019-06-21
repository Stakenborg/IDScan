//
//  ImageAcceptanceView.swift
//  scantest
//
//  Created by Brandon Stakenborg on 6/13/19.
//  Copyright © 2019 Brandon Stakenborg. All rights reserved.
//

import UIKit

class ImageAcceptanceView: UIView {
    
    let acceptButton = UIButton(type: .system)
    let retryButton = UIButton(type: .system)
    
    init(image: UIImage) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        headerLabel.textAlignment = .center
        headerLabel.text = "Check Picture"
        
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = "Verify your document clear, easy to read,\nand with no glare"
        
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.layer.cornerRadius = 5.0
        acceptButton.backgroundColor = .sharpBlue
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.setTitle("Use This Picture", for: .normal)
        
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.layer.cornerRadius = 5.0
        retryButton.layer.borderWidth = 2.0
        retryButton.layer.borderColor = UIColor.sharpBlue.cgColor
        retryButton.setTitle("Retake Picture", for: .normal)
        
        addSubview(headerLabel)
        addSubview(imageView)
        addSubview(subtitleLabel)
        addSubview(acceptButton)
        addSubview(retryButton)
        
        headerLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -40).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: image.size.height/image.size.width).isActive = true
        let centerXConstraint = imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20)
        centerXConstraint.priority = .defaultLow
        centerXConstraint.isActive = true
        
        subtitleLabel.leftAnchor.constraint(equalTo: headerLabel.leftAnchor).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: headerLabel.rightAnchor).isActive = true
        
        acceptButton.leftAnchor.constraint(equalTo: headerLabel.leftAnchor).isActive = true
        acceptButton.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 20).isActive = true
        acceptButton.rightAnchor.constraint(equalTo: headerLabel.rightAnchor).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        retryButton.leftAnchor.constraint(equalTo: acceptButton.leftAnchor).isActive = true
        retryButton.topAnchor.constraint(equalTo: acceptButton.bottomAnchor, constant: 10).isActive = true
        retryButton.rightAnchor.constraint(equalTo: acceptButton.rightAnchor).isActive = true
        retryButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        retryButton.heightAnchor.constraint(equalTo: acceptButton.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
