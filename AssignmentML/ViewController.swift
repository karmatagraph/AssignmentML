//
//  ViewController.swift
//  AssignmentML
//
//  Created by karma on 3/21/22.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // camera setup using AVKit
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
    }


}

