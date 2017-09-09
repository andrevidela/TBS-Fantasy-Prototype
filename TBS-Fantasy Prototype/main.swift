//
//  main.swift
//  TBS-Fantasy Prototype
//
//  Created by Brandon Zimmerman on 8/29/17.
//  Copyright © 2017 Hammer Forged Games. All rights reserved.
//

import Foundation

let inv = Inventory()
let equ = Equipment()

let boots = EquippableItem(0001, name: "Boots of Speed", description: "These will get you where you want to go (fast).", class: .boots, level: 1, sockets: 0, def: 5)

let healthPot = ConsumableItem(1001, name: "Health Potion (Minor)", description: "A flask filled with a viscous and bitter fluid.", hp: 30)

let note = QuestItem(2001, name: "Inconspicuous Note", description: "...", questId: 0001)

let ringOfThorns = EquippableItem(0002, name: "Ring of Thorns", description: "Fancy.", class: .ring, level: 8, sockets: 1)

let manaPot = ConsumableItem(1002, name: "Mana Potion (Minor)", description: "Drippy.", mp: 30)

let key = QuestItem(2002, name: "Inconspicuous Key", description: "...", questId: 0001)

let shield = EquippableItem(0003, name: "Tower Shield", description: "Tall.", class: .shield, level: 8, sockets: 2, def: 20)

let bastardSword = EquippableItem(0004, name: "Bastard Sword", description: "...", class: .weapon2H, level: 1, sockets: 1, att: 15)

let ringOfHealing = EquippableItem(0002, name: "Ring of Healing", description: "Fancy.", class: .ring, level: 4, sockets: 0)

let fireGemstone = GemstoneItem(0001, type: .fire, level: 4, description: "A stone.")

if bastardSword.socket(fireGemstone)
{
    print("Socketed \(bastardSword.name) with \(fireGemstone.name)")
}

func testInventory()
{
    print("Adding items to inventory...")

    inv.addItem(boots)
    inv.addItem(healthPot)
    inv.addItem(note)
    inv.addItem(ringOfThorns)
    inv.addItem(manaPot)
    inv.addItem(key)
    inv.addItem(shield)
    inv.addItem(bastardSword)
    inv.addItem(ringOfHealing)
    inv.addItem(fireGemstone)

    debugPrint(inv)

    print("Sorting your inventory...")
    inv.sortItems()

    debugPrint(inv)

    print("Selecting slot 03\nRemoving slot 03")
    inv.selectedSlot = 3
    let _ = inv.removeItem()

    debugPrint(inv)

    print("Swapping slot 05 with slot 00")
    inv.swapItem(at: 05, with: 00)

    debugPrint(inv)

    print("Sorting your inventory...")
    inv.sortItems()

    debugPrint(inv)
}

func testEquipment()
{
    print("Equipping \(boots)...")
    if !equ.equip(boots) { print("Couldn't equip it.") }

    debugPrint(equ)

    print("Equipping \(shield)...")
    if !equ.equip(shield) { print("Couldn't equip it.") }

    debugPrint(equ)

    print("Equipping \(bastardSword)...")
    if !equ.equip(bastardSword) { print("Couldn't equip it.") }

    debugPrint(equ)

    print("Equipping \(ringOfThorns)...")
    if !equ.equip(ringOfThorns) { print("Couldn't equip it.") }

    debugPrint(equ)

    print("Equipping \(ringOfHealing)...")
    if !equ.equip(ringOfHealing) { print("Couldn't equip it.") }

    debugPrint(equ)

    print("Equipping \(ringOfHealing)...")
    if !equ.equip(ringOfHealing) { print("Couldn't equip it.") }

    debugPrint(equ)

    print("Unequipping offhand...")
    let _ = equ.unequip(slot: .offhand)

    debugPrint(equ)

    print("Equipping \(bastardSword)...")
    if !equ.equip(bastardSword) { print("Couldn't equip it.") }

    debugPrint(equ)
}

func testJSONCoding<T: Codable>(for item: T) -> T
{
    do
    {
        print("Attempting to encode \(item)...")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(item)
        let jsonOutput = String(data: data, encoding: .utf8)!

        print("Converted to JSON:")
        print(jsonOutput)

        print("Attempting to decode...")
        let decoder = JSONDecoder()
        let itemCopy = try decoder.decode(T.self, from: data)

        print("Successful. Decoded object:")
        debugPrint(itemCopy)

        return itemCopy
    }
    catch
    {
        print("The coding for \(item) failed.")
        exit(EXC_CRASH)
    }
}

testInventory()
let copy = testJSONCoding(for: inv)
let copyCopy = testJSONCoding(for: copy)
