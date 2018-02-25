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
import flash.events.Event;

public class ModelEvent extends Event {
    public static const COMPILED:String = "MLANE.OnModelCompiled";
    public static const LOADED:String = "MLANE.OnModelLoaded";
    public static const ERROR:String = "MLANE.OnModelLoadError";
    public static const RESULT:String = "MLANE.OnModelResult";
    public var id:String;
    public var filePath:String;
    public var error:String;
    public var result:Object;

    public function ModelEvent(type:String, id:String, filePath:String = null, error:String = null,
                               result:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.id = id;
        this.filePath = filePath;
        this.error = error;
        this.result = result;
    }

    public override function clone():Event {
        return new ModelEvent(type, this.id, this.filePath, this.error, this.result, bubbles, cancelable);
    }

    public override function toString():String {
        return formatToString("ModelEvent", "type", "id", "filePath", "error", "type", "bubbles", "cancelable");
    }
}
}
