pragma Singleton
import Quickshell

Singleton {
    property var entries: ({})
    property string activeName: ""
    property var anchors: ({})
    function setAnchor(name, screenName, owner, item) {
        const next = Object.assign({}, anchors)
        next[name + ":" + screenName] = { owner: owner, item: item }
        anchors = next
    }
    function removeAnchor(name, screenName, owner) {
        const key = name + ":" + screenName
        if (!anchors[key] || anchors[key].owner !== owner) return
        const next = Object.assign({}, anchors)
        delete next[key]
        anchors = next
    }
    function anchorFor(name, screenName) {
        const anchor = anchors[name + ":" + screenName]
        return anchor ? anchor.item : null
    }
    function register(name, owner, openAction, closeAction) {
        const next = Object.assign({}, entries)
        next[name] = { owner: owner, open: openAction, close: closeAction }
        entries = next
    }
    function unregister(name, owner) {
        if (!entries[name] || entries[name].owner !== owner) return
        const next = Object.assign({}, entries)
        delete next[name]
        entries = next
        closed(name)
    }
    function screenFor(name) {
        return Quickshell.screens.find(screen => screen.name === name) || Quickshell.screens[0]
    }
    function open(name, screenName) {
        if (!entries[name]) return false
        for (const key of Object.keys(entries)) if (key !== name) entries[key].close()
        activeName = name
        entries[name].open(screenName)
        return true
    }
    function close(name) {
        if (!entries[name]) return false
        entries[name].close()
        closed(name)
        return true
    }
    function toggle(name, screenName) {
        return activeName === name ? close(name) : open(name, screenName)
    }
    function closed(name) { if (activeName === name) activeName = "" }
}
