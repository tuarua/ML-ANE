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
import CoreML
import FreSwift

public extension MLModelDescription {
    func toFREObject() -> FREObject? {
        guard let fre = FreObjectSwift(className: "com.tuarua.mlane.FeatureDescription") else {
            return nil
        }
        
        fre.predictedFeatureName = self.predictedFeatureName
        fre.predictedProbabilitiesName = self.predictedProbabilitiesName
        fre.metadata = self.metadata.toFREObject()

        var freInputDict = FREObject(className: "flash.utils.Dictionary")
        for input in self.inputDescriptionsByName {
            freInputDict?[input.key] = input.value.toFREObject()
        }
        fre.inputDescriptionsByName = freInputDict
        
        var freOutputDict = FREObject(className: "flash.utils.Dictionary")
        for output in self.outputDescriptionsByName {
            freOutputDict?[output.key] = output.value.toFREObject()
        }
        fre.outputDescriptionsByName = freOutputDict
        return fre.rawValue
    }
}
