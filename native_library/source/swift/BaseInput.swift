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

import Cocoa
import CoreML
import FreSwift

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class BaseInput: MLFeatureProvider {
    private var inputs: [String: Any?] = [:]
    private var modelDescription: MLModelDescription
    
    var featureNames: Set<String> = []
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        for item in modelDescription.inputDescriptionsByName {
            switch item.value.type {
            case .dictionary:
                if let val = inputs[featureName] as? [AnyHashable: NSNumber] {
                    return try? MLFeatureValue(dictionary: val)
                }
            case .double:
                if let val = inputs[featureName] as? Double {
                    return MLFeatureValue(double: val)
                }
            case .image:
                let val = inputs[featureName] as! CVPixelBuffer
                return MLFeatureValue(pixelBuffer: val)
            case .int64:
                if let val = inputs[featureName] as? Int64 {
                    return MLFeatureValue(int64: val)
                }
            case .invalid:
                break
            case .multiArray:
                if let val = inputs[featureName] as? MLMultiArray {
                    return MLFeatureValue(multiArray: val)
                }
            case .string:
                if let val = inputs[featureName] as? String {
                    return MLFeatureValue(string: val)
                }
            }
        }
        return nil
    }
    
    init(modelDescription: MLModelDescription) {
        self.modelDescription = modelDescription
        for item in modelDescription.inputDescriptionsByName {
            featureNames.insert(item.value.name)
        }
    }
    
    func setValues(dictionary: [String: Any?]) {
        // TODO
    }
    
}
