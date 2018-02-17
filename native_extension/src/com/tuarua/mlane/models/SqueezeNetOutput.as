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

package com.tuarua.mlane.models {
import flash.utils.Dictionary;

public class SqueezeNetOutput {
    public var classLabel:String;
    public var classLabelProbs:Dictionary = new Dictionary();

    public function SqueezeNetOutput(mapFrom:Object) {
        try {
            this.classLabel = mapFrom.classLabel.stringV;
            var arr:Array = mapFrom.classLabelProbs.dictionaryV;
            for each (var object:Object in arr) {
                classLabelProbs[object.k] = object.v;
            }
        } catch (e:Error) {
            trace("SqueezeNetOutput", e.message);
        }
    }
}
}
