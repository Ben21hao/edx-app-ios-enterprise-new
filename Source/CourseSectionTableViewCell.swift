//
//  CourseSectionTableViewCell.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 04/06/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

protocol CourseSectionTableViewCellDelegate : class {
    func sectionCellChoseDownload(cell : CourseSectionTableViewCell, videos : [OEXHelperVideoDownload], forBlock block : CourseBlock)
    func sectionCellChoseShowDownloads(cell : CourseSectionTableViewCell)
    func sectionCellCancelDownloadVideo(cell: CourseSectionTableViewCell, videos : [OEXHelperVideoDownload]?)
}

class CourseSectionTableViewCell: UITableViewCell, CourseBlockContainerCell {
    
    static let identifier = "CourseSectionTableViewCellIdentifier"
    
    private let content = CourseOutlineItemView()
    private let downloadView = DownloadsAccessoryView()//下载按钮
    
    weak var delegate : CourseSectionTableViewCellDelegate?
    
    private let videosStream = BackedStream<[OEXHelperVideoDownload]>()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(content)
        content.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(contentView)
        }
        
        downloadView.downloadAction = {[weak self] _ in//点击下载
            if let owner = self, block = owner.block, videos = self?.videosStream.value {
                owner.delegate?.sectionCellChoseDownload(owner, videos: videos, forBlock: block)
            }
        }
        
        videosStream.listen(self) {[weak self] downloads in //数据
            
            if let downloads = downloads.value, state = self?.downloadStateForDownloads(downloads) {
                
                self?.downloadView.state = state
                
                self?.content.trailingView = self?.downloadView
                self?.downloadView.itemCount = downloads.count
                
                let size = downloads.reduce(0) { totals,video in
                    
                    return totals + (video.summary?.size == nil ? 0.0 : video.summary?.size?.doubleValue)!
                }
                self?.downloadView.videoSize = size
            
            } else {
                self?.content.trailingView = nil
            }
            
            self?.updateDownLoadProgress(self?.videosStream.value)
        }
        
        for notification in [OEXDownloadProgressChangedNotification, OEXDownloadEndedNotification, OEXVideoStateChangedNotification] {
            
            NSNotificationCenter.defaultCenter().oex_addObserver(self, name: notification) { (_, observer, _) -> Void in
                
                if let state = observer.downloadStateForDownloads(observer.videosStream.value) { //更新章节下载状态
                    
                    observer.downloadView.state = state
                    observer.updateDownLoadProgress(observer.videosStream.value) //更新章节几个视频的下载进度
                    
                } else {
                    observer.content.trailingView = nil
                }
            }
        }
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addAction {[weak self]_ in
            if let owner = self where owner.downloadView.state == .Downloading {
//                owner.delegate?.sectionCellChoseShowDownloads(owner) //跳转到下载进度页面
                owner.delegate?.sectionCellCancelDownloadVideo(owner, videos: owner.videosStream.value) //取消章节几个视频的下载
            }
        }
        downloadView.addGestureRecognizer(tapGesture)
        
        let fromDetailView = NSUserDefaults.standardUserDefaults().valueForKey("Come_From_Course_Detail")
        if fromDetailView != nil {
            downloadView.hidden = true
        } else {
            downloadView.hidden = false
        }
    }
    
    var videos : Stream<[OEXHelperVideoDownload]> = Stream() {
        didSet {
            videosStream.backWithStream(videos)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videosStream.backWithStream(Stream(value:[]))
    }
    
    func updateDownLoadProgress(videos : [OEXHelperVideoDownload]?) { //更新章节的下载进度
        if let videos = videos where videos.count > 0  {
            
            let allProgress = videos.reduce(0) { totals,video in
                return totals + video.downloadProgress
            }
//            print("章节进度 ------->>> \(allProgress) ------>> \(videos.count)")
            self.downloadView.progress = allProgress / Double(videos.count)
        }
        
    }
    
    func downloadStateForDownloads(videos : [OEXHelperVideoDownload]?) -> DownloadsAccessoryView.State? {
        
        if let videos = videos where videos.count > 0 {
            
            var isDownding = false
            let allDownloading = videos.reduce(true) {(acc, video) in
                if video.isVideoDownloading == true {
                    isDownding = true
                }
                return acc && video.downloadState == .Partial
            }
            
            let allCompleted = videos.reduce(true) {(acc, video) in
                return acc && video.downloadState == .Complete
            }
            
            if allDownloading || isDownding {
                return .Downloading //正在下载
            } else if allCompleted {
                return .Done //已下载
            } else {
                return .Available
            }
        } else {
            return nil
        }
    }
    
    var block : CourseBlock? = nil {
        didSet {
            content.setTitleText(block?.displayName)
            content.isGraded = block?.graded
            content.setDetailText(block?.format ?? "")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
