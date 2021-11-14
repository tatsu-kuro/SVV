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
//    var degree:Int=0
    var tempdiameter:Int=0
    var VROnOff:Int = 0
    var tenTimesOnOff:Int = 1
    var locationX:Int = 0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameter: UILabel!
    @IBOutlet weak var VRLocationXSlider: UISlider!
    
    @IBOutlet weak var tenTimesText: UILabel!
    @IBAction func onTenTimesSwitch(_ sender: Any) {
        if tenTimesSwitch.isOn{
            tenTimesOnOff=1
        }else{
            tenTimesOnOff=0
        }
        UserDefaults.standard.set(tenTimesOnOff, forKey: "tenTimesOnOff")
    }
    @IBOutlet weak var tenTimesSwitch: UISwitch!
    
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var lineWidth: UILabel!
    @IBOutlet weak var useVRButton: UIButton!
    @IBAction func changeDiameter(_ sender: UISlider) {
        circleDiameter.text="Diameter:" + String(Int(sender.value*10))
        diameter=Int(sender.value*10)
        if(diameter != tempdiameter){
            UserDefaults.standard.set(diameter,forKey: "circleDiameter")
            reDrawCirclesLines()
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
 
//    @IBAction func onVROnSwitch(_ sender: Any) {
//        if VROnSwitch.isOn == true{
//            VROnOff=1
//            VRLocationXSlider.isHidden=false
//        }else{
//            VROnOff=0
//            VRLocationXSlider.isHidden=true
//        }
//        UserDefaults.standard.set(VROnOff, forKey: "VROnOff")
//        drawBack(remove: true)
//    }
    
    @IBAction func onChangeVRslider(_ sender: UISlider) {
        if VROnOff == 0{
            return
        }
        locationX=Int(sender.value)
        UserDefaults.standard.set(locationX,forKey: "VRLocationX")
        reDrawCirclesLines()
    }
    @IBAction func setWidth(_ sender: UISlider) {
        lineWidth.text="LineWidth:" + String(Int(sender.value*98)+1)
        width=Int(sender.value*98)+1
        UserDefaults.standard.set(width,forKey: "lineWidth")
        reDrawCirclesLines()
    }
    @IBAction func onUseVRButton(_ sender: Any) {
        if VROnOff==0{
            VROnOff=1
            VRLocationXSlider.isEnabled=true// isHidden=false
            VRLocationXSlider.isHighlighted=true
        }else{
            VROnOff=0
            VRLocationXSlider.isEnabled=false// isHidden=true
            VRLocationXSlider.isHighlighted=false
        }
        UserDefaults.standard.set(VROnOff, forKey: "VROnOff")
        reDrawCirclesLines()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func buttonsToFront(){
        self.view.bringSubviewToFront(useVRButton)
        self.view.bringSubviewToFront(exitButton)
        self.view.bringSubviewToFront(tenTimesText)
        self.view.bringSubviewToFront(tenTimesSwitch)
        self.view.bringSubviewToFront(circleDiameter)
        self.view.bringSubviewToFront(lineWidth)
        self.view.bringSubviewToFront(diameterSlider)
        self.view.bringSubviewToFront(lineWidthSlider)
        self.view.bringSubviewToFront(VRLocationXSlider)
    }
    func buttonsToBack(){
        self.view.sendSubviewToBack(useVRButton)
        self.view.sendSubviewToBack(exitButton)
        self.view.sendSubviewToBack(tenTimesText)
        self.view.sendSubviewToBack(tenTimesSwitch)
        self.view.sendSubviewToBack(circleDiameter)
        self.view.sendSubviewToBack(lineWidth)
        self.view.sendSubviewToBack(diameterSlider)
        self.view.sendSubviewToBack(lineWidthSlider)
        self.view.sendSubviewToBack(VRLocationXSlider)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        width=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        VROnOff=UserDefaults.standard.integer(forKey:"VROnOff")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        diameterSlider.value=Float(diameter)/10
        lineWidthSlider.value=Float(width-1)/98
        VRLocationXSlider.value=Float(locationX)
        circleDiameter.text="Diameter:" + String(diameter)
        lineWidth.text="lineWidth:" + String(width)
        drawBackCircles()
        drawLines()
        setButtons()
        buttonsToFront()
     }
    func setButtons(){
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
        let sp=ww/120
        let bw=(ww-sp*6)/5
        let bh=bw/3.5
        let by=wh-bh-sp
        let x0=leftPadding+sp
        let xCenter=view.bounds.width/2
        tenTimesSwitch.frame = CGRect(x:xCenter,y:by,width:bw/3,height: bh)
        //switchの大きさは規定されているので、作ってみてそのサイズを得て、再設定
        let switchWidth=tenTimesSwitch.frame.width
        let switchHeight=tenTimesSwitch.frame.height
        let d=(bh-switchHeight)/2
        tenTimesSwitch.frame = CGRect(x:xCenter+sp,y:by+d,width:switchWidth,height: bh)
        tenTimesText.frame = CGRect(x:xCenter+sp+switchWidth,y:by,width:x0+sp*2+bw*4-xCenter-switchWidth,height:bh)
        VRLocationXSlider.frame = CGRect(x:x0,y:by,width:xCenter-bw-sp-x0,height: bh)
        circleDiameter.frame = CGRect(x:x0+sp*4+bw*4, y: by-bh-sp, width: bw, height: bh)
        diameterSlider.frame = CGRect(x:xCenter+sp,y:by-bh-sp,width:xCenter-bw-sp-x0,height:bh)
        lineWidth.frame = CGRect(x:xCenter-bw, y:by-bh-sp, width: bw, height: bh)
        lineWidthSlider.frame = CGRect(x:x0, y: by-bh-sp, width: xCenter-bw-sp-x0, height: bh)

        useVRButton.frame = CGRect(x:xCenter-bw,y:by,width:bw,height:bh)
        exitButton.frame = CGRect(x:x0+sp*4+bw*4,y:by,width:bw,height:bh)
        useVRButton.layer.cornerRadius=5
        exitButton.layer.cornerRadius=5
        tenTimesText.text="stop after 10"
        tenTimesText.layer.cornerRadius=5
        tenTimesText.layer.borderWidth = 1.0
        tenTimesText.layer.masksToBounds = true
        tenTimesText.layer.cornerRadius = 5
        if VROnOff==0{
            VRLocationXSlider.isEnabled=false
        }else{
            VRLocationXSlider.isEnabled=true
        }
        if tenTimesOnOff==0{
            tenTimesSwitch.isOn=false
        }else{
            tenTimesSwitch.isOn=true
        }
    }
 

    func reDrawCirclesLines(){
        buttonsToBack()
        view.layer.sublayers?.removeLast()
        view.layer.sublayers?.removeLast()
        view.layer.sublayers?.removeLast()
        view.layer.sublayers?.removeLast()

        drawBackCircles()
        drawLines()
        buttonsToFront()
    }
    func drawLines(){//remove:Bool){
        //線を引く
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0L=ww*1/4 + CGFloat(locationX)
        let x0M=ww/2
        let x0R=ww*3/4 - CGFloat(locationX)
        let y0=wh/2
        let r=wh*(70+13*CGFloat(diameter))/400
        
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        if VROnOff==1{
            uiPath.move(to:CGPoint.init(x: x0L,y: y0 - r))
            uiPath.addLine(to: CGPoint(x:x0L,y:y0 + r))
            uiPath.move(to:CGPoint.init(x: x0R,y: y0 - r))
            uiPath.addLine(to: CGPoint(x:x0R,y:y0 + r))
        }else{
            uiPath.move(to:CGPoint.init(x: x0M,y: y0 - r))
            uiPath.addLine(to: CGPoint(x:x0M,y:y0 + r))
        }
        uiPath.lineWidth=5.0
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth=CGFloat(width)/10.0
        shapeLayer.path = uiPath.cgPath
        self.view.layer.addSublayer(shapeLayer)
    }
    func drawBackCircles(){//remove:Bool){
        let ww=view.bounds.width
        let wh=view.bounds.height
        // 四角形を描画
        let rectangleLayer = CAShapeLayer.init()
        let rectangleFrame = CGRect.init(x: 0, y: 0, width:ww/*/2+wh/2*/, height: wh)
        rectangleLayer.frame = rectangleFrame
        rectangleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        rectangleLayer.fillColor = UIColor.black.cgColor// 四角形の中の色
        rectangleLayer.lineWidth = 2.5
        
        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
        self.view.layer.addSublayer(rectangleLayer)
        // --- 円を描画 ---
        if VROnOff==1{
            draw1circle(lmr: 1, isWhite: false)
            draw1circle(lmr: 0, isWhite: true)
            draw1circle(lmr: 2, isWhite: true)
        }else{
            draw1circle(lmr: 0, isWhite: false)
            draw1circle(lmr: 2, isWhite: false)
            draw1circle(lmr: 1, isWhite: true)
        }
  
        //線を引く
//        let shapeLayer = CAShapeLayer.init()
//        self.view.layer.addSublayer(shapeLayer)
    }
    func draw1circle(lmr:Int,isWhite:Bool){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let circleLayer = CAShapeLayer.init()
        let r=wh*(70+13*CGFloat(diameter))/200
        var x0:CGFloat=0
        if lmr==0{//left
            x0=ww/4 + CGFloat(locationX) - r/2
        }else if lmr==1{//mid
            x0=ww/2-r/2
        }else{//right
            x0=ww*3/4 - CGFloat(locationX) - r/2
        }
//        let x0M=ww/2-r/2
//        let x0L=ww/4 + CGFloat(locationX) - r/2
//        let x0R=ww*3/4 - CGFloat(locationX) - r/2
        let y0=wh/2-r/2
        //print(r,x0,y0)
        let circleFrame = CGRect.init(x:x0,y:y0,width:r,height:r)
        circleLayer.frame = circleFrame
        circleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        if isWhite{
            circleLayer.fillColor = UIColor.white.cgColor// 円の中の色
        }else{
            circleLayer.fillColor = UIColor.black.cgColor// 円の中の色
        }
        circleLayer.lineWidth = 0.5// 輪郭の太さ
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }

}
