//
//  BaseViewController.swift
//  RTMPDemo
//
//  Created by black2w on 2023/2/23.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addNotificaton()
    }
    

    
    func addNotificaton() -> Void {
        // Do any additional setup after loading the view.
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func orientationDidChange(notifaication: Notification) {
    
    }
    
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }

}
