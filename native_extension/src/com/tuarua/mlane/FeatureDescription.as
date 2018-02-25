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
[RemoteClass(alias="com.tuarua.mlane.FeatureDescription")]
public class FeatureDescription {
    /** Name of feature */
    public var name:String;
    /** Whether this feature can take an undefined value or not */
    public var isOptional:Boolean;
    /** FeatureType of data */
    public var type:int;
    /** Constraint when type == FeatureType.image, null otherwise */
    public var imageConstraint:ImageConstraint;
    /** Constraint when type == FeatureType.dictionary, null otherwise */
    public var dictionaryConstraint:DictionaryConstraint;

    /** @private */
    public function FeatureDescription() {
    }
}
}