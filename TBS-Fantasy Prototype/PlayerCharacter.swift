//
//  PlayerCharacter.swift
//  TBS-Fantasy Prototype
//
//  Created by Brandon Zimmerman on 9/8/17.
//  Copyright © 2017 Hammer Forged Games. All rights reserved.
//

class PlayerCharacter
{
    let name: String
    var stats = (str: 1, dex: 1, mag: 1)
    var location = (x: 0, y: 0)
    let equipment: Equipment

    init(name: String)
    {
        self.name = name
        self.equipment = Equipment()
    }
}
