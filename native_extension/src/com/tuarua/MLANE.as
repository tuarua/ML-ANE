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
import com.tuarua.fre.ANEError;
import com.tuarua.mlane.Model;
import com.tuarua.mlane.display.NativeDisplayObject;

import flash.display.BitmapData;

import flash.events.EventDispatcher;

public class MLANE extends EventDispatcher {
    private static var _isSupported:Boolean = false;
    private static var _coreml:MLANE;

    public function MLANE() {
        if (_coreml) {
            throw new Error(MLANEContext.NAME + " is a singleton, use .coreml");
        }
        if (MLANEContext.context) {
            var theRet:* = MLANEContext.context.call("init");
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            _isSupported = theRet;
        }
        _coreml = this;
    }

    public static function dispose():void {
        if (MLANEContext.context) {
            MLANEContext.dispose();
        }
    }

    public static function get coreml():MLANE {
        if (!_coreml) {
            new MLANE();
        }
        return _coreml;
    }

    public function inputFromCamera(input:Model, onResult:Function, onError:Function = null):void {
        input.onResult = onResult;
        input.onError = onError;
        var theRet:* = MLANEContext.context.call("inputFromCamera", input.id);
        if (theRet is ANEError) {
            throw theRet as ANEError;
        }
    }

    public function closeCamera():void {
        var theRet:* = MLANEContext.context.call("closeCamera");
        if (theRet is ANEError) {
            throw theRet as ANEError;
        }
    }

    //noinspection JSMethodCanBeStatic
    public function addChild(nativeDisplayObject:NativeDisplayObject):void {
        if (nativeDisplayObject.isAdded) return;
        if (MLANEContext.context) {
            try {
                MLANEContext.context.call("addNativeChild", nativeDisplayObject);
                nativeDisplayObject.isAdded = true;
            } catch (e:Error) {
                trace(e.message);
            }
        }
    }

    //noinspection JSMethodCanBeStatic
    public function removeChild(nativeDisplayObject:NativeDisplayObject):void {
        if (MLANEContext.context) {
            try {
                MLANEContext.context.call("removeNativeChild", nativeDisplayObject.id);
                nativeDisplayObject.isAdded = false;
            } catch (e:Error) {
                trace(e.message);
            }
        }
    }

    public function get isSupported():Boolean {
        return _isSupported;
    }
}
}
