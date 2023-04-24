//
//  SetteiViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/20.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class SetteiViewController: UIViewController {
    @IBOutlet weak var stop10Switch: UISwitch!
    
    @IBOutlet weak var lineFixedLabel: UILabel!
    @IBOutlet weak var lineFixedSwitch: UISwitch!
    @IBOutlet weak var lineMovingLabel: UILabel!
    @IBOutlet weak var lineMovingSwitch: UISwitch!
    @IBOutlet weak var stop10Label: UILabel!
    var circleDiameter:Int = 0
    var verticalLineWidth:Int = 0
    var timer: Timer!
    var directionR:Bool=true
    var time=CFAbsoluteTimeGetCurrent()
    var tempdiameter:Int=0
    var circleNumber:Int = 0
    var backImageDots:Int = 0
    var tenTimesOnOff:Int = 1
    var locationX:Int = 0
    var dotsRotationSpeed:Int = 0
    var lineMovingOnOff:Int = 0
    var lineFixedOnOff:Int = 0
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var circleDiameterLabel: UILabel!
    @IBOutlet weak var VRLocationXSlider: UISlider!
    @IBOutlet weak var rotationSpeedSlider: UISlider!
    @IBOutlet weak var grayImage: UIImageView!
    @IBOutlet weak var randomImage1: UIImageView!
    @IBOutlet weak var randomImage2: UIImageView!
    @IBOutlet weak var randomImage: UIImageView!
    @IBAction func onLineFixedSwitch(_ sender: UISwitch) {
        if sender.isOn{
            lineFixedOnOff=1
        }else{
            lineFixedOnOff=0
        }
        UserDefaults.standard.set(lineFixedOnOff,forKey: "lineFixedOnOff")

    }
    
    @IBAction func onLineMovingSwitch(_ sender: UISwitch) {
        if sender.isOn{
            lineMovingOnOff=1
        }else{
            lineMovingOnOff=0
        }
        UserDefaults.standard.set(lineMovingOnOff,forKey: "lineMovingOnOff")
    }
    
    @IBAction func onBackImageSwitch(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "backImageDots")
        backImageDots=UserDefaults.standard.integer(forKey: "backImageDots")
        setRandomImages()
        reDrawCirclesLines()//左行でbackImageDotsをセット
        print("backImageDots:",backImageDots)
        setRotationSpeedSliderOnOff()
    }
    func setDotsRotationSpeedText(){
        if Locale.preferredLanguages.first!.contains("ja"){
            backImageSwitch.setTitle("背景白", forSegmentAt: 0)
            backImageSwitch.setTitle("半玉:" + String(dotsRotationSpeed*5), forSegmentAt: 1)
            backImageSwitch.setTitle("水玉:" + String(dotsRotationSpeed*5), forSegmentAt: 2)
        }else{
            backImageSwitch.setTitle("white", forSegmentAt: 0)
            backImageSwitch.setTitle("half:" + String(dotsRotationSpeed*5), forSegmentAt: 1)
            backImageSwitch.setTitle("dots:" + String(dotsRotationSpeed*5), forSegmentAt: 2)
        }
        rotationSpeedSlider.value=Float(dotsRotationSpeed+72)/144
    }
    @IBAction func onRotationSpeedSlider(_ sender: UISlider) {
        dotsRotationSpeed = Int(sender.value*144) - 72
        print("speed:",dotsRotationSpeed)
        UserDefaults.standard.set(dotsRotationSpeed, forKey: "dotsRotationSpeed")
        setDotsRotationSpeedText()
    }
    @IBOutlet weak var backImageSwitch: UISegmentedControl!
    
    @IBOutlet weak var circleNumberSwitch: UISegmentedControl!
    
    @IBAction func onStop10Switch(_ sender: UISwitch) {
        if sender.isOn{
            tenTimesOnOff=1
        }else{
            tenTimesOnOff=0
        }
        UserDefaults.standard.set(tenTimesOnOff,forKey: "tenTimesOnOff")
    }
    
//    @IBAction func onTenTimeSwitch(_ sender: UISegmentedControl) {
//        print("tentime:",sender.selectedSegmentIndex)
//        tenTimesOnOff=sender.selectedSegmentIndex
//        UserDefaults.standard.set(tenTimesOnOff,forKey: "tenTimesOnOff")
//    }
//    @IBOutlet weak var tenTimesSwitch: UISegmentedControl!
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var diameterSlider: UISlider!
    @IBOutlet weak var lineWidthLabel: UILabel!
    @IBAction func changeDiameter(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            circleDiameterLabel.text="直径:" + String(1+Int(sender.value*9))
        }else{
            circleDiameterLabel.text="Dia:" + String(1+Int(sender.value*9))
        }
        circleDiameter=Int(sender.value*9)
        if(circleDiameter != tempdiameter){
            UserDefaults.standard.set(circleDiameter,forKey: "circleDiameter")
            reDrawCirclesLines()
        }
        tempdiameter=circleDiameter
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
    @IBAction func onLineWidthSlider(_ sender: UISlider) {
        if Locale.preferredLanguages.first!.contains("ja"){
            lineWidthLabel.text="線幅:" + String(Int(sender.value*9))
        }else{
            lineWidthLabel.text="LineW:" + String(Int(sender.value*9))
        }
        verticalLineWidth=Int(sender.value*9)
        UserDefaults.standard.set(verticalLineWidth,forKey: "lineWidth")
        reDrawCirclesLines()
    }
    func setRotationSpeedSliderOnOff()
    {
        if UserDefaults.standard.integer(forKey: "backImageDots")>0{
            rotationSpeedSlider.isEnabled=true
            rotationSpeedSlider.tintColor=UIColor.systemGreen
        }else{
            rotationSpeedSlider.isEnabled=false
            rotationSpeedSlider.tintColor=UIColor.lightGray
        }
    }
    
    func setVRsliderOnOff(){
        if circleNumber==1{
            VRLocationXSlider.isEnabled=true
            VRLocationXSlider.tintColor=UIColor.systemGreen
        }else{
            VRLocationXSlider.isEnabled=false
            VRLocationXSlider.tintColor=UIColor.lightGray
        }
    }
    
    @IBAction func onCircleNumberSwitch(_ sender: UISegmentedControl) {
        circleNumber=sender.selectedSegmentIndex
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "circleNumber")
        reDrawCirclesLines()
        setVRsliderOnOff()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func buttonsToFront(){
        self.view.bringSubviewToFront(exitButton)
//        self.view.bringSubviewToFront(tenTimesSwitch)
        self.view.bringSubviewToFront(circleDiameterLabel)
        self.view.bringSubviewToFront(lineWidthLabel)
        self.view.bringSubviewToFront(stop10Label)
        self.view.bringSubviewToFront(stop10Switch)
        self.view.bringSubviewToFront(lineMovingSwitch)
        self.view.bringSubviewToFront(lineMovingLabel)
        self.view.bringSubviewToFront(lineFixedSwitch)
        self.view.bringSubviewToFront(lineFixedLabel)

        self.view.bringSubviewToFront(diameterSlider)
        self.view.bringSubviewToFront(lineWidthSlider)
        self.view.bringSubviewToFront(VRLocationXSlider)
        self.view.bringSubviewToFront(circleNumberSwitch)
        self.view.bringSubviewToFront(backImageSwitch)
        self.view.bringSubviewToFront(rotationSpeedSlider)
    }
    func buttonsToBack(){
        self.view.sendSubviewToBack(exitButton)
//        self.view.sendSubviewToBack(tenTimesSwitch)
        self.view.sendSubviewToBack(circleDiameterLabel)
        self.view.sendSubviewToBack(lineWidthLabel)
        self.view.sendSubviewToBack(stop10Label)
        self.view.sendSubviewToBack(stop10Switch)
        self.view.sendSubviewToBack(lineMovingSwitch)
        self.view.sendSubviewToBack(lineMovingLabel)
        self.view.sendSubviewToBack(lineFixedSwitch)
        self.view.sendSubviewToBack(lineFixedLabel)
        self.view.sendSubviewToBack(diameterSlider)
        self.view.sendSubviewToBack(lineWidthSlider)
        self.view.sendSubviewToBack(VRLocationXSlider)
        self.view.sendSubviewToBack(circleNumberSwitch)
        self.view.sendSubviewToBack(backImageSwitch)
        self.view.sendSubviewToBack(rotationSpeedSlider)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        verticalLineWidth=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        circleNumber=UserDefaults.standard.integer(forKey:"circleNumber")
        backImageDots=UserDefaults.standard.integer(forKey: "backImageDots")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        lineMovingOnOff=UserDefaults.standard.integer(forKey: "lineMovingOnOff")
        lineFixedOnOff=UserDefaults.standard.integer(forKey: "lineFixedOnOff")
        dotsRotationSpeed=UserDefaults.standard.integer(forKey: "dotsRotationSpeed")
        diameterSlider.value=Float(circleDiameter)/9
        lineWidthSlider.value=Float(verticalLineWidth)/9
        VRLocationXSlider.value=Float(locationX)
        if Locale.preferredLanguages.first!.contains("ja"){
            backImageSwitch.setTitle("背景白", forSegmentAt: 0)
            stop10Label.text="10回で終了"
            circleDiameterLabel.text="直径:" + String(circleDiameter+1)
            lineWidthLabel.text="線幅:" + String(verticalLineWidth)
            lineMovingLabel.text="垂直線：動く"
            lineFixedLabel.text="表示のみ"
        }else{
            backImageSwitch.setTitle("back white", forSegmentAt: 0)
            stop10Label.text="stop at 10 times"
            circleDiameterLabel.text="Dia:" + String(circleDiameter+1)
            lineWidthLabel.text="lineW:" + String(verticalLineWidth)
            lineMovingLabel.text="line : moving"
            lineFixedLabel.text="display only"
        }
        drawBack()
        drawLines(degree:0)
        setButtons()
        buttonsToFront()
        setVRsliderOnOff()
        setRotationSpeedSliderOnOff()
        setDotsRotationSpeedText()
//        grayImage.image=UIImage(named: "black")
//        randomImage.image=UIImage(named:"random_gray")
       setRandomImages()
        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
     }
    func setRandomImages(){
        if backImageDots==1{
            randomImage.image=UIImage(named: "random2")
        }else if backImageDots==2{
            randomImage.image=UIImage(named: "random")
        }else{
            randomImage.image=UIImage(named: "white_black")
        }
    }
    func setLabelProperty(_ label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
//        label.layer.borderWidth = 1.0
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
        let bw=(ww-sp*7)*2/15
        let bh=bw/2.5
        let by=wh-bh-sp
        let x0=leftPadding+sp
        let sliderWidth=(ww-3*bw-sp*7)/3
        VRLocationXSlider.frame =  CGRect(x:x0+sp*5+sliderWidth*2+bw*3,y:by-bh-sp,width:sliderWidth,height: bh)
        setSwitchProperty(circleNumberSwitch, x: x0+sp*4+sliderWidth*2+bw*2, y: by-bh-sp, w: bw, h: bh)

        setLabelProperty(lineWidthLabel, x:x0+sp*2+sliderWidth+bw, y:by-bh-sp, w: bw, h: bh,UIColor.white)
        lineWidthSlider.frame = CGRect(x:x0+sp*3+sliderWidth+bw*2,y:by-bh-sp,width:sliderWidth,height:bh)
        diameterSlider.frame = CGRect(x:x0+sp+bw,y:by-bh-sp,width:sliderWidth,height:bh)
        setLabelProperty(circleDiameterLabel,x:x0, y: by-bh-sp, w: bw, h: bh,UIColor.white)
        stop10Switch.frame=CGRect(x:x0,y:sp*2,width: 50,height: 20)
        setLabelProperty(stop10Label, x: x0+sp+stop10Switch.frame.width, y: sp*2, w: 150, h: stop10Switch.frame.height, UIColor.white)
        lineMovingSwitch.frame=CGRect(x:x0,y:sp*3+stop10Switch.frame.height,width:stop10Switch.frame.width,height: stop10Switch.frame.height)
        setLabelProperty(lineMovingLabel,x:x0+sp+stop10Switch.frame.width,y:sp*3+stop10Switch.frame.height,w:150,h:stop10Switch.frame.height,UIColor.white)
        lineFixedSwitch.frame=CGRect(x:x0,y:sp+lineMovingSwitch.frame.maxY,width:stop10Switch.frame.width,height: stop10Switch.frame.height)
        setLabelProperty(lineFixedLabel,x:x0+sp+stop10Switch.frame.width,y:sp+lineMovingSwitch.frame.maxY,w:150,h:stop10Switch.frame.height,UIColor.white)

        let exitX=x0+sp*5+sliderWidth*3+bw*2
        exitButton.frame = CGRect(x:exitX,y:by,width:bw,height: bh)
   //     rotationSpeedSlider.frame = CGRect(x:x0+(exitX-x0)/2,y:by,width:(exitX-x0)/2-sp,height:bh)
        let backImageSwitchW=lineWidthLabel.frame.maxX-x0
        setSwitchProperty(backImageSwitch, x: x0, y: by, w:backImageSwitchW, h: bh)
        let speedSliderW=exitX-backImageSwitch.frame.maxX-sp*2
        rotationSpeedSlider.frame = CGRect(x:backImageSwitch.frame.maxX+sp,y:by,width:speedSliderW,height:bh)

        exitButton.layer.cornerRadius=5
        circleDiameterLabel.layer.masksToBounds = true
        circleDiameterLabel.layer.cornerRadius = 5
        lineWidthLabel.layer.masksToBounds = true
        lineWidthLabel.layer.cornerRadius = 5
        circleNumberSwitch.selectedSegmentIndex=circleNumber
        backImageSwitch.selectedSegmentIndex=backImageDots
        if tenTimesOnOff==1{
            stop10Switch.isOn=true
        }else{
            stop10Switch.isOn=false
        }
        if lineMovingOnOff==1{
            lineMovingSwitch.isOn=true
        }else{
            lineMovingSwitch.isOn=false
        }
        if lineFixedOnOff==1{
            lineFixedSwitch.isOn=true
        }else{
            lineFixedSwitch.isOn=false
        }
    }
 
    func reDrawCirclesLines(){
        buttonsToBack()
        self.view.layer.sublayers?.removeLast()
 //       print("sublayer2:",view.layer.sublayers?.count)
        drawBack()
        drawLines(degree: 0)
        buttonsToFront()
    }
    func killTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
    }
    var currentDotsDegree:CGFloat=0
    @objc func update(tm: Timer) {//1/60sec
        if backImageDots==0{
            return
        }
        currentDotsDegree += CGFloat(dotsRotationSpeed)/12.0
        reDrawCirclesLines()
//        print("dotsRotationSpeed",dotsRotationSpeed)
    }
    func drawLines(degree:Int){//remove:Bool){
        //線を引く
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0L=ww*1/4 + CGFloat(locationX)
        let x0M=ww/2
        let x0R=ww*3/4 - CGFloat(locationX)
        let y0=wh/2
        var r=wh*(70+13*CGFloat(circleDiameter))/400
        if backImageDots==1{
            r=r*0.45
        }
        
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
        shapeLayer.lineWidth=CGFloat(verticalLineWidth)//+0.5
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
    var initDrawBackBackFlag:Bool=true
    
    func drawBack(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let backImageDots = getUserDefault(str:"backImageDots",ret:0)
        let circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        
        // 四角形を描画
        if initDrawBackBackFlag==true{
            initDrawBackBackFlag=false
            grayImage.frame=CGRect(x:0,y:0,width: ww,height: wh)
        }
        
        let r=wh*(70+13*CGFloat(circleDiameter))/400
        var x0=ww/2
        if circleNumber == 1{
            x0=ww/4 + CGFloat(locationX)
        }
        let y0=wh/2
        if backImageDots==0{
            randomImage1.image=UIImage(named: "white_black")// randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage2.image=UIImage(named: "white_black")//randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
            
        }else{
            randomImage1.image=randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage2.image=randomImage1.image//randomImage.image?.rotatedBy(degree: currentDotsDegree)
            randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
        }
    }
}
