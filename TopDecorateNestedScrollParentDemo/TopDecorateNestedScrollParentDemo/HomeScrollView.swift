//
//  HomeScrollView.swift
//  Client
//
//  Created by nullLuli on 2020/2/19.
//  Copyright © 2020 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class HomeScrollView: UIScrollView, UIGestureRecognizerDelegate {
    static var kHomeScrollViewKVOContext = 0

    private var observedViews: [UIScrollView] = []
    private var _isObserving: Bool = false
    private var _isParentScroll: Bool = true
    
    override weak var delegate: UIScrollViewDelegate? {
        didSet {
            if !(delegate is HomeScrollViewDelegateDecorator) {
                self.forward?.delegate = delegate
                delegate = self.forward
            }
        }
    }
    
    private var forward: HomeScrollViewDelegateDecorator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        forward = HomeScrollViewDelegateDecorator()
        delegate = forward
        
        addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: contentOffset)), options: [.old, .new], context: &HomeScrollView.kHomeScrollViewKVOContext)
        _isObserving = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 滑动逻辑
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollView = otherGestureRecognizer.view as? UIScrollView else {
            return false
        }

        guard scrollView != self else {
            return false
        }
        
        // Tricky case: UITableViewWrapperView
        guard !(scrollView.superview is UITableView) else {
            return false
        }
                
        guard gestureRecognizer is UIPanGestureRecognizer else {return false}
        guard otherGestureRecognizer is UIPanGestureRecognizer else {return false}
        
        // Lock horizontal pan gesture.
        if let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self) {
            if abs(velocity.x) > abs(velocity.y) {
                return false
            }
        }

        if !observedViews.contains(scrollView) {
            observedViews.append(scrollView)
            scrollView.addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: contentOffset)), options: [.old, .new], context: &HomeScrollView.kHomeScrollViewKVOContext)
        }
                
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let newOffSet = change?[NSKeyValueChangeKey.newKey] as? CGPoint, let oldOffSet = change?[NSKeyValueChangeKey.oldKey] as? CGPoint else {
            return
        }
        
        let direct: CGFloat = newOffSet.y - oldOffSet.y

        guard direct != 0 else {return}
        
        if !_isObserving {
            return
        }
        
        //滑动逻辑控制，滑动时，父滑动先滑，父滑动滑动的时候禁止子滑动滑动，父滑动结束后，子滑动进行滑动
        if direct > 0 {
            //上滑
            if (object as? HomeScrollView) == self {
                _isParentScroll = true
                if newOffSet.y + self.frame.height >= contentSize.height {
                    //                print("parent scoll finish")
                    setContentOffset(offset: CGPoint(x: self.contentOffset.x, y: contentSize.height - self.frame.height), to: self)
                    _isParentScroll =  false
                }
            } else if let scrollView = object as? UIScrollView {
                if _isParentScroll {
                    //                print("child scoll disable")
                    setContentOffset(offset: oldOffSet, to: scrollView)
                } else {
                    //                print("child scolling")
                }
            }
        } else if direct < 0 {
            //下滑
            if (object as? HomeScrollView) == self {
                _isParentScroll = true
                if newOffSet.y <= -contentInset.top {
                    setContentOffset(offset: CGPoint(x: self.contentOffset.x, y: -contentInset.top), to: self)
                    _isParentScroll = false
                }
            } else if let scrollView = object as? UIScrollView {
                if _isParentScroll {
                    //                print("parent scoll finish")
                    setContentOffset(offset: oldOffSet, to: scrollView)
                }
            }
        }

    }
    
    private func setContentOffset(offset: CGPoint, to scrollView: UIScrollView) {
        _isObserving = false
        scrollView.contentOffset = offset
        _isObserving = true
    }
    
    private func removeObserverViews() {
        for view in observedViews {
            view.removeObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: contentOffset)), context: &HomeScrollView.kHomeScrollViewKVOContext)
        }
        
        observedViews.removeAll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            removeObserverViews()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        removeObserverViews()
    }
    
    deinit {
        removeObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: contentOffset)), context: &HomeScrollView.kHomeScrollViewKVOContext)
        removeObserverViews()
    }
}

class HomeScrollViewDelegateDecorator: NSObject, UIScrollViewDelegate {
    var delegate: UIScrollViewDelegate?
    
    override func responds(to aSelector: Selector!) -> Bool {
        let respond = (delegate?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
        return respond
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return delegate
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        (scrollView as? HomeScrollView)?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        (scrollView as? HomeScrollView)?.scrollViewDidEndDecelerating(scrollView)
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
}
