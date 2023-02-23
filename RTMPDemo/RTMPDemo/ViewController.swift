//
//  ViewController.swift
//  RTMPDemo
//
//  Created by black2w on 2023/2/9.
//

import UIKit
//import LFLiveKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var urlTxtFld: UITextField!
    
    
    //  默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏
    var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low1)
        if UIDevice.current.isIpad {
//            videoConfiguration?.outputImageOrientation = .landscapeLeft
        }
        
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        return session!
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stateLabel.text = "未连接"
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        
        startLiveButton.setTitleColor(UIColor.red, for:UIControl.State.normal)
        startLiveButton.setTitleColor(UIColor.red, for:UIControl.State.selected)
        startLiveButton.setTitle("开始直播", for: UIControl.State.normal)
        startLiveButton.setTitle("结束直播", for: UIControl.State.selected)
        startLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        
        
        session.delegate = self
        session.preView = self.view
        
        self.requestAccessForVideo()
        self.requestAccessForAudio()
        self.view.backgroundColor = UIColor.clear
        
    }
    


    
    // 开始直播
    @objc @IBAction func didTappedStartLiveButton(_ button: UIButton) -> Void {
        startLiveButton.isSelected = !startLiveButton.isSelected;
        if (startLiveButton.isSelected) {
            startLiveButton.setTitle("结束直播", for: UIControl.State.normal)
            let stream = LFLiveStreamInfo()
            stream.url = urlTxtFld.text!
            session.startLive(stream)
        } else {
            startLiveButton.setTitle("开始直播", for: UIControl.State.normal)
            session.stopLive()
        }
    }

    
    @objc @IBAction func didTapChangeCameraButton(_ button: UIButton) -> Void {
        let devicePositon = session.captureDevicePosition
        session.captureDevicePosition = (devicePositon == AVCaptureDevice.Position.back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
    }
    
    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    
    func orientationDidChange(notifaication: Notification) {
        let deviceOriengation = (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation)!
        if deviceOriengation == .landscapeLeft || deviceOriengation == .landscapeRight {
            print("1234")
        } else {
            print("1234")
        }
    }
}

extension ViewController: LFLiveSessionDelegate {
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        print("debugInfo: \(String(describing: debugInfo?.currentBandwidth))")
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("errorCode: \(errorCode.rawValue)")
    }
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        print("liveStateDidChange: \(state.rawValue)")
        switch state {
        case LFLiveState.ready:
            stateLabel.text = "未连接"
            break;
        case LFLiveState.pending:
            stateLabel.text = "连接中"
            break;
        case LFLiveState.start:
            stateLabel.text = "已连接"
            break;
        case LFLiveState.error:
            stateLabel.text = "连接错误"
            break;
        case LFLiveState.stop:
            stateLabel.text = "未连接"
            break;
        default:
                break;
        }
    }
}

//音视频权限
extension ViewController {
    func requestAccessForVideo() -> Void {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        switch status  {
        // 许可对话没有出现，发起授权许可
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if(granted){
                    DispatchQueue.main.async {
                        self.session.running = true
                    }
                }
            })
            break;
        // 已经开启授权，可继续
        case AVAuthorizationStatus.authorized:
            session.running = true;
            break;
        // 用户明确地拒绝授权，或者相机设备无法访问
        case AVAuthorizationStatus.denied: break
        case AVAuthorizationStatus.restricted:break;
        default:
            break;
        }
    }
    
    func requestAccessForAudio() -> Void {
        let status = AVCaptureDevice.authorizationStatus(for:AVMediaType.audio)
        switch status  {
        // 许可对话没有出现，发起授权许可
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                
            })
            break;
        // 已经开启授权，可继续
        case AVAuthorizationStatus.authorized:
            break;
        // 用户明确地拒绝授权，或者相机设备无法访问
        case AVAuthorizationStatus.denied: break
        case AVAuthorizationStatus.restricted:break;
        default:
            break;
        }
    }
    
}

