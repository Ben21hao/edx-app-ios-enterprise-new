//
//  DownloadsAccessoryView.swift
//  edX
//
//  Created by Akiva Leffert on 9/24/15.
//  Copyright © 2015 edX. All rights reserved.
//

import UIKit


class DownloadsAccessoryView : UIView {
    
    enum State {
        case Available
        case Downloading
        case Done
    }
    
    private let downloadButton = UIButton(type: .System)
//    private let downloadSpinner = SpinnerView(size: .Medium, color: .Primary)
    private let downloadProgressView = TDCircleProgressView()
    private let iconFontSize : CGFloat = 15
    private let countLabel : UILabel = UILabel()
    private let videoSizeLabel = UILabel()
    
    override init(frame : CGRect) {
        state = .Available
        itemCount = nil
        
        super.init(frame: frame)
        
        downloadButton.tintColor = OEXStyles.sharedStyles().baseColor8()
        downloadButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
//        countLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        videoSizeLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
//        downloadSpinner.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        
        self.addSubview(downloadButton)
        self.addSubview(downloadProgressView)
//        self.addSubview(downloadSpinner)
        self.addSubview(countLabel)
        self.addSubview(videoSizeLabel)
        
        countLabel.font = UIFont.init(name: "OpenSans", size: 12)
        countLabel.textColor = OEXStyles.sharedStyles().baseColor8()
        
        self.videoSizeLabel.font = UIFont.init(name: "OpenSans", size: 8)
        self.videoSizeLabel.textColor = OEXStyles.sharedStyles().baseColor8()
        
        // This view is atomic from an accessibility point of view
        self.isAccessibilityElement = true
//        downloadSpinner.accessibilityTraits = UIAccessibilityTraitNotEnabled
        countLabel.accessibilityTraits = UIAccessibilityTraitNotEnabled
        videoSizeLabel.accessibilityTraits = UIAccessibilityTraitNotEnabled
        downloadButton.accessibilityTraits = UIAccessibilityTraitNotEnabled
        
//        downloadSpinner.stopAnimating()
//        
//        downloadSpinner.snp_makeConstraints {make in
//            make.center.equalTo(self)
//        }
        
        downloadButton.snp_makeConstraints {make in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(38)
        }
        
        countLabel.snp_makeConstraints {make in
            make.leading.equalTo(self)
            make.centerY.equalTo(self)
            make.trailing.equalTo(downloadButton.imageView!.snp_leading).offset(-6)
        }
        
        downloadProgressView.snp_makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.centerX.equalTo(self.downloadButton);
            make.size.equalTo(CGSizeMake(38, 38))
        }
        
        videoSizeLabel.snp_makeConstraints { (make) in
            make.top.equalTo(downloadButton.snp_bottom)
            make.centerX.equalTo(downloadButton.snp_centerX)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var downloadAction : (() -> Void)? = nil {
        didSet {
            downloadButton.oex_removeAllActions()
            downloadButton.oex_addAction({ _ in self.downloadAction?() }, forEvents: .TouchUpInside)
        }
    }
    
    var itemCount : Int? {
        didSet {
            let count = itemCount ?? 0
            let text = (count > 0 ? "\(count)" : "")
//            let styledText = CourseOutlineItemView.detailFontStyle.attributedStringWithText(text)
//            countLabel.attributedText = styledText
            countLabel.text = text
        }
    }
    
    var videoSize : Double? {
        didSet {
            let size = videoSize ?? 0
            if size == 0 {
                return
            }
            videoSizeLabel.text = String(format: "%.0fMB",(size / 1024) / 1024)
        }
    }
    
    
    var state : State {
        didSet {
            switch state {
            case .Available:
                downloadButton.setImage(UIImage.init(named: "no_download"), forState: .Normal)
//                downloadButton.tintColor = OEXStyles.sharedStyles().baseColor1()
                downloadButton.userInteractionEnabled = true
                downloadButton.hidden = false
                
                downloadProgressView.hidden = true
//                downloadSpinner.hidden = true
//                countLabel.hidden = false
                self.userInteractionEnabled = true
                
                
                if let count = itemCount {
                    let message = Strings.downloadManyVideos(videoCount: count)
                    self.accessibilityLabel = message
                } else {
                    self.accessibilityLabel = TDLocalizeSelectSwift("DOWNLOAD")
                }
                self.accessibilityTraits = UIAccessibilityTraitButton
                
            case .Downloading:
//                downloadSpinner.startAnimating()
//                downloadSpinner.hidden = false
                downloadProgressView.hidden = false
                
                downloadButton.userInteractionEnabled = true
                downloadButton.hidden = true
//                countLabel.hidden = true
                self.userInteractionEnabled = true
                
                
                self.accessibilityLabel = TDLocalizeSelectSwift("DOWNLOADING")
                self.accessibilityTraits = UIAccessibilityTraitButton
            case .Done:
                downloadButton.setImage(UIImage.init(named: "had_download"), forState: .Normal)
//                downloadButton.tintColor = OEXStyles.sharedStyles().neutralBase()
                downloadButton.hidden = false
                
                downloadProgressView.hidden = true
//                downloadSpinner.hidden = true
//                countLabel.hidden = false
                self.userInteractionEnabled = false
                
                if let count = itemCount {
                    let message = Strings.downloadManyVideos(videoCount: count)
                    self.accessibilityLabel = message
                }
                else {
                    self.accessibilityLabel = TDLocalizeSelectSwift("DOWNLOADED")
                }
                self.accessibilityTraits = UIAccessibilityTraitStaticText
            }
        }
    }
    
    var progress : Double? {
        didSet {
            let progressNum = progress ?? 0
            downloadProgressView.progress = progressNum
        }
    }
}
