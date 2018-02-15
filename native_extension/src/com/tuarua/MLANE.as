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

    public function classifyImage(type:int, path:String, bitmapData:BitmapData = null):void {
        if (safetyCheck()) {
            MLANEContext.context.call("classifyImage", type, path, bitmapData);
        }
    }

    private function safetyCheck():Boolean {
        return (MLANEContext.context && _coreml);
    }

    public function get isSupported():Boolean {
        return _isSupported;
    }
}
}
