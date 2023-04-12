//
//  ViewController.swift
//  RTMPDemo
//
//  Created by black2w on 2023/2/9.
//

import UIKit
import SVProgressHUD
//import LFLiveKit

class ViewController: UIViewController {
    
    @IBOutlet weak var topToolView: UIView!
    @IBOutlet weak var stateIcon: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    let hostStr = "rtmp://101.133.213.32/live/"
    var hideTimer: Timer?
    var count = 5
    
    var blurView: UIVisualEffectView?
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var urlTxtField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    var state: LFLiveState = .ready
    
    
    //  默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏
    var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.high3)
        videoConfiguration!.autorotate = true
        if UIDevice.current.isIpad {
//            videoConfiguration?.outputImageOrientation = .landscapeLeft
        }
        
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        return session!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configTopToolViewUI()
        configAlertViewUI()
        
        session.delegate = self
        session.preView = self.view
        
        self.requestAccessForVideo()
        self.requestAccessForAudio()
        self.view.backgroundColor = UIColor.clear
        
        self.didTappedBeautyButton(self.beautyButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bView = self.blurView else{
            return
        }
        
        bView.frame.size = CGSize(width: self.view.frame.width, height: 50)
        
    }
    
    func configTopToolViewUI() {
        // 添加毛玻璃
        if self.blurView == nil {
            let blurEffect = UIBlurEffect(style: .light)
            self.blurView = UIVisualEffectView(effect: blurEffect)
            self.blurView!.frame.size = CGSize(width: view.frame.width, height: 50)
            topToolView.insertSubview(self.blurView!, at: 0)
        }

        
        
        stateLabel.text = "未连接"
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        
        stateIcon.layer.cornerRadius = 4.0
        stateIcon.layer.masksToBounds = true
        stateIcon.backgroundColor = UIColor.red
        
        beautyButton.setImage(UIImage(named: "camra_beauty_close"), for: UIControl.State.normal)
        beautyButton.setImage(UIImage(named: "camra_beauty"), for: UIControl.State.selected)
    }

    func configAlertViewUI() {
        alertView.layer.cornerRadius = 15
        alertView.layer.masksToBounds = true
        
        codeTextField.delegate = self
        
        copyButton.layer.cornerRadius = 12
        copyButton.layer.masksToBounds = true
        
        actionButton.layer.cornerRadius = 12
        actionButton.layer.masksToBounds = true
        actionButton.setTitle("开始推流", for: UIControl.State.normal)
        actionButton.setTitle("结束推流", for: UIControl.State.selected)
        
        // 生成随机数
        let random = arc4random_uniform(899999) + 100000
        codeTextField.text = "\(random)"
        urlTxtField.text = hostStr + "\(random)"
    }
    
    func creatHideTimer() {
        if hideTimer == nil {
            print("123 创建定时器")
            hideTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(secondCountDown), userInfo: nil, repeats: true)
            count = 5
        }
    }
    
    @objc func secondCountDown() {
        count -= 1
        print("123 倒计时 \(count)")
        if (count < 0) {
            invalidateTimer()
            print("123 隐藏工具栏")
            topToolView.isHidden = true
        }
    }
    
    func invalidateTimer() {
        if hideTimer != nil && hideTimer?.isValid != nil {
            print("123 销毁定时器")
            hideTimer?.invalidate()
            hideTimer = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first!
        let location = touch.location(in: self.view)
        
        if (alertView.isHidden == false && alertView.frame.contains(location)) {
            return
        }
        
        if topToolView.isHidden == true {
            topToolView.isHidden = false
            creatHideTimer()
        } else {
            count = 5
        }
        
        // 点击隐藏alertView
        if (alertView.isHidden == false) {
            alertView.isHidden = true
            if state == .start {
                creatHideTimer()
            }
        }
    }
    
    @IBAction func didTapCopyButton(_ sender: UIButton) {
        view.endEditing(true)

        UIPasteboard.general.string = urlTxtField.text
        SVProgressHUD.showSuccess(withStatus: "复制成功")
    }
    
    @IBAction func didTapSettingButton(_ sender: UIButton) {
        if alertView.isHidden == true {
            alertView.isHidden = false
            invalidateTimer()
        } else {
            alertView.isHidden = true
            creatHideTimer()
        }
    }
    
    // 开始直播
    @objc @IBAction func didTappedStartLiveButton(_ button: UIButton) -> Void {
        view.endEditing(true)
        if (codeTextField.text?.count ?? 0) <= 0 {
            SVProgressHUD.showError(withStatus: "请输入推流码")
            return
        }
        actionButton.isSelected = !actionButton.isSelected;
        if (actionButton.isSelected) {
            let stream = LFLiveStreamInfo()
            stream.url = urlTxtField.text
            session.startLive(stream)
            alertView.isHidden = true
            creatHideTimer()
        } else {
            session.stopLive()
        }
    }

    
    @objc @IBAction func didTapChangeCameraButton(_ button: UIButton) -> Void {
        view.endEditing(true)
        let devicePositon = session.captureDevicePosition
        session.captureDevicePosition = (devicePositon == AVCaptureDevice.Position.back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
    }
    
    // 美颜
    @objc @IBAction func didTappedBeautyButton(_ button: UIButton) -> Void {
        view.endEditing(true)
        session.beautyFace = !session.beautyFace;
        beautyButton.isSelected = !session.beautyFace
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

extension ViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        urlTxtField.text = hostStr + codeTextField.text!
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
        self.state = state
        switch state {
        case LFLiveState.ready:
            stateLabel.text = "未连接"
            stateIcon.backgroundColor = UIColor.red
            break;
        case LFLiveState.pending:
            stateLabel.text = "连接中"
            stateIcon.backgroundColor = UIColor.orange
            break;
        case LFLiveState.start:
            stateLabel.text = "已连接"
            stateIcon.backgroundColor = UIColor.green
            break;
        case LFLiveState.error:
            stateLabel.text = "连接错误"
            stateIcon.backgroundColor = UIColor.red
            break;
        case LFLiveState.stop:
            stateLabel.text = "未连接"
            stateIcon.backgroundColor = UIColor.red
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

