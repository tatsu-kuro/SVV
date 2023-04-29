//
//  SVVViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/03.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import CoreMotion

class SVVViewController: UIViewController {
    @IBOutlet weak var randomImage: UIImageView!
    @IBOutlet weak var randomImage1: UIImageView!
    @IBOutlet weak var randomImage2: UIImageView!
    @IBOutlet weak var blackImage: UIImageView!
    
    var lastSensorDegree:Double=0
    let motionManager = CMMotionManager()
    var backImageType:Int=0
    var dotsRotationSpeed:Int=0
    var currentDotsDegree:CGFloat=0
    var cirDiameter:CGFloat = 0
    var lineWidth:Int=0
    var locationX:Int=0
    var circleNumber:Int=0
    var circleDiameter:Int=0
//    var timer: Timer!
    var lbf:Bool=false
    var rbf:Bool=false
    var movingBarFlag:Bool=false
    var resultf:Bool=false
    var directionR:Bool=true
    var dateString:String=""
    var lastrand:Int=0
    var tcount: Int = 0
    var degree:Double=0.0
    var curAcc:Double=0
    var sensorArray = Array<Double>()//sensor
    var displayTimeArray = Array<Double>()
    var displaySensorArray = Array<Double>()
    var degreeArray = Array<Double>()//degree
    var svvArray = Array<Double>()//delta Subjective Visual Vertical
    var actionTimeLast=CFAbsoluteTimeGetCurrent()//tap or remoteController
    var verticalLinef:Bool=false
    var tenTimesOnOff:Int = 1
    var lineMovingOnOff:Int = 1
    var SVVorDisplay:Int = 1
    var displayModeType:Int = 0
    var gyroOnOff:Int = 0


    func setDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd/ HH:mm"
        let date = Date()
        dateString = dateFormatter.string(from: date)
 //       print(dateString)
    }
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        //呼び出されたタイミングを確認する。
        if(sender.state == UIGestureRecognizer.State.began) {
            if sender.location(in: self.view).x<self.view.bounds.width/3{
                lbf=true
                movingBarFlag=false
           //     print("longPressBeginLeft")
             }else if sender.location(in: self.view).x>self.view.bounds.width*2/3{
                rbf=true
                movingBarFlag=false
            //    print("longPressBeginRight")
            }
        } else if (sender.state == UIGestureRecognizer.State.ended) {
            if sender.location(in: self.view).x<self.view.bounds.width/3{
          //      print("longPressEndLeft")
                lbf=false
            }else if sender.location(in: self.view).x>self.view.bounds.width*2/3{
        //        print("longPressEndRight")
                rbf=false
            }
        }
    }
    func returnMain(){
//        if timer?.isValid == true {
//            timer.invalidate()
//        }
        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
        mainView.svvArray.removeAll()
        mainView.degreeArray.removeAll()
        mainView.sensorArray.removeAll()
        mainView.displaySensorArray.removeAll()
        mainView.displayTimeArray.removeAll()
        if SVVorDisplay==0{
            for i in 0..<degreeArray.count{
                mainView.svvArray.append(svvArray[i])
                mainView.degreeArray.append(degreeArray[i])
                mainView.sensorArray.append(sensorArray[i])
            }
        }else{
            for i in 0..<displaySensorArray.count{
                mainView.displaySensorArray.append(displaySensorArray[i])
                mainView.displayTimeArray.append(displayTimeArray[i])
            }
        }
        setDate()
        mainView.dateString=dateString
        if degreeArray.count>0 || displayTimeArray.count > 0 {
            mainView.savedFlag=false
        }
        stopAccelerometer()//version1.9で加えた
        self.present(mainView, animated: false, completion: nil)
        Globalmode=0
        return//iranasasou? <-kokotouruyo?
    }
    @IBAction func singleTap(_ sender: UITapGestureRecognizer) {
        if sender.location(in: self.view).x < self.view.bounds.width/3{
            movingBarFlag=false
            degree -= 1
        }else if sender.location(in: self.view).x < self.view.bounds.width*2/3{
            if(movingBarFlag==true){
                if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                    returnMain()
                }
                actionTimeLast=CFAbsoluteTimeGetCurrent()
                return
            }
            movingBarFlag=true
            appendData()
            if lineMovingOnOff==0{
               degree=getRandom()
            }
            if(tenTimesOnOff==1 && sensorArray.count==10){
                returnMain()
            }
        }else{
            movingBarFlag=false
            degree += 1
        }
    }
 /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)

//     // タイマーを停止する//二重に停止してもmainでも動く。どうして？
//        if let workingTimer = timer{
//         workingTimer.invalidate()
//        }
        Globalmode=0
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        stopAccelerometer()
        Globalmode=0
        stopDisplaylink()
  //      print("stopSensor")
    }
    func getSenserDegree()->Double{
        let s=round(curAcc*10)//shishagonyuu 90degree
        return -s/10.0
    }
    func appendData(){
        let s=round(curAcc*10)//shishagonyuu 90degree
        if SVVorDisplay==0{
            sensorArray.append(-s/10.0)
            degreeArray.append(degree/5.0)
            let v1 = curAcc*10.0 + degree*2.0
            let v2 = round(v1)
            
            svvArray.append(v2/10.0)
//        }else{
//            displaySensorArray.append(-s/10)
//            displayTimeArray.append(CFAbsoluteTimeGetCurrent()-mainTime)
        }
    }
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        if let event = event {
            switch event.subtype {
                
            case .remoteControlTogglePlayPause:
  //              print("TogglePlayPause")
                if(movingBarFlag==true){
                    if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
           //             print("doubleTap")
                        returnMain()
                    }
                    actionTimeLast=CFAbsoluteTimeGetCurrent()
                    return
                }
                movingBarFlag=true
                appendData()
                if(tenTimesOnOff==1 && sensorArray.count==10){
                    returnMain()
                }
 
            case .remoteControlPlay:
 //               print("Play")
                if(movingBarFlag==true){
                    if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                         returnMain()
                    }
                    actionTimeLast=CFAbsoluteTimeGetCurrent()
                    return
                }
                movingBarFlag=true
                appendData()
                if(tenTimesOnOff==1 && sensorArray.count==10){
                    returnMain()
                }
            case .remoteControlNextTrack:
                movingBarFlag=false
                degree += 1
  //              print("NextTrack")
            case .remoteControlPreviousTrack:
                movingBarFlag=false
                degree -= 1
 //               print("PreviousTrack")
            case .remoteControlBeginSeekingBackward:
                lbf=true
                movingBarFlag=false
 //               print("BeginSeekingBackward")
            case .remoteControlEndSeekingBackward:
                lbf=false
//                print("EndSeekingBackward")
            case .remoteControlBeginSeekingForward:
                rbf=true
                movingBarFlag=false
  //              print("BeginSeekingForward")
            case .remoteControlEndSeekingForward:
                rbf=false
 //               print("EndSeekingForward")
            default:
                print("Others")
            }
        }
    }
    let KalQ2:Double = 0.0001
    let KalR2:Double = 0.001
    var KalX2:Double = 0.0
    var KalP2:Double = 0.0
    var KalK2:Double = 0.0
    func KalmeasurementUpdate2()
    {
        KalK2 = (KalP2 + KalQ2) / (KalP2 + KalQ2 + KalR2)
        KalP2 = KalR2 * (KalP2 + KalQ2) / (KalR2 + KalP2 + KalQ2)
    }
    func Kalupdate2(measurement:Double) -> Double//CGFloat) -> CGFloat
    {
        KalmeasurementUpdate2()
        let result = KalX2 + (measurement - KalX2) * KalK2
        KalX2 = result
        return result
    }
    let KalQ1:Double = 0.0001
    let KalR1:Double = 0.001
    var KalX1:Double = 0.0
    var KalP1:Double = 0.0
    var KalK1:Double = 0.0
    func KalmeasurementUpdate1()
    {
        KalK1 = (KalP1 + KalQ1) / (KalP1 + KalQ1 + KalR1)
        KalP1 = KalR1 * (KalP1 + KalQ1) / (KalR1 + KalP1 + KalQ1)
    }
    func Kalupdate1(measurement:Double) -> Double//CGFloat) -> CGFloat
    {
        KalmeasurementUpdate1()
        let result = KalX1 + (measurement - KalX1) * KalK1
        KalX1 = result
        return result
    }
    let KalQ:Double = 0.0001
    let KalR:Double = 0.001
    var KalX:Double = 0.0
    var KalP:Double = 0.0
    var KalK:Double = 0.0
    func KalmeasurementUpdate()
    {
        KalK = (KalP + KalQ) / (KalP + KalQ + KalR)
        KalP = KalR * (KalP + KalQ) / (KalR + KalP + KalQ)
    }
    func Kalupdate(measurement:Double) -> Double//CGFloat) -> CGFloat
    {
        KalmeasurementUpdate()
        let result = KalX + (measurement - KalX) * KalK
        KalX = result
        return result
    }
    /*
    var aData = [0.0,0.0]
    var vData = [0.0,0.0]
    var s = 0.0
    var loopCount:Int = 0
    func distance(acceleration: CMAcceleration) {
        loopCount += 1
         var x = acceleration.x
        var y = acceleration.y
        var z = acceleration.z
        
        x=Kalupdate(measurement: x)
        y=Kalupdate1(measurement: y)
        z=Kalupdate2(measurement: z)

        let pa = aData[loopCount]
        let a = cbrt(x * y * z)
        let dv = (a + pa) * 0.01 * 0.5
        aData.append(a)
        
        let pv = vData[loopCount]
        let v = pv + dv
        let ds = (v + dv) * 0.01 * 0.5
        vData.append(v)
        
        s += ds
        print("")
        print(aData.last!)
        print(vData.last!)
        print(s)
    }*/

    func outputAccelData(acceleration: CMAcceleration){
        var ax=acceleration.x
        var ay=acceleration.y
  //      var az=acceleration.z
        ax=Kalupdate(measurement: ax)
        ay=Kalupdate1(measurement: ay)
    //    az=Kalupdate2(measurement: az)
        let len=sqrt(ax*ax+ay*ay)
        var curAcc_temp=asin(ay/len)
        
        curAcc_temp=curAcc_temp*90.0/(Double.pi/2)
        curAcc=curAcc_temp
        if curAcc<0 && ax>0{
            curAcc = -180 - curAcc
        }else if curAcc>0 && ax>0{
            curAcc = 180 - curAcc
        }
        curAcc = -curAcc
        if SVVorDisplay==1{
            displayTimeArray.append(CFAbsoluteTimeGetCurrent()-mainTime)
            displaySensorArray.append(curAcc)
        }
//        print(String(format:"curAcc:%d,%.1f,%.1f,%.1f,%.1f",displaySensorArray.count,curAcc,ax,ay))
    }
    // センサー取得を止める場合
    func stopAccelerometer(){
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
        print("StopMotionSensor",curAcc.description.count)
    }
    var mainTime=CFAbsoluteTimeGetCurrent()
    var displayLink:CADisplayLink?
    var displayLinkF:Bool=false
    func stopDisplaylink(){
        if displayLinkF==true{
            displayLink?.invalidate()
            displayLinkF=false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        lineWidth=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        circleNumber=UserDefaults.standard.integer(forKey:"circleNumber")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        dotsRotationSpeed=UserDefaults.standard.integer(forKey: "dotsRotationSpeed")
        lineMovingOnOff=UserDefaults.standard.integer(forKey: "lineMovingOnOff")
        SVVorDisplay=UserDefaults.standard.integer(forKey: "SVVorDisplay")
        displayModeType=UserDefaults.standard.integer(forKey: "displayModeType")
        gyroOnOff=UserDefaults.standard.integer(forKey: "gyroOnOff")
        backImageType=UserDefaults.standard.integer(forKey:"backImageType")
  
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        if motionManager.isAccelerometerAvailable {
            // intervalの設定 [sec]
//            if SVVorDisplay==0{
                motionManager.accelerometerUpdateInterval = 0.02
//            }else{
//                motionManager.accelerometerUpdateInterval = 0.03
//            }
            // センサー値の取得開始
            motionManager.startAccelerometerUpdates(
                to: OperationQueue.current!,
                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
                    self.outputAccelData(acceleration: accelData!.acceleration)
//                    self.distance(acceleration: accelData!.acceleration)
                })
        }
        if SVVorDisplay==1{
            //             if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
            //              }
            
            if displayModeType==0{
                randomImage.image=UIImage(named: "random")
            }else if displayModeType==1{
                randomImage.image=UIImage(named: "dots562")
            }else if displayModeType==2{
                randomImage.image=UIImage(named:"dots562t")
            }else if displayModeType==3{
                randomImage.image=UIImage(named: "band562")
            }else{
                randomImage.image=UIImage(named:"band562t")
            }
        }else if backImageType==2{
            randomImage.image=UIImage(named: "random")
        }else if backImageType==1{
            randomImage.image=UIImage(named: "randoms")
        }else{
            randomImage.image=UIImage(named: "white_black")
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.preferredFramesPerSecond = 120
        //displayLinkスタート
        displayLink?.add(to: RunLoop.main, forMode: .common)
        displayLinkF=true
         
//        timer = Timer.scheduledTimer(timeInterval: 1.0/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        movingBarFlag=true
        
        actionTimeLast=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()//
        sensorArray.removeAll()
        degreeArray.removeAll()
        Globalmode=1
        if lineMovingOnOff==0{
            degree = getRandom()
        }else{
            degree -= 1
        }
    }
    
    func getRandom()->Double{
        var ret:Double=0
        while(ret < 150 && ret > -150){
            ret=Double.random(in:-345...345)
        }
        return ret
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var initUpdateFlag:Bool=true
//    var displayWorkingF:Bool=false
    @objc func update(){//tm: Timer) {
        //        print("sublayers:",view.layer.sublayers?.count)
        // if(Globalef==true){//gamepadがない時は変化しないのでチェックせず
        currentDotsDegree=(CFAbsoluteTimeGetCurrent()-mainTime)*CGFloat(dotsRotationSpeed)*5
//        currentDotsDegree += CGFloat(dotsRotationSpeed)/12.0
        if initUpdateFlag==true{
            initUpdateFlag=false
            blackImage.frame=CGRect(x:0,y:0,width: view.bounds.width,height: view.bounds.height)
            if backImageType==0 && SVVorDisplay==0{
                drawWhiteCircle()
            }
        }else{
            view.layer.sublayers?.removeLast()
            if circleNumber==1{
                view.layer.sublayers?.removeLast()
            }
        }
        if backImageType>0 || SVVorDisplay==1{
//            if !displayWorkingF{
//                displayWorkingF=true
                drawDotsCircle()
//                displayWorkingF=false
//            }
        }
        //        print("sublayers:",view.layer.sublayers?.count)

        degree += Double(GlobalStickXvalue)*2
        degree += Double(GlobalPadXvalue)/2
        degree += Double(GlobalButtonBvalue)/2
        degree -= Double(GlobalButtonXvalue)/2
        if(movingBarFlag==true){
            if(GlobalStickXvalue != 0.0 || GlobalPadXvalue != 0.0 || GlobalButtonBvalue != 0.0 || GlobalButtonXvalue != 0.0){
                movingBarFlag=false
            }
        }
      
        let tmpD=getSenserDegree()
        if lastSensorDegree < tmpD - 5 || lastSensorDegree > tmpD + 5{
            lastSensorDegree = tmpD
        }
        if movingBarFlag {
            if(degree > lastSensorDegree*5 + 150){
                directionR=false
            }else if(degree < lastSensorDegree*5 - 150){
                directionR=true
            }
            if lineMovingOnOff==1{
                if(directionR){
                    degree += 2
                }else{
                    degree -= 2
                }
            }
        } else{
            if (rbf) {
                degree += 1
            } else if (lbf) {
                degree -= 1
            }
            if(degree > 600){
                degree = 600
            }else if(degree < -600){
                degree = -600
            }
        }
        if(GlobalButtonAvalue == 0.0 && GlobalButtonAvalueLast != 0.0){
            GlobalButtonAvalueLast=GlobalButtonAvalue
            if movingBarFlag==true{
                if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                    Globalmode=0
                    returnMain()
                }
                actionTimeLast=CFAbsoluteTimeGetCurrent()
                return
            }
            movingBarFlag=true
            appendData()
            if(tenTimesOnOff==1 && sensorArray.count==10){
                Globalmode=0
                GlobalButtonAvalueLast=0
                returnMain()
            }
        }
        GlobalButtonAvalueLast=GlobalButtonAvalue
        
        if(Globalmode == 1){
            if(GlobalButtonYvalue == 0.0 && GlobalButtonYvalueLast1 != 0.0){
                movingBarFlag=true
                GlobalButtonYvalueLast1 = 0.0
                Globalmode=0
                returnMain()
            }else{
                GlobalButtonYvalueLast1=GlobalButtonYvalue
            }
            
        }
        if SVVorDisplay == 0{
            drawLine(degree:Float(degree),remove:true)
        }else{
            drawLine(degree:Float(0),remove:true)
        }
        if CFAbsoluteTimeGetCurrent()-actionTimeLast>300{
            returnMain()
        }
        if SVVorDisplay==1 && CFAbsoluteTimeGetCurrent()-mainTime>60{
            returnMain()
        }
    }

    var initFlag:Bool=true
    func drawLine(degree:Float,remove:Bool){
       //線を引く

        let ww=view.bounds.width
        let wh=view.bounds.height
        var x0=ww/2
        if circleNumber == 1{
            x0=ww*3/4 - CGFloat(locationX)
        }
        let y0=wh/2
//        let r=wh*(70+13*CGFloat(circleDiameter))/400
        
        var r=wh*(70+13*CGFloat(circleDiameter))/400
        if backImageType==1 && SVVorDisplay==0{
            r=r*0.35
        }
        
        let dd:Double=3.14159/900//3600//1800//900
        let x1=CGFloat(Double(r)*sin(Double(degree)*dd))
        let y1=CGFloat(Double(r)*cos(Double(degree)*dd))
        let shapeLayer = CAShapeLayer.init()
        let uiPath = UIBezierPath()
        uiPath.move(to:CGPoint.init(x: x0 + x1,y: y0 - y1))
        uiPath.addLine(to: CGPoint(x:x0 - x1,y:y0 + y1))
        if movingBarFlag==true && SVVorDisplay==0{
            shapeLayer.strokeColor = UIColor.red.cgColor
        } else {
            shapeLayer.strokeColor = UIColor.blue.cgColor
        }
        shapeLayer.path = uiPath.cgPath
        shapeLayer.lineWidth=CGFloat(lineWidth)
        self.view.layer.addSublayer(shapeLayer)
        if circleNumber==1{
            x0=ww/4 + CGFloat(locationX)
            let shapeLayer1 = CAShapeLayer.init()
            let uiPath1 = UIBezierPath()
            uiPath1.move(to:CGPoint.init(x: x0 + x1,y: y0 - y1))
            uiPath1.addLine(to: CGPoint(x:x0 - x1,y:y0 + y1))
            if movingBarFlag==true && SVVorDisplay==0{
                shapeLayer1.strokeColor = UIColor.red.cgColor
            } else {
                shapeLayer1.strokeColor = UIColor.blue.cgColor
            }
            shapeLayer1.path = uiPath1.cgPath
            shapeLayer1.lineWidth=CGFloat(lineWidth)
            self.view.layer.addSublayer(shapeLayer1)
        }
    }

    func drawWhiteCircle(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let r=wh*(70+13*CGFloat(circleDiameter))/400
        var x0=ww/2
        let y0=wh/2
        if circleNumber == 1{
            x0=ww/4+CGFloat(locationX)
        }
        randomImage1.image=UIImage(named:"white_black")
        randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
        self.view.bringSubviewToFront(randomImage1)
        if circleNumber == 1{
            x0=ww*3/4 - CGFloat(locationX)
            randomImage2.image=UIImage(named: "white_black")
            randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage2)
        }
    }
  
     func drawDotsCircle1(){
         let ww=view.bounds.width
         let wh=view.bounds.height
         let r=wh*(70+13*CGFloat(circleDiameter))/400
         var x0=ww/2
         let y0=wh/2
         if circleNumber == 1{
             x0=ww/4+CGFloat(locationX)
         }
         randomImage1.image=randomImage.image?.rotatedBy(degree: currentDotsDegree)
         randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
         self.view.bringSubviewToFront(randomImage1)
         if circleNumber == 1{
             x0=ww*3/4 - CGFloat(locationX)
             randomImage2.image=randomImage1.image//randomImage.image?.rotatedBy(degree: currentDotsDegree)
             randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
             self.view.bringSubviewToFront(randomImage2)
         }
     }
    func trimmingImage(_ image: UIImage,_ trimmingArea: CGRect) -> UIImage {
        let imgRef = image.cgImage?.cropping(to: trimmingArea)
        let trimImage = UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
        return trimImage
    }
    var initDrawBackBackFlag:Bool=true

    func drawDotsCircle(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let backImageType = getUserDefault(str:"backImageType",ret:0)
        let circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        
        let r=wh*(70+13*CGFloat(circleDiameter))/400
        var x0=ww/2
        if circleNumber == 1{
            x0=ww/4 + CGFloat(locationX)
        }
        let y0=wh/2
        if backImageType==0 && SVVorDisplay==0{
            randomImage1.image=UIImage(named: "white_black")
            randomImage2.image=UIImage(named: "white_black")
            randomImage1.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
            self.view.bringSubviewToFront(randomImage1)
            if circleNumber==1{
                x0=ww*3/4 - CGFloat(locationX)
                randomImage2.frame=CGRect(x:x0-r,y:y0-r,width: r*2,height: r*2)
                self.view.bringSubviewToFront(randomImage2)
            }else{
                randomImage2.frame=CGRect(x:0,y:0,width: 0,height: 0)
            }
            
        }else if SVVorDisplay==1{
            if displayModeType>0{
                var imgxy=CGFloat(Int(currentDotsDegree*5)%771)
                if imgxy<0{
                    imgxy += 771
                }
                if displayModeType==1 || displayModeType==3{
                    let image1=trimmingImage(randomImage.image!,CGRect(x:imgxy,y:0,width: 562,height: 562))
                    // 画像を合成する.
                    let image2=UIImage(named: "white_black562")
                    if gyroOnOff==1{
                        let image3 = UIImage.ComposeUIImage(UIImageArray: [image1,image2!], width: 562, height: 562)
                        randomImage1.image = image3!.rotatedBy(degree:getSenserDegree())
                    }else{
                        randomImage1.image = UIImage.ComposeUIImage(UIImageArray: [image1,image2!], width: 562, height: 562)
                    }
                }else{
                    let image1=trimmingImage(randomImage.image!,CGRect(x:0,y:imgxy,width: 562,height: 562))
                    // 画像を合成する.
                    let image2=UIImage(named: "white_black562")
                    if gyroOnOff==1{
                        let image3 = UIImage.ComposeUIImage(UIImageArray: [image1,image2!], width: 562, height: 562)
                        randomImage1.image = image3!.rotatedBy(degree:getSenserDegree())
                    }else{
                        randomImage1.image = UIImage.ComposeUIImage(UIImageArray: [image1,image2!], width: 562, height: 562)
                    }
                }
                    
            }else{
                randomImage1.image=randomImage.image?.rotatedBy(degree: currentDotsDegree)
            }
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
