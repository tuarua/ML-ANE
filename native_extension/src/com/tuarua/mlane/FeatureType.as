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
public final class FeatureType {
    public var invalid:int = 0;
    public var int64:int = 1;
    public var double:int = 2;
    public var string:int = 3;
    public var image:int = 4;
    public var multiArray:int = 5;
    public var dictionary:int = 6;
}
}