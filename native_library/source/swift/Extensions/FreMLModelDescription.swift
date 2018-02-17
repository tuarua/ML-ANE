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
        do {
            let ret = try FREObject(className: "com.tuarua.mlane.ModelDescription")
            try ret?.setProp(name: "predictedFeatureName",
                                   value: self.predictedFeatureName)
            try ret?.setProp(name: "predictedProbabilitiesName",
                                   value: self.predictedProbabilitiesName)
            try ret?.setProp(name: "metadata", value: self.metadata.toFREObject())
            let freInputDict = try FREObject(className: "flash.utils.Dictionary")
            for input in self.inputDescriptionsByName {
                try freInputDict?.setProp(name: input.key, value: input.value.toFREObject())
            }
            try ret?.setProp(name: "inputDescriptionsByName", value: freInputDict)
            
            let freOutputDict = try FREObject(className: "flash.utils.Dictionary")
            for output in self.outputDescriptionsByName {
                try freOutputDict?.setProp(name: output.key, value: output.value.toFREObject())
            }
            try ret?.setProp(name: "outputDescriptionsByName", value: freOutputDict)
            return ret
        } catch {
        }
        return nil
    }
}
