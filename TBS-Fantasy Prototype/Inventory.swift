//
//  Inventory.swift
//  TBS-Fantasy Prototype
//
//  Created by Brandon Zimmerman on 9/1/17.
//  Copyright © 2017 Hammer Forged Games. All rights reserved.
//

class Inventory: Codable
{
    static let capacity = 36

    private var items: [Item?]
    {
        didSet
        {
            let count = items.count
            if count < Inventory.capacity
            {
                // pads the other slots with nils, if undersized, allowing us to store undersized arrays to self.items without having to worry about padding each time
                let amendment = [Item?](repeating: nil, count: Inventory.capacity - count)
                items += amendment
            }
        }
    }
    var selectedSlot: InventorySlot = 0
    {
        didSet
        {
            if selectedSlot < 0
            {
                selectedSlot = 0
            }
            else if selectedSlot >= Inventory.capacity
            {
                selectedSlot = Inventory.capacity
            }
        }
    }
    var currentlySelectedItem: Item?
    {
        return items[selectedSlot]
    }

    init()
    {
        items = [Item?](repeating: nil, count: Inventory.capacity)
    }

    private func firstEmptySlot() -> InventorySlot?
    {
        for (slot, item) in items.enumerated()
        {
            if item == nil { return slot }
        }
        return nil
    }

    @discardableResult
    func addItem(_ item: Item) -> Bool
    {
        guard let slot = firstEmptySlot() else { return false }
        items[slot] = item
        return true
    }

    func removeItem() -> Item?
    {
        let removedItem = items[selectedSlot]
        items[selectedSlot] = nil
        return removedItem
    }

    func swapItem(at slotA: InventorySlot, with slotB: InventorySlot)
    {
        let temp = items[slotB]
        items[slotB] = items[slotA]
        items[slotA] = temp
    }

    func sortItems()
    {
        func precedesAlphabetically(_ left: Item, _ right: Item) -> Bool
        {
            return left.name < right.name
        }

        let grouped = items.reduce(([], [], [], [])) {
            (acc, item) -> ([Item], [Item], [Item], [Item]) in
            if let item = item as? QuestItem
            {
                return (acc.0 + [item], acc.1, acc.2, acc.3)
            }
            else if let item = item as? ConsumableItem
            {
                return (acc.0, acc.1 + [item], acc.2, acc.3)
            }
            else if let item = item as? GemstoneItem
            {
                return (acc.0, acc.1, acc.2 + [item], acc.3)
            }
            else if let item = item as? EquippableItem
            {
                return (acc.0, acc.1, acc.2, acc.3 + [item])
            }
            else
            {
                return (acc.0, acc.1, acc.2, acc.3)
            }
        }
        let sorted: [Item] =
            grouped.0.sorted(by: precedesAlphabetically) + // QuestItems
            grouped.1.sorted(by: precedesAlphabetically) + // ConsumableItems
            grouped.2.sorted(by: precedesAlphabetically) + // GemstoneItems
            grouped.3.sorted(by: precedesAlphabetically)   // EquippableItems

        self.items = sorted
    }
}
extension Inventory: CustomDebugStringConvertible
{
    var debugDescription: String
    {
        var debugString: String = "=== Inventory: ===\n"
        for (slot, item) in items.enumerated()
        {
            debugString += "\(String(format: "%02d", slot)): \(item?.name ?? "--")\n"
        }
        return debugString
    }
}
