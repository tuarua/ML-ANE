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

public extension MLFeatureDescription {
    func toFREObject() -> FREObject? {
        do {
            let ret = try FREObject(className: "com.tuarua.mlane.FeatureDescription")
            try ret?.setProp(name: "name", value: name)
            try ret?.setProp(name: "type", value: type.rawValue)
            try ret?.setProp(name: "isOptional", value: isOptional)
            
            if let imageConstraint = imageConstraint {
                try ret?.setProp(name: "imageConstraint", value: imageConstraint.toFREObject())
            } else if let dictionaryConstraint = dictionaryConstraint {
                try ret?.setProp(name: "dictionaryConstraint", value: dictionaryConstraint.toFREObject())
            }
            
            // // multiArrayConstraint
            
            return ret
        } catch {
        }
        return nil
    }
}
