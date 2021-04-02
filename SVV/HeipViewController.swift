//
//  HeipViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/03.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class HeipViewController: UIViewController {

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
    func setButtons(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let bw=ww/8
        let bh=bw*15/44
        let sp=(ww/8)/8
        let by=wh-bh-sp*2/3
        exitButton.frame = CGRect(x: ww - bw - sp, y: by, width: bw, height: bh)
        engButton.frame = CGRect(x:sp,y:by,width:bw,height:bh)
        exitButton.layer.cornerRadius=5
        engButton.layer.cornerRadius=5
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
