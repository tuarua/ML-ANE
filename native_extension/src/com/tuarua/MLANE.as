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

import flash.display.BitmapData;
import flash.events.EventDispatcher;

public class MLANE extends EventDispatcher {
    private static var _isSupported:Boolean = false;
    private static var _coreml:MLANE;

    /** @private */
    public function MLANE() {
        if (_coreml) {
            throw new Error(MLANEContext.NAME + " is a singleton, use .coreml");
        }
        if (MLANEContext.context) {
            var theRet:* = MLANEContext.context.call("init");
            if (theRet is ANEError) throw theRet as ANEError;
            _isSupported = theRet;
        }
        _coreml = this;
    }

    /** Disposes the ANE */
    public static function dispose():void {
        if (MLANEContext.context) {
            MLANEContext.dispose();
        }
    }

    /** The ANE instance. */
    public static function get coreml():MLANE {
        if (!_coreml) {
            new MLANE();
        }
        return _coreml;
    }

    /** Launches the native camera and runs a Vision based prediction.
     * 
     * iOS only
     * @param input
     * @param onResult
     * @param onError
     * @param mask An Optional bitmapdata which masks the airView. This allows us to use our AIR stage as UI over
     */
    public function inputFromCamera(input:Model, onResult:Function, onError:Function = null, mask:BitmapData = null):void {
        input.onResult = onResult;
        input.onError = onError;
        var theRet:* = MLANEContext.context.call("inputFromCamera", input.id, mask);
        if (theRet is ANEError) {
            throw theRet as ANEError;
        }
    }

    /** Closes the native camera
     *
     * iOS only
     *
     */
    public function closeCamera():void {
        var theRet:* = MLANEContext.context.call("closeCamera");
        if (theRet is ANEError) throw theRet as ANEError;
    }

    /** Requests permissions for this ANE
     *
     * iOS only
     *
     */
    public function requestPermissions():void {
        if (MLANEContext.context) {
            MLANEContext.context.call("requestPermissions");
        }
    }

    /** Whether this ANE is supported on the current version of iOS / OSX. */
    public function get isSupported():Boolean {
        return _isSupported;
    }
}
}
