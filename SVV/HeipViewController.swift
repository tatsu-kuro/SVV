//
//  HeipViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/03.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class HeipViewController: UIViewController {

    @IBOutlet weak var dateText: UILabel!
    var englishF:Bool=false
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var engButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        englishF=true
        japanEnglish(0)
        setButtons()
    }
    @IBAction func engJapan(_ sender: Any) {
        japanEnglish(0)
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBOutlet weak var helpTexteng: UIImageView!
    @IBOutlet weak var helpText: UIImageView!
    @IBAction func japanEnglish(_ sender: Any) {
        if(englishF){
            englishF=false
            helpText.alpha=1.0
            helpTexteng.alpha=0
        }else{
            englishF=true
            helpText.alpha=0
            helpTexteng.alpha=1.0
        }
    }
    /*
     func setButtons(){
         let ww=view.bounds.width-leftPadding-rightPadding
         let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
         let logoh=ww*84/1300
         let bw=ww/6
         //let bw_help=bw/2
         let bh=bw*15/44
         let sp=(ww/6)/6
         let by=wh-bh-sp*2/3
         logoImage.frame = CGRect(x:leftPadding+0,y:0,width:ww,height:logoh)
         listButton.frame = CGRect(x:leftPadding+sp, y: by, width: bw, height: bh)
         saveButton.frame = CGRect(x:leftPadding+sp*2+bw*1,y:by,width:bw,height:bh)
         startButton.frame = CGRect(x:leftPadding+sp*3+bw*2, y: by, width: bw, height: bh)//440*150
         setteiButton.frame = CGRect(x:leftPadding+sp*4+bw*3,y:by,width:bw,height:bh)
         helpButton.frame = CGRect(x:leftPadding+sp*5+bw*4,y:by,width:bw,height:bh)
         titleImage.frame = CGRect(x:leftPadding+0, y: logoh, width: ww, height: wh-logoh-bh*3/2)
         listButton.layer.cornerRadius=5
         saveButton.layer.cornerRadius=5
         startButton.layer.cornerRadius=5
         setteiButton.layer.cornerRadius=5
         helpButton.layer.cornerRadius=5
     }
     */
    func setButtons(){
        let left=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let right=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let top=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))//anytime 0
        let bottom=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))

        let ww=view.bounds.width - left - right
        let wh=view.bounds.height - top - bottom
//        let bw=ww/8
//        let bh=bw*15/44
//        let sp=(ww/8)/8
//        let by=wh-bh-sp*2/3
        
        let bw=ww/6
        //let bw_help=bw/2
        let bh=bw*15/44
        let sp=(ww/6)/6
        let by=wh-bh-sp*2/3
        
        helpText.frame = CGRect(x:left+sp,y:top+sp,width: ww-2*sp,height: wh-top-bottom-bh-sp*2)
        helpTexteng.frame = CGRect(x:left+sp,y:top+sp,width: ww-2*sp,height: wh-top-bottom-bh-sp*2)

        exitButton.frame = CGRect(x:left + ww - bw - sp, y: by, width: bw, height: bh)
        engButton.frame = CGRect(x:left + sp,y:by,width:bw,height:bh)
        exitButton.layer.cornerRadius=5
        engButton.layer.cornerRadius=5
        dateText.frame = CGRect(x:left+ww/2,y:by,width: ww/2-bw-right-sp*2,height: bh)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
