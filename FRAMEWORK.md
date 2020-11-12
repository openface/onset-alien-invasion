# Framework API

## Registering Item


## Item Callbacks

#### USE

```
# items/toolbox.lua
AddEvent("items:toolbox:use", function(player, item_cfg, options)
```


## Inventory Item Types

#### WEAPON

#### RESOURCE
- Can be used but not directly

#### EQUIPPABLE

#### USABLE
- Can be used directory from inventory

## Interactive World Props

```
CreateProp(v, { message = "Search", remote_event = "SearchForScrap"})
```

```
AddRemoteEvent("SearchForScrap", function(player)
```