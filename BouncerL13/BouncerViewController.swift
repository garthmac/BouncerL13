//
//  BouncerViewController.swift
//  BouncerL13 -RED BLOCK
//
//  Created by iMac21.5 on 5/19/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit
import MediaPlayer

class BouncerViewController: UIViewController {
    
    @IBOutlet weak var bouncerView: UIImageView!
    
    let bouncer = BouncerBehavior()
    lazy var animator: UIDynamicAnimator = {
        UIDynamicAnimator(referenceView: self.bouncerView) }()
    var moviePlayer: MPMoviePlayerController!
    lazy var randomLetter: String = {
        if let fav = NSUserDefaults.standardUserDefaults().stringForKey(Constants.FavVideo) {
            if !fav.isEmpty {
                return fav  //if settings favVideo not set
            }
        }
        return String.random
    }()
    lazy var repeatVideo: Bool = {
        return NSUserDefaults.standardUserDefaults().boolForKey(Constants.RepeatVideo)
        }()
    lazy var opacity: CGFloat = {
        let alpha = NSUserDefaults.standardUserDefaults().floatForKey(Constants.BlockOpacity)
        if alpha != 0.0 {
            return CGFloat(alpha)
        }
        return 1.0
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVideo()
        animator.addBehavior(bouncer)
    }
    
    func videoNameFor(sel: String) -> String {
        switch String(Array(sel).first!) {
        case "A": return BouncerViewController.Videos.A
        case "B": return BouncerViewController.Videos.B
        case "C": return BouncerViewController.Videos.C
        case "D": return BouncerViewController.Videos.D
        case "E": return BouncerViewController.Videos.E
        case "F": return BouncerViewController.Videos.F
        case "G": return BouncerViewController.Videos.G
        default: return BouncerViewController.Videos.C
        }
    }
    
    func addVideo() {
        let path = NSBundle.mainBundle().pathForResource(videoNameFor(randomLetter), ofType:"mp4")
        let url = NSURL.fileURLWithPath(path!)
        self.moviePlayer = MPMoviePlayerController(contentURL: url)
        if let player = self.moviePlayer {
            player.view.frame = bouncerView.frame
            var model = UIDevice.currentDevice().model
            if model.hasPrefix("iPad") {
                player.view.frame.size = CGSize(width: 1024, height: 800)
            } else { // midY/2 is a compromize for iPhones
                player.view.center = CGPoint(x: bouncerView.bounds.midX, y: bouncerView.bounds.midY/2)
            }
            player.scalingMode = MPMovieScalingMode.AspectFit
            player.setFullscreen(true, animated: true)
            player.view.sizeToFit()
            player.controlStyle = MPMovieControlStyle.None
            player.movieSourceType = MPMovieSourceType.File
            if repeatVideo {
                player.repeatMode = MPMovieRepeatMode.One }
            else {
                player.repeatMode = MPMovieRepeatMode.None }
            player.play()
            bouncerView.addSubview(player.view)
        } else {
            debugPrintln("Oops, something went wrong when playing background video")
        }
    }
    
    struct Constants {
        static let BlockOpacity = "BouncerViewController.BlockOpacity"
        static let BlockPathName = "Box"
        static let BlockRandomColorOn = "BouncerViewController.UseRandomColor"
        static let BlockSize = CGSize(width: 40.0, height: 40.0)
        static let FavVideo = "BouncerViewController.FavVideo"
        static let RepeatVideo = "BouncerViewController.RepeatVideo"
    }
    
    struct Videos {
        static let
            A = "Youre_Beautiful_-Phil_Wickham_{HD}",
            B = "CYMATICS_Science_Vs._Music_-_Nigel_Stanford",
            C = "Cornerstone_-_Hillsong_Live_(2012_Album_Cornerstone)_Lyrics_DVD_(Worship_Song_to_Jesus)",
            D = "How_to_Get_to_Mars._Very_Cool!_HD",
            E = "Matthew_24",
            F = "Phil Wickham - This Is Amazing Grace",
            G = "Blood_Moons_In_Biblical_Prophecy_Incredible_Year_Ahead_In_2015!_Part_1"
    }
    
    var redBlock: UIView?

    lazy var blockColor: UIColor = {
        if NSUserDefaults.standardUserDefaults().boolForKey(Constants.BlockRandomColorOn) == true {
            return UIColor.random
        }
        return UIColor.redColor()
    }()

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if redBlock == nil {
            redBlock = addDrop()
            redBlock?.backgroundColor = blockColor
            bouncer.addDrop(redBlock!)
        }
        let motionMgr = AppDelegate.Motion.Manager
        if motionMgr.accelerometerAvailable {
            motionMgr.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { (data, error) -> Void in
                let data = motionMgr.accelerometerData
                self.bouncer.gravity.gravityDirection = CGVector(dx: data.acceleration.x, dy: -data.acceleration.y)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        AppDelegate.Motion.Manager.stopAccelerometerUpdates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var gameRect = bouncerView.bounds
        gameRect.size.height *= 2
        bouncer.addBarrier(UIBezierPath(rect: gameRect), named: Constants.BlockPathName)
        //Its not nice if the player looses a block because the device has been rotated accidentally. In such cases put the block back on screen:
        for block in bouncer.blocks {
            if !CGRectContainsRect(bouncerView.bounds, block.frame) {
                placeDrop(block)
                animator.updateItemUsingCurrentState(block)
            }
        }
    }
    
    func addDrop() -> UIView {
        let drop = UIView(frame: CGRect(origin: CGPointZero, size: Constants.BlockSize))
        drop.alpha = opacity
        placeDrop(drop)
        bouncerView.addSubview(drop)
        return drop
    }
    
    func placeDrop(drop: UIView) {
        drop.center = CGPoint(x: bouncerView.bounds.midX, y: bouncerView.bounds.midY)  //from ball game
    }
}

private extension String {
    static var random: String {
        switch arc4random() % 8 {
        case 0: return "A"
        case 1: return "B"
        case 2: return "C"
        case 3: return "D"
        case 4: return "E"
        case 5: return "F"
        case 6: return "G"
        default: return "C"
        }
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 11 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        case 5: return UIColor.yellowColor()
        case 6: return UIColor.brownColor()
        case 7: return UIColor.darkGrayColor()
        case 8: return UIColor.lightGrayColor()
        case 9: return UIColor.cyanColor()
        //case 10: return UIColor.clearColor()
        default: return UIColor.blackColor()
        }
    }
}