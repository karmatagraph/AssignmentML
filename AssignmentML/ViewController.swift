//
//  ViewController.swift
//  AssignmentML
//
//  Created by karma on 3/21/22.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // camera setup using AVKit
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        // to show the captured video on the view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        
        // we need to set the frame of the preview layer
        previewLayer.frame = view.frame
        
        // monitoring every frame captured by the camera
        let dataOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(dataOutput)
        // monitor the frame
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    }
        
        
        

    // delegate method that notifies when a frame is captured
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("camera was able to capture a frame: \(Date())")
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        //config for model
        let defaultConfig = MLModelConfiguration()
        // create model
        guard let model = try? VNCoreMLModel(for: SqueezeNet(configuration: defaultConfig).model) else{return}
        
        let request = VNCoreMLRequest(model: model){
            (finishedReq , error) in
            // check the error and print result
            print(finishedReq.results)
        }

        // this is responsible for analysing the image
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

