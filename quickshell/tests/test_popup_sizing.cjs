// Run with: node --test quickshell/tests/test_popup_sizing.cjs
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const sizing = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(__dirname, '../components/containers/PopupSizing.js'), 'utf8')
    .replace(/^\.pragma library\s*/, ''), sizing);

test('numbers scale once; monitor fractions do not scale', () => {
    assert.equal(sizing.dimension(360, 1920, 1.25, 0), 450);
    assert.equal(sizing.dimension('40%', 1920, 1.25, 0), 768);
    assert.equal(sizing.dimension('40%', 1280, 1.25, 0), 512);
});
test('relative launcher width respects scaled bounds and small screens', () => {
    const width = (available, scale = 1) => sizing.extent('40%', 480 * scale,
        900 * scale, available, 200, 18, scale, true);
    assert.equal(width(1920), 768);
    assert.equal(width(3840), 900);
    assert.equal(width(1000), 480);
    assert.equal(width(300), 300);
    assert.equal(width(1920, 2), 960);
});
test('content includes padding, grows to the cap, and overrides global fixed sizing', () => {
    assert.equal(sizing.extent('content', 0, 700, 1000, 200, 18, 1, false), 236);
    assert.equal(sizing.extent('content', 0, 700, 1000, 1200, 18, 1, true), 700);
    assert.equal(sizing.extent('70%', 0, 1000, 1000, 200, 18, 1, true), 700);
});
test('legacy omitted axes still obey hugContents', () => {
    assert.equal(sizing.extent(undefined, 0, 600, 1000, 200, 18, 1, true), 236);
    assert.equal(sizing.extent(undefined, 0, 600, 1000, 200, 18, 1, false), 600);
});
test('invalid values fall back; zero, conflicting bounds and unavailable screens are safe', () => {
    for (const value of [-1, NaN, Infinity, 'oops', '-20%', '40%junk', null])
        assert.equal(sizing.dimension(value, 1000, 1, 123), 123);
    assert.equal(sizing.dimension(0, 1000, 1, 123), 0);
    assert.equal(sizing.extent('content', 1080, 600, 1000, 100, 18, 1, true), 600);
    assert.equal(sizing.extent('40%', 480, 900, 0, 100, 18, 1, true), 0);
});
