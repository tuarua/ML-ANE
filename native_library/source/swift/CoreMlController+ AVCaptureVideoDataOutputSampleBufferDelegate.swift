/* Copyright 2018 Tua Rua Ltd.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import FreSwift
import CoreML
import Vision
import AVFoundation

extension CoreMlController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
    }
    
    // UIApplication.shared.keyWindow?.rootViewController
    func beginCapture(rootViewController: UIViewController) { // pass in AIR rvc
        let view = UIView(frame: CGRect(x: 0, y: 0, width: rootViewController.view.frame.width,
                                        height: rootViewController.view.frame.height))
        if let captureDevice = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput.init(device: captureDevice)
                captureSession = AVCaptureSession()
                captureSession.addInput(input)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer.frame = view.layer.bounds
                view.layer.addSublayer(videoPreviewLayer)
                rootViewController.view.addSubview(view)
                
                let videoDataOutput = AVCaptureVideoDataOutput()
                let queue = DispatchQueue(label: "com.tuarua.mlane.cameraQueue")
                videoDataOutput.setSampleBufferDelegate(self, queue: queue)
                guard captureSession.canAddOutput(videoDataOutput) else {
                    trace("ERR canAddOutput false")
                    return
                }
                captureSession.addOutput(videoDataOutput)
                captureSession.startRunning()

            } catch {
                trace("ERR no capture device")
            }
            
        }
    }
}
