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
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // camera setup using AVKit
        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        // to show the captured video on the view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // we need to set the frame of the preview layer
            previewLayer.frame = self.imageView.bounds
            self.imageView.layer.addSublayer(previewLayer)
        }
        
        
        
        
        
        
        
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
        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: defaultConfig).model) else{return}
        
        let request = VNCoreMLRequest(model: model){
            (finishedReq , error) in
            // check the error and print result
//            print(finishedReq.results)
            // get the prediction
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
            
            DispatchQueue.main.async {
                let confi = Int(firstObservation.confidence*100)
                self.nameLbl.text = firstObservation.identifier + ". Accuracy: " + String(confi)
            }
            print(firstObservation.identifier, firstObservation.confidence)
            
        }
        
        

        // this is responsible for analysing the image
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

