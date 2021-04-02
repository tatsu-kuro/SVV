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
    var timer: Timer!
    var directionR:Bool=true
    var time=CFAbsoluteTimeGetCurrent()
    var degree:Int=0
    var tempdiameter:Int=0
    var VROnOff:Int = 0
    var locationX:Int = 0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameter: UILabel!
    @IBOutlet weak var VRLocationXSlider: UISlider!
    
    @IBOutlet weak var VROnText: UILabel!
    @IBOutlet weak var VROnSwitch: UISwitch!
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var lineWidth: UILabel!
    @IBOutlet weak var defaultButton: UIButton!
    @IBAction func setDiameter(_ sender: UISlider) {
        circleDiameter.text="Diameter:" + String(Int(sender.value*10))
        diameter=Int(sender.value*10)
        if(diameter != tempdiameter){
            UserDefaults.standard.set(diameter,forKey: "circleDiameter")
            drawBack(remove:true)
        }
        tempdiameter=diameter
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
 
    @IBAction func onVROnSwitch(_ sender: Any) {
        if VROnSwitch.isOn == true{
            VROnOff=1
            VRLocationXSlider.isHidden=false
        }else{
            VROnOff=0
            VRLocationXSlider.isHidden=true
        }
        UserDefaults.standard.set(VROnOff, forKey: "VROnOff")
        drawBack(remove: true)
    }
    
    @IBAction func onChangeVRslider(_ sender: UISlider) {
        if VROnOff == 0{
            return
        }
        locationX=Int(sender.value)
        UserDefaults.standard.set(locationX,forKey: "VRLocationX")
        view.layer.sublayers?.removeLast()
        drawBack(remove:true)
    }
    @IBAction func setWidth(_ sender: UISlider) {
        lineWidth.text="LineWidth:" + String(Int(sender.value*98)+1)
        width=Int(sender.value*98)+1
        UserDefaults.standard.set(width,forKey: "lineWidth")
    }
    @IBAction func setDefault(_ sender: Any) {
            locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
            if VROnOff == 0{
                diameter=7
                width=10
            }else{
                locationX=15
                VRLocationXSlider.value=Float(15)
                diameter=5
                width=5
            }
            UserDefaults.standard.set(diameter,forKey: "circleDiameter")
            UserDefaults.standard.set(width,forKey: "lineWidth")
            UserDefaults.standard.set(locationX,forKey: "VRLocationX")
            diameterSlider.value=Float(diameter)/10
            circleDiameter.text="Diameter:" + String(diameter)
            lineWidthSlider.value=Float(width-1)/98
            lineWidth.text="LineWidth:" + String(width)
            drawBack(remove:true)
        }

//    @IBAction func setDefault(_ sender: Any) {
//        UserDefaults.standard.set(dia0,forKey: "circleDiameter")
//        UserDefaults.standard.set(width0,forKey: "lineWidth")
//        UserDefaults.standard.set(0,forKey: "VROnOff")
//        UserDefaults.standard.set(0,forKey: "VRLocationX")
//        VRLocationXSlider.value=0
//        VROnSwitch.isOn=false
//        diameterSlider.value=Float(dia0)/10
//        circleDiameter.text="Diameter:" + String(dia0)
//        lineWidthSlider.value=Float(width0-1)/98
//        lineWidth.text="LineWidth:" + String(width0)
//        diameter=dia0
//        width=width0
//        drawBack(remove:true)
//    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        width=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        VROnOff=UserDefaults.standard.integer(forKey:"VROnOff")
        if VROnOff==0{
            VROnSwitch.isOn=false
        }else{
            VROnSwitch.isOn=true
        }
        diameterSlider.value=Float(diameter)/10
        lineWidthSlider.value=Float(width-1)/98
        VRLocationXSlider.value=Float(locationX)
        circleDiameter.text="Diameter:" + String(diameter)
        lineWidth.text="lineWidth:" + String(width)
        time=CFAbsoluteTimeGetCurrent()
        drawBack(remove:false)
        drawLine(degree: 0, remove: false)
        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        setButtons()
    }
  
    func setButtons(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0=(ww/2+wh/2)+(ww-ww/2-wh/2)/10
        let bw=(ww-ww/2-wh/2)*8/10
        let bh=wh/9
        let sp=bh/10

        VROnSwitch.frame = CGRect(x:x0,y:sp*3,width:bw/3,height: bh)
        VROnText.frame = CGRect(x:x0+bw/2,y:sp*3,width:bw/2,height:bh)
        VROnText.text="for VR"
        VRLocationXSlider.frame = CGRect(x:x0,y:bh*1+sp,width:bw,height: bh)
        circleDiameter.frame = CGRect(x:x0, y: bh*2+sp*5, width: bw, height: bh)
        diameterSlider.frame = CGRect(x:x0,y:bh*3+sp*3,width:bw,height:bh)
        lineWidth.frame = CGRect(x:x0, y:bh*4+sp*7, width: bw, height: bh)
        lineWidthSlider.frame = CGRect(x:x0, y: bh*5+sp*5, width: bw, height: bh)
        defaultButton.frame = CGRect(x:x0, y: bh*6+sp*7, width: bw, height: bh)
        exitButton.frame = CGRect(x:x0,y:bh*7+sp*8,width:bw,height:bh)
        exitButton.layer.cornerRadius=5
        defaultButton.layer.cornerRadius=5
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
        var x0=ww/2
        if VROnSwitch.isOn == true{
            x0=ww/4 + CGFloat(locationX)
        }
        let y0=wh/2
        let r=wh*(70+13*CGFloat(diameter))/400
        let dd:Double=3.14159/900
        let x1=CGFloat(Double(r)*sin(Double(degree)*dd))
        let y1=CGFloat(Double(r)*cos(Double(degree)*dd))
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        uiPath.move(to:CGPoint.init(x: x0 + x1,y: y0 - y1))
        uiPath.addLine(to: CGPoint(x:x0 - x1,y:y0 + y1))
        uiPath.lineWidth=5.0
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth=CGFloat(width)/10.0
        shapeLayer.path = uiPath.cgPath
        self.view.layer.addSublayer(shapeLayer)
    }
    func drawBack(remove:Bool){
        if remove==true{
            view.layer.sublayers?.removeLast()
         }
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
        let r=wh*(70+13*CGFloat(diameter))/200
        var x0=ww/2-r/2
        if VROnSwitch.isOn == true{
            x0=ww/4 + CGFloat(locationX) - r/2
        }
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
        self.view.layer.addSublayer(shapeLayer)
    }
}
