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

public extension Dictionary where Key == MLModelMetadataKey, Value == Any {
    func toFREObject() -> FREObject? {
        guard let fre = FreObjectSwift(className: "com.tuarua.mlane.ModelMetadata") else {
            return nil
        }
        fre.author = self[.author] as? String
        fre.license = self[.license] as? String
        fre.version = self[.versionString] as? String
        fre.rawValue?["description"] = (self[.description] as? String)?.toFREObject()
        return fre.rawValue
    }
}
