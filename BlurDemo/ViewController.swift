//
//  ViewController.swift
//  BlurDemo
//
//  Created by Lumia_Saki on 15/5/29.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

import UIKit
import SnapKit
 
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var blurImageView: UIImageView!
    
//    private let originImage = UIImage(named: "逢泽莉娜.jpg")!
    private let originImage = UIImage(named: "cover.png")!
    private var blurImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        blurImageView.image = nil
        blurImageView.backgroundColor = UIColor.lightGrayColor()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        blurImageView.addSubview(activityIndicator)
        
        activityIndicator.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.blurImageView)
            
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        blurImageView.setNeedsLayout()
        
        activityIndicator.startAnimating()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        prepareBlurImages({ [unowned self] (resultArray) -> Void in
            self.blurImages = resultArray
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                activityIndicator.stopAnimating()
                
                self.blurImageView.image = self.originImage
                
                let endTime = CFAbsoluteTimeGetCurrent()
                
                println(endTime - startTime)
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("reuseCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = "Row \(indexPath.row)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 {
            scrollView.contentOffset.y = -100
        }
        
        if blurImageView.image != nil {
            if (abs(Int(scrollView.contentOffset.y) / 10)) <= 10 && scrollView.contentOffset.y < 0 {
                blurImageView.image = blurImages[abs(Int(scrollView.contentOffset.y) / 10)]
            } else {
                blurImageView.image = originImage
            }
        }
    }
    
    private func prepareBlurImages(completionHandler:(resultArray:[UIImage]) -> Void) {
        var imageArray = [UIImage]()
        
        var blurRate: CGFloat = 2.0
        
        dispatch_async(dispatch_get_global_queue(0, 0), { [unowned self] () -> Void in
            for var i = 0; i < 11; i++ {
                
                if let lastImage: UIImage = imageArray.last {
                    imageArray.append(lastImage.applyBlurWithRadius(CGFloat(blurRate), tintColor: UIColor.clearColor(), saturationDeltaFactor: 1.0, maskImage: nil))
                } else {
                    imageArray.append(self.originImage)
                }
                
                if imageArray.count == 11 {
                    completionHandler(resultArray: imageArray)
                }
            }
        })
    }
}

