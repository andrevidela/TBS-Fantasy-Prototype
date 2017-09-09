//
//  Item.swift
//  TBS-Fantasy Prototype
//
//  Created by Brandon Zimmerman on 8/29/17.
//  Copyright © 2017 Hammer Forged Games. All rights reserved.
//
//  TODO: if Items end up not needing to be equated (==), then just remove
//  all that extra-ass code
//

import Foundation

protocol Sellable
{
    var value: Int { get }
}

/*****************************
 * Item (DO NOT INSTANTIATE) *
 *****************************/

class Item: Codable
{
    let id: ItemId // just the Id of the base item, regardless of additional attributes etc, that was used to create it
    let name: String
    let description: String

    init(_ id: ItemId, name: String, description: String)
    {
        self.id = id
        self.name = name
        self.description = description
    }
}

// EVERYTHING BELOW IS INSTANTIABLE

enum EquippableItemClass: String, Codable
{
    case helmet, body, legs, overall
    case gloves, boots
    case pendant, ring
    case weapon1H, weapon2H, rangedWeapon2H, magicWeapon1H
    case shield, tome

    var slotLogic: Equipment.SlotLogic
    {
        switch self
        {
        case .helmet:
            return .anySlots([.head])
        case .body:
            return .anySlots([.body])
        case .legs:
            return .anySlots([.legs])
        case .overall:
            return .allSlots([.body, .legs])
        case .gloves:
            return .anySlots([.gloves])
        case .boots:
            return .anySlots([.boots])
        case .pendant:
            return .anySlots([.pendant])
        case .ring:
            return .anySlots([.ring1, .ring2])
        case .weapon1H:
            return .anySlots([.mainhand, .offhand])
        case .magicWeapon1H:
            return .anySlots([.mainhand])
        case .weapon2H, .rangedWeapon2H:
            return .allSlots([.mainhand, .offhand])
        case .shield, .tome:
            return .anySlots([.offhand])
        }
    }

    var valueWeight: Double
    {
        // these are scalars that represent the weighted value of certain classes of EquippableItems; used in calculating the value of EquippleItems; leg armor is decidedly about medium-value, so are standardized as 1.0 and the values of other classes are calibrated around that
        switch self
        {
        case .legs, .weapon1H:
            return 1.0
        case .body, .weapon2H, .rangedWeapon2H:
            return 1.6
        case .magicWeapon1H, .shield:
            return 1.2
        case .overall:
            return 2.5
        case .helmet, .ring:
            return 0.8
        case .boots, .gloves:
            return 0.4
        case .pendant, .tome:
            return 1.5
        }
    }
}

class EquippableItem: Item, Sellable
{
    let level: Int
    let equipClass: EquippableItemClass
    let attributes: (def: Int, att: Int, matt: Int, range: Int)
    let numberOfSockets: Int
    var sockets: (GemstoneItem?, GemstoneItem?, GemstoneItem?) = (nil, nil, nil)
    var rarity: String
    {
        switch numberOfSockets
        {
        case 0:
            return "Common"
        case 1:
            return "Uncommon"
        case 2:
            return "Rare"
        default:
            return "Ultra-rare!"
        }
    }

    var value: Int
    {
        // formula: 10^(1 + (levelReq-1) * 0.08)
        // lv1 common legs are used as the baseline and cost roughly 10g
        let baseValue = pow(10.0, 1 + Double(level-1) * 0.08)
        return max(1, Int(baseValue * equipClass.valueWeight))
    }

    // for convenience
    var slotLogic: Equipment.SlotLogic { return equipClass.slotLogic }

    init(_ id: ItemId,
         name: String,
         description: String,
         class equipClass: EquippableItemClass,
         level levelRequirement: Int,
         sockets: Int = 0,
         def: Int = 0,
         att: Int = 0,
         matt: Int = 0,
         range: Int = 1)
    {
        self.equipClass = equipClass
        self.level = levelRequirement
        assert(sockets >= 0 && sockets <= 3, "Incorrect number of sockets (\(sockets)) to EquippableItem initializer")
        self.numberOfSockets = sockets
        self.attributes = (def, att, matt, range)
        super.init(id, name: name, description: description)
    }

    func socket(_ gemstone: GemstoneItem) -> Bool
    {
        if numberOfSockets >= 1 && sockets.0 == nil
        {
            sockets.0 = gemstone
        }
        else if numberOfSockets >= 2 && sockets.1 == nil
        {
            sockets.1 = gemstone
        }
        else if numberOfSockets == 3 && sockets.2 == nil
        {
            sockets.2 = gemstone
        }
        else
        {
            return false
        }
        return true
    }

    // CODABLE

    enum CodingKeys: CodingKey
    {
        case levelRequirement, equipClass, def, att, matt, range, numberOfSockets, sockets
    }

    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.level = try values.decode(Int.self, forKey: .levelRequirement)
        self.equipClass = try values.decode(EquippableItemClass.self, forKey: .equipClass)
        // attributes
        let def = try values.decode(Int.self, forKey: .def)
        let att = try values.decode(Int.self, forKey: .att)
        let matt = try values.decode(Int.self, forKey: .matt)
        let range = try values.decode(Int.self, forKey: .range)
        self.attributes = (def, att, matt, range)
        // sockets
        self.numberOfSockets = try values.decode(Int.self, forKey: .numberOfSockets)
        let sockets = try values.decode([GemstoneItem?].self, forKey: .sockets)
        self.sockets = (sockets[0], sockets[1], sockets[2])

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws
    {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .levelRequirement)
        try container.encode(equipClass, forKey: .equipClass)
        try container.encode(attributes.def, forKey: .def)
        try container.encode(attributes.att, forKey: .att)
        try container.encode(attributes.matt, forKey: .matt)
        try container.encode(attributes.range, forKey: .range)
        try container.encode(numberOfSockets, forKey: .numberOfSockets)
        let socketsArray = [sockets.0, sockets.1, sockets.2]
        try container.encode(socketsArray, forKey: .sockets)
    }
}
extension EquippableItem: CustomDebugStringConvertible
{
    var debugDescription: String
    {
        return "[EquippableItem \"\(name)\" lv:\(level) class:\(equipClass) sockets:\(numberOfSockets) rarity:\(rarity) value:\(value)]"
    }
}

class ConsumableItem: Item, Sellable
{
    let restoration: (hp: Double, mp: Double)

    var value: Int
    {
        return 0 // TODO CHANGE
    }

    init(_ id: ItemId,
         name: String,
         description: String,
         hp: Double = 0.0,
         mp: Double = 0.0)
    {
        self.restoration = (hp, mp)
        super.init(id, name: name, description: description)
    }

    // CODABLE

    enum CodingKeys: CodingKey
    {
        case hp, mp
    }

    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // attributes
        let hp = try values.decode(Double.self, forKey: .hp)
        let mp = try values.decode(Double.self, forKey: .mp)
        self.restoration = (hp, mp)

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws
    {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(restoration.hp, forKey: .hp)
        try container.encode(restoration.mp, forKey: .mp)
    }
}
extension ConsumableItem: CustomDebugStringConvertible
{
    var debugDescription: String
    {
        return "[ConsumableItem \"\(name)\" attr:\(restoration) value:\(value)]"
    }
}

class QuestItem: Item
{
    let questId: QuestId

    init(_ id: ItemId, name: String, description: String, questId: QuestId)
    {
        self.questId = questId
        super.init(id, name: name, description: description)
    }

    // CODABLE

    enum CodingKeys: CodingKey
    {
        case questId
    }

    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.questId = try values.decode(QuestId.self, forKey: .questId)

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws
    {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(questId, forKey: .questId)
    }
}
extension QuestItem: CustomDebugStringConvertible
{
    var debugDescription: String
    {
        return "[QuestItem \"\(name)\" quest:\(questId)]"
    }
}

enum GemstoneType: String, Codable, CustomStringConvertible
{
    case water, fire, earth, lightning

    var description: String
    {
        return self.rawValue.capitalized
    }
}

class GemstoneItem: Item, Sellable
{
    let type: GemstoneType
    let level: Int

    var value: Int
    {
        return 0 // TODO CHANGE
    }

    init(_ id: ItemId, type: GemstoneType, level: Int, description: String)
    {
        self.type = type
        self.level = level
        let name = "\(type) Gemstone (\(level.romanized()))"
        super.init(id, name: name, description: description)
    }

    // CODABLE

    enum CodingKeys: CodingKey
    {
        case type, level
    }

    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try values.decode(GemstoneType.self, forKey: .type)
        self.level = try values.decode(Int.self, forKey: .level)

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws
    {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(level, forKey: .level)
    }
}
extension GemstoneItem: CustomDebugStringConvertible
{
    var debugDescription: String
    {
        return "[GemstoneItem \"\(name)\" level:\(level) value:\(value)]"
    }
}
