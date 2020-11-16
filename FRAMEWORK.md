# Framework API

## Registering Item

#### Inventory Configuration


```
RegisterObject("wooden_chair", {        -- unique id / item name
    name = "Wooden Chair",              -- display name
    type = 'prop',                      -- item type (see Item Types)
    interaction = {
        animation = { name = "SIT" }    -- animation to play when equipping/using
        sound = ""                      -- sound to play when equipping/using
    },
    modelid = 1262,                     -- modelid
    max_carry = 1,                      -- maximum number that can be carried in inventory
    recipe = {                          -- resources required to build this item (workbench)
        metal = 20,
        plastic = 5
    },
    price = 150,                        -- cash required to purchase this item (merchant)
    attachment = {                      -- how to attach this item to player when equipped/using
        x = -20, 
        y = 5, 
        z = 22, 
        rx = 82, 
        ry = 180, 
        rz = 10, 
        bone = "hand_r" 
    }
})
```

## Inventory Item Types

#### WEAPON
- Weapons are their own system, but are loosely integrated into the inventory
- Can be dropped from inventory
- Can only carry 2 weapons in slots 2,3.  (slot 1 is reserved for fists/disarm)

#### RESOURCE
- Can be used but not directly (Eg. Fishing rod is used by interacting with water)
- Does not adhere to max_uses or track uses
- Found in the world by scavenging scrap heaps

#### EQUIPPABLE
- Can be used directory from inventory to equip
- Does not adhere to max_uses or tracks uses
- Plays interaction when equipping

#### USABLE
- Can be used directory from inventory
- Adheres to max_uses and trackes item uses

#### PROP
- Interactive props that can be stored in inventory
- Can be mounted into the world from inventory
- When dropped, they are pickups
- Can be interacted with (Eg. Press [E] to sit in a chair)
- TODO: how to move them around within the world or unmount them from world

## Interactive World Props

```
CreateProp(v, { message = "Search", remote_event = "SearchForScrap"})
```

```
AddRemoteEvent("SearchForScrap", function(player)
```

## Item Callbacks

#### USE

```
Called AFTER duration delay

# items/toolbox.lua
AddEvent("items:toolbox:use", function(player, item_cfg, options)
```
