//
//  ImagePickerViewController.swift
//  SVV
//
//  Created by kuroda tatsuaki on 2019/07/07.
//  Copyright © 2019 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import MessageUI

class ImagePickerViewController: UIViewController, MFMailComposeViewControllerDelegate{

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var gomiButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setButtons_init()
        textView.font=UIFont.monospacedSystemFont(ofSize: 14.0, weight: .regular)
        textView.text=loadSVVdata(filename: "SVVdata.txt")
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
                return text//print( "SVVdata:",text )
            } catch {
                print("SVVdata read error")//エラー処理
            }
        }
        return ""
    }
    func setButtons_init(){
        let leftPadding=CGFloat( UserDefaults.standard.integer(forKey:"leftPadding"))
        let rightPadding=CGFloat(UserDefaults.standard.integer(forKey:"rightPadding"))
        let topPadding=CGFloat(UserDefaults.standard.integer(forKey:"topPadding"))//anytime 0
        let bottomPadding=CGFloat(UserDefaults.standard.integer(forKey:"bottomPadding"))

        let ww=view.bounds.width-leftPadding-rightPadding
        let wh=view.bounds.height-topPadding-bottomPadding//topPadding is 0 anytime?

        var sp=ww/120
        let bw=(ww-sp*6)/5
        let bh=bw/3.5
        let by=wh-bh-sp
        
        mailButton.frame = CGRect(x:leftPadding+sp,y:by,width:bw,height:bh)
        gomiButton.frame = CGRect(x:leftPadding+sp*2+bw*1, y: by, width: bw, height: bh)//440*150
        exitButton.frame = CGRect(x:leftPadding+sp*5+bw*4, y: by, width:bw, height: bh)

        mailButton.layer.cornerRadius=5
        gomiButton.layer.cornerRadius=5
        exitButton.layer.cornerRadius=5
        sp = sp/2
        self.textView.frame = CGRect(x:leftPadding+sp,y:sp,width:ww-2*sp,height:wh-4*sp-bh)
        let text:String=loadSVVdata(filename: "SVVdata.txt")
        self.textView.text=text
    }

    @IBAction func mailOne(_ sender: Any) {
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("SVV")
    
        mailViewController.setMessageBody(textView.text, isHTML: false)
        present(mailViewController, animated: true, completion: nil)
    }
 
    @IBAction func deleOne(_ sender: Any) {
        let alert = UIAlertController(
            title: "Erasing all Data !",
            message: "OK ?",
            preferredStyle: .alert)
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let file_name = "SVVdata.txt"
            let text = ""//self.loadSVVdata(filename: "SVVdata.txt")

            if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                self.textView.text=""
                let path_file_name = dir.appendingPathComponent( file_name )

                do {
                    try text.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )

                } catch {
                    print("SVVdata.txt write err")//エラー処理
                }
            }
        
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler:{ action in
           
        }))
        // アラート表示
        self.present(alert, animated: true, completion: nil)
        //１：直ぐここと２を通る

    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {//errorの時に通る
        
        switch result {
        case .cancelled:
            print("cancel")
        case .saved:
            print("save")
        case .sent:
            print("send")
        case .failed:
            print("fail")
        default:
            print("error")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
