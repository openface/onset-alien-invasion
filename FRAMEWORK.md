# Framework API

## Items

Most item configuration options are optional.  Here is a sample pulled together from various objects:

```
RegisterObject("wooden_chair", {        -- [required] unique id / item name
    name = "Wooden Chair",              -- [required] display name
    type = 'prop',                      -- [required] item type (see Item Types)
    category = 'Furniture',             -- [required] item category for merchant grouping
    interaction = {
        animation = { 
            name = "SIT",               -- animation to play when equipping/using
            duration = "4000"           -- milliseconds to delay for animation (default 2000)
            spinner = false             -- shows a spinner for the duration of interaction
        },
        sound = "sounds/squeak.mp3"     -- sound to play during interaction with object
    },
    modelid = 1262,                     -- [required] object modelid
    image = "survival/SM_Axe-Neo.png",  -- 2D image for objects using a custom asset
    max_carry = 1,                      -- [required] maximum number that can be carried in inventory
    max_use = 1,                        -- for usable types, number of times it can be used
    use_label = "Activate",             -- for usable types, the alternate name for "Use"
    recipe = {                          -- resources required to build this item at workbench (nil = non-buildable)
        metal = 20,
        plastic = 5,
        wood = 2,
        computer_part = 1
    },
    price = 150,                        -- cash required to purchase this item at merchant (nil = non-purchasable)
    attachment = {                      -- how to attach this item to player when equipped/using
        x = -20, 
        y = 5, 
        z = 22, 
        rx = 82, 
        ry = 180, 
        rz = 10, 
        bone = "hand_r" 
    },
    component = {                       -- light component to attach to object
        type = "pointlight",            -- pointlight, spotlight, or rectlight
        position = {
            x = 3,
            y = 0,
            z = 20,
            rx = 0,
            ry = 0,
            rz = 0
        },
        intensity = 5000                -- light intensity
    },
    particle = {                        -- particle to emit for this object
        path = "/Game/Geometry/OldTown/Effects/PS_LanternFire",
        position = {                    -- relative position to object
            x = 0, 
            y = 0, 
            z = 17, 
            rx = 0, 
            ry = 0, 
            rz = 0 
        },
    },
    prop_options = {                    -- creates interactive props
        message = "Sit",
        client_event = "SitInChair",
        remote_event = "SitInChair",
        options = {
            type = 'object',
        }
    }
})
```

## Inventory Item Types

#### weapon
- Weapons are their own system, but are loosely integrated into the inventory
- Can be dropped from inventory
- Can only carry 2 weapons in slots 2,3.  (slot 1 is reserved for fists/disarm)

#### resource
- Used at the workbench to build them from them
- Can be used but not directly (Eg. Fishing Rod is used by interacting with water)
- Does not adhere to max_uses or track uses
- Found in the world by scavenging scrap heaps

#### equipable
- Can be used directory from inventory to equip
- Does not adhere to max_uses or tracks uses
- Plays interaction when equipping

#### usable
- Can be used directory from inventory
- Adheres to max_uses and trackes item uses
- Plays interaction when using

#### placeable
- Interactive props that can be stored in inventory
- Can be placed into the world from inventory (cannot become a pickup again)
- When dropped instead of placed, they are pickups
- Can be interacted with using `prop_options` (Eg. Press [E] to sit in a chair)
- Placeable objects are editable (rotation and location)
- Player can hold Left Ctrl to see all placeable objects and click to edit objects nearby

## Interactive World Props

```
CreateProp(v, { message = "Search", remote_event = "SearchForScrap"})
```

```
AddRemoteEvent("SearchForScrap", function(player)
```

### Built-in Interactive Prop Definitions

#### Sitting in a chair
#### Fishing in water
#### Harvesting tree
#### Repairing vehicle
#### Opening storage

## Item Event Callbacks

#### After Use

```
AddEvent("items:beer:use", function(player)
    -- drunk effect
end)
```

#### After Equip
```
AddEvent("items:vest:equip", function(player, object)
    SetPlayerArmor(player, 100)
end)
```

#### After Unequip

```
AddEvent("items:vest:unequip", function(player, object)
    SetPlayerArmor(player, 0)
end)
```

## Merchants

```
RegisterMerchant("Store", {
    "x": -99669.5703125,
    "y": 197139.015625,
    "z": 1231.4288330078,
    "rx": -0.0026842642109841,
    "sx": 1,
    "rz": -0.0026855466421694,
    "ry": -178.4490814209,
    "modelID": 571,
    "sz": 1,
    "sy": 1
  })
```

## Storages

```
RegisterStorage("Crate",   {
    "rz": 0,
    "sz": 1,
    "y": 192622.484375,
    "x": -103740.4765625,
    "sx": 1,
    "z": 1215,
    "modelID": 1013,
    "sy": 1,
    "ry": 0,
    "rx": 0
  })
```

## Scrapheaps

```
RegisterScrapheap({
    "rz": 0,
    "sz": 1,
    "y": 177447.8125,
    "x": -107744.359375,
    "sx": 1,
    "z": 1205.9958496094,
    "modelID": 345,
    "sy": 1,
    "ry": 0,
    "rx": 0
  })
```