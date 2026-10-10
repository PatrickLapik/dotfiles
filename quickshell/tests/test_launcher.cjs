const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const logic = vm.createContext({});
for (const file of ['Calculator.js', 'Fuzzy.js']) {
    vm.runInContext(fs.readFileSync(path.join(__dirname, '../modules/launcher', file), 'utf8'), logic);
}
test('calculator precedence, right-associative powers, unary signs and functions', () => {
    for (const [expression, expected] of [
        ['2+3*4', '14'], ['(2+3)*4', '20'], ['2^3^2', '512'], ['-2^2', '-4'],
        ['(-2)^2', '4'], ['2^-2', '0.25'], ['sqrt(81)+abs(-2)', '11'],
        ['1e3 / 4', '250'], ['=42', '42'], ['0.1 + 0.2', '0.3'], ['10 % 3', '1']
    ]) assert.equal(logic.calculate(expression), expected, expression);
});
test('calculator ignores searches, rejects incomplete, unsafe and nonfinite expressions', () => {
    for (const expression of ['Firefox', '123', '1/0', 'sqrt(-1)', '2+', '(2+3', '2 3',
        'process.exit()', '1;2', 'constructor(1)', '=NaN', '9^9999', '('.repeat(300)]) {
        assert.equal(logic.calculate(expression), null, expression);
    }
});
test('search matches window titles, keywords and app IDs; excludes hidden entries', () => {
    const entries = [
        {id: 'browser', name: 'Browser', keywords: ['web']},
        {id: 'window:editor', name: 'project notes — Editor', genericName: 'Editor'},
        {id: 'org.tools.Terminal', name: 'Console'},
        {id: 'hidden', name: 'Hidden', noDisplay: true}
    ];
    assert.equal(logic.rank('notes', entries)[0].id, 'window:editor');
    assert.equal(logic.rank('web', entries)[0].id, 'browser');
    assert.equal(logic.rank('terminal', entries)[0].id, 'org.tools.Terminal');
    assert.equal(logic.rank('hidden', entries).length, 0);
});
test('usage breaks close ties without displacing exact names or including nonmatches', () => {
    const entries = [{id: 'one', name: 'Code'}, {id: 'two', name: 'Code Editor'}, {id: 'three', name: 'Calculator'}];
    assert.equal(logic.rank('code', entries, id => id === 'two' ? 7 : 0)[0].id, 'one');
    assert.equal(logic.rank('code', entries, () => 7).length, 2);
    const twins = [{id: 'old', name: 'Terminal'}, {id: 'recent', name: 'Terminal'}];
    assert.equal(logic.rank('term', twins, id => id === 'recent' ? 7 : 0)[0].id, 'recent');
});

test('app search groups launch first and all running windows below it', () => {
    const app = {id: 'Alacritty', name: 'Alacritty', kind: 'app'};
    const windows = [
        {id: 'w1', name: 'project shell', genericName: 'Alacritty', entry: app, kind: 'window'},
        {id: 'w2', name: 'logs', genericName: 'Alacritty', entry: app, kind: 'window'}
    ];
    const rows = logic.grouped('alacritty', [app], windows, () => 0);
    assert.deepEqual(Array.from(rows, row => row.id), ['Alacritty', 'w1', 'w2']);
    assert.ok(rows[1].child && rows[2].child);
});
test('window-title search retains its launch parent but excludes unrelated children', () => {
    const app = {id: 'terminal', name: 'Alacritty'};
    const windows = [{id: 'w1', name: 'project logs', entry: app}, {id: 'w2', name: 'other', entry: app}];
    assert.deepEqual(Array.from(logic.grouped('logs', [app], windows), row => row.id), ['terminal', 'w1']);
});
test('empty search ranks app groups by history and preserves untracked and unmapped entries', () => {
    const apps = [{id: 'old', name: 'A'}, {id: 'recent', name: 'Z'}];
    const windows = [{id: 'w', name: 'Window', entry: apps[1]}, {id: 'unknown', name: 'Unmapped'}];
    const rows = logic.grouped('', apps, windows, id => id === 'recent' ? 7 : 0);
    assert.deepEqual(Array.from(rows, row => row.id), ['recent', 'w', 'old', 'unknown']);
    assert.equal(rows[3].child, undefined);
});
