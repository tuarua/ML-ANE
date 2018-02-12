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

package com.tuarua.mlane.events {
import com.tuarua.mlane.VisionClassification;

import flash.events.Event;

public class VisionClassificationEvent extends Event {
    public static const RESULT:String = "MLANE.OnVisionClassified";
    public static const ERROR:String = "MLANE.OnVisionClassifationError";

    public var results:Vector.<VisionClassification> = new <VisionClassification>[];
    public var error:String;

    public function VisionClassificationEvent(type:String, results:Vector.<VisionClassification> = null,
                                              error:String = null, bubbles:Boolean = false,
                                              cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.results = (results) ? results : this.results;
        this.error = error;
    }

    public override function clone():Event {
        return new VisionClassificationEvent(type, this.results, this.error, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("VisionClassificationEvent", "results", "error", "type", "bubbles", "cancelable");
    }
}
}
