//
//  TDUserCeterCell.swift
//  edX
//
//  Created by Elite Edu on 17/4/14.
//  Copyright © 2017年 edX. All rights reserved.
//

import UIKit

class TDUserCeterCell: UITableViewCell {
    
    let bgView = UIView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        configView()
        setViewConstraint()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        bgView.backgroundColor = OEXStyles.sharedStyles().baseColor5()
        self.contentView.addSubview(bgView)
        
        bgView.addSubview(iconImageView)
        
        titleLabel.textColor = OEXStyles.sharedStyles().baseColor10()
        titleLabel.font = UIFont.init(name: "OpenSans", size: 14)
        bgView.addSubview(titleLabel)
        
        messageLabel.textColor = OEXStyles.sharedStyles().baseColor8()
        messageLabel.font = UIFont.init(name: "OpenSans", size: 12)
        bgView.addSubview(messageLabel)
    }
    
    func setViewConstraint() {
        bgView.snp_makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.contentView)
        }
        
        iconImageView.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(18)
            make.centerY.equalTo(bgView)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(75)
            make.bottom.equalTo(bgView.snp_centerY).offset(-3)
        }
        
        messageLabel.snp_makeConstraints { (make) in
            make.left.equalTo(bgView.snp_left).offset(75)
            make.top.equalTo(bgView.snp_centerY).offset(3)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
