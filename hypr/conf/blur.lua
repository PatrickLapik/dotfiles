return {
    enabled = true,
    size = 10,
    passes = 3,
    new_optimizations = true,
    ignore_opacity = true,
    xray = true,
    -- Darken and soften the backdrop so bright windows can't wash out translucent
    -- panels; a little noise hides banding and the "smeared picture" look.
    brightness = 0.7,
    contrast = 0.9,
    noise = 0.02,
}
