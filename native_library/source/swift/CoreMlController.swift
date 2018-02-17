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
    private var models: [String: MLModel] = [:]
    private let backgroundQueue = DispatchQueue(label: "com.tuarua.mlane.backgroundQueue", qos: .background)
    convenience init(context: FreContextSwift) {
        self.init()
        self.context = context
    }

    func compileModel(id: String, path: String) {
        var props: [String: Any] = Dictionary()
        props["id"] = id
        guard let modelUrl = URL(safe: path) else {
            props["error"] = "invalid path"
            let json = JSON(props)
            self.sendEvent(name: ModelEvent.ERROR, value: json.description)
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
                    props["path"] = compiledUrl.absoluteString
                    let json = JSON(props)
                    self.sendEvent(name: ModelEvent.COMPILED, value: json.description)
                } catch {
                    props["error"] = error.localizedDescription
                    let json = JSON(props)
                    self.sendEvent(name: ModelEvent.ERROR, value: json.description)
                }
            } catch let error {
                props["error"] = error.localizedDescription
                let json = JSON(props)
                self.sendEvent(name: ModelEvent.ERROR, value: json.description)
            }
        }
    }
    
    func loadModel(id: String, path: String) {
        var props: [String: Any] = Dictionary()
        props["id"] = id
        backgroundQueue.async {
            do {
                guard let url = URL(safe: path) else {
                    props["error"] = "invalid path"
                    let json = JSON(props)
                    self.sendEvent(name: ModelEvent.ERROR, value: json.description)
                    return
                }
                self.models[id] = try MLModel(contentsOf: url)
                props["path"] = path
                let json = JSON(props)
                self.sendEvent(name: ModelEvent.LOADED, value: json.description)
            } catch let error {
                props["error"] = error.localizedDescription
                let json = JSON(props)
                self.sendEvent(name: ModelEvent.ERROR, value: json.description)
            }
        }
    }
    
    func prediction(id: String, input: [String: MLFeatureValue], maxResults: Int) {
        if let model = models[id] {
            var props: [String: Any] = Dictionary()
            props["id"] = id
            let modelDescription = model.modelDescription
            let featureProvider = BaseInput.init(modelDescription: modelDescription)
            featureProvider.setValues(dictionary: input, context)
            DispatchQueue.main.async {
                do {
                    let prediction = try model.prediction(from: featureProvider)
                    for featureName in prediction.featureNames {
                        var feature: [String: Any] = Dictionary()
                        if let val = prediction.featureValue(for: featureName) {
                            switch val.type {
                            case .dictionary:
                                let dictionaryValue = val.dictionaryValue
                                if dictionaryValue.isEmpty {
                                    feature["dictionaryV"] = [:]
                                } else {
                                    let slicedArray = dictionaryValue.sorted { $0.value > $1.value }.prefix(maxResults)
                                    feature["dictionaryV"] = slicedArray.map { item in
                                        return ["k": item.key, "v": item.value]
                                    }
                                }
                            case .double:
                                feature["doubleV"] = val.doubleValue
                            case .string:
                                feature["stringV"] = val.stringValue
                            case .int64:
                                feature["int64V"] = val.int64Value
                            default:
                                break
                            }
                            // TODO val.imageBufferValue
                            // TODO val.multiArrayValue
                            props[featureName] = feature
                        }
                    }
                    let json = JSON(props)
                    self.sendEvent(name: ModelEvent.RESULT, value: json.description)
                } catch let error {
                    props["error"] = error.localizedDescription
                    let json = JSON(props)
                    self.sendEvent(name: ModelEvent.ERROR, value: json.description)
                }
            }
        }
    }
    
    func getModelDescription(id: String) -> MLModelDescription? {
        return models[id]?.modelDescription
    }
}
