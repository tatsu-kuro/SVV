//
//  SVVViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/03.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import CoreMotion
//import AudioToolbox
import AVFoundation
import MediaPlayer

class SVVViewController: UIViewController {
    var soundPlayer: AVAudioPlayer? = nil
//    var motionmanagerFlag:Bool=false
    @IBOutlet weak var randomImage1: UIImageView!
    @IBOutlet weak var randomImage2: UIImageView!
    @IBOutlet weak var blackImage: UIImageView!
    var backImage:UIImage!
    var lastSensorDegree:Double=0
    let motionManager = CMMotionManager()
    var SVVModeType:Int=0
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
    var idString:String=""
    var lastrand:Int=0
 //   var tcount: Int = 0
    var degree:Double=0.0
    var curAcc:Double=0
    var curAccz:Double=0
    var sensorArrayOld = Array<Double>()//sensor
    var degreeArrayOld = Array<Double>()//degree
    var svvArrayOld = Array<Double>()//delta Subjective Visual Vertical
    var sensorArray = Array<Double>()//sensor
    var degreeArray = Array<Double>()//degree
    var svvArray = Array<Double>()//delta Subjective Visual Vertical
    var displayTimeArray = Array<Double>()
    var displaySensorArray = Array<Double>()
    var actionTimeLast=CFAbsoluteTimeGetCurrent()//tap or remoteController
    var beepTimeLast=CFAbsoluteTimeGetCurrent()
    var audioPlayer: AVAudioPlayer!
    var verticalLinef:Bool=false
    var tenTimesOnOff:Int = 1
    var lineMovingOnOff:Int = 1
    var SVVorDisplay:Int = 1
    var displayModeType:Int = 0
    var gyroOnOff:Int = 0
    var beepOnOff:Int = 0
    var fps:Int = 0
    var depth3D:Int = 0
    func sound(snd:String){
        if let soundharu = NSDataAsset(name: snd) {
            soundPlayer = try? AVAudioPlayer(data: soundharu.data)
            soundPlayer?.play() // → これで音が鳴る
        }
    }

    func setDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd,HH:mm"
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
        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
        print("doubleTap")
        if SVVorDisplay==0{
            if svvArray.count>0{
                for i in 0..<degreeArray.count{
                    mainView.svvArray.append(svvArray[i])
                    mainView.degreeArray.append(degreeArray[i])
                    mainView.sensorArray.append(sensorArray[i])
                }
                setDate()
            }else{
                for i in 0..<degreeArrayOld.count{
                    mainView.svvArray.append(svvArrayOld[i])
                    mainView.degreeArray.append(degreeArrayOld[i])
                    mainView.sensorArray.append(sensorArrayOld[i])
                }
                mainView.idString=idString
            }
        }else{
            for i in 0..<displaySensorArray.count{
                mainView.displaySensorArray.append(displaySensorArray[i])
                mainView.displayTimeArray.append(displayTimeArray[i])
            }
            setDate()
        }
        mainView.dateString=dateString
        mainView.savedFlag=false

        stopAccelerometer()
        motionManager.stopAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0 // 更新間隔をゼロにする
        Globalmode=0
        stopDisplaylink()
        audioPlayer.stop()
        mainView.startSVVtime=CFAbsoluteTimeGetCurrent()
        print("SVV:returnMain",mainView.sensorArray.count,mainView.displaySensorArray.count)
        self.present(mainView, animated: false, completion: nil)
//        motionmanagerFlag=false
//        return//iranasasou? <-kokotouruyo?
//        performSegue(withIdentifier: "fromSVV", sender: self)
    }
    func tapKettei(){
        sound(snd:"silence")

  //      print("1beepOnOff:",beepOnOff,curAccz,curAcc)
        if(beepOnOff==0||(curAccz<5&&curAccz > -5)){//} && curAcc<3&&curAcc > -3)){
  //          print("2beepOnOff:",beepOnOff,curAccz,curAcc)
            movingBarFlag=true
            appendData()
            if lineMovingOnOff==0{
                degree=getRandom()
            }

            if(tenTimesOnOff==1 && sensorArray.count==10){
                returnMain()
            }
        }
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
            tapKettei()
        }else{
            movingBarFlag=false
            degree += 1
        }
    }
 /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
       
            motionManager.stopAccelerometerUpdates()
            print("Accelerometer updates stopped on back transition.")
        commandCenter.togglePlayPauseCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.previousTrackCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.nextTrackCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.seekForwardCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.seekBackwardCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫

        
//     // タイマーを停止する//二重に停止してもmainでも動く。どうして？
//        if let workingTimer = timer{
//         workingTimer.invalidate()
//        }
        Globalmode=0
    }
    var ww:CGFloat=0
    var wh:CGFloat=0
    var radius:CGFloat=0
    var x0Right:CGFloat=0
    var x0Left:CGFloat=0
    var image3D:UIImage?
    var image3DLeft:UIImage?
    var image3DRight:UIImage?
    override func viewDidAppear(_ animated: Bool) {
        print("didappear****")
        setupRemoteControl()
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("SVV:ViewDidDisapear")
//        motionManager.stopAccelerometerUpdates()
        MotionManager.shared.stopAccelerometerUpdates()
              print("🛑 加速度センサー停止")
    }
    func getSensorDegree()->Double{
        let s=round(curAcc*10)//shishagonyuu 90degree
        return -s/10.0
    }
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        motionManager.shared.stopUpdates()
//    }

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
    let commandCenter = MPRemoteCommandCenter.shared()

    func setupRemoteControl() {
        commandCenter.togglePlayPauseCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget{ [self] event in
            if(movingBarFlag==true){
                if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                    print("doubleTap,stopAccelerometeupdates")
                    motionManager.stopAccelerometerUpdates()
                    returnMain()
                }
                actionTimeLast=CFAbsoluteTimeGetCurrent()
                //    return
            }else{
                tapKettei()
            }
            return .success
        }
        commandCenter.previousTrackCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.previousTrackCommand.addTarget { [self] _ in
            movingBarFlag=false
            degree -= 1
            return .success
        }
        commandCenter.nextTrackCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.nextTrackCommand.addTarget { [self] _ in
            movingBarFlag=false
            degree += 1
            return .success
        }
        commandCenter.seekForwardCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.seekForwardCommand.addTarget { [weak self] event in
            guard let seekEvent = event as? MPSeekCommandEvent else {
                return .commandFailed
            }
            
            switch seekEvent.type{//}.positionTime == 0 {
            case .beginSeeking:
                print("⏪ 早送り開始！")
                self!.rbf=true
                self!.movingBarFlag=false
                case .endSeeking://} else {
                print("⏪ 早送り終了！")
                self!.rbf=false
            @unknown default:
                print("ufo")
            }
            return .success
        }
        commandCenter.seekBackwardCommand.removeTarget(nil) // 既存のターゲットを削除（重複防止）、削除されていても大丈夫
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            guard let seekEvent = event as? MPSeekCommandEvent else {
                return .commandFailed
            }
            
            switch seekEvent.type {
            case .beginSeeking:
                print("⏪ 巻き戻し開始！")
                self!.lbf=true
                self!.movingBarFlag=false
            case .endSeeking:
                print("⏹️ 巻き戻し終了！")
                self!.lbf=false
            @unknown default:
                print("⚠️ 未知のイベント")
            }
            return .success
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    /*
     override func remoteControlReceived(with event: UIEvent?) {
     guard event?.type == .remoteControl else { return }
     if let event = event {
     switch event.subtype {
     
     case .remoteControlTogglePlayPause:
     //              print("TogglePlayPause")
     if(movingBarFlag==true){
     if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
     print("doubleTap,stopAccelerometeupdates")
     motionManager.stopAccelerometerUpdates()
     
     returnMain()
     }
     actionTimeLast=CFAbsoluteTimeGetCurrent()
     return
     }
     tapKettei()
     //                movingBarFlag=true
     //                appendData()
     //                if lineMovingOnOff==0{
     //                   degree=getRandom()
     //                }
     //                if(tenTimesOnOff==1 && sensorArray.count==10){
     //                    returnMain()
     //                }
     case .remoteControlPlay:
 //               print("Play")
                if(movingBarFlag==true){
                    if (CFAbsoluteTimeGetCurrent()-actionTimeLast)<0.3{
                         returnMain()
                    }
                    actionTimeLast=CFAbsoluteTimeGetCurrent()
                    return
                }
                tapKettei()
//                movingBarFlag=true
//                appendData()
//                if lineMovingOnOff==0{
//                   degree=getRandom()
//                }
//                if(tenTimesOnOff==1 && sensorArray.count==10){
//                    returnMain()
//                }
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
    }*/
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
        var az=acceleration.z
        ax=Kalupdate(measurement: ax)
        ay=Kalupdate1(measurement: ay)
        az=Kalupdate2(measurement: az)
        let len=sqrt(ax*ax+ay*ay)
        let lenz=sqrt(ax*ax+az*az)
        curAccz=asin(az/lenz)*90.0/(Double.pi/2)//前後への傾き
        curAcc=asin(ay/len)*90.0/(Double.pi/2)
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
        if(curAccz>5||curAccz < -5){//}||curAcc>3||curAcc < -3){
            tiltFlag=true
            if beepOnOff==1{//} && motionmanagerFlag{
                    if((CFAbsoluteTimeGetCurrent()-beepTimeLast)>0.5){
                    if (audioPlayer.isPlaying) {
                        audioPlayer.stop()
                        audioPlayer.currentTime = 0
                    }
                    print("vibe_sound*****")//,motionmanagerFlag)
//                                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    audioPlayer.play()
                    beepTimeLast=CFAbsoluteTimeGetCurrent()
                }
//            }else{
//                tiltFlag=false
            }
        }else{
         tiltFlag=false
        }
    }
    
    
    /*
     if(curAccz>5||curAccz < -5){//}||curAcc>3||curAcc < -3){
                if(beepOnOff==1){
                    tiltFlag=true
                    if((CFAbsoluteTimeGetCurrent()-beepTimeLast)>0.2){
                        if (audioPlayer.isPlaying) {
                            audioPlayer.stop()
                            audioPlayer.currentTime = 0
                        }
           //             AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        audioPlayer.play()
                        beepTimeLast=CFAbsoluteTimeGetCurrent()
                    }
                }else{
                    tiltFlag=false
                }
            }else{
                tiltFlag=false
            }
     */
    // センサー取得を止める場合
    func stopAccelerometer(){
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
        print("StopMotionSensor",curAcc.description.count)
        motionManager.stopDeviceMotionUpdates()
//        motionManager.accelerometerData = nil
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
    func pasteLine(orgImg:UIImage,startP:CGPoint,endP:CGPoint,color:UIColor) -> UIImage {
        UIGraphicsBeginImageContext(orgImg.size)
        orgImg.draw(at:CGPoint.zero)
        let line = UIBezierPath() // 線
        line.move(to: startP) // 最初の位置
        line.addLine(to:endP)// 次の位置
        line.close()
        color.setStroke()
        line.lineWidth = CGFloat(lineWidth)//width// 線の太さ
        line.stroke()// 線を塗りつぶす
        let image = UIGraphicsGetImageFromCurrentImageContext()// イメージコンテキストからUIImageを作る
        UIGraphicsEndImageContext()  // イメージ処理の終了
        return image!
    }
    func pasteImage(orgImg:UIImage,posx:CGFloat) -> UIImage {
        // イメージ処理の開始]
        UIGraphicsBeginImageContext(orgImg.size)
        orgImg.draw(at:CGPoint.zero)
        let circle = UIBezierPath(arcCenter: CGPoint(x: 281+posx, y: 281), radius: 281+1, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
        UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).setStroke() // 線の色
        circle.lineWidth = abs(posx*2)+2 // 線の太さ
        circle.stroke()// 線を塗りつぶす
        let image = UIGraphicsGetImageFromCurrentImageContext()// イメージコンテキストからUIImageを作る
        UIGraphicsEndImageContext()  // イメージ処理の終了
        return image!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        motionmanagerFlag=true
        //        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
        //        print("SVV:DidLoad",mainView.sensorArray.count,mainView.displaySensorArray.count)
        circleDiameter=UserDefaults.standard.integer(forKey: "circleDiameter")
        lineWidth=UserDefaults.standard.integer(forKey: "lineWidth")
        locationX=UserDefaults.standard.integer(forKey:"VRLocationX")
        circleNumber=UserDefaults.standard.integer(forKey:"circleNumber")
        tenTimesOnOff=UserDefaults.standard.integer(forKey:"tenTimesOnOff")
        dotsRotationSpeed=UserDefaults.standard.integer(forKey: "dotsRotationSpeed")
        lineMovingOnOff=UserDefaults.standard.integer(forKey: "lineMovingOnOff")
        SVVorDisplay=UserDefaults.standard.integer(forKey: "SVVorDisplay")
        displayModeType=UserDefaults.standard.integer(forKey: "displayModeType")
        SVVModeType=UserDefaults.standard.integer(forKey:"SVVModeType")
        gyroOnOff=UserDefaults.standard.integer(forKey: "gyroOnOff")
        beepOnOff=UserDefaults.standard.integer(forKey: "beepOnOff")

        fps=UserDefaults.standard.integer(forKey: "fps")
//        UIApplication.shared.beginReceivingRemoteControlEvents()
//        self.becomeFirstResponder()
        if motionManager.isAccelerometerAvailable {
            // intervalの設定 [sec]
            //            if SVVorDisplay==0{
            //0.01だとセンサー値が拾えない。0.02だと初代SEでも頑張れそう。0.05だとtouchでもいける
            if fps==0 || SVVorDisplay==0{
                motionManager.accelerometerUpdateInterval = 1/20
            }else if fps==1{
                motionManager.accelerometerUpdateInterval = 1/30
            }else if fps==2{
                motionManager.accelerometerUpdateInterval = 1/50
                
            }else{
                motionManager.accelerometerUpdateInterval = 1/100
            }
            // センサー値の取得開始
            // 加速度センサーを開始
                MotionManager.shared.startAccelerometerUpdates { acceleration in
                    self.outputAccelData(acceleration: acceleration) // 自分の関数を呼び出す
                }
//            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelData, error) in
//                guard let acceleration = accelData?.acceleration else { return }
//                self.outputAccelData(acceleration: acceleration)
//            }
            
            
//            motionManager.startAccelerometerUpdates(
//                to: OperationQueue.current!,
//                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
//                    self.outputAccelData(acceleration: accelData!.acceleration)
//                    //                    self.distance(acceleration: accelData!.acceleration)
//                })
        }
        if SVVorDisplay==1{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
            if displayModeType==0{
                backImage=UIImage(named: "random")
            }else if displayModeType==1{
                backImage=UIImage(named: "dotYoko")
            }else if displayModeType==2{
                backImage=UIImage(named:"dotTate")
            }else if displayModeType==3{
                backImage=UIImage(named: "bandYoko")
            }else{
                backImage=UIImage(named:"bandTate")
            }
        }else{
            if SVVModeType==0{
                backImage=UIImage(named: "white_black")
            }else if SVVModeType==1{
                backImage=UIImage(named: "randoms")
            }else{
                backImage=UIImage(named: "random")
            }
        }
        
        image3D=UIImage(named: "white_black_transparent")
        depth3D=UserDefaults.standard.integer(forKey: "depth3D")
        image3DRight=pasteImage(orgImg:image3D!,posx:CGFloat(depth3D))
        image3DLeft=pasteImage(orgImg:image3D!,posx:-CGFloat(depth3D))

        ww=view.bounds.width
        wh=view.bounds.height
        radius=wh*(70+13*CGFloat(circleDiameter)/5)/400
        x0Right=ww/4 + CGFloat(locationX)
        x0Left=ww*3/4 - CGFloat(locationX)

        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.preferredFramesPerSecond = 120
        //displayLinkスタート
        displayLink?.add(to: RunLoop.main, forMode: .common)
        displayLinkF=true

        movingBarFlag=true
        
        actionTimeLast=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
        Globalmode=1
        if lineMovingOnOff==0{
            degree = getRandom()
        }else{
            degree -= 1
        }
        try! audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "beep1", ofType: "wav")!))
        //事前に一度再生をしておかないとず正しく再生されないことがあるのでこいつを呼び出しておく
        audioPlayer.prepareToPlay()
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
    @objc func update(){
        //        print("sublayers:",view.layer.sublayers?.count)
        currentDotsDegree=(CFAbsoluteTimeGetCurrent()-mainTime)*CGFloat(dotsRotationSpeed)*5
        if initUpdateFlag==true{
            initUpdateFlag=false
            blackImage.frame=CGRect(x:0,y:0,width: view.bounds.width,height: view.bounds.height)
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
      
        let tmpD=getSensorDegree()
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
            if lineMovingOnOff==0{
               degree=getRandom()
            }
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
             getLinePoint(degree: Float(degree))
            drawCircle()
        }else{
            getLinePoint(degree:0)
            drawCircle()
        }
        if CFAbsoluteTimeGetCurrent()-actionTimeLast>300{
            returnMain()
        }
        if SVVorDisplay==1 && CFAbsoluteTimeGetCurrent()-mainTime>180{
            returnMain()
        }
    }

    var lineStartPoint:CGPoint!
    var lineEndPoint:CGPoint!
    var lineColor:UIColor!
    func getLinePoint(degree:Float){
       //線を引く
        let x0:CGFloat=281
        let y0:CGFloat=281
        var r:CGFloat=281
        if SVVModeType==1 && SVVorDisplay==0{
            r=r*0.35
        }
        let dd:Double=3.14159/900//3600//1800//900
        let x1=CGFloat(Double(r)*sin(Double(degree)*dd))
        let y1=CGFloat(Double(r)*cos(Double(degree)*dd))
        lineStartPoint=CGPoint.init(x: x0 + x1,y: y0 - y1)
        lineEndPoint=CGPoint(x:x0 - x1,y:y0 + y1)
        if movingBarFlag==true && SVVorDisplay==0{
            lineColor = UIColor.red
        } else {
            lineColor = UIColor.blue
        }
    }
    func trimmingImage(_ image: UIImage,_ trimmingArea: CGRect) -> UIImage {
        let imgRef = image.cgImage?.cropping(to: trimmingArea)
        let trimImage = UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
        return trimImage
    }
    var tiltFlag:Bool=false
    func drawCircle_(){//_ angle:CGFloat){
        let image1=getBackImage()
        let image=pasteLine(orgImg: image1, startP: lineStartPoint, endP: lineEndPoint, color: lineColor)
        if circleNumber==0{
            randomImage1.image=UIImage.ComposeUIImage(UIImageArray: [image,image3D!], width: 562, height: 562)
            randomImage1.frame=CGRect(x:ww/2-radius,y:wh/2-radius,width: radius*2,height: radius*2)
            self.view.bringSubviewToFront(randomImage1)
        }else{
            //右を合成
            randomImage1.image=UIImage.ComposeUIImage(UIImageArray: [image,image3DRight!], width: 562, height: 562)
            randomImage1.frame=CGRect(x:x0Right-radius,y:wh/2-radius,width: radius*2,height: radius*2)
            self.view.bringSubviewToFront(randomImage1)
            //左を合成
            if depth3D==0{
                randomImage2.image=randomImage1.image
            }else{
                randomImage2.image=UIImage.ComposeUIImage(UIImageArray: [image,image3DLeft!], width: 562, height: 562)
            }
            randomImage2.frame=CGRect(x:x0Left-radius,y:wh/2-radius,width: radius*2,height: radius*2)
            self.view.bringSubviewToFront(randomImage2)
        }
    }
    func drawCircle(){//_ angle:CGFloat){
          let image1=getBackImage()
          let image=pasteLine(orgImg: image1, startP: lineStartPoint, endP: lineEndPoint, color: !tiltFlag ? lineColor:UIColor.systemGray5)
//          let image=pasteLine(orgImg: image1, startP: lineStartPoint, endP: lineEndPoint,color: UIColor.systemGray5)
          if circleNumber==0{
              randomImage1.image=UIImage.ComposeUIImage(UIImageArray: [image,image3D!], width: 562, height: 562)
              randomImage1.frame=CGRect(x:ww/2-radius,y:wh/2-radius,width: radius*2,height: radius*2)
              self.view.bringSubviewToFront(randomImage1)
          }else{
              //右を合成
              randomImage1.image=UIImage.ComposeUIImage(UIImageArray: [image,image3DRight!], width: 562, height: 562)
              randomImage1.frame=CGRect(x:x0Right-radius,y:wh/2-radius,width: radius*2,height: radius*2)
              self.view.bringSubviewToFront(randomImage1)
              //左を合成
              if depth3D==0{
                  randomImage2.image=randomImage1.image
              }else{
                  randomImage2.image=UIImage.ComposeUIImage(UIImageArray: [image,image3DLeft!], width: 562, height: 562)
              }
              randomImage2.frame=CGRect(x:x0Left-radius,y:wh/2-radius,width: radius*2,height: radius*2)
              self.view.bringSubviewToFront(randomImage2)
          }
      }
    func getBackImage()->UIImage{

        var image:UIImage!
        if SVVorDisplay==0{//SVV
            if SVVModeType==0{
                image=backImage
            }else{
                image=backImage?.rotatedBy(degree: currentDotsDegree)
            }
        }else{//display
            if displayModeType>0{
                var imgxy=CGFloat(Int(currentDotsDegree*5)%770)
                if imgxy<0{
                    imgxy += 770
                }
                if displayModeType==1 || displayModeType==3{
                    let image3=trimmingImage(backImage!,CGRect(x:imgxy,y:0,width: 562,height: 562))
                    if gyroOnOff==1{
                        image = image3.rotatedBy(degree: getSensorDegree())
                    }else{
                        image=image3
                    }
                }else{
                    let image3=trimmingImage(backImage!,CGRect(x:0,y:imgxy,width: 562,height: 562))
                    if gyroOnOff==1{
                        image = image3.rotatedBy(degree: getSensorDegree())
                    }else{
                        image=image3
                    }
                }
                
            }else{
                image=backImage?.rotatedBy(degree: currentDotsDegree)
            }
            
        }
        return image
    }

}
