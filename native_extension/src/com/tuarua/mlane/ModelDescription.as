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

package com.tuarua.mlane {
import flash.utils.Dictionary;
[RemoteClass(alias="com.tuarua.mlane.ModelDescription")]
public class ModelDescription {
    /** Name of the primary target / predicted output feature in the output descriptions */
    public var predictedFeatureName:String;
    /** Key for all predicted probabilities stored as a MLFeatureTypeDictionary in the output descriptions */
    public var predictedProbabilitiesName:String;
    /** Description of the inputs to the model */
    public var inputDescriptionsByName:Dictionary; //FeatureDescription
    /** Description of the outputs to the model */
    public var outputDescriptionsByName:Dictionary; //FeatureDescription
    /** Optional metadata describing the model */
    public var metadata:ModelMetadata;
    /** @private */
    public function ModelDescription() {
    }
}
}


