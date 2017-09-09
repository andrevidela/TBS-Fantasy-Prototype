//
//  Equipment.swift
//  TBS-Fantasy Prototype
//
//  Created by Brandon Zimmerman on 8/31/17.
//  Copyright © 2017 Hammer Forged Games. All rights reserved.
//

// one Equipment object per Character in the Party
class Equipment: Codable
{
    enum Slot: String, Codable
    {
        case head, body, legs
        case gloves, boots
        case pendant, ring1, ring2
        case mainhand, offhand
    }
    enum SlotLogic
    {
        case allSlots([Slot])
        case anySlots([Slot])
    }

    private var equipped: [Slot: EquippableItem?] =
        [.head: nil,
         .body: nil,
         .legs: nil,
         .gloves: nil,
         .boots: nil,
         .pendant: nil,
         .ring1: nil,
         .ring2: nil,
         .mainhand: nil,
         .offhand: nil]

    // returns false if the item cannot be equipped
    func equip(_ item: EquippableItem) -> Bool
    {
        switch item.slotLogic
        {
        case .anySlots(let possibleSlots):
            for slot in possibleSlots
            {
                if equipped[slot]! == nil
                {
                    equipped[slot] = item
                    return true
                }
            }
            return false
        case .allSlots(let requiredSlots):
            for slot in requiredSlots
            {
                guard equipped[slot]! == nil else { return false }
            }
            // successful (all required slots are empty)
            for slot in requiredSlots
            {
                // fill up all the required slots with the item
                equipped[slot] = item
            }
            return true
        }
    }

    func unequip(slot: Slot) -> EquippableItem?
    {
        guard let item = equipped[slot]! else { return nil }
        switch item.slotLogic
        {
        case .anySlots:
            equipped.updateValue(nil, forKey: slot)
        case .allSlots(let requiredSlots):
            for slot in requiredSlots
            {
                equipped.updateValue(nil, forKey: slot)
            }
        }
        return item
    }
}
extension Equipment: CustomDebugStringConvertible
{
    var debugDescription: String
    {
        var debugString: String = "=== Equipment: ===\n"
        for (slot, item) in equipped
        {
            debugString += "\(slot):\t\(item?.name ?? "--")\n"
        }
        return debugString
    }
}
