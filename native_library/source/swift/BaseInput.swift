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

import CoreML
import FreSwift

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class BaseInput: MLFeatureProvider {
    private var inputs: [String: MLFeatureValue] = [:]
    var featureNames: Set<String> = []
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return inputs[featureName]
    }
    
    init(modelDescription: MLModelDescription) {
        for item in modelDescription.inputDescriptionsByName {
            featureNames.insert(item.value.name)
        }
    }
    
    func setValues(dictionary: [String: MLFeatureValue], _ context: FreContextSwift? = nil) {
        inputs = dictionary
    }
    
}
