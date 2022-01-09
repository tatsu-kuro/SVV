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
        if Locale.preferredLanguages.first!.contains("ja"){
            circleDiameter.text="直径:" + String(Int(sender.value*10))
        }else{
            circleDiameter.text="Diameter:" + String(Int(sender.value*10))
        }
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
    
    @IBAction func onChangeVRslider(_ sender: UISlider) {
        if VROnOff == 0{
            return
        }
        locationX=Int(sender.value)
        UserDefaults.standard.set(locationX,forKey: "VRLocationX")
        reDrawCirclesLines()
    }
    @IBAction func setWidth(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            lineWidth.text="線幅:" + String(Int(sender.value*98)+1)
        }else{
            lineWidth.text="LineWidth:" + String(Int(sender.value*98)+1)
        }
        width=Int(sender.value*98)+1
        UserDefaults.standard.set(width,forKey: "lineWidth")
        reDrawCirclesLines()
    }
    func setVRsliderONOFF(){
        if VROnOff==1{
            VRLocationXSlider.isHidden=false
            VRLocationXSlider.isHighlighted=true
        }else{
            VRLocationXSlider.isHidden=true
        }
    }
    
    @IBAction func onUseVRButton(_ sender: Any) {
        if VROnOff==0{
            VROnOff=1
        }else{
            VROnOff=0
        }
        setVRsliderONOFF()
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
        if Locale.preferredLanguages.first!.contains("ja"){
            circleDiameter.text="直径:" + String(diameter)
            lineWidth.text="線幅:" + String(width)
        }else{
            circleDiameter.text="Diameter:" + String(diameter)
            lineWidth.text="lineWidth:" + String(width)
        }
        drawBackCircles()
        drawLines(degree:-10)
        setButtons()
        buttonsToFront()
        setVRsliderONOFF()
     }
    func setLabelProperty(_ label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.backgroundColor = color
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
        setLabelProperty(tenTimesText,x:xCenter+sp+switchWidth,y:by,w:x0+sp*2+bw*4-xCenter-switchWidth,h:bh,UIColor.white)
        VRLocationXSlider.frame = CGRect(x:x0,y:by,width:xCenter-bw-sp-x0,height: bh)
        setLabelProperty(circleDiameter,x:x0+sp*4+bw*4, y: by-bh-sp, w: bw, h: bh,UIColor.white)
//        circleDiameter.frame = CGRect(x:x0+sp*4+bw*4, y: by-bh-sp, width: bw, height: bh)
        diameterSlider.frame = CGRect(x:xCenter+sp,y:by-bh-sp,width:xCenter-bw-sp-x0,height:bh)
 //        setLabelProperty(lightLabel,x:x0,y:by1,w:bw,h:bh,UIColor.white)
        setLabelProperty(lineWidth,x:xCenter-bw, y:by-bh-sp, w: bw, h: bh,UIColor.white)
        lineWidthSlider.frame = CGRect(x:x0, y: by-bh-sp, width: xCenter-bw-sp-x0, height: bh)
  
        useVRButton.frame = CGRect(x:xCenter-bw,y:by,width:bw,height:bh)
        exitButton.frame = CGRect(x:x0+sp*4+bw*4,y:by,width:bw,height:bh)
        useVRButton.layer.cornerRadius=5
        exitButton.layer.cornerRadius=5
        tenTimesText.layer.masksToBounds = true
        tenTimesText.layer.cornerRadius = 5
        circleDiameter.layer.masksToBounds = true
        circleDiameter.layer.cornerRadius = 5
        lineWidth.layer.masksToBounds = true
        lineWidth.layer.cornerRadius = 5
        if tenTimesOnOff==0{
            tenTimesSwitch.isOn=false
        }else{
            tenTimesSwitch.isOn=true
        }
    }
 
    func reDrawCirclesLines(){
        buttonsToBack()
        self.view.layer.sublayers?.removeLast()
        self.view.layer.sublayers?.removeLast()
        self.view.layer.sublayers?.removeLast()
        self.view.layer.sublayers?.removeLast()

        drawBackCircles()
        drawLines(degree: -10)
        buttonsToFront()
    }

    func drawLines(degree:Int){//remove:Bool){
        //線を引く
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0L=ww*1/4 + CGFloat(locationX)
        let x0M=ww/2
        let x0R=ww*3/4 - CGFloat(locationX)
        let y0=wh/2
        let r=wh*(70+13*CGFloat(diameter))/400
        
        let dd:Double=3.14159/900
        let x1=CGFloat(Double(r)*sin(Double(degree)*dd))
        let y1=CGFloat(Double(r)*cos(Double(degree)*dd))
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        if VROnOff==1{
            uiPath.move(to:CGPoint.init(x: x0L+x1,y: y0 - y1))
            uiPath.addLine(to: CGPoint(x:x0L-x1,y:y0 + y1))
            uiPath.move(to:CGPoint.init(x: x0R+x1,y: y0 - y1))
            uiPath.addLine(to: CGPoint(x:x0R-x1,y:y0 + y1))
        }else{
            uiPath.move(to:CGPoint.init(x: x0M+x1,y: y0 - y1))
            uiPath.addLine(to: CGPoint(x:x0M-x1,y:y0 + y1))
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
        rectangleLayer.fillColor = UIColor.systemGray4.cgColor// 四角形の中の色
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
        circleLayer.strokeColor = UIColor.systemGray4.cgColor// 輪郭の色
        if isWhite{
            circleLayer.fillColor = UIColor.white.cgColor// 円の中の色
        }else{
            circleLayer.fillColor = UIColor.systemGray4.cgColor// 円の中の色
        }
        circleLayer.lineWidth = 0.5// 輪郭の太さ
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }

}
