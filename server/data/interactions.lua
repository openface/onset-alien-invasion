local Interactions = {
  scrap = {
      models = {343, 344, 345, 346, 347, 348, 349, 350, 350, 351, 352, 353, 354, 362, 363, 364, 365, 366, 367, 1397},
      message = "Hit [E] to Search",
      remote_event = 'SearchForScrap'
  },
  workbench = {
      models = {1101, 1082},
      message = "Hit [E] to Use Workbench",
      remote_event = 'GetWorkbenchData'
  }
}
return Interactions