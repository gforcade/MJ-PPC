Definitions {
AnalyticalProfile "XPosition" {
Species = "PMIUserField0"
Function = General(init="", function = "x", value = 10)
}
AnalyticalProfile "YPosition" {
Species = "PMIUserField1"
Function = General(init="", function = "y", value = 10)
}
}


Placements {
AnalyticalProfile "XPosition" {
Reference = "XPosition"
EvaluateWindow {
Element = material ["Silicon"]
}
}
AnalyticalProfile "YPosition" {
Reference = "YPosition"
EvaluateWindow {
Element = material ["Silicon"]
}
}
}
