const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const logic = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(__dirname, '../modules/clipboard/ClipboardModel.js'), 'utf8'), logic);
const entry = (id, preview = id, binary = false) => ({id, preview, binary});
function model(entries) {
    const rows = entries.map(e => ({entryId: e.id, rawPreview: e.preview, binaryEntry: e.binary}));
    const mutations = [];
    return {
        rows, mutations,
        get count() {return rows.length;},
        get: index => rows[index],
        insert(index, row) {mutations.push('insert'); rows.splice(index, 0, row);},
        move(from, to, count) {mutations.push('move'); rows.splice(to, 0, ...rows.splice(from, count));},
        remove(index, count) {mutations.push('remove'); rows.splice(index, count);},
        setProperty(index, key, value) {mutations.push('update'); rows[index][key] = value;}
    };
}
test('unchanged refreshes produce no list mutations', () => {
    const entries = [entry('a'), entry('b')];
    const list = model(entries);
    assert.equal(logic.sameEntries(entries, entries.map(e => ({...e}))), true);
    logic.syncEntries(list, entries);
    assert.deepEqual(list.mutations, []);
});
test('promoting an old entry retains every existing row and its selected identity', () => {
    const list = model([entry('a'), entry('b'), entry('c')]);
    const selected = list.rows[1];
    const existing = [...list.rows];
    logic.syncEntries(list, [entry('c'), entry('a'), entry('b')]);
    assert.deepEqual(list.rows, [existing[2], existing[0], existing[1]]);
    assert.equal(list.get(logic.indexOf(list, 'b')), selected);
    assert.deepEqual(list.mutations, ['move']);
});
test('insertions and deletions preserve the row used as a scroll anchor', () => {
    const list = model([entry('a'), entry('b'), entry('c')]);
    const anchor = list.rows[1];
    logic.syncEntries(list, [entry('new'), entry('b'), entry('c')]);
    assert.deepEqual(list.rows.map(row => row.entryId), ['new', 'b', 'c']);
    assert.equal(list.get(logic.indexOf(list, 'b')), anchor);
    assert.equal(logic.indexOf(list, 'a'), -1);
});
test('preview and binary changes update an existing row', () => {
    const entries = [entry('a')];
    const next = [entry('a', 'image preview', true)];
    const list = model(entries);
    const original = list.rows[0];
    assert.equal(logic.sameEntries(entries, next), false);
    logic.syncEntries(list, next);
    assert.equal(list.get(0), original);
    assert.equal(original.rawPreview, 'image preview');
    assert.equal(original.binaryEntry, true);
});
test('clearing and repopulating history handles an empty model', () => {
    const list = model([entry('a')]);
    logic.syncEntries(list, []);
    assert.equal(list.count, 0);
    assert.equal(logic.indexOf(list, 'a'), -1);
    logic.syncEntries(list, [entry('b')]);
    assert.equal(list.get(0).entryId, 'b');
});
