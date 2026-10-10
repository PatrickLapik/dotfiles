// Ordered subsequence matching, rewarding word starts and consecutive letters.
function score(query, text) {
    query = query.toLocaleLowerCase();
    text = text.toLocaleLowerCase();
    let position = -1, total = 0;
    for (const letter of query) {
        const next = text.indexOf(letter, position + 1);
        if (next < 0) return -Infinity;
        total += 10;
        if (next === position + 1) total += 12;
        if (next === 0 || /[\s._-]/.test(text[next - 1])) total += 15;
        total -= next - position - 1;
        position = next;
    }
    return total - text.length * 0.05;
}

function matches(query, entries, boost) {
    const words = query.trim().toLocaleLowerCase().split(/\s+/).filter(Boolean);
    return entries.filter(entry => !entry.noDisplay).map(entry => {
        const fields = [entry.name || '', entry.genericName || '',
            (entry.keywords || []).join(' '), entry.id || ''];
        let total = 0;
        for (const word of words) {
            const best = Math.max(...fields.map((field, index) => score(word, field) - index * 15));
            if (best === -Infinity) return { entry, score: -Infinity };
            total += best;
        }
        const exact = fields[0].toLocaleLowerCase() === query.trim().toLocaleLowerCase();
        return { entry, score: total + (exact && words.length ? 1000 : 0) + (boost ? boost(entry.id) : 0) };
    }).filter(match => match.score !== -Infinity)
        .sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));
}

function rank(query, entries, boost) {
    return matches(query, entries, boost).map(match => match.entry);
}

// Rank whole app groups; a launch action always precedes its selectable windows.
function grouped(query, apps, windows, boost) {
    const appMatches = matches(query, apps, boost);
    const windowMatches = matches(query, windows);
    const appScores = new Map(appMatches.map(match => [match.entry.id, match.score]));
    const windowScores = new Map(windowMatches.map(match => [match.entry, match.score]));
    const installed = new Set(apps.map(app => app.id));
    const groups = [];
    for (const app of apps) {
        const children = windows.filter(row => row.entry && row.entry.id === app.id);
        const matchingChildren = children.filter(row => windowScores.has(row));
        const appMatchesQuery = appScores.has(app.id);
        if (!appMatchesQuery && !matchingChildren.length) continue;
        const score = Math.max(appMatchesQuery ? appScores.get(app.id) : -Infinity,
            ...matchingChildren.map(row => windowScores.get(row) + (boost ? boost(app.id) : 0)));
        groups.push({name: app.name, score: score, rows: [app].concat(
            (appMatchesQuery ? children : matchingChildren).map(row => Object.assign({}, row, {child: true})))});
    }
    // Unmapped windows remain searchable even without an installed launch action.
    for (const match of windowMatches) {
        if (!match.entry.entry || !installed.has(match.entry.entry.id))
            groups.push({name: match.entry.name, score: match.score, rows: [match.entry]});
    }
    groups.sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
    return groups.reduce((rows, group) => rows.concat(group.rows), []);
}
