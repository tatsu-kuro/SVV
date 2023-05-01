//
//  ViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/03.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import GameController

extension UIImage {
    func rotatedBy(degree: CGFloat) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)

        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
}
/*
extension DateFormatter {
    // テンプレートの定義(例)
    enum Template: String {
        case date = "yMd"     // 2017/1/1
        case time = "Hms"     // 12:39:22
        case full = "yMdkHms" // 2017/1/1,12:39:22
        case onlyHour = "k"   // 17時
        case era = "GG"       // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case weekDay = "EEEE" // 日曜日
    }
    
    func setTemplate(_ template: Template) {
        // optionsは拡張用の引数だが使用されていないため常に0
        dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: .current)
    }
}
*/
// テンプレートから時刻を表示
class ViewController: UIViewController {
 //let fromAppDelegate: AppDelegate = NSApplication.shared().delegate as! AppDelegate
//    let diameter0:Int = 7
//    let width0:Int = 10
    var diameter:Int = 0
    var width:Int = 0
    var soundPlayer: AVAudioPlayer? = nil
    var sensorArray = Array<Double>()//sensor
    var degreeArray = Array<Double>()//degree
    var displaySensorArray = Array<Double>()
    var displayTimeArray = Array<Double>()
    var svvArray = Array<Double>()//delta Subjective Visual Vertical
    var savedFlag:Bool = true
    var dateString:String = ""
    var idStr:String=""
    var idStr0:String=""
    var avesdStr:String=""
    var aveStr:String=""
    var sdStr:String=""
    var svvStrNor:String = ""
    var svvStrNeg:String = ""
    var svvStrPos:String = ""
    var SVVorDisplay:Int = 0

    @IBOutlet weak var resultView: UIImageView!
    var idString:String = ""
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var setteiButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var titleImage: UIImageView!
    
    @IBOutlet weak var displayTextView: UITextView!
    //    @IBOutlet weak var logoImage: UIImageView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        sound(snd:"silence")
    }
    var topPadding:CGFloat = 0
    var bottomPadding:CGFloat = 0
    var leftPadding:CGFloat = 0
    var rightPadding:CGFloat = 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            topPadding = self.view.safeAreaInsets.top
            bottomPadding = self.view.safeAreaInsets.bottom
            leftPadding = self.view.safeAreaInsets.left
            rightPadding = self.view.safeAreaInsets.right
            UserDefaults.standard.set(topPadding,forKey: "topPadding")
            UserDefaults.standard.set(bottomPadding,forKey: "bottomPadding")
            UserDefaults.standard.set(leftPadding,forKey: "leftPadding")
            UserDefaults.standard.set(rightPadding,forKey: "rightPadding")
            print("View:viewDidLayoutSubviews")
            let left=UserDefaults.standard.integer(forKey:"leftPadding")
            print(topPadding,bottomPadding,left,rightPadding)    // iPhoneXなら44, その他は20.0
        }
//        setButtons()
    }
    func writeSVVdata(){
        var text:String=""
        //let str = self.dateString.components(separatedBy: " ")
        if svvArray.count>0{
          text = setSVVData(type: 0) + "\n\n"
        }else{
            text=dateString + "," + idString + "\n"
            text += "time,"
            for i in 0..<displayTimeArray.count{
                let numRound = round(displayTimeArray[i] * 100)/100
                text += String(format:"%.2f",numRound) + ","
            }
            text += "\nangle,"
            for i in 0..<displayTimeArray.count{
                text += String(format:"%.1f",displaySensorArray[i]) + ","
            }
            text += "\n\n"
        }
        let file_name = "SVVdata.txt"
        text += self.loadSVVdata(filename: "SVVdata.txt")
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( file_name )
            do {
                try text.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
            } catch {
                print("SVVdata.txt write err")//エラー処理
            }
        }
    }
    
    @IBAction func saveData(_ sender: Any) {
        sound(snd:"silence")
        if svvArray.count<1 && displaySensorArray.count<1{
            return
        }
        let alert = UIAlertController(title: "SVV", message: "Input ID without space", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
            self.idString=textField.text!
            self.viewDidAppear(true)
            // イメージビューに設定する
            self.savedFlag = true //解析結果がsaveされた
            self.setViews()
            self.writeSVVdata()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
            //         self.idNumber = 1//キャンセルしてもここは通らない？
        }
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.keyboardType = UIKeyboardType.default// .numberPad
        }
        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }
    func getAve(array:Array<Double>)->Double{
        var ave:Double=0
        for i in 0..<array.count{
            ave += array[i]
        }
        return ave/Double(array.count)
    }
    func getSD(array:Array<Double>,svvAv:Double)->Double{
        var svvSd:Double=0
        for i in 0..<array.count {
            svvSd += (array[i]-svvAv)*(array[i]-svvAv)
        }
        svvSd=svvSd/Double(array.count)
        svvSd = sqrt(svvSd)
        return svvSd
    }
    func setSVVData(type:Int) -> String {
        var svvAvNor:Double = 0
        var svvSdNor:Double = 0
        var svvAvNeg:Double = 0
        var svvSdNeg:Double = 0
        var svvAvPos:Double = 0
        var svvSdPos:Double = 0
        var str=dateString + "," + idString + "\n"
        str +=  "range,n,average,SD\n"
        if type==1{
            str=dateString + "   ID:" + idString + "\n\n"
            str += "range    , n,average,SD\n"
        }
        if svvArray.count > 0 {
            var svvArrayNor = Array<Double>()
            var svvArrayNeg = Array<Double>()
            var svvArrayPos = Array<Double>()
            for i in 0..<sensorArray.count{
                if sensorArray[i] < -10{
                    svvArrayNeg.append(svvArray[i])
                }else if sensorArray[i] < 10{
                    svvArrayNor.append(svvArray[i])
                }else{
                    svvArrayPos.append(svvArray[i])
                }
            }
            svvAvNeg=getAve(array: svvArrayNeg)
            svvSdNeg=getSD(array:svvArrayNeg,svvAv: svvAvNeg)
            svvAvNor=getAve(array: svvArrayNor)
            svvSdNor=getSD(array:svvArrayNor,svvAv: svvAvNor)
            svvAvPos=getAve(array: svvArrayPos)
            svvSdPos=getSD(array:svvArrayPos,svvAv: svvAvPos)
            if type==1{
                str += String(format: "     <-10,%02d,%.02f,%.02f\n",svvArrayNeg.count,svvAvNeg,svvSdNeg)
                str += String(format: "-10<= <10,%02d,%.02f,%.02f\n",svvArrayNor.count,svvAvNor,svvSdNor)
                str += String(format: "10<=     ,%02d,%.02f,%.02f\n",svvArrayPos.count,svvAvPos,svvSdPos)
                str += "\n"
            }else{
                str += String(format: " <-10,%d,%.02f,%.02f\n",svvArrayNeg.count,svvAvNeg,svvSdNeg)
                str += String(format: "-10<= <10,%d,%.02f,%.02f\n",svvArrayNor.count,svvAvNor,svvSdNor)
                str += String(format: "10<= ,%d,%.02f,%.02f\n",svvArrayPos.count,svvAvPos,svvSdPos)
            }
        }
        if type==1{
            str += "angle "
        }else{
            str += "angle"
        }
        for i in 0..<degreeArray.count{
            str += String(format:",%.1f",degreeArray[i])
        }
        str += "\nsensor"
        for i in 0..<degreeArray.count{
            str += String(format:",%.1f",sensorArray[i])
        }
        if type==1{
            str += "\nSVV   "
        }else{
            str += "\nSVV"
        }
        for i in 0..<degreeArray.count{
            str += String(format:",%.1f",svvArray[i])
        }
        return str
    }
 
/*    func drawSVVData(width w:CGFloat,height h:CGFloat) -> UIImage {
        let size = CGSize(width:w, height:h)
        // イメージ処理の開始
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        var svvAvNor:Double = 0
        var svvSdNor:Double = 0
        var svvAvNeg:Double = 0
        var svvSdNeg:Double = 0
        var svvAvPos:Double = 0
        var svvSdPos:Double = 0
        let x0=0
        if svvArray.count > 0 {
            var svvArrayNor = Array<Double>()
            var svvArrayNeg = Array<Double>()
            var svvArrayPos = Array<Double>()
            for i in 0..<sensorArray.count{
                if sensorArray[i] < -10{
                    svvArrayNeg.append(svvArray[i])
                }else if sensorArray[i] < 10{
                    svvArrayNor.append(svvArray[i])
                }else{
                    svvArrayPos.append(svvArray[i])
                }
            }
            svvAvNor=getAve(array: svvArrayNor)
            svvSdNor=getSD(array:svvArrayNor,svvAv: svvAvNor)
            svvStrNor = String(format: "AVE:%.02f SD:%.02f(%d)",svvAvNor,svvSdNor,svvArrayNor.count)
            if svvArrayNor.count==0{svvStrNor = "(0)"}
            svvAvNeg=getAve(array: svvArrayNeg)
            svvSdNeg=getSD(array:svvArrayNeg,svvAv: svvAvNeg)
            svvStrNeg = String(format: "AVE:%.02f SD:%.02f(%d)",svvAvNeg,svvSdNeg,svvArrayNeg.count)
            if svvArrayNeg.count==0{svvStrNeg = "(0)"}
            svvAvPos=getAve(array: svvArrayPos)
            svvSdPos=getSD(array:svvArrayPos,svvAv: svvAvPos)
            svvStrPos = String(format: "AVE:%.02f SD:%.02f(%d)",svvAvPos,svvSdPos,svvArrayPos.count)
            if svvArrayPos.count==0{svvStrPos = "(0)"}
        }
        idStr = "ID:" + idString + "  "
        dateString.draw(at: CGPoint(x: x0, y: 0), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 40, weight: UIFont.Weight.regular)])
        idStr.draw(at: CGPoint(x: x0+250*2, y: 0), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 40, weight: UIFont.Weight.regular)])
        
        
        let xd=90
        let x0d=x0+110
        let y0=65//angle, sensor, svv
        let y1=y0+140//<-10
        "<-10".draw(at: CGPoint(x: x0+47*2, y: y1), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 32, weight: UIFont.Weight.regular)])
        svvStrNeg.draw(at: CGPoint(x: x0+100*2, y: y1), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 32, weight: UIFont.Weight.regular)])

        "-10<=  <10".draw(at: CGPoint(x: x0, y: y1+24*2), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 32, weight: UIFont.Weight.regular)])
        svvStrNor.draw(at: CGPoint(x:x0+100*2, y: y1+24*2), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 32, weight: UIFont.Weight.regular)])
        " 10<=".draw(at: CGPoint(x: x0, y: y1+48*2), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 32, weight: UIFont.Weight.regular)])
        svvStrPos.draw(at: CGPoint(x: x0+100*2, y: y1+48*2), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 32, weight: UIFont.Weight.regular)])
         UIColor.black.setStroke()
     
        var dStr:String="angle "// + String(dArray[0]) + " " + String(dArray[1])
        var sStr:String="sensor"// + String(sArray[0]) + " " + String(sArray[1])
        var vStr:String="S V V"// + String(vArray[0]) + " " + String(vArray[1])
        dStr.draw(at: CGPoint(x: x0, y: y0), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.regular)])
        sStr.draw(at: CGPoint(x: x0, y: y0+22*2), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.regular)])
        vStr.draw(at: CGPoint(x: x0, y: y0+44*2), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.regular)])
       
        for i in 0..<10{//vArray.count{
            if(i<degreeArray.count){
                dStr=String(format:"%.1f",degreeArray[i])
                sStr=String(sensorArray[i])
                vStr=String(svvArray[i])
            }else{
                dStr="---"
                sStr="---"
                vStr="---"
            }
            dStr.draw(at: CGPoint(x: x0d+i*xd, y: y0), withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.regular)])
            sStr.draw(at: CGPoint(x: x0d+i*xd, y: y0+22*2), withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.regular)])
            vStr.draw(at: CGPoint(x: x0d+i*xd, y: y0+44*2), withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.regular)])

        }
      // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
 */
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        sound(snd:"silence")
        _ = getUserDefault(str:"circleDiameter",ret:7)//if not exist, make
        _ = getUserDefault(str:"lineWidth",ret:3)
        _ = getUserDefault(str:"circleNumber",ret:1)
        _ = getUserDefault(str:"backImageType",ret:0)
        _ = getUserDefault(str: "displayModeType", ret: 0)
        _ = getUserDefault(str:"VRLocationX",ret:0)
        _ = getUserDefault(str:"tenTimesOnOff",ret:1)
        _ = getUserDefault(str:"lineMovingOnOff",ret:1)
        _ = getUserDefault(str:"SVVorDisplay",ret:0)
        _ = getUserDefault(str:"dotsRotationSpeed", ret: 10)
        _ = getUserDefault(str: "gyroOnOff", ret: 0)
        _ = getUserDefault(str: "displayModeType",ret:1)
        setupGameController()
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func loadSVVdata(filename:String)->String{
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {

            let path_file_name = dir.appendingPathComponent( filename )

            do {

                let text = try String( contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                return text

            } catch {
                print("SVVdata read error")//エラー処理
            }
        }
        return ""
    }
    // Setup: Game Controller
    func setupGameController() {
        NotificationCenter.default.addObserver(
                self, selector: #selector(self.handleControllerDidConnect),
                name: NSNotification.Name.GCControllerDidConnect, object: nil)
          
        NotificationCenter.default.addObserver(
              self, selector: #selector(self.handleControllerDidDisconnect),
              name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
          
        guard let controller = GCController.controllers().first else {
              return
        }
        registerGameController(controller)
    }
//    func setRight(but:UIButton){
//        let ww=view.bounds.width
//        let wh=view.bounds.height
//        let bw=ww/6
//        let bh=bw*15/44
//        let sp=(ww/6)/6
//        let by=wh-bh-sp*2/3
//        but.frame = CGRect(x: sp*5+bw*4, y: by, width: bw, height: bh)
//    }
    func setButtons(){
        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?
        let logoh=ww*84/1300
        let sp=ww/120
        let bw=(ww-sp*6)/5
        let bh=bw/3.5
        let by=wh-bh-sp
//        logoImage.frame = CGRect(x:leftPadding+0,y:0,width:ww,height:logoh)
        listButton.frame = CGRect(x:leftPadding+sp, y: by, width: bw, height: bh)
        saveButton.frame = CGRect(x:leftPadding+sp*2+bw*1,y:by,width:bw,height:bh)
        startButton.frame = CGRect(x:leftPadding+sp*3+bw*2, y: by, width: bw, height: bh)//440*150
        setteiButton.frame = CGRect(x:leftPadding+sp*4+bw*3,y:by,width:bw,height:bh)
        helpButton.frame = CGRect(x:leftPadding+sp*5+bw*4,y:by,width:bw,height:bh)
        titleImage.frame = CGRect(x:leftPadding+0, y: logoh, width: ww, height: wh-logoh-bh*3/2)
        listButton.layer.cornerRadius=5
        saveButton.layer.cornerRadius=5
        startButton.layer.cornerRadius=5
        setteiButton.layer.cornerRadius=5
        helpButton.layer.cornerRadius=5
        resultView.frame=CGRect(x:leftPadding+sp*2, y: sp*3, width: ww-sp*4, height: wh-sp*4-bh)
        displayTextView.frame=CGRect(x:leftPadding+sp, y: topPadding+sp, width: ww-sp*2, height: wh-sp*3-bh)
    }
    func setViews(){
        if sensorArray.count==0 && displaySensorArray.count==0{
            SVVorDisplay = getUserDefault(str:"SVVorDisplay",ret:0)
            if SVVorDisplay==0{
                titleImage.image = UIImage(named: "svvhead")
            }else{
                titleImage.image = UIImage(named: "svvheadDisplay")
            }
            titleImage.alpha=1
            resultView.alpha=0
            displayTextView.alpha=0
        }else if sensorArray.count>0{
            titleImage.alpha=0
            resultView.alpha=0
            displayTextView.alpha=1
            displayTextView.font=UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
            displayTextView.text!=setSVVData(type:1)
//            resultView.image=drawSVVData(width: 1000, height: 340)
        }else{
            titleImage.alpha=0
            resultView.alpha=0
            displayTextView.alpha=1
            var str:String=dateString + " ID:" + idString + "\n(time)angle:"
            for i in 0..<displayTimeArray.count{
                let numRound = round(displayTimeArray[i] * 100)/100
                str += "(" + String(format:"%.2f",numRound) + ")"
                str += String(format:"%.1f",displaySensorArray[i]) + ","
            }
            displayTextView.font=UIFont.monospacedSystemFont(ofSize: 12.0, weight: .regular)
            displayTextView.text! = str
        }
    }
    var timer: Timer!
    @objc func update(tm: Timer) {
        var str:String="(time)angle:"
        for i in 0..<displayTimeArray.count{
            str += "(" + String(format:"%.2f",displayTimeArray[i]) + ")"
            str += String(format:"%.1f",displaySensorArray[i]) + ","
        }
        displayTextView.text=str
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = false//スリープする
        print("View:viewDidAppear",sensorArray.count,displaySensorArray.count)
        setButtons()
        setViews()
     }
    func sound(snd:String){
        if let soundharu = NSDataAsset(name: snd) {
            soundPlayer = try? AVAudioPlayer(data: soundharu.data)
            soundPlayer?.play() // → これで音が鳴る
        }
    }
    
    @IBAction func startSVV(_ sender: Any) {
        //print("startSVV : ",savedFlag)
        sound(snd:"silence")
//リモートコントローラーからは”LIST"button
        let buttonTitle=(sender as! UIButton).currentTitle
        if savedFlag == false && buttonTitle=="START"{
            //setButtons(mode: false)
            let alert = UIAlertController(
                title: "You are erasing SVV Data.",
                message: "OK ?",
                preferredStyle: .alert)
            // アラートにボタンをつける
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                //self.setButtons(mode: false)
                self.savedFlag=false
                self.segueSVV()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler:{ action in
                //self.setButtons(mode: true)
                //         print("****cancel")
            }))
            // アラート表示
            self.present(alert, animated: true, completion: nil)
            //１：直ぐここと２を通る
        }else if savedFlag == false{
            idString="temp"
            writeSVVdata()
            self.segueSVV()
        }else{
            self.segueSVV()
        }
        //２：直ぐここを通る
    }
    func segueSVV(){
        print("segueSVV",sensorArray.count,displaySensorArray.count)
        let nextView = storyboard?.instantiateViewController(withIdentifier: "SVV") as! SVVViewController
        self.present(nextView, animated: true, completion: nil)
     }

    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        if let event = event {
            switch event.subtype {
            
            case .remoteControlPlay:
                //               print("Play")
                startSVV(listButton!)
            case .remoteControlPause:
                print("Pause")
            case .remoteControlStop:
                print("Stop")
            case .remoteControlTogglePlayPause:
                //             print("TogglePlayPause")
                startSVV(listButton!)
            case .remoteControlNextTrack:
                print("NextTrack")
            case .remoteControlPreviousTrack:
                print("PreviousTrack")
            case .remoteControlBeginSeekingBackward:
                print("BeginSeekingBackward")
            case .remoteControlEndSeekingBackward:
                print("EndSeekingBackward")
            case .remoteControlBeginSeekingForward:
                print("BeginSeekingForward")
            case .remoteControlEndSeekingForward:
                print("EndSeekingForward")
            default:
                print("Others")
            }
        }
    }
    @IBAction func returnToMe(segue: UIStoryboardSegue) {
        print("returnToMe")
        if let vc = segue.source as? SetteiViewController {
            let SetteiViewController:SetteiViewController = vc
            if SetteiViewController.timer?.isValid == true {
                SetteiViewController.timer.invalidate()
            }
        }
    }
}
