pragma Singleton
import Quickshell

Singleton {
    id: root
    property var locks: []
    property int nextToken: 1
    property var visibleBottoms: ({})

    function setVisibleBottom(screen: ShellScreen, bottom: real) {
        if (!screen || visibleBottoms[screen.name] === bottom) return
        const next = Object.assign({}, visibleBottoms)
        next[screen.name] = bottom
        visibleBottoms = next
    }
    function visibleBottom(screen: ShellScreen): real {
        return screen ? visibleBottoms[screen.name] || 0 : 0
    }

    function acquire(screen: ShellScreen): int {
        if (!screen) return -1
        const token = nextToken++
        locks = locks.concat([{ token: token, screenName: screen.name }])
        return token
    }
    function release(token: int) {
        if (token < 0) return
        locks = locks.filter(lock => lock.token !== token)
    }
    function isLocked(screen: ShellScreen): bool {
        return !!screen && locks.some(lock => lock.screenName === screen.name)
    }
}
