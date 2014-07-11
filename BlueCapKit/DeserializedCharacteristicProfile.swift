//
//  IntegerCharacteristicProfile.swift
//  BlueCap
//
//  Created by Troy Stribling on 7/9/14.
//  Copyright (c) 2014 gnos.us. All rights reserved.
//

import Foundation

class DeserializedCharacteristicProfile<DeserializedType:Deserialized> : CharacteristicProfile {

    var endianness : Endianness = .Little
    
    init(uuid:String, name:String, fromEndianness endianness:Endianness) {
        super.init(uuid:uuid, name:name)
        self.endianness = endianness
    }
    
    convenience init(uuid:String, name:String, fromEndianness endianness:Endianness, profile:(characteristic:DeserializedCharacteristicProfile) -> ()) {
        self.init(uuid:uuid, name:name, fromEndianness:endianness)
        profile(characteristic:self)
    }
    
    // APPLICATION INTERFACE
    override func stringValue(data:NSData) -> Dictionary<String, String>? {
        return [self.name:"\(self.deserialize(data))"]
    }
    
    override func anyValue(data:NSData) -> Any? {
        return self.deserialize(data)
    }
    
    override func dataValue(data:Dictionary<String, String>) -> NSData? {
        if let stringValue = data[self.name] {
            if let value = DeserializedType.fromString(stringValue) {
                return self.serialize(value)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    override func dataValue(object: Any) -> NSData? {
        if let value = object as? DeserializedType.DeserializedType {
            return self.serialize(value)
        } else {
            return nil
        }
    }
    
    // PRIVATE INTERFACE
    func deserialize(data:NSData) -> DeserializedType.DeserializedType {
        switch self.endianness {
        case Endianness.Little:
            return DeserializedType.deserializeFromLittleEndian(data)
        case Endianness.Big:
            return DeserializedType.deserializeFromBigEndian(data)
        }
    }
    
    func serialize(value:DeserializedType.DeserializedType) -> NSData {
        switch self.endianness {
        case Endianness.Little:
            return NSData.serializeToLittleEndian(value)
        case Endianness.Big:
            return NSData.serializeToBigEndian(value)
        }
    }
}