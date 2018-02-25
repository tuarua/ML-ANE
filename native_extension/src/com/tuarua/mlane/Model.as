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
import com.tuarua.MLANEContext;
import com.tuarua.fre.ANEError;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class Model extends EventDispatcher {
    private var _description:ModelDescription;
    private static var _path:String;
    private static var _fileName:String;
    private static var _id:String;
    private static var _onLoaded:Function;
    private static var _onError:Function;
    private static var _onCompiled:Function;
    private static var _onResult:Function;
    private var _provider:Object; // TODO

    public function Model(contentsOf:String = null) {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        _id = MLANEContext.context.call("createGUID") as String;
        if (contentsOf && getExtension(contentsOf) != "mlmodelc") {
            throw new Error("contentsOf must be of file type mlmodelc");
        }
        _path = contentsOf;
        _fileName = fileNameFromUrl(_path);
        MLANEContext.models[_id] = this;
    }

    public function get description():ModelDescription {
        return _description;
    }

    private function safetyCheck():Boolean {
        return (MLANEContext.context);
    }

    public function load(onLoaded:Function = null, onError:Function = null):void {
        if (safetyCheck()) {
            _onLoaded = onLoaded;
            _onError = onError;
            var theRet:* = MLANEContext.context.call("loadModel", _id, _path);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    public static function fromUrl(url:String, onProgress:Function = null, onComplete:Function = null,
                                   onCompiled:Function = null, onError:Function = null):Model { //TODO onError
        if (!MLANEContext.context) throw new Error("NO ANE context");
        if (getExtension(url) != "mlmodel") {
            throw new Error("contentsOf must be of file type mlmodel");
        }
        _onCompiled = onCompiled;
        var model:Model = new Model();
        MLANEContext.models[model.id] = model;
        var request:URLRequest = new URLRequest(url);
        var downloader:URLLoader = new URLLoader();
        downloader.dataFormat = URLLoaderDataFormat.BINARY;
        if (onProgress) {
            downloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }
        if (onComplete) {
            downloader.addEventListener(Event.COMPLETE, onComplete);
        }
        downloader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var path:String = File.applicationStorageDirectory.resolvePath(fileNameFromUrl(url)).nativePath;
            writeBytesToFile(path, event.target.data as ByteArray);
            MLANEContext.context.call("compileModel", model.id, path);
        });
        downloader.load(request);
        return model;
    }

    public static function fromPath(path:String, onCompiled:Function = null):Model {
        if (!MLANEContext.context) throw new Error("NO ANE context");
        if (getExtension(path) != "mlmodel") {
            throw new Error("contentsOf must be of file type mlmodel");
        }
        _onCompiled = onCompiled;
        var model:Model = new Model();
        MLANEContext.models[model.id] = model;
        var theRet:* = MLANEContext.context.call("compileModel", model.id, path);
        if (theRet is ANEError) {
            throw theRet as ANEError;
        }
        return model;
    }

    public function prediction(provider:Object, onResult:Function, maxResults:int = 5):void {
        _provider = provider;
        _onResult = onResult;
        var theRet:* = MLANEContext.context.call("prediction", _id, _provider, maxResults);
        if (theRet is ANEError) {
            throw theRet as ANEError;
        }
    }

    public function dispose():void {
        var theRet:* = MLANEContext.context.call("disposeModel", _id);
        if (theRet is ANEError) {
            throw theRet as ANEError;
        }
        delete MLANEContext.models[_id];
    }

    private static function fileNameFromUrl(path:String):String {
        if (path == null) return null;
        var arr:Array = path.split("/");
        return arr[arr.length - 1];
    }

    private static function writeBytesToFile(fileName:String, data:ByteArray):void {
        var outFile:File = File.desktopDirectory;
        outFile = outFile.resolvePath(fileName);
        var outStream:FileStream = new FileStream();
        outStream.open(outFile, FileMode.WRITE);
        outStream.writeBytes(data, 0, data.length);
        outStream.close();
    }

    private static function getExtension(file:String):String {
        var split:String = file.split("?")[0];
        return split.substring(split.lastIndexOf(".") + 1, split.length);
    }

    public function get path():String {
        return _path;
    }

    public function set path(value:String):void {
        _path = value;
    }

    public function get fileName():String {
        return _fileName;
    }

    public function get id():String {
        return _id;
    }

    public function get onCompiled():Function {
        return _onCompiled;
    }

    public function get onResult():Function {
        return _onResult;
    }

    public function set onResult(value:Function):void {
        _onResult = value;
    }

    public function get onError():Function {
        return _onError;
    }

    public function set onError(value:Function):void {
        _onError = value;
    }

    public function get onLoaded():Function {
        return _onLoaded;
    }

    public function set description(value:ModelDescription):void {
        _description = value;
    }


}
}
