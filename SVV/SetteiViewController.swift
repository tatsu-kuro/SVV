//
//  SetteiViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/20.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class SetteiViewController: UIViewController {
    var cirDiameter:CGFloat = 0
    var diameter:Int = 0
    var width:Int = 0
    let dia0:Int = 7
    let width0:Int = 10
    var timer: Timer!
    var directionR:Bool=true
    var time=CFAbsoluteTimeGetCurrent()
    var degree:Int=0
    var tempdiameter:Int=0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameter: UILabel!
    @IBOutlet weak var lineSlider: UISlider!
    @IBOutlet weak var circleSlider: UISlider!
    @IBOutlet weak var lineWidth: UILabel!
    @IBOutlet weak var defaultButton: UIButton!
    @IBAction func setDiameter(_ sender: UISlider) {
        circleDiameter.text="Diameter:" + String(Int(sender.value*10))
        diameter=Int(sender.value*10)
        if(diameter != tempdiameter){
            UserDefaults.standard.set(diameter,forKey: "circleDiameter")
            drawBack()
        }
        tempdiameter=diameter
    }
    
    @IBAction func setWidth(_ sender: UISlider) {
        lineWidth.text="LineWidth:" + String(Int(sender.value*98)+1)
        width=Int(sender.value*98)+1
        UserDefaults.standard.set(width,forKey: "lineWidth")
    }
//    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
//        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
//            return UserDefaults.standard.integer(forKey:str)
//        }else{
//            UserDefaults.standard.set(ret, forKey: str)
//            return ret
//        }
//    }
    @IBAction func setDefault(_ sender: Any) {
        UserDefaults.standard.set(dia0,forKey: "circleDiameter")
        UserDefaults.standard.set(width0,forKey: "lineWidth")
        circleSlider.value=Float(dia0)/10
        circleDiameter.text="Diameter:" + String(dia0)
        lineSlider.value=Float(width0-1)/98
        lineWidth.text="LineWidth:" + String(width0)
        diameter=dia0
        width=width0
        drawBack()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        width=UserDefaults.standard.integer(forKey: "lineWidth")
        circleSlider.value=Float(diameter)/10
        lineSlider.value=Float(width-1)/98
        circleDiameter.text="Diameter:" + String(diameter)
        lineWidth.text="lineWidth:" + String(width)
        time=CFAbsoluteTimeGetCurrent()
        drawBack()
        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        setButtons()
    }
    /* @IBOutlet weak var exitButton: UIButton!
       @IBOutlet weak var circleDiameter: UILabel!
       @IBOutlet weak var lineSlider: UISlider!
       @IBOutlet weak var circleSlider: UISlider!
       @IBOutlet weak var lineWidth: UILabel!*/
    func setButtons(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0=(ww/2+wh/2)+(ww-ww/2-wh/2)/10
        let bw=(ww-ww/2-wh/2)*8/10
        let bh=(ww/6)*15/44
        let sp=(ww/6)/6
        let by=wh-bh-sp*2/3
        let bdy=(by-bh*5)/15
        
        self.circleDiameter.frame = CGRect(x:x0, y: bdy*3, width: bw, height: bh)
        self.circleSlider.frame = CGRect(x:x0,y:bdy*3+bh,width:bw,height:bh)
        self.lineWidth.frame = CGRect(x:x0, y:bdy*6+bh*2, width: bw, height: bh)
        self.lineSlider.frame = CGRect(x:x0, y: bdy*6+bh*3, width: bw, height: bh)
        self.defaultButton.frame = CGRect(x:x0, y: bdy*10+bh*4, width: bw, height: bh)
        
        
        // bw=ww/6
        // bh=bw*15/44
        // sp=(ww/6)/6
        // by=wh-bh-sp*2/3
         //self.changeButton.frame = CGRect(x: sp, y: by, width: bw, height: bh)
         //self.mailButton.frame = CGRect(x:sp*2+bw*1,y:by,width:bw,height:bh)
         //self.gomiButton.frame = CGRect(x: sp*3+bw*2, y: by, width: bw, height: bh)//440*150
        // self.exitButton.frame = CGRect(x:sp*5+bw*4, y: by, width:bw, height: bh)
        //self.exitButton.frame = CGRect(x: ww-sp-bh, y: by, width: bh, height: bh)
        setRight(but: exitButton, x0:x0, w:bw)
    }
    func setRight(but:UIButton,x0:CGFloat,w:CGFloat){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let bw=ww/6
        let bh=bw*15/44
        let sp=(ww/6)/6
        let by=wh-bh-sp*2/3
        //let x0=(ww/2+wh/2)+(ww-ww/2-wh/2)/10//default button x
   //     if sp*5+bw*4<x0{
            but.frame = CGRect(x:x0,y:by,width:w,height:bh)
   //     }else{
   //         but.frame = CGRect(x: sp*5+bw*4, y: by, width: bw, height: bh)
   //     }
    }
     @objc func update(tm: Timer) {
            if(degree>100){
                directionR=false
            }else if(degree < -100){
                directionR=true
            }
            if(directionR){
                degree += 2
            }else{
                degree -= 2
            }
        drawLine(degree:degree,remove:true)
    }
    
    func drawLine(degree:Int,remove:Bool){
        //線を引く
        if remove==true{
            view.layer.sublayers?.removeLast()
        }
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0=ww/2
        let y0=wh/2
        let r=wh*(150+5*CGFloat(diameter))/400
        let dd:Double=3.14159/900
        let x1=CGFloat(Double(r)*sin(Double(degree)*dd))
        let y1=CGFloat(Double(r)*cos(Double(degree)*dd))
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
    //    uiPath.lineWidth=CGFloat(35)
        uiPath.move(to:CGPoint.init(x: x0 + x1,y: y0 - y1))
        uiPath.addLine(to: CGPoint(x:x0 - x1,y:y0 + y1))
        uiPath.lineWidth=5.0
 //       if mbf==true {
//            shapeLayer.strokeColor = UIColor.red.cgColor
///        } else {
            shapeLayer.strokeColor = UIColor.blue.cgColor
//        }
        shapeLayer.lineWidth=CGFloat(width)/10.0
        shapeLayer.path = uiPath.cgPath
        self.view.layer.addSublayer(shapeLayer)
    }
    func drawBack(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        // 四角形を描画
        let rectangleLayer = CAShapeLayer.init()
        let rectangleFrame = CGRect.init(x: 0, y: 0, width:ww/2+wh/2, height: wh)
        rectangleLayer.frame = rectangleFrame
        rectangleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        rectangleLayer.fillColor = UIColor.black.cgColor// 四角形の中の色
        rectangleLayer.lineWidth = 2.5
        
        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
        self.view.layer.addSublayer(rectangleLayer)
        // --- 円を描画 ---
        let circleLayer = CAShapeLayer.init()
        let r=wh*(150+5*CGFloat(diameter))/200
        let x0=ww/2-r/2
        let y0=wh/2-r/2
        //print(r,x0,y0)
        let circleFrame = CGRect.init(x:x0,y:y0,width:r,height:r)
        circleLayer.frame = circleFrame
        circleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        circleLayer.fillColor = UIColor.white.cgColor// 円の中の色
        circleLayer.lineWidth = 0.5// 輪郭の太さ
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
        //線を引く
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        uiPath.move(to:CGPoint.init(x: ww/2,y: wh/2-r/2))
        uiPath.addLine(to: CGPoint(x:ww/2,y:wh/2+r/2))
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.path = uiPath.cgPath
        self.view.layer.addSublayer(shapeLayer)
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
