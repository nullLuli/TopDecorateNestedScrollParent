//
//  HomeSegmentController.swift
//  TopDecorateNestedScrollParentDemo
//
//  Created by PXCM-0101-01-0045 on 2020/2/23.
//  Copyright © 2020 nullLuli. All rights reserved.
//

import Foundation
import UIKit
import FlexPageView

class HomeSegmentController: UIViewController, FlexPageViewDataSource, FlexPageViewUISource, FlexPageViewDelegate {
    var segmentView: FlexPageView? = {
        var option = FlexPageViewOption()
        option.titleMargin = 30
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.3
        option.preloadRange = 1
        option.underlineColor = UIColor(rgb: 0x4285F4)
        option.selectedColor = UIColor(rgb: 0x262626)
        option.titleColor = UIColor(rgb: 0x999CA0)
        option.extraImage = UIImage(named: "ic_nav_menu")
        option.extraImageSize = CGSize(width: 50, height: 40)
        option.extraMaskImage = UIImage(named: "Rectangle")
        option.extraMaskImageSize = CGSize(width: 50, height: 40)
        let pageView = FlexPageView(option: option, layout: MenuViewLayout(option: option))
        return pageView
    }()
        
    let titles: [String] = ["关注", "推荐", "热榜", "一个长的标签", "短", "汽车", "5G", "科技", "生活"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge.right
        
        segmentView?.delegate = self
        segmentView?.dataSource = self
        segmentView?.uiSource = self
        if let segmentView = segmentView {
            view.addSubview(segmentView)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        segmentView?.frame = view.bounds
    }
    
    // MARK: FlexPageView
    func numberOfPage() -> Int {
        return titles.count
    }
    
    func titleDatas() -> [IMenuViewCellData] {
        return titles.map { (title) -> MenuViewCellData in
            return MenuViewCellData(title: title)
        }
    }
    
    func page(at index: Int) -> UIView {
        let control = ContentController()
        control.title = titles[index]
        addChild(control)
        control.didMove(toParent: self)
        return control.view
    }
    
    func pageID(at index: Int) -> String {
        return String(index)
    }
    
    func register() -> [String : UICollectionViewCell.Type] {
        return [MenuViewCell.identifier : MenuViewCell.self]
    }
    
    func extraViewAction() {
        let label = UILabel()
        label.text = "extraViewAction"
        view.addSubview(label)
        label.sizeToFit()
        label.center = view.center
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            label.removeFromSuperview()
        }
    }
    
    func selectItemFromTapMenuView(select index: Int) {
    }

    func didRemovePage(_ page: UIView, at index: Int) {
        for control in children {
            if control.view == page {
                control.removeFromParent()
            }
        }
    }
    
    func pageWillAppear(_ page: UIView, at index: Int) {
        debugPrint("pageWillAppear \(index)")
    }
    
    func pageWillDisappear(_ page: UIView, at index: Int) {
        debugPrint("pageWillDisappear \(index)")
    }
    
}
