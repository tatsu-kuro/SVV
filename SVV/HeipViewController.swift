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
    @IBOutlet weak var helpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        englishF=true
        japanEnglish(0)
        // Do any additional setup after loading the view.
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
 //       print("engjap")
    }
    func setRight(but:UIButton){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let bw=ww/6
        let bh=bw*15/44
        let sp=(ww/6)/6
        let by=wh-bh-sp*2/3
        but.frame = CGRect(x: sp*5+bw*4, y: by, width: bw, height: bh)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   //     let ww=view.bounds.width
   //     let wh=view.bounds.height
  //      let bw=ww/20
  //      let bh=bw//*15/20
  //      let x0=ww-ww/36-ww*5/88
  //      let h=ww*5/88
  //      let y0=wh-ww*5/88-ww/48
        //self.helpButton.frame = CGRect(x:x0,y:y0,width: h,height: h)
        setRight(but: helpButton)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
