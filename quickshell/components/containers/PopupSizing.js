.pragma library

function implicitExtent(items, dimension) {
    let extent = 0
    for (const item of items) extent = Math.max(extent, item[dimension] || 0)
    return extent
}

function fittedExtent(minimum, maximum, content, padding, hugContents) {
    maximum = Math.max(0, maximum)
    minimum = Math.max(0, Math.min(minimum, maximum))
    return hugContents ? Math.max(minimum, Math.min(maximum, Math.ceil(content + padding * 2))) : maximum
}

// Fallbacks and content measurements are already in scaled logical pixels.
function dimension(value, available, scale, fallback) {
    if (typeof value === "number" && Number.isFinite(value) && value >= 0)
        return Math.round(value * scale)
    if (typeof value === "string" && /^\s*\d+(?:\.\d+)?%\s*$/.test(value))
        return Math.round(available * parseFloat(value) / 100)
    return fallback
}

function extent(value, minimum, maximum, available, content, padding, scale, hugContents) {
    maximum = Math.max(0, Math.min(maximum, available))
    minimum = Math.max(0, Math.min(minimum, maximum))
    const fallback = fittedExtent(minimum, maximum, content, padding, hugContents)
    const preferred = value === "content"
        ? fittedExtent(minimum, maximum, content, padding, true)
        : dimension(value, available, scale, fallback)
    return Math.max(minimum, Math.min(maximum, preferred))
}
