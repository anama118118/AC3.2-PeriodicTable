//
//  ElementView.swift
//  PeriodicTable
//
//  Created by Ana Ma on 12/21/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class ElementView: UIView {
    @IBOutlet weak var atomicNumberLabel: UILabel!
    
    @IBOutlet weak var symbolLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //this class is going to own this file, the object will be the view
        if let view = Bundle.main.loadNibNamed("ElementView", owner: self, options: nil)?.first as? UIView {
            self.addSubview(view)
            view.frame = self.bounds
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
