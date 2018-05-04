//
//  OTMenuHeaderView.swift
//  entourage
//
//  Created by Veronica on 24/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class OTMenuHeaderView: UIView {
    var profileBtn = UIButton()
    var imgAssociation = UIImageView()
    var editLabel = UILabel()
    var nameLabel = UILabel()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - Private Functions
    
    private func commonInit() {
        addSubview(profileBtn)
        addSubview(imgAssociation)
        addSubview(editLabel)
        addSubview(nameLabel)
        
        self.backgroundColor = .white
        profileBtn.snp.makeConstraints {
            
            $0.height.width.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(20)
        }
        
        imgAssociation.snp.makeConstraints {
            $0.height.width.equalTo(48)
            $0.trailing.equalTo(profileBtn.snp.trailing)
            $0.bottom.equalTo(profileBtn.snp.bottom)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
            $0.top.equalTo(profileBtn.snp.bottom)
        }
        
        editLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
}