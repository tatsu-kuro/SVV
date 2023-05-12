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
        
//                let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
//                print("HELP:DidLoad",mainView.sensorArray.count,mainView.displaySensorArray.count)

        if Locale.preferredLanguages.first!.contains("ja"){
            englishF=false
        }else{
            englishF=true
        }
        dispHelp()
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
    func dispHelp(){
        if englishF==false{
            helpText.image=UIImage(named: "helpj")
        }else{
            helpText.image=UIImage(named:"helpe")
        }
    }
//    @IBOutlet weak var helpTexteng: UIImageView!
    @IBOutlet weak var helpText: UIImageView!
    @IBAction func japanEnglish(_ sender: Any) {
        if(englishF){
            englishF=false
        }else{
            englishF=true
        }
        dispHelp()
    }
    
    func setButtons(){
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))//anytime 0
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
        
        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
        let sp=ww/120
        let bw=(ww-sp*6)/5
        let bh=bw/3.5
        let by=wh-bh-sp
        
        engButton.isHidden=true
        helpText.frame = CGRect(x:leftPadding+sp,y:topPadding+sp,width: ww-2*sp,height: wh-topPadding-bh-sp*2)
        exitButton.frame = CGRect(x:leftPadding + ww - bw - sp, y: by, width: bw, height: bh)
        engButton.frame = CGRect(x:leftPadding + sp,y:by,width:bw,height:bh)
        exitButton.layer.cornerRadius=5
        engButton.layer.cornerRadius=5
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
