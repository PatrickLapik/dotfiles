pragma Singleton
import Quickshell

// Visible popup footprints in screen coordinates, shared with notification placement.
Singleton {
    property var surfaces: []

    function setSurface(owner, screen, bounds) {
        const current = surfaces.find(surface => surface.owner === owner)
        const screenName = screen ? screen.name : ""
        if (current && current.screenName === screenName
            && current.bounds.x === bounds.x && current.bounds.y === bounds.y
            && current.bounds.width === bounds.width && current.bounds.height === bounds.height) return
        surfaces = surfaces.filter(surface => surface.owner !== owner)
            .concat([{ owner: owner, screenName: screenName, bounds: bounds }])
    }

    function removeSurface(owner) {
        if (surfaces.some(surface => surface.owner === owner))
            surfaces = surfaces.filter(surface => surface.owner !== owner)
    }

    function notificationTop(screen, left, width, baseline, gap) {
        if (!screen) return baseline
        let top = baseline
        for (const surface of surfaces) {
            const bounds = surface.bounds
            if (surface.screenName === screen.name && bounds.width > 0 && bounds.height > 0
                && bounds.x < left + width && bounds.x + bounds.width > left)
                top = Math.max(top, bounds.y + bounds.height + gap)
        }
        return top
    }
}
