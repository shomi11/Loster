//
//  ConfirmationBtn.swift
//  Loster
//
//  Created by Malovic, Milos on 4/22/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import Foundation
import UIKit

class ConfirmationButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tintColor = .white
        self.layer.shadowRadius = 8.0;
        self.layer.shadowColor = UIColor.systemIndigo.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 8.0)
        self.layer.shadowOpacity = 0.6;
        self.layer.masksToBounds = false
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.systemBackground.cgColor
        self.layer.cornerRadius = self.frame.height / 2 - 5
        self.backgroundColor = .systemIndigo
      
    }
}
