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

function rank(query, entries) {
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
        return { entry, score: total };
    }).filter(match => match.score !== -Infinity)
        .sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name))
        .map(match => match.entry);
}
