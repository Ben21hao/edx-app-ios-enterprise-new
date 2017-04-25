//
//  CourseDashboardCell.swift
//  edX
//
//  Created by Jianfeng Qiu on 13/05/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

class CourseDashboardCell: UITableViewCell {

    static let identifier = "CourseDashboardCellIdentifier"
    
    //TODO: all these should be adjusted once the final UI is ready
    private let ICON_SIZE : CGFloat = OEXTextStyle.pointSizeForTextSize(OEXTextSize.XXXLarge)
    private let ICON_MARGIN : CGFloat = 18.0
    private let LABEL_MARGIN : CGFloat = 68.0
    private let LABEL_SIZE_HEIGHT = 20.0
    private let CONTAINER_SIZE_HEIGHT = 60.0
    private let CONTAINER_MARGIN_BOTTOM = 15.0
    private let INDICATOR_SIZE_WIDTH = 10.0
    
    private let container = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let bottomLine = UIView()
    
    private var titleTextStyle : OEXTextStyle {
        return OEXTextStyle(weight : .Normal, size: .Base, color : OEXStyles.sharedStyles().neutralXDark())
    }
    private var detailTextStyle : OEXTextStyle {
        return OEXTextStyle(weight : .Normal, size: .XXSmall, color : OEXStyles.sharedStyles().neutralBase())
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViews()
    }

    func useItem(item : StandardCourseDashboardItem) {
        self.titleLabel.attributedText = titleTextStyle.attributedStringWithText(item.title)
        self.titleLabel.font = UIFont.systemFontOfSize(16);
        self.detailLabel.attributedText = detailTextStyle.attributedStringWithText(item.detail)
        self.detailLabel.font = UIFont.systemFontOfSize(14);
        self.iconView.image = item.icon.imageWithFontSize(ICON_SIZE)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        self.bottomLine.backgroundColor = OEXStyles.sharedStyles().neutralXLight()
        
        applyStandardSeparatorInsets()
        
        self.container.addSubview(iconView)
        self.container.addSubview(titleLabel)
        self.container.addSubview(detailLabel)
        
        self.contentView.addSubview(container)
        
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        iconView.tintColor = OEXStyles.sharedStyles().neutralLight()
        
        container.snp_makeConstraints { make -> Void in
            make.edges.equalTo(contentView)
        }
        
        iconView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(container).offset(ICON_MARGIN)
            make.centerY.equalTo(container)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(container).offset(LABEL_MARGIN)
            make.trailing.lessThanOrEqualTo(container)
            make.top.equalTo(container).offset(LABEL_SIZE_HEIGHT)
            make.height.equalTo(LABEL_SIZE_HEIGHT)
        }
        detailLabel.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(container)
            make.top.equalTo(titleLabel.snp_bottom)
            make.height.equalTo(LABEL_SIZE_HEIGHT)
        }
    }
}
