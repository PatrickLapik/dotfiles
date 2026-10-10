// Small arithmetic grammar. Never evaluates JavaScript or shell commands.
function calculate(input) {
    const source = input.trim().replace(/^=\s*/, '');
    if (!source || source.length > 256) return null;
    const tokens = source.match(/(?:\d+(?:\.\d*)?|\.\d+)(?:e[+-]?\d+)?|[a-z]+|[^\s]/gi) || [];
    let i = 0;
    function primary() {
        const token = tokens[i++];
        if (token === '(') {
            const value = sum();
            if (tokens[i++] !== ')') throw Error('parenthesis');
            return value;
        }
        if (/^(?:\d+(?:\.\d*)?|\.\d+)(?:e[+-]?\d+)?$/i.test(token || '')) return Number(token);
        if (token === 'pi') return Math.PI;
        if (token === 'e') return Math.E;
        const functions = {sqrt: Math.sqrt, abs: Math.abs, round: Math.round, floor: Math.floor, ceil: Math.ceil};
        if (Object.prototype.hasOwnProperty.call(functions, token) && tokens[i++] === '(') {
            const value = sum();
            if (tokens[i++] !== ')') throw Error('parenthesis');
            return functions[token](value);
        }
        throw Error('operand');
    }
    function power() {
        const value = primary();
        if (tokens[i] === '^') { i++; return Math.pow(value, unary()); }
        return value;
    }
    function unary() {
        if (tokens[i] === '+') { i++; return unary(); }
        if (tokens[i] === '-') { i++; return -unary(); }
        return power();
    }
    function product() {
        let value = unary();
        while (['*', '/', '%'].indexOf(tokens[i]) >= 0) {
            const op = tokens[i++], rhs = unary();
            value = op === '*' ? value * rhs : op === '/' ? value / rhs : value % rhs;
        }
        return value;
    }
    function sum() {
        let value = product();
        while (tokens[i] === '+' || tokens[i] === '-') {
            const op = tokens[i++], rhs = product();
            value = op === '+' ? value + rhs : value - rhs;
        }
        return value;
    }
    try {
        const value = sum();
        if (i !== tokens.length || !Number.isFinite(value)) return null;
        // Plain numbers are usually application searches unless explicitly prefixed.
        if (!input.trim().startsWith('=') && tokens.length === 1 && !isNaN(Number(tokens[0]))) return null;
        return String(Number(value.toPrecision(12)));
    } catch (_) { return null; }
}
