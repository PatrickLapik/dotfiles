function sameEntries(previous, next) {
    return previous.length === next.length && previous.every((entry, index) =>
        entry.id === next[index].id && entry.preview === next[index].preview
            && entry.binary === next[index].binary)
}

// Reuse rows by ID so refreshes retain delegates, focus and hover state.
function syncEntries(model, entries) {
    for (let index = 0; index < entries.length; index++) {
        const entry = entries[index]
        if (index >= model.count || model.get(index).entryId !== entry.id) {
            let existing = index + 1
            while (existing < model.count && model.get(existing).entryId !== entry.id) existing++
            if (existing < model.count) model.move(existing, index, 1)
            else model.insert(index, { entryId: entry.id, rawPreview: entry.preview, binaryEntry: entry.binary })
        }
        const row = model.get(index)
        if (row.rawPreview !== entry.preview) model.setProperty(index, "rawPreview", entry.preview)
        if (row.binaryEntry !== entry.binary) model.setProperty(index, "binaryEntry", entry.binary)
    }
    if (model.count > entries.length) model.remove(entries.length, model.count - entries.length)
}

function indexOf(model, id) {
    for (let index = 0; index < model.count; index++) {
        if (model.get(index).entryId === id) return index
    }
    return -1
}
