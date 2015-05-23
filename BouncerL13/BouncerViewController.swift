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
        if let fav = NSUserDefaults.standardUserDefaults().stringForKey("BouncerViewController.FavVideo") {
            if fav != "" { return fav } //without this check video 6 gets returned if settings empty
        }
        return String.random
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVideo()
        animator.addBehavior(bouncer)
    }
    
    func videoNameFor(sel: String) -> String {
        switch sel {
        case "A": return BouncerViewController.Videos.A
        case "B": return BouncerViewController.Videos.B
        case "C": return BouncerViewController.Videos.C
        case "D": return BouncerViewController.Videos.D
        default: return BouncerViewController.Videos.E
        }
    }
    
    func addVideo() {
        let path = NSBundle.mainBundle().pathForResource(videoNameFor(randomLetter), ofType:"mp4")
        let url = NSURL.fileURLWithPath(path!)
        self.moviePlayer = MPMoviePlayerController(contentURL: url)
        if let player = self.moviePlayer {
            player.view.frame = bouncerView.frame
            var model = UIDevice.currentDevice().model
//            println("\(model)")
//            println("\(bouncerView.frame)")
            if model.hasPrefix("iPad") {
                player.view.frame.size = CGSize(width: 1022, height: 800)
            } else {
                player.view.center = CGPoint(x: bouncerView.bounds.midX, y: bouncerView.bounds.midY/2)
                // midY/2 is a compromize for iPhones
            }
            player.scalingMode = MPMovieScalingMode.AspectFit
            player.setFullscreen(true, animated: true)
            player.view.sizeToFit()
            player.controlStyle = MPMovieControlStyle.None
            player.movieSourceType = MPMovieSourceType.File
            player.repeatMode = MPMovieRepeatMode.One
            player.play()
            bouncerView.addSubview(player.view)
        } else {
        debugPrintln("Oops, something went wrong when playing background video")
        }
    }
    
    struct Constants {
        static let  BlockSize = CGSize(width: 40.0, height: 40.0)
    }
    
    struct Videos {
        static let
            A = "Youre_Beautiful_-Phil_Wickham_{HD}",
            B = "CYMATICS_Science_Vs._Music_-_Nigel_Stanford",
            C = "Cornerstone_-_Hillsong_Live_(2012_Album_Cornerstone)_Lyrics_DVD_(Worship_Song_to_Jesus)",
            D = "How_to_Get_to_Mars._Very_Cool!_HD",
            E = "Blood_Moons_In_Biblical_Prophecy_Incredible_Year_Ahead_In_2015!_Part_1"
    }
    
    var redBlock: UIView?

    lazy var blockColor: UIColor = {
        if NSUserDefaults.standardUserDefaults().boolForKey("BouncerViewController.isRandomColor") == true {
            return UIColor.random
        } else {
            return UIColor.redColor()
        }
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
    
    func addDrop() -> UIView {
        let drop = UIView(frame: CGRect(origin: CGPointZero, size: Constants.BlockSize))
        drop.center = CGPoint(x: bouncerView.bounds.midX, y: bouncerView.bounds.midY)
        bouncerView.addSubview(drop)
        return drop
    }
}

private extension String {
    static var random: String {
        switch arc4random() % 5 {
        case 0: return "A"
        case 1: return "B"
        case 2: return "C"
        case 3: return "D"
        default: return "E"
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
        default: return UIColor.blackColor()
        }
    }
}