-- === CURVES (snappy + controlled) ===

hl.curve("fast", {
    type = "bezier",
    points = { {0.1, 0.0}, {0.0, 1.0} }
})

hl.curve("smooth", {
    type = "bezier",
    points = { {0.25, 0.1}, {0.25, 1.0} }
})

hl.curve("linear", {
    type = "bezier",
    points = { {0, 0}, {1, 1} }
})

hl.animation({ leaf = "global",     enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "border",     enabled = true, speed = 2, bezier = "smooth" })

hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "fast" })

hl.animation({ leaf = "windowsIn",  enabled = true, speed = 2, bezier = "fast" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "fast" })

hl.animation({ leaf = "fade",       enabled = true, speed = 1.5, bezier = "linear" })

hl.animation({ leaf = "layers",     enabled = true, speed = 3, bezier = "smooth" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smooth" })

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 3, bezier = "smooth" })
