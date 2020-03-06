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
import Accelerate
import SwiftyJSON

extension CoreMlController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video) ?? nil
    }
    
    private func setUpCaptureSessionInput() {
        var props = [String: Any]()
        sessionQueue.async {
            guard let device = self.captureDevice(forPosition: .back) else { return }
            do {
                let currentInputs = self.captureSession.inputs
                for input in currentInputs {
                    self.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.canAddInput(input) else { return }
                self.captureSession.addInput(input)
            } catch {
                props["error"] = "no capture device"
                self.dispatchEvent(name: VisionEvent.ERROR, value: JSON(props).description)
            }
        }
    }
    
    private func setUpCaptureSessionOutput() {
        var props = [String: Any]()
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = AVCaptureSession.Preset.high
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
            let queue = DispatchQueue(label: "com.tuarua.mlane.cameraQueue")
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            
            guard self.captureSession.canAddOutput(videoDataOutput) else {
                props["error"] = "cannot add camera output"
                self.dispatchEvent(name: VisionEvent.ERROR, value: JSON(props).description)
                return
            }
            self.captureSession.addOutput(videoDataOutput)
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    private func setUpPreviewLayer(rootViewController: UIViewController, mask: CGImage?) {
        var props = [String: Any]()
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let videoPreviewLayer = videoPreviewLayer,
            let cameraView = cameraView else {
                props["error"] = "cannot add camera input"
                self.dispatchEvent(name: VisionEvent.ERROR, value: JSON(props).description)
                return
        }
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(videoPreviewLayer)
        
        if let mask = mask {
            let newLayer = CALayer()
            newLayer.backgroundColor = UIColor.clear.cgColor
            newLayer.frame = CGRect(x: 0,
                                         y: 0,
                                         width: rootViewController.view.frame.width,
                                         height: rootViewController.view.frame.height)
            newLayer.contents = mask
            for sv in rootViewController.view.subviews {
                if sv.debugDescription.starts(with: "<CTStageView") && sv.layer is CAEAGLLayer {
                    sv.layer.mask = newLayer
                }
            }
            // insert under AIR subView
            rootViewController.view.insertSubview(cameraView, at: 0)
        } else {
            rootViewController.view.addSubview(cameraView)
       }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let visionModel = visionModel,
            let img = CIImage(cmSampleBuffer: sampleBuffer) else { return }
        
        let request = VNCoreMLRequest(model: visionModel, completionHandler: { [weak self] request, error in
            self?.processClassifications(for: request, error: error)
        })
        request.imageCropAndScaleOption = .centerCrop
        userInitiatedQueue.async {
            let handler = VNImageRequestHandler(ciImage: img, orientation: CGImagePropertyOrientation.up)
            do {
                try handler.perform([request])
            } catch { }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results else { return }
        if let classifications = results as? [VNClassificationObservation] {
            if let bestResult = classifications.first(where: { result in result.confidence > 0.5 }),
                let label = bestResult.identifier.split(separator: ",").first {
                visionModelResult["id"] = self.visionModelId
                visionModelResult["lbl"] = String(label)
                visionModelResult["cnf"] = bestResult.confidence
                self.dispatchEvent(name: VisionEvent.RESULT, value: JSON(visionModelResult).description)
            }
        }
    }
    
    func inputFromCamera(rootViewController: UIViewController, id: String, mask: CGImage?) {
        guard let model = models[id] else { return }
        var props = [String: Any]()
        props["id"] = id
        do {
            visionModel = try VNCoreMLModel(for: model)
            visionModelId = id
        } catch {
            props["error"] = "cannot create vision model"
            self.dispatchEvent(name: VisionEvent.ERROR, value: JSON(props).description)
            return
        }
        cameraView = UIView(frame: CGRect(x: 0, y: 0, width: rootViewController.view.frame.width,
                                        height: rootViewController.view.frame.height))
        
        setUpCaptureSessionInput()
        setUpPreviewLayer(rootViewController: rootViewController, mask: mask)
        setUpCaptureSessionOutput()
    }
    
    func closeCamera(rootViewController: UIViewController) {
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        
        videoPreviewLayer?.removeFromSuperlayer()
        cameraView?.removeFromSuperview()
        
        videoPreviewLayer = nil
        cameraView = nil
        
        for sv in rootViewController.view.subviews {
            if sv.debugDescription.starts(with: "<CTStageView") && sv.layer is CAEAGLLayer {
                sv.layer.mask = nil
            }
        }
    }
    
}
