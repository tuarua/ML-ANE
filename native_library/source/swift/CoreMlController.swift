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

class CoreMlController: NSObject, FreSwiftController {
    var TAG: String? = "CoreMlController"
    var context: FreContextSwift!
    private var model: MLModel?
    private let backgroundQueue = DispatchQueue(label: "com.tuarua.mlane.compileQueue", qos: .background)
    private var maxResults: Int = 5
    convenience init(context: FreContextSwift) {
        self.init()
        self.context = context
    }

    func compileModel(path: String) {
        trace("compile this", path)
        // https://www.appcoda.com/grand-central-dispatch/
        var urlPath: URL?
        if path.starts(with: "file:") {
            urlPath = URL(string: path)
        } else {
            urlPath = URL(fileURLWithPath: path)
        }
        guard let modelUrl = urlPath else {
            self.trace("invalid path")
            self.sendEvent(name: ModelEvent.ERROR, value: "invalid path")
            return
        }
        backgroundQueue.async {
            do {
                let tmpUrl = try MLModel.compileModel(at: modelUrl)
                let fileManager = FileManager.default
                var compiledUrl = modelUrl
                compiledUrl.deleteLastPathComponent()
                compiledUrl.appendPathComponent(tmpUrl.lastPathComponent)
                do {
                    // if the file exists, replace it. Otherwise, copy the file to the destination.
                    if fileManager.fileExists(atPath: compiledUrl.absoluteString) {
                        _ = try fileManager.replaceItemAt(compiledUrl, withItemAt: tmpUrl)
                    } else {
                        try fileManager.copyItem(at: tmpUrl, to: compiledUrl)
                    }
                    
                    self.sendEvent(name: CompileEvent.COMPLETE, value: compiledUrl.absoluteString)
                } catch {
                    self.trace(error.localizedDescription)
                    self.sendEvent(name: ModelEvent.ERROR, value: error.localizedDescription)
                }
            } catch let error {
                self.trace(error.localizedDescription)
                self.sendEvent(name: ModelEvent.ERROR, value: error.localizedDescription)
            }
        }
    }
    
    // this loads the COMPILED MODEL
    func loadModel(path: String) {
        backgroundQueue.async {
            do {
                var urlPath: URL?
                if path.starts(with: "file:") {
                    urlPath = URL(string: path)
                } else {
                    urlPath = URL(fileURLWithPath: path)
                }
                guard let url = urlPath else {
                    self.trace("invalid path")
                    self.sendEvent(name: ModelEvent.ERROR, value: "invalid path")
                    return
                }
                self.model = try MLModel(contentsOf: url)
                if let md = self.model?.modelDescription {
                    let fp = BaseInput.init(modelDescription: md)
                    self.trace(fp.featureValue(for: "image").debugDescription)
                }
                
                
                // try model?.prediction(from: 66 as! MLFeatureProvider)
                // props["description"] = self.model?.modelDescription.debugDescription
                
                
// self.trace("inputDescriptionsByName", self.model?.modelDescription.inputDescriptionsByName.debugDescription)
// self.trace("outputDescriptionsByName", self.model?.modelDescription.outputDescriptionsByName.debugDescription)
// self.trace("predictedFeatureName", self.model?.modelDescription.predictedFeatureName)
// self.trace("predictedProbabilitiesName", self.model?.modelDescription.predictedProbabilitiesName)
// self.trace("metadata", self.model?.modelDescription.metadata.debugDescription)
                
                // self.trace(self.model?.modelDescription.debugDescription ?? "")

                self.sendEvent(name: ModelEvent.LOADED, value: path)
            } catch let error {
                self.trace(error.localizedDescription)
                self.sendEvent(name: ModelEvent.ERROR, value: error.localizedDescription)
            }
        }
    }
    
    var modelDescription: MLModelDescription? {
        return model?.modelDescription
    }
    
    // https://github.com/shingt/BeerClassifier/blob/a93224f1a57b948c501fe2d8b210126e032d076f/iOS/
    // BeerClassifier/ClassificationService.swift#L74
    
    func classifyImage(type: Int, cgImage: CGImage) {
        // let orientation = CGImagePropertyOrientation(image.imageOrientation)
        let ciImage = CIImage.init(cgImage: cgImage)
        backgroundQueue.async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                if let cr = self.classificationRequest {
                   try handler.perform([cr])
                }
            } catch {
                self.sendEvent(name: VisionClassificationEvent.ERROR, value: error.localizedDescription)
            }
        }
    }
    
    lazy private var classificationRequest: VNCoreMLRequest? = {
        do {
            guard let sourceModel = self.model else { return nil }
            let model = try VNCoreMLModel(for: sourceModel)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            self.sendEvent(name: ModelEvent.ERROR, value: error.localizedDescription)
            return nil
        }
    }()
    
    private func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            if let e = error {
                sendEvent(name: VisionClassificationEvent.ERROR, value: e.localizedDescription)
            }
            return
        }
        var props: [String: Any] = Dictionary()
        if results.isEmpty {
            props["results"] = []
        } else {
            let topClassifications = results.prefix(maxResults)
            let descriptions = topClassifications.map { classification in
                return ["i": classification.identifier, "c": classification.confidence]
            }
            props["results"] = descriptions
        }
        let json = JSON(props)
        sendEvent(name: VisionClassificationEvent.RESULT, value: json.description)
    }
    
}
