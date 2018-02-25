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
import com.tuarua.mlane.Classification;
import com.tuarua.mlane.Model;
import com.tuarua.mlane.ModelDescription;
import com.tuarua.mlane.events.ModelEvent;
import com.tuarua.mlane.events.VisionEvent;
import com.tuarua.mlane.permissions.PermissionEvent;

import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.utils.Dictionary;
/** @private */
public class MLANEContext {
    internal static const NAME:String = "MLANE";
    internal static const TRACE:String = "TRACE";
    private static var _context:ExtensionContext;
    private static var argsAsJSON:Object;
    private static var classification:Classification;
    private static var _models:Dictionary = new Dictionary();

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
            case ModelEvent.COMPILED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var modelA:Model = _models[argsAsJSON.id];
                    if (modelA) {
                        modelA.path = argsAsJSON.path;
                        if (modelA.onCompiled) {
                            modelA.onCompiled.call(null, new ModelEvent(event.level, argsAsJSON.id, argsAsJSON.path));
                        }
                    }
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case ModelEvent.LOADED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var modelB:Model = _models[argsAsJSON.id];
                    if (modelB) {
                        modelB.description = MLANEContext.context.call("getDescription", modelB.id) as ModelDescription;
                        if (modelB.onLoaded) {
                            modelB.onLoaded.call(null, new ModelEvent(event.level, argsAsJSON.id, argsAsJSON.path));
                        }
                    }
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case ModelEvent.RESULT:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var modelC:Model = _models[argsAsJSON.id];
                    if (modelC && modelC.onResult) {
                        modelC.onResult.call(null, new ModelEvent(event.level, argsAsJSON.id, null, null,
                                argsAsJSON));
                    }
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case ModelEvent.ERROR:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var modelD:Model = _models[argsAsJSON.id];
                    if (modelD && modelD.onError) {
                        modelD.onError.call(null, new ModelEvent(event.level, argsAsJSON.id, null, argsAsJSON.error));
                    }
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case VisionEvent.RESULT:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var modelE:Model = _models[argsAsJSON.id];
                    if (modelE && modelE.onResult) {
                        if (classification) {
                            classification.label = argsAsJSON.lbl;
                            classification.confidence = argsAsJSON.cnf;
                        } else {
                            classification = new Classification(argsAsJSON.lbl, argsAsJSON.cnf);
                        }
                        modelE.onResult.call(null, new VisionEvent(event.level, argsAsJSON.id, null, classification, argsAsJSON.error));
                    }
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case VisionEvent.ERROR:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var modelF:Model = _models[argsAsJSON.id];
                    if (modelF && modelF.onError) {
                        modelF.onError.call(null, new VisionEvent(event.level, argsAsJSON.id, argsAsJSON.error));
                    }
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
            case PermissionEvent.STATUS_CHANGED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    MLANE.coreml.dispatchEvent(new PermissionEvent(event.level, argsAsJSON.status));
                } catch (e:Error) {
                    trace(e.message);
                }
                break;
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

    public static function get models():Dictionary {
        return _models;
    }
}
}
