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

package com.tuarua {
import com.tuarua.mlane.VisionClassification;
import com.tuarua.mlane.events.VisionClassificationEvent;

import flash.events.StatusEvent;
import flash.external.ExtensionContext;

public class MLANEContext {
    internal static const NAME:String = "MLANE";
    internal static const TRACE:String = "TRACE";
    private static var _context:ExtensionContext;
    private static var argsAsJSON:Object;

    public function MLANEContext() {
    }

    public static function get context():ExtensionContext {
        if (_context == null) {
            try {
                _context = ExtensionContext.createExtensionContext("com.tuarua." + NAME, null);
                if (_context == null) {
                    throw new Error("ANE " + NAME + " not created properly.  Future calls will fail.");
                }
                _context.addEventListener(StatusEvent.STATUS, gotEvent);
            } catch (e:Error) {
                trace("[" + NAME + "] ANE not loaded properly.  Future calls will fail.");
            }
        }
        return _context;
    }

    private static function gotEvent(event:StatusEvent):void {

        switch (event.level) {
            case TRACE:
                trace("[" + NAME + "]", event.code);
                break;

//            case CompileEvent.ERROR:
//                MLANE.coreml.dispatchEvent(new CompileEvent(event.level, null, event.code));
//                break;
//            case ModelEvent.ERROR:
//                MLANE.coreml.dispatchEvent(new ModelEvent(event.level, null, event.code));
//                break;
//            case VisionClassificationEvent.RESULT:
//                try {
//                    argsAsJSON = JSON.parse(event.code);
//                    var results:Array = argsAsJSON.results;
//                    var vec:Vector.<VisionClassification> = new Vector.<VisionClassification>();
//                    for each (var classification:Object in results) {
//                        vec.push(new VisionClassification(classification.c, classification.i));
//                    }
//                    MLANE.coreml.dispatchEvent(new VisionClassificationEvent(event.level, vec));
//                } catch (e:Error) {
//                    trace(e.message);
//                }
//                break;
//            case VisionClassificationEvent.ERROR:
//                MLANE.coreml.dispatchEvent(new VisionClassificationEvent(event.level, null, event.code));
//                break;
        }
    }

    public static function dispose():void {
        if (!_context) {
            return;
        }
        trace("[" + NAME + "] Unloading ANE...");
        _context.removeEventListener(StatusEvent.STATUS, gotEvent);
        _context.dispose();
        _context = null;
    }
}
}
