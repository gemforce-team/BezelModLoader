package Bezel.Lattice.Assembly.serialization {
    import Bezel.Lattice.Assembly.values.ABCType;
    import flash.utils.Dictionary;
    import Bezel.Lattice.Assembly.ASValue;
    import Bezel.Lattice.Assembly.conversion.NamespacePool;
    import Bezel.Lattice.Assembly.ASNamespace;
    import Bezel.Lattice.Assembly.ASMultiname;
    import Bezel.Lattice.Assembly.multiname.ASQName;
    import Bezel.Lattice.Assembly.multiname.ASRTQName;
    import Bezel.Lattice.Assembly.multiname.ASRTQNameL;
    import Bezel.Lattice.Assembly.multiname.ASMultinameSubdata;
    import Bezel.Lattice.Assembly.multiname.ASMultinameL;
    import Bezel.Lattice.Assembly.multiname.ASTypeName;
    import Bezel.Lattice.Assembly.ASTrait;
    import Bezel.Lattice.Assembly.values.TraitType;
    import Bezel.Lattice.Assembly.trait.ASTraitSlot;
    import Bezel.Lattice.Assembly.values.TraitAttributes;
    import Bezel.Lattice.Assembly.ASMetadata;
    import Bezel.Lattice.Assembly.ASClass;
    import Bezel.Lattice.Assembly.trait.ASTraitClass;
    import Bezel.Lattice.Assembly.trait.ASTraitFunction;
    import Bezel.Lattice.Assembly.trait.ASTraitMethod;
    import Bezel.Lattice.Assembly.ASMethod;
    import Bezel.Lattice.Assembly.values.MethodFlags;
    import Bezel.Lattice.Assembly.ASInstance;
    import Bezel.Lattice.Assembly.values.InstanceFlags;
    import Bezel.Lattice.Assembly.ASScript;
    import Bezel.Lattice.Assembly.ASMethodBody;
    import Bezel.Lattice.Assembly.ASException;
    import Bezel.Lattice.Assembly.InstructionLabel;
    import Bezel.Lattice.Assembly.ASInstruction;
    import Bezel.Lattice.Assembly.Opcode;
    import Bezel.Lattice.Assembly.OpcodeArgumentType;
    import Bezel.Lattice.Assembly.ASProgram;

    /**
     * ...
     * @author Chris
     */
    public class Assembler {
        // string[string] -> Object with strings
        private var strings:Object;
        private var namespaces:NamespacePool;

        private var currentFile:SourceFile;

        // string[string] -> Object with strings
        private var vars:Object;
        // uint[string] -> Object with strings
        private var namespaceLabels:Object;
        private var sourceVersion:uint;

        private var classFixups:Vector.<UnifiedFixup>;
        private var methodFixups:Vector.<UnifiedFixup>;

        private var classesById:Dictionary;
        private var methodsById:Dictionary;

        private var asp:ASProgram;

        public function Assembler(asp:ASProgram) {
            classFixups = new Vector.<UnifiedFixup>();
            methodFixups = new Vector.<UnifiedFixup>();
            vars = new Object();
            strings = new Object();
            namespaces = new NamespacePool();
            namespaceLabels = new Object();
            classesById = new Dictionary();
            methodsById = new Dictionary();

            this.asp = asp;
        }

        private function skipWhitespace():void {
            while (true) {
                var c:String;
                while ((c = peekChar()) == "") {
                    popFile();
                }
                if (c == ' ' || c == '\r' || c == '\n' || c == '\t') {
                    skipChar();
                } else if (c == '#') {
                    handlePreprocessor();
                } else if (c == '$') {
                    handleVar();
                } else if (c == ';') {
                    do {
                        skipChar();
                    } while (peekChar() != '\n');
                } else
                    return;
            }
        }

        private function handlePreprocessor():void {
            skipChar(); // #
            var word:String = readWord();
            var s:String;
            switch (word) {
                case "mixin":
                    pushFile(new SourceFile("#mixin", readImmString()));
                    break;
                case "call":
                    pushFile(new SourceFile("#call", readImmString(), Vector.<String>(readList("(", ")", this.readImmString, false))));
                    break;
                case "include":
                    // pushFile(new SourceFile(convertFilename(readString())));
                    s = readString();
                    pushFile(new SourceFile(s, strings[s]));
                    break;
                case "get":
                    s = readString();
                    pushFile(new SourceFile(s, toStringLiteral(strings[s])));
                    break;
                case "set":
                    vars[readWord()] = readImmString();
                    break;
                case "unset":
                    delete vars[readWord()];
                    break;
                case "privatens":
                    if (sourceVersion >= 3)
                        throw new Error("#privatens is deprecated");
                    readUInt();
                    readString();
                    break;
                case "version":
                    sourceVersion = readUInt();
                    if (sourceVersion < 1 || sourceVersion > 4)
                        throw new Error("Unknown #version");
                    break;
                default:
                    backpedal(word.length);
                    throw new Error("Unknown preprocessor declaration: " + word);
            }
        }

        public function handleVar():void {
            skipChar(); // $
            skipWhitespace();

            var asStringLiteral:Boolean = false;
            var name:String;
            if (peekChar() == '"') {
                name = readString();
                asStringLiteral = true;
            } else {
                name = readWord();
            }

            if (name.length == 0) {
                throw new Error("Empty var name");
            }
            if (name.charCodeAt(0) >= 0x31 && name.charCodeAt(0) <= 0x39) // ASCII values for 1 and 9
            {
                for (var f:SourceFile = currentFile; f != null; f = f.parent) {
                    if (f.arguments != null && f.arguments.length > 0) {
                        var index:uint = parseInt(name) - 1;
                        if (index >= f.arguments.length) {
                            throw new Error("Argument index out of bounds");
                        }
                        var value:String = f.arguments[index];
                        pushFile(new SourceFile("$" + name, asStringLiteral ? toStringLiteral(value) : value));
                        return;
                    }
                }
                throw new Error("No arguments in context");
            } else {
                if (!(name in vars)) {
                    throw new Error("Variable \'" + name + "\' is not defined");
                }
                pushFile(new SourceFile("$" + name, asStringLiteral ? toStringLiteral(value) : value));
            }
        }

        private static function isWordChar(c:String):Boolean {
            if (c.length > 1)
                throw new Error("This is multiple characters");
            if (c == "")
                return false;

            return (c.charCodeAt(0) >= 0x61 && c.charCodeAt(0) <= 0x7A) || // a-z
                (c.charCodeAt(0) >= 0x41 && c.charCodeAt(0) <= 0x5A) || // A-Z
                (c.charCodeAt(0) >= 0x30 && c.charCodeAt(0) <= 0x39) || // 0-9
                c == "_" || c == "-" || c == "+" || c == ".";
        }

        private function readWord():String {
            skipWhitespace();
            if (!isWordChar(currentFile.front)) {
                // TODO: return null?
                throw new Error("Word character expected, got \'" + currentFile.front + "\' (code " + currentFile.front.charCodeAt(0) + ")");
            }

            var ret:String = "";
            while (isWordChar(currentFile.front)) {
                ret = ret + currentFile.front;
                currentFile.popFront();
            }
            return ret;
        }

        private function readImmWord():String {
            return readWord();
        }

        private static function fromHex(x:String):uint {
            switch (x) {
                case '0':
                    return 0;
                case '1':
                    return 1;
                case '2':
                    return 2;
                case '3':
                    return 3;
                case '4':
                    return 4;
                case '5':
                    return 5;
                case '6':
                    return 6;
                case '7':
                    return 7;
                case '8':
                    return 8;
                case '9':
                    return 9;
                case 'a':
                case 'A':
                    return 10;
                case 'b':
                case 'B':
                    return 11;
                case 'c':
                case 'C':
                    return 12;
                case 'd':
                case 'D':
                    return 13;
                case 'e':
                case 'E':
                    return 14;
                case 'f':
                case 'F':
                    return 15;
                default:
                    throw new Error("Malformed hex digit " + x);
            }
        }

        private function pushFile(file:SourceFile):void {
            file.parent = currentFile;
            currentFile = file;
        }

        private function popFile():void {
            if (currentFile == null || currentFile.parent == null) {
                throw new Error("Unexpected end of file");
            }
            currentFile = currentFile.parent;
        }

        private function expectWord(expected:String):void {
            var word:String = readWord();
            if (word != expected) {
                backpedal(word.length);
                throw new Error("Expected " + expected);
            }
        }

        private function peekChar():String {
            return currentFile.front;
        }

        private function skipChar():void {
            currentFile.popFront();
        }

        private function backpedal(amount:uint = 1):void {
            currentFile.shift -= amount;
        }

        private function readChar():String {
            var ret:String = currentFile.front;
            if (ret != "") {
                currentFile.popFront();
            }
            return ret;
        }

        private function readSymbol():String {
            skipWhitespace();
            return readChar();
        }

        private function expectSymbol(c:String):void {
            if (readSymbol() != c) {
                backpedal();
                throw new Error("Expected " + c);
            }
        }

        private static function mustBeNull(v:*):void {
            if (v != null)
                throw new Error("Repeating field declaration");
        }

        private static function mustBeSet(name:String, v:*):void {
            if (v == null)
                throw new Error(name + " is not set");
        }

        private static function toABCType(name:String):ABCType {
            var ret:ABCType = ABCType.fromString(name);
            if (ret == null)
                throw new Error("Unknown ABCType " + name);
            return ret;
        }

        private static function addUniqueTo(name:String, container:Dictionary, key:*, value:*):void {
            if (key in container) {
                throw new Error("Duplicate " + name);
            }
            container[key] = value;
        }

        private static function toStringLiteral(v:String):String {
            if (v == null) {
                return "null";
            } else {
                var ret:String = "\"";
                for (var i:int = 0; i < v.length; i++) {
                    if (v.charAt(i) == "\n") {
                        ret += "\\n";
                    } else if (v.charAt(i) == "\r") {
                        ret += "\\r";
                    } else if (v.charAt(i) == "\\") {
                        ret += "\\\\";
                    } else if (v.charAt(i) == "\"") {
                        ret += "\\\"";
                    } else if (v.charCodeAt(i) < 0x20) {
                        var addMe:String = v.charCodeAt(i).toString(16);
                        if (addMe.length == 1) {
                            addMe = "0" + addMe;
                        }
                        ret += "\\x" + addMe;
                    } else {
                        ret += v.charAt(i);
                    }
                }
                ret += "\"";
                return ret;
            }
        }

        private function readValue():ASValue {
            var v:ASValue = new ASValue();
            v.type = toABCType(readWord());
            expectSymbol("(");
            switch (v.type) {
                case ABCType.Integer:
                    v.data = readInt();
                    break;
                case ABCType.UInteger:
                    v.data = readUInt();
                    break;
                case ABCType.Double:
                    v.data = readDouble();
                    break;
                case ABCType.Utf8:
                    v.data = readImmString();
                    break;
                case ABCType.Namespace:
                case ABCType.PackageNamespace:
                case ABCType.PackageInternalNs:
                case ABCType.ProtectedNamespace:
                case ABCType.ExplicitNamespace:
                case ABCType.StaticProtectedNs:
                case ABCType.PrivateNamespace:
                    v.data = readNamespace();
                    break;
                case ABCType.True:
                case ABCType.False:
                case ABCType.Null:
                case ABCType.Undefined:
                    break;
                default:
                    throw new Error("Unknown type");
            }
            expectSymbol(")");
            return v;
        }

        private function readFlag(names:Vector.<String>):uint {
            var word:String = readWord();
            var ret:uint = 1;
            for (var i:int = 0; ret < 0xFF; i++, ret <<= 1) {
                if (word == names[i]) {
                    return ret;
                }
            }
            backpedal(word.length);
            throw new Error("Unknown flag " + word);
        }

        private function readList(open:String, close:String, reader:Function, allowNull:Boolean):Array {
            if (allowNull) {
                skipWhitespace();
                if (peekChar() != open) {
                    var word:String = readWord();
                    if (word != "null") {
                        backpedal(word.length);
                        throw new Error("Expected " + open + " or null");
                    }
                    return null;
                }
            }

            expectSymbol(open);

            skipWhitespace();
            if (peekChar() == close) {
                skipChar(); // CLOSE
                return new Array();
            }

            var ret:Array = new Array();

            while (true) {
                ret.push(reader());
                var c:String = readSymbol();
                if (c == close) {
                    break;
                }
                if (c != ',') {
                    backpedal();
                    throw new Error("Expected " + close + " or ,");
                }
            }
            return ret;
        }

        private function readInt():int {
            var w:String = readWord();
            if (w == "null")
                return 0;
            var val:Number = parseInt(w);
            if (val > int.MAX_VALUE || val < int.MIN_VALUE || val != int(val)) {
                throw new Error("Int out of bounds");
            }
            return val;
        }

        private function readUInt():uint {
            var w:String = readWord();
            if (w == "null")
                return 0;
            var val:Number = parseInt(w);
            if (val > uint.MAX_VALUE || val < uint.MIN_VALUE || val != uint(val)) {
                throw new Error("Int out of bounds");
            }
            return val;
        }

        private function readDouble():Number {
            var w:String = readWord();
            if (w == "null") {
                return NaN;
            }
            return parseFloat(w);
        }

        private function readString():String {
            skipWhitespace();
            var c:String = readSymbol();
            if (c != '\"') {
                var word:String = readWord();
                if (c == 'n' && word == 'ull') {
                    return null;
                } else {
                    backpedal(1 + word.length);
                    throw new Error("String literal expected");
                }
            }
            var ret:String = "";
            while (true) {
                switch (c = readChar()) {
                    case '\"':
                        return ret;
                    case '\\':
                        switch (c = readChar()) {
                            case 'n':
                                ret = ret + "\n";
                                break;
                            case 'r':
                                ret = ret + "\r";
                                break;
                            case 'x':
                                var c0:String = readChar();
                                var c1:String = readChar();
                                ret = ret + String.fromCharCode((parseInt(c0, 16) << 4) | parseInt(c1, 16));
                                break;
                            default:
                                ret = ret + c;
                                break;
                        }
                        break;
                    case "":
                        throw new Error("Unexpected null/terminator");
                    default:
                        ret = ret + c;
                }
            }

            throw new Error("This place should never be reached");
        }

        private function readImmString():String {
            return readString();
        }

        private function readNamespace():ASNamespace {
            var word:String = readWord();
            if (word == "null") {
                return null;
            }
            var type:ABCType = ABCType.fromString(word);
            expectSymbol('(');
            var name:String = readImmString();
            var id:uint = 0;
            if (peekChar() == ',') {
                skipChar();
                var s:String = readImmString();
                if (s in namespaceLabels) {
                    id = namespaceLabels[s];
                } else {
                    id = namespaceLabels[s] = namespaceLabels.length + 1;
                }
            }
            expectSymbol(')');

            return namespaces.get(type, name, id);
        }

        private function readNamespaceSet():Vector.<ASNamespace> {
            return Vector.<ASNamespace>(readList('[', ']', readNamespace, true));
        }

        private function readMultiname():ASMultiname {
            var word:String = readWord();
            if (word == "null") {
                return null;
            }

            var type:ABCType = ABCType.fromString(word);

            expectSymbol('(');

            var extra:*;

            switch (type) {
                case ABCType.QName:
                case ABCType.QNameA:
                    extra = new ASQName(readNamespace(), null);
                    expectSymbol(',');
                    extra.name = readImmString();
                    break;
                case ABCType.RTQName:
                case ABCType.RTQNameA:
                    extra = new ASRTQName(readImmString());
                    break;
                case ABCType.RTQNameL:
                case ABCType.RTQNameLA:
                    extra = new ASRTQNameL();
                    break;
                case ABCType.Multiname:
                case ABCType.MultinameA:
                    extra = new ASMultinameSubdata(readImmString(), null);
                    expectSymbol(',');
                    extra.ns_set = readNamespaceSet();
                    break;
                case ABCType.MultinameL:
                case ABCType.MultinameLA:
                    extra = new ASMultinameL(readNamespaceSet());
                    break;
                case ABCType.TypeName:
                    extra = new ASTypeName(readMultiname(), Vector.<ASMultiname>(readList('<', '>', readMultiname, false)));
                    break;
                default:
                    throw new Error("Unknown multiname type");
            }

            expectSymbol(')');
            return new ASMultiname(type, extra);
        }

        private function readTrait():ASTrait {
            var ret:ASTrait = new ASTrait();
            ret.type = TraitType.fromString(readWord());
            ret.metadata = new Vector.<ASMetadata>();

            var word:String;
            ret.name = readMultiname();
            switch (ret.type) {
                case TraitType.Slot:
                case TraitType.Const:  {
                    var astslot:ASTraitSlot = ret.extraData = new ASTraitSlot();
                    while (true) {
                        word = readWord();
                        switch (word) {
                            case "flag":
                                ret.attributes |= readFlag(TraitAttributes.names);
                                break;
                            case "slotid":
                                astslot.slotId = readUInt();
                                break;
                            case "type":
                                if (astslot.typeName != null) {
                                    throw new Error("Cannot have two type names for a trait " + ret.type.name);
                                }
                                astslot.typeName = readMultiname();
                                break;
                            case "value":
                                astslot.value = readValue();
                                break;
                            case "metadata":
                                ret.metadata.push(readMetadata());
                                break;
                            case "end":
                                return ret;
                            default:
                                throw new Error("Unknown " + ret.type.name + " trait field " + word);
                        }
                    }
                }
                case TraitType.Class:  {
                    var astclass:ASTraitClass = ret.extraData = new ASTraitClass();
                    while (true) {
                        word = readWord();
                        switch (word) {
                            case "flag":
                                ret.attributes |= readFlag(TraitAttributes.names);
                                break;
                            case "slotid":
                                astclass.slotId = readUInt();
                                break;
                            case "class":
                                if (astclass.classv != null) {
                                    throw new Error("Cannot have two classes for a trait class");
                                }
                                astclass.classv = readClass();
                                break;
                            case "metadata":
                                ret.metadata.push(readMetadata());
                                break;
                            case "end":
                                return ret;
                            default:
                                throw new Error("Unknown " + ret.type.name + " trait field " + word);
                        }
                    }
                }
                case TraitType.Function:  {
                    var astfunction:ASTraitFunction = ret.extraData = new ASTraitFunction();
                    while (true) {
                        word = readWord();
                        switch (word) {
                            case "flag":
                                ret.attributes |= readFlag(TraitAttributes.names);
                                break;
                            case "slotid":
                                astfunction.slotId = readUInt();
                                break;
                            case "method":
                                if (astfunction.functionv != null) {
                                    throw new Error("Cannot have two methods for a trait function");
                                }
                                astfunction.functionv = readMethod();
                                break;
                            case "metadata":
                                ret.metadata.push(readMetadata());
                                break;
                            case "end":
                                return ret;
                            default:
                                throw new Error("Unknown " + ret.type.name + " trait field " + word);
                        }
                    }
                }
                case TraitType.Getter:
                case TraitType.Setter:
                case TraitType.Method:  {
                    var astmethod:ASTraitMethod = ret.extraData = new ASTraitMethod();
                    while (true) {
                        word = readWord();
                        switch (word) {
                            case "flag":
                                ret.attributes |= readFlag(TraitAttributes.names);
                                break;
                            case "dispid":
                                astmethod.slotId = readUInt();
                                break;
                            case "method":
                                if (astmethod.method != null) {
                                    throw new Error("Cannot have two methods for a trait method");
                                }
                                astmethod.method = readMethod();
                                break;
                            case "metadata":
                                ret.metadata.push(readMetadata());
                                break;
                            case "end":
                                return ret;
                            default:
                                throw new Error("Unknown " + ret.type.name + " trait field " + word);
                        }
                    }
                }
                default:
                    throw new Error("Unknown trait type");
            }
        }

        private function readMetadata():ASMetadata {
            var ret:ASMetadata = new ASMetadata();
            ret.name = readImmString();
            ret.keys = new Vector.<String>();
            ret.values = new Vector.<String>();
            while (true) {
                switch (readWord()) {
                    case "item":
                        if (sourceVersion < 2) {
                            ret.keys.push(readImmString());
                            ret.keys.push(readImmString());
                        } else {
                            ret.keys.push(readImmString());
                            ret.values.push(readImmString());
                        }
                        break;
                    case "end":
                        if (sourceVersion < 2) {
                            while (ret.keys.length > ret.values.length) {
                                ret.values.push(ret.keys.pop());
                            }
                        }
                        return ret;
                    default:
                        throw new Error("Expected item or end");
                }
            }

            throw new Error("Unreachable");
        }

        private function readMethod():ASMethod {
            var ret:ASMethod = new ASMethod();
            ret.paramTypes = new Vector.<ASMultiname>();
            ret.paramNames = new Vector.<String>();
            ret.options = new Vector.<ASValue>();

            while (true) {
                var word:String = readWord();
                switch (word) {
                    case "name":
                        if (ret.name != null) {
                            throw new Error("Method cannot have two names");
                        }
                        ret.name = readImmString();
                        break;
                    case "refid":
                        addUniqueTo("method", methodsById, readImmString(), ret);
                        break;
                    case "param":
                        ret.paramTypes.push(readMultiname());
                        break;
                    case "returns":
                        if (ret.returnType != null) {
                            throw new Error("Method cannot have two return types");
                        }
                        ret.returnType = readMultiname();
                        break;
                    case "flag":
                        ret.flags |= readFlag(MethodFlags.names);
                        break;
                    case "optional":
                        ret.options.push(readValue());
                        break;
                    case "paramname":
                        ret.paramNames.push(readImmString());
                        break;
                    case "body":
                        ret.body = readMethodBody();
                        ret.body.method = ret;
                        break;
                    case "end":
                        return ret;
                    default:
                        throw new Error("Unknown method field " + word);
                }
            }

            throw new Error("Unreachable");
        }

        private function readInstance():ASInstance {
            var ret:ASInstance = new ASInstance();
            ret.interfaces = new Vector.<ASMultiname>();
            ret.traits = new Vector.<ASTrait>();

            ret.name = readMultiname();

            while (true) {
                var word:String = readWord();
                switch (word) {
                    case "extends":
                        if (ret.superName != null) {
                            throw new Error("Instance cannot have two superclasses");
                        }
                        ret.superName = readMultiname();
                        break;
                    case "implements":
                        ret.interfaces.push(readMultiname());
                        break;
                    case "flag":
                        ret.flags |= readFlag(InstanceFlags.names);
                        break;
                    case "protectedns":
                        if (ret.protectedNs != null) {
                            throw new Error("Instance cannot have two protected namespaces");
                        }
                        ret.protectedNs = readNamespace();
                        break;
                    case "iinit":
                        if (ret.iinit != null) {
                            throw new Error("Instance cannot have two constructors (aka iinit)");
                        }
                        ret.iinit = readMethod();
                        break;
                    case "trait":
                        ret.traits.push(readTrait());
                        break;
                    case "end":
                        if (ret.iinit == null) {
                            throw new Error("Instance must have a constructor (aka iinit)");
                        }
                        return ret;
                    default:
                        throw new Error("Unknown instance field " + word);
                }
            }

            throw new Error("Unreachable");
        }

        private function readClass():ASClass {
            var ret:ASClass = new ASClass();
            ret.traits = new Vector.<ASTrait>();

            while (true) {
                var word:String = readWord();
                switch (word) {
                    case "refid":
                        addUniqueTo("class", classesById, readImmString(), ret);
                        break;
                    case "instance":
                        if (ret.instance != null) {
                            throw new Error("Class cannot have two instances");
                        }
                        ret.instance = readInstance();
                        break;
                    case "cinit":
                        if (ret.cinit != null) {
                            throw new Error("Class cannot have two static constructors (aka cinit)");
                        }
                        ret.cinit = readMethod();
                        break;
                    case "trait":
                        ret.traits.push(readTrait());
                        break;
                    case "end":
                        if (ret.cinit == null) {
                            throw new Error("Class must have a static constructor (aka cinit)");
                        }
                        if (ret.instance == null) {
                            throw new Error("Class must have an instance");
                        }
                        return ret;
                    default:
                        throw new Error("Unknown class field " + word);
                }
            }

            throw new Error("Unreachable");
        }

        private function readScript():ASScript {
            var ret:ASScript = new ASScript();
            ret.traits = new Vector.<ASTrait>();

            while (true) {
                var word:String = readWord();
                switch (word) {
                    case "sinit":
                        if (ret.sinit != null) {
                            throw new Error("Script cannot have two script constructors (aka sinit)");
                        }
                        ret.sinit = readMethod();
                        break;
                    case "trait":
                        ret.traits.push(readTrait());
                        break;
                    case "end":
                        if (ret.sinit == null) {
                            throw new Error("Script must have a script constructor (aka sinit)");
                        }
                        return ret;
                    default:
                        throw new Error("Unknown script field " + word);
                }
            }

            throw new Error("Unreachable");
        }

        private function readMethodBody():ASMethodBody {
            var ret:ASMethodBody = new ASMethodBody();
            ret.exceptions = new Vector.<ASException>();
            ret.traits = new Vector.<ASTrait>();
            // uint[string] labels
            var labels:Dictionary = new Dictionary();

            while (true) {
                var word:String = readWord();
                switch (word) {
                    case "maxstack":
                        ret.maxStack = Math.max(ret.maxStack, readUInt());
                        break;
                    case "localcount":
                        ret.localCount = readUInt();
                        break;
                    case "initscopedepth":
                        ret.initScopeDepth = readUInt();
                        break;
                    case "maxscopedepth":
                        ret.maxScopeDepth = Math.max(ret.maxScopeDepth, readUInt()); // changed from = readUInt()
                        break;
                    case "code":
                        ret.instructions = readInstructions(labels);
                        break;
                    case "try":
                        ret.exceptions.push(readException(labels));
                        break;
                    case "trait":
                        ret.traits.push(readTrait());
                        break;
                    case "end":
                        return ret;
                    default:
                        throw new Error("Unknown body field " + word);
                }
            }

            throw new Error("Unreachable");
        }

        private function parseLabel(label:String, labels:Dictionary /* uint[string] */):InstructionLabel {
            var offset:int = 0;
            var toFoundPlus:int = label.lastIndexOf("+");
            var toFoundMinus:int = label.lastIndexOf("-");
            if (toFoundPlus != -1 || toFoundMinus != -1) {
                if (toFoundPlus > toFoundMinus) {
                    offset = parseInt(label.substr(toFoundPlus + 1));
                    label = label.substr(0, toFoundPlus);
                } else {
                    offset = parseInt(label.substr(toFoundMinus));
                    label = label.substr(0, toFoundMinus);
                }
            }

            if (!(label in labels)) {
                throw new Error("Unknown label " + label);
            }

            return new InstructionLabel(labels[label], offset);
        }

        private function readInstructions(labels:Dictionary /* ref uint[string] */):Vector.<ASInstruction> {
            var ret:Vector.<ASInstruction> = new Vector.<ASInstruction>();
            var jumpFixups:Vector.<LocalFixup> = new Vector.<LocalFixup>();
            var switchFixups:Vector.<LocalFixup> = new Vector.<LocalFixup>();
            var localClassFixups:Vector.<LocalFixup> = new Vector.<LocalFixup>();
            var localMethodFixups:Vector.<LocalFixup> = new Vector.<LocalFixup>();

            while (true) {
                var word:String = readWord();
                if (word == "end")
                    break;
                if (peekChar() == ":") {
                    addUniqueTo("label", labels, word, ret.length);
                    skipChar(); // :
                    continue;
                }

                var instruction:ASInstruction = new ASInstruction();
                instruction.arguments = new Array();
                instruction.opcode = Opcode.fromInfo(word);

                if (instruction.opcode == null) {
                    backpedal(word.length);
                    throw new Error("Unknown OPCode " + word);
                }

                for (var i:int = 0; i < instruction.opcode.arguments.length; i++) {
                    switch (instruction.opcode.arguments[i]) {
                        case OpcodeArgumentType.Unknown:
                            throw new Error("Don't know how to assemble OP_" + instruction.opcode.name);

                        case OpcodeArgumentType.ByteLiteral:
                            if (sourceVersion < 4) {
                                instruction.arguments[i] = readInt();
                            } else {
                                instruction.arguments[i] = readInt();
                                if (instruction.arguments[i] > 0x80) {
                                    instruction.arguments[i] = -(~((instruction.arguments[i] | 0xFFFFFF00) - 1))
                                }
                            }
                            break;
                        case OpcodeArgumentType.UByteLiteral:
                            instruction.arguments[i] = readUInt();
                            break;
                        case OpcodeArgumentType.IntLiteral:
                            instruction.arguments[i] = readInt();
                            break;
                        case OpcodeArgumentType.UIntLiteral:
                            instruction.arguments[i] = readUInt();
                            break;

                        case OpcodeArgumentType.Int:
                            instruction.arguments[i] = readInt();
                            break;
                        case OpcodeArgumentType.UInt:
                            instruction.arguments[i] = readUInt();
                            break;
                        case OpcodeArgumentType.Double:
                            instruction.arguments[i] = readDouble();
                            break;
                        case OpcodeArgumentType.String:
                            instruction.arguments[i] = readImmString();
                            break;
                        case OpcodeArgumentType.Namespace:
                            instruction.arguments[i] = readNamespace();
                            break;
                        case OpcodeArgumentType.Multiname:
                            instruction.arguments[i] = readMultiname();
                            break;
                        case OpcodeArgumentType.Class:
                            localClassFixups.push(new LocalFixup(currentFile.position, ret.length, i, readImmString()));
                            break;
                        case OpcodeArgumentType.Method:
                            localMethodFixups.push(new LocalFixup(currentFile.position, ret.length, i, readImmString()));
                            break;

                        case OpcodeArgumentType.JumpTarget:
                        case OpcodeArgumentType.SwitchDefaultTarget:
                            jumpFixups.push(new LocalFixup(currentFile.position, ret.length, i, readWord()));
                            break;

                        case OpcodeArgumentType.SwitchTargets:  {
                            var switchTargetLabels:Array = readList("[", "]", readImmWord, false);
                            instruction.arguments[i] = new Vector.<InstructionLabel>();
                            for (var li:int = 0; li < switchTargetLabels.length; li++) {
                                switchFixups.push(new LocalFixup(currentFile.position, ret.length, i, switchTargetLabels[li], li));
                            }
                            break;
                        }
                    }
                    if (i < instruction.opcode.arguments.length - 1) {
                        expectSymbol(",");
                    }
                }

                // Convert (g|s)etlocal [0, 3] to (g|s)etlocal0-(g|s)etlocal3
                if (instruction.opcode == Opcode.OP_getlocal && instruction.arguments[0] < 4) {
                    instruction.opcode = Opcode.fromInfo(Opcode.OP_getlocal0.val + instruction.arguments[0]);
                    instruction.arguments = new Array();
                } else if (instruction.opcode == Opcode.OP_setlocal && instruction.arguments[0] < 4) {
                    instruction.opcode = Opcode.fromInfo(Opcode.OP_setlocal0.val + instruction.arguments[0]);
                    instruction.arguments = new Array();
                }

                ret.push(instruction);
            }

            for each (var fixup:LocalFixup in jumpFixups) {
                try {
                    ret[fixup.ii].arguments[fixup.ai] = parseLabel(fixup.name, labels);
                } catch (e:Error) {
                    fixup.where.load(); // setFile(f.where.load());
                    throw e;
                }
            }

            for each (fixup in switchFixups) {
                try {
                    ret[fixup.ii].arguments[fixup.ai][fixup.si] = parseLabel(fixup.name, labels);
                } catch (e:Error) {
                    fixup.where.load(); // setFile(f.where.load());
                    throw e;
                }
            }

            for each (fixup in localClassFixups) {
                classFixups.push(new UnifiedFixup(fixup.where, ret[fixup.ii].arguments, fixup.ai, fixup.name));
            }
            for each (fixup in localMethodFixups) {
                methodFixups.push(new UnifiedFixup(fixup.where, ret[fixup.ii].arguments, fixup.ai, fixup.name));
            }

            return ret;
        }

        private function readException(labels:Dictionary /* uint[string] */):ASException {
            var readLabel:Function = function():InstructionLabel {
                var word:String = readWord();
                try {
                    return parseLabel(word, labels);
                } catch (e:Error) {
                    backpedal(word.length);
                    throw e;
                }
            };

            var ret:ASException = new ASException();

            while (true) {
                var word:String = readWord();
                switch (word) {
                    case "from":
                        ret.from = readLabel();
                        break;
                    case "to":
                        ret.to = readLabel();
                        break;
                    case "target":
                        ret.target = readLabel();
                        break;
                    case "type":
                        ret.exceptionType = readMultiname();
                        break;
                    case "name":
                        ret.varName = readMultiname();
                        break;
                    case "end":
                        return ret;
                    default:
                        throw new Error("Unknown exception field " + word);
                }
            }

            throw new Error("Unreachable");
        }

        private function readProgram():void {
            expectWord("program");
            while (true) {
                var word:String = readWord();
                switch (word) {
                    case "minorversion":
                        asp.minorVersion = readUInt();
                        break;
                    case "majorversion":
                        asp.majorVersion = readUInt();
                        break;
                    case "script":
                        asp.scripts.push(readScript());
                        break;
                    case "class":
                        asp.orphanClasses.push(readClass());
                        break;
                    case "method":
                        asp.orphanMethods.push(readMethod());
                        break;
                    case "end":
                        return;
                    default:
                        throw new Error("Unknown program field " + word);
                }
            }
        }

        private function context():String {
            var s:String = currentFile.positionStr + ": ";
            for (var f:SourceFile = currentFile.parent; f != null; f = f.parent) {
                s = s + "\n\t(included from " + f.positionStr + ")";
            }

            return s;
        }

        public function assemble(strings:Object):void {
            this.strings = strings;
            var mainFile:SourceFile = new SourceFile("main.asasm", strings["main.asasm"]);
            pushFile(mainFile);

            try {
                readProgram();
                applyFixups();
            } catch (e:Error) {
                e.message = "\n" + context() + "\n" + e.message;
                throw e;
            }
        }

        private function applyFixups():void {
            for each (var fixup:UnifiedFixup in classFixups) {
                if (fixup.name != null) {
                    if (!(fixup.name in classesById)) {
                        fixup.where.load();
                        throw new Error("Unknown class refid: " + fixup.name);
                    }
                    fixup.value = classesById[fixup.name];
                }
            }

            for each (fixup in methodFixups) {
                if (fixup.name != null) {
                    if (!(fixup.name in methodsById)) {
                        fixup.where.load();
                        throw new Error("Unknown class refid: " + fixup.name);
                    }
                    fixup.value = methodsById[fixup.name];
                }
            }

            classFixups = null;
            methodFixups = null;
            classesById = null;
            methodsById = null;
        }
    }
}
