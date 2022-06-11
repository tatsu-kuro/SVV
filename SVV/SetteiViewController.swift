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
    var circleNumber:Int = 0
    var backImageDots:Int = 0
    var tenTimesOnOff:Int = 1
    var locationX:Int = 0
    var dotsRotationSpeed:Int = 0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameter: UILabel!
    @IBOutlet weak var VRLocationXSlider: UISlider!
    
    @IBOutlet weak var rotationSpeedSlider: UISlider!
    @IBOutlet weak var randomImage2: UIImageView!
    @IBOutlet weak var randomImage: UIImageView!
    @IBAction func onBackImageSwitch(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "backImageDots")
        reDrawCirclesLines()//左行でbackImageDotsをセット
        print("backImageDots:",backImageDots)
        setRotationSpeedSliderOnOff()
    }
    func setDotsRotationSpeedText(){
        if Locale.preferredLanguages.first!.contains("ja"){
            backImageSwitch.setTitle("水玉 : " + String(dotsRotationSpeed), forSegmentAt: 1)
        }else{
            backImageSwitch.setTitle("dots : " + String(dotsRotationSpeed), forSegmentAt: 1)
        }
        rotationSpeedSlider.value=Float(dotsRotationSpeed+3)/6.0
    }
    @IBAction func onRotationSpeedSlider(_ sender: UISlider) {
        dotsRotationSpeed = Int(sender.value*6) - 3
        print("speed:",dotsRotationSpeed)
        UserDefaults.standard.set(dotsRotationSpeed, forKey: "dotsRotationSpeed")
        setDotsRotationSpeedText()
    }
    @IBOutlet weak var backImageSwitch: UISegmentedControl!
    
    @IBOutlet weak var circleNumberSwitch: UISegmentedControl!
    
    @IBAction func onTenTimeSwitch(_ sender: UISegmentedControl) {
        print("tentime:",sender.selectedSegmentIndex)
        tenTimesOnOff=sender.selectedSegmentIndex
        UserDefaults.standard.set(tenTimesOnOff,forKey: "tenTimesOnOff")
    }
    @IBOutlet weak var tenTimesSwitch: UISegmentedControl!
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var lineWidth: UILabel!
    @IBAction func changeDiameter(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            circleDiameter.text="直径:" + String(Int(sender.value*10))
        }else{
            circleDiameter.text="Dia:" + String(Int(sender.value*10))
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
        if circleNumber == 0{
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
            lineWidth.text="LineW:" + String(Int(sender.value*98)+1)
        }
        width=Int(sender.value*98)+1
        UserDefaults.standard.set(width,forKey: "lineWidth")
        reDrawCirclesLines()
    }
    func setRotationSpeedSliderOnOff()
    {
        if UserDefaults.standard.integer(forKey: "backImageDots")==1{
            rotationSpeedSlider.alpha=1
            rotationSpeedSlider.isEnabled=true
//            rotationSpeedSlider.isHighlighted=true
           }else{
            rotationSpeedSlider.isEnabled=false
            rotationSpeedSlider.alpha=0.4
        }

    }
    func setVRsliderOnOff(){
        if circleNumber==1{
            VRLocationXSlider.alpha=1
            VRLocationXSlider.isEnabled=true
//            VRLocationXSlider.isHighlighted=true
           }else{
            VRLocationXSlider.isEnabled=false
            VRLocationXSlider.alpha=0.4
        }
    }
    
    
    @IBAction func onCircleNumberSwitch(_ sender: UISegmentedControl) {
        circleNumber=sender.selectedSegmentIndex
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "circleNumber")
        setVRsliderOnOff()
        reDrawCirclesLines()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func buttonsToFront(){
        self.view.bringSubviewToFront(exitButton)
        self.view.bringSubviewToFront(tenTimesSwitch)
        self.view.bringSubviewToFront(circleDiameter)
        self.view.bringSubviewToFront(lineWidth)
        self.view.bringSubviewToFront(diameterSlider)
        self.view.bringSubviewToFront(lineWidthSlider)
        self.view.bringSubviewToFront(VRLocationXSlider)
        self.view.bringSubviewToFront(circleNumberSwitch)
        self.view.bringSubviewToFront(backImageSwitch)
        self.view.bringSubviewToFront(rotationSpeedSlider)
    }
    func buttonsToBack(){
        self.view.sendSubviewToBack(exitButton)
        self.view.sendSubviewToBack(tenTimesSwitch)
        self.view.sendSubviewToBack(circleDiameter)
        self.view.sendSubviewToBack(lineWidth)
        self.view.sendSubviewToBack(diameterSlider)
        self.view.sendSubviewToBack(lineWidthSlider)
        self.view.sendSubviewToBack(VRLocationXSlider)
        self.view.sendSubviewToBack(circleNumberSwitch)
        self.view.sendSubviewToBack(backImageSwitch)
        self.view.sendSubviewToBack(rotationSpeedSlider)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        diameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        width=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        circleNumber=UserDefaults.standard.integer(forKey:"circleNumber")
        backImageDots=UserDefaults.standard.integer(forKey: "backImageDots")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        dotsRotationSpeed=UserDefaults.standard.integer(forKey: "dotsRotationSpeed")
        diameterSlider.value=Float(diameter)/10
        lineWidthSlider.value=Float(width-1)/98
        VRLocationXSlider.value=Float(locationX)
        if Locale.preferredLanguages.first!.contains("ja"){
            backImageSwitch.setTitle("白", forSegmentAt: 0)
//            backImageSwitch.setTitle("水玉 : -3", forSegmentAt: 1)
            tenTimesSwitch.setTitle("自動終了無し", forSegmentAt: 0)
            tenTimesSwitch.setTitle("10回で終了", forSegmentAt: 1)

            circleDiameter.text="直径:" + String(diameter)
            lineWidth.text="線幅:" + String(width)
        }else{
            backImageSwitch.setTitle("white", forSegmentAt: 0)
//            backImageSwitch.setTitle("dots : -3", forSegmentAt: 1)

            circleDiameter.text="Dia:" + String(diameter)
            lineWidth.text="lineW:" + String(width)
        }
        drawBack()
        drawLines(degree:0)
        setButtons()
        buttonsToFront()
        setVRsliderOnOff()
        setRotationSpeedSliderOnOff()
        setDotsRotationSpeedText()
     }
    func setLabelProperty(_ label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.backgroundColor = color
    }
    func setSwitchProperty(_ label:UISegmentedControl,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 1
//        label.backgroundColor = UIColor.black
    }
    func setButtons(){
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))
        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
        let sp=ww/120
        let bw=(ww-sp*8)*2/15
        let bh=bw/3.5
        let by=wh-bh-sp
        let x0=leftPadding+sp
        let sliderWidth=(ww-3*bw-sp*6)/3
        VRLocationXSlider.frame =  CGRect(x:x0,y:by-bh-sp,width:sliderWidth,height: bh)
        setSwitchProperty(circleNumberSwitch, x: x0+sp+sliderWidth, y: by-bh-sp, w: bw, h: bh)
        setLabelProperty(lineWidth, x:x0+sp*3+sliderWidth*2+bw, y:by-bh-sp, w: bw, h: bh,UIColor.white)
        lineWidthSlider.frame = CGRect(x:x0+sp*2+sliderWidth+bw,y:x0+sp*2+sliderWidth+bw,width:sliderWidth,height:bh)
        diameterSlider.frame = CGRect(x:x0+sp*4+sliderWidth*2+bw*2,y:by-bh-sp,width:sliderWidth,height:bh)
        rotationSpeedSlider.frame = CGRect(x:x0,y:by,width: sliderWidth,height:bh)
        setLabelProperty(circleDiameter,x:x0+sp*5+sliderWidth*3+bw*2, y: by-bh-sp, w: bw, h: bh,UIColor.white)
        setSwitchProperty(backImageSwitch, x: x0+sliderWidth+sp, y: by, w: sliderWidth+sp+bw, h: bh)
        setSwitchProperty(tenTimesSwitch, x: x0+sliderWidth*2+sp*3+bw, y: by, w: sliderWidth+sp+bw, h: bh)
        exitButton.frame = CGRect(x:x0+sp*5+sliderWidth*3+bw*2,y:by,width:bw,height: bh)
        exitButton.layer.cornerRadius=5
        circleDiameter.layer.masksToBounds = true
        circleDiameter.layer.cornerRadius = 5
        lineWidth.layer.masksToBounds = true
        lineWidth.layer.cornerRadius = 5
        tenTimesSwitch.selectedSegmentIndex=tenTimesOnOff
        circleNumberSwitch.selectedSegmentIndex=circleNumber
        backImageSwitch.selectedSegmentIndex=backImageDots
    }
 
    func reDrawCirclesLines(){
        buttonsToBack()
        if backImageDots==0{
            self.view.layer.sublayers?.removeLast()
        }
        self.view.layer.sublayers?.removeLast()
        backImageDots=UserDefaults.standard.integer(forKey: "backImageDots")

        drawBack()//Circles()
        drawLines(degree: 0)
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
        if circleNumber==1{
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
 
    func drawCircle(x0:CGFloat,y0:CGFloat,r:CGFloat,color:CGColor){
           // --- 円を描画 ---
        let circleLayer = CAShapeLayer.init()
        let circleFrame = CGRect.init(x:x0-r,y:y0-r,width:r*2,height:r*2)
        circleLayer.frame = circleFrame
        circleLayer.strokeColor = UIColor.black.cgColor// 輪郭の色
        circleLayer.fillColor = color//UIColor.black.cgColor// 円の中の色
        circleLayer.lineWidth = 0.5// 輪郭の太さ
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }
    func drawBack(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let backImageDots = getUserDefault(str:"backImageDots",ret:0)
        let circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")

        // 四角形を描画
        let rectangleLayer = CAShapeLayer.init()
        let rectangleFrame = CGRect.init(x: 0, y: 0, width:ww, height: wh)
        rectangleLayer.frame = rectangleFrame
        rectangleLayer.strokeColor = UIColor.systemGray4.cgColor// 輪郭の色
        rectangleLayer.fillColor = UIColor.systemGray4.cgColor// 四角形の中の色
        rectangleLayer.lineWidth = 2.5

        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath


        self.view.layer.addSublayer(rectangleLayer)
        // --- 円を描画 ---
          //let r=wh*180/200
        let r=wh*(70+13*CGFloat(circleDiameter))/400
        var x0=ww/2
        if circleNumber == 1{
            x0=ww/4 + CGFloat(locationX)
        }
        let y0=wh/2
        if backImageDots==0{
            drawCircle(x0: x0, y0: y0, r:r , color: UIColor.white.cgColor)
        }else{
            randomImage.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage)
        }

        if circleNumber == 1{
            x0=ww*3/4 - CGFloat(locationX)
            if backImageDots==0{
                drawCircle(x0: x0, y0: y0, r: r, color: UIColor.white.cgColor)
            }else{
                randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
                self.view.bringSubviewToFront(randomImage2)
            }
        }
     }
}
