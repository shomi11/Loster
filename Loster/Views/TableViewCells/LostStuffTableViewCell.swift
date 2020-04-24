//
//  LostStuffTableViewCell.swift
//  Loster
//
//  Created by Malovic, Milos on 4/21/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import UIKit

class LostStuffTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: RadiusShadowView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var stuffImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        stuffImageView.layer.cornerRadius = 8
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
