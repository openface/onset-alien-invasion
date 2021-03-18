# Framework API

## Items

Most item configuration options are optional. Here is a sample pulled together from various objects:

```
ItemConfig["wooden_chair"] = {          -- [required] unique id / item name
    name = "Wooden Chair",              -- [required] display name
    type = 'placement',                 -- [required] item type (see Item Types)
    category = 'Furniture',             -- [required] item category for merchant grouping
    interactions = {
        use = {                         -- for interacting with object in your hand
            use_label = "Drink",
            sound = "sounds/drink.wav",
            animation = { name = "DRINKING" },
            event = "DrinkWater"
        },
        water = {                       -- for interacting with object on water.  (tree, water, vehicle_hood, etc)
            use_label = "Fill Bottle",
            sound = "sounds/fill_water.wav",
            animation = { id = 921, duration = 10000 },
            event = "FillBottle"
        }
    },
    modelid = 1262,                     -- [required] object modelid
    image = "survival/SM_Axe-Neo.png",  -- 2D image for objects using a custom asset
    max_carry = 1,                      -- [required] maximum number that can be carried in inventory
    max_use = 1,                        -- for usable types, number of times it can be used
    recipe = {                          -- resources required to build this item at workbench (nil = non-buildable)
        metal = 20,
        plastic = 5,
        wood = 2,
        computer_part = 1
    },
    weapon_id = 12,                     -- weapon id (type weapon only)
    mag_item = "rifle_mag",             -- magazine item used by this weapon (type weapon only)
    mag_size = 30,                      -- magazine size for this weapon (type weapon only)
    auto_equip = true                   -- automatically equip the item when picked up
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
    light_component = {                       -- light component to attach to object
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
        default_enabled = false         -- default light enabled
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
    prop = {                            -- creates interactive props (Hit [F] while looking at it)
        use_label = "Open",             -- use this prop directly (not through interaction with another item)
        event = "OpenStorage",          -- the event to call when using this prop directly
        options = {                     -- options passed into the event
            whatever = 'youlike',
        },
        interacts_with = {              -- when interacting with this prop through another item in-hand
            screwdriver = "picklock",   -- the item name and the item interaction to run
            crowbar = "pry"
        },
    }
})
```

## Inventory Item Types

#### weapon

-   Weapons are their own system, but are loosely integrated into the inventory
-   Can be dropped from inventory
-   Can only carry 2 weapons in slots 2,3. (slot 1 is reserved for fists/disarm)

#### resource

-   Used at the workbench to build them from them
-   Can be used but not directly (Eg. Fishing Rod is used by interacting with water)
-   Does not adhere to max_uses or track uses
-   Found in the world by scavenging scrap heaps

#### equipable

-   Can be used directory from inventory to equip
-   Does not adhere to max_uses or tracks uses
-   Plays interaction when equipping

#### usable

-   Can be used directory from inventory
-   Adheres to max_uses and trackes item uses
-   Plays interaction when using

#### placeable

-   Interactive props that can be stored in inventory
-   Can be placed into the world from inventory (cannot become a pickup again)
-   When dropped instead of placed, they are pickups
-   Can be interacted with using `prop` interactions (Eg. Press [E] to sit in a chair)
-   Placeable objects are editable (rotation and location)
-   Player can hold Left Ctrl to see all placeable objects and click to edit objects nearby
-   Placeable objects persist to the database and are respawn when server starts.

## Interactive World Props

### Merchants

```
CreateMerchant("Store", {
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

### Workbenches

```
CreateWorkbench({
    "id": 1,
    "name": "Workbench 1",
    "rz": 0,
    "sz": 1,
    "y": 193639.828125,
    "x": -105958.46875,
    "sx": 1,
    "z": 1301.0041503906,
    "modelID": 1101,
    "sy": 1,
    "ry": 1.6349707841873,
    "rx": 0
})
```

### Mechanics

Creates an interactive area for vehicle analysis and repair.

```
CreateMechanic({
    "name": "Fancy Mechanic",
    "y": 195897.5625,
    "x": -100827.96875,
    "z": 1222.7762451172,
    "sz": 1,
    "sx": 1,
    "sy": 1,
    "ry": 94.462623596191,
    "rx": -0.0014343396760523,
    "modelID": 2,
    "rz": -0.0014343259390444
})
```

### Placeable Items
