//
//  BouncerBehavior.swift
//  Bouncer
//
//  Created by iMac21.5 on 5/3/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit

class BouncerBehavior: UIDynamicBehavior {
    //changed all UIView to UIButton July 1/15
    let gravity = UIGravityBehavior()
    
    lazy var collider: UICollisionBehavior = {
        let lazyCreatedCollider = UICollisionBehavior()
        lazyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
            lazyCreatedCollider.action = {
                for block in self.blocks {
                    if !CGRectIntersectsRect(self.dynamicAnimator!.referenceView!.bounds, block.frame) {
                        self.removeDrop(block)
                    }
                }
            }
        return lazyCreatedCollider
        }()
    var blocks:[UIButton] {
        get {
            return collider.items.filter{$0 is UIButton}.map{$0 as! UIButton}
        }
    }
    lazy var dropBehavior: UIDynamicItemBehavior = {
        let lazyCreatedDropBehavior = UIDynamicItemBehavior()
        lazyCreatedDropBehavior.allowsRotation = true
        let elasticity = CGFloat(NSUserDefaults.standardUserDefaults().doubleForKey("BouncerBehavior.Elasticity"))
        if elasticity != 0 {
            lazyCreatedDropBehavior.elasticity = elasticity
        } else {
            lazyCreatedDropBehavior.elasticity = 0.95
        }
        lazyCreatedDropBehavior.friction = 0
        lazyCreatedDropBehavior.resistance = 0
        //(should really remove observer...like Trax) see Settings.bundle - Root.plist
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification,
            object: nil,
            queue: nil) { (notification) -> Void in
                lazyCreatedDropBehavior.elasticity = CGFloat(NSUserDefaults.standardUserDefaults().doubleForKey("BouncerBehavior.Elasticity")) }
        return lazyCreatedDropBehavior
        }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(dropBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addDrop(drop: UIButton) {
        //        println(dynamicAnimator?.referenceView?.description)
        dynamicAnimator?.referenceView?.addSubview(drop)
        gravity.addItem(drop)
        collider.addItem(drop)
        dropBehavior.addItem(drop)
    }
    
    func removeDrop(drop: UIButton) {
        gravity.removeItem(drop)
        collider.removeItem(drop)
        dropBehavior.removeItem(drop)
        drop.removeFromSuperview()
    }
}
