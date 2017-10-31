//
//  CourseVideoTableViewCell.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 12/05/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit


protocol CourseVideoTableViewCellDelegate : class {
    func videoCellChoseDownload(cell : CourseVideoTableViewCell, block : CourseBlock)
    func videoCellChoseShowDownloads(cell : CourseVideoTableViewCell)
    func videoCellCancelDownloadVideo(cell: CourseVideoTableViewCell, video : OEXHelperVideoDownload)
}

private let titleLabelCenterYOffset = -12

class CourseVideoTableViewCell: UITableViewCell, CourseBlockContainerCell {
    
    static let identifier = "CourseVideoTableViewCellIdentifier"
    weak var delegate : CourseVideoTableViewCellDelegate?
    
    private let content = CourseOutlineItemView()
    private let downloadView = DownloadsAccessoryView()
    
    var block : CourseBlock? = nil {
        didSet {
            content.setTitleText(block?.displayName)
        }
    }
        
    var localState : OEXHelperVideoDownload? {
        didSet {
            updateDownloadViewForVideoState()
            updateDownLoadProgress()
            
            if localState?.summary?.duration != nil {
                content.setDetailText(OEXDateFormatting.formatSecondsAsVideoLength(Double((localState?.summary?.duration)!) ?? 0))
            }
            
            if localState?.summary?.size != nil {
                downloadView.videoSize = localState?.summary?.size?.doubleValue
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(content)
        content.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(contentView)
        }
        content.setContentIcon(Icon.CourseVideoContent)
        
        downloadView.downloadAction = {[weak self] _ in
            if let owner = self, block = owner.block {
                owner.delegate?.videoCellChoseDownload(owner, block : block)
            }
        }
        
        for notification in [OEXDownloadProgressChangedNotification, OEXDownloadEndedNotification, OEXVideoStateChangedNotification] {
            
            NSNotificationCenter.defaultCenter().oex_addObserver(self, name: notification) { (_, observer, _) -> Void in
                observer.updateDownloadViewForVideoState() //更新下载状态
                
                if notification == OEXDownloadProgressChangedNotification {
                    observer.updateDownLoadProgress() //更新下载进度
                }
            }
        }
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addAction {[weak self]_ in
            if let owner = self where owner.downloadState == .Downloading {
//                owner.delegate?.videoCellChoseShowDownloads(owner) //跳转总的下载进度页面
                owner.delegate?.videoCellCancelDownloadVideo(owner, video: owner.localState!) //取消下载
            }
        }
        downloadView.addGestureRecognizer(tapGesture)
        
        content.trailingView = downloadView
        
        downloadView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        
        let fromDetailView = NSUserDefaults.standardUserDefaults().valueForKey("Come_From_Course_Detail")
        if fromDetailView != nil {
            downloadView.hidden = true
        } else {
            downloadView.hidden = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var downloadState : DownloadsAccessoryView.State {
        switch localState?.downloadProgress ?? 0 {
        case 0:
            return .Available
        case OEXMaxDownloadProgress:
            return .Done
        default:
            return .Downloading
        }
    }
    
    private func updateDownloadViewForVideoState() {
        switch localState?.watchedState ?? .Unwatched {
        case .Unwatched, .PartiallyWatched:
            content.leadingIconColor = OEXStyles.sharedStyles().primaryBaseColor()
        case .Watched:
            content.leadingIconColor = OEXStyles.sharedStyles().neutralDark()
        }
        
        guard !(self.localState?.summary?.onlyOnWeb ?? false) else {
            content.trailingView = nil
            return
        }
        
        if self.localState?.summary?.videoID == nil {
            content.trailingView = nil
            return
        }
        
        content.trailingView = downloadView
        downloadView.state = downloadState
    }
    
    func updateDownLoadProgress() { //更新章节的下载进度
//        print("视频进度 ------->>> \(localState?.downloadProgress)")
        self.downloadView.progress = localState?.downloadProgress
    }
}
