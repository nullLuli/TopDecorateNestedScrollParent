//
//  HomeViewController.swift
//  TopDecorateNestedScrollParentDemo
//
//  Created by PXCM-0101-01-0045 on 2020/2/23.
//  Copyright © 2020 nullLuli. All rights reserved.
//

import Foundation
import UIKit
import FlexPageView

class HomeViewController: UIViewController {
    private var scrollView: HomeScrollView = HomeScrollView()
    private var topDecorateView: UISearchBar = UISearchBar()
    private var segmentView: UIView?
    private var segmentControl: HomeSegmentController?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        segmentControl = HomeSegmentController()
        segmentView = segmentControl?.view
        if let segmentControl = segmentControl {
            addChild(segmentControl)
            segmentControl.didMove(toParent: self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(scrollView)
        scrollView.addSubview(topDecorateView)
        if let segmentView = segmentView {
            scrollView.addSubview(segmentView)
        }
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = CGRect(x: 0, y: UIScreen.statusBarHeight, width: view.bounds.width, height: view.bounds.height)
        topDecorateView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75)
        segmentView?.frame = CGRect(x: 0, y: 75, width: view.bounds.width, height: view.bounds.height)
        scrollView.contentSize = CGSize(width: 0, height: view.bounds.height + 75)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

public extension UIDevice {
    
    enum DeviceKind: String {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case iPhoneX
        case iPad
        case Unknown
    }
    
    var kind: DeviceKind {
        guard userInterfaceIdiom == .phone else {
            return .iPad
        }
        
        let result: DeviceKind
        switch UIScreen.main.nativeBounds.height {
        case 960:
            result = .iPhone4
        case 1136:
            result = .iPhone5
        case 1334:
            result = .iPhone6
        case 2208:
            result = .iPhone6Plus
        case 2436,
             1792,
             2688:
            result = .iPhoneX
            
        default:
            result = .Unknown
        }
        
        return result
    }
}

extension UIScreen {
    static var statusBarHeight: CGFloat {
        switch UIDevice.current.kind {
        case .iPhoneX:
            return 44
        default:
            return 20
        }
    }
}
