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
import com.tuarua.mlane.Classification;

import flash.events.Event;

public class VisionEvent extends Event {
    public static const RESULT:String = "MLANE.OnVisionResult";
    public static const ERROR:String = "MLANE.OnVisionError";
    public var id:String;
    public var error:String;
    public var result:Classification;

    public function VisionEvent(type:String,id:String, error:String = null, result:Classification = null,
                                bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.id = id;
        this.error = error;
        this.result = result;
    }

    public override function clone():Event {
        return new VisionEvent(type, this.id, this.error, this.result, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("VisionEvent", "type", "id", "error", "result", "bubbles", "cancelable");
    }
}
}
