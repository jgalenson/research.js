var Module = require('./build/lingeling.js')

// Testing function.
var solve_string = Module.cwrap('solve_string', 'string', ['string', 'int']);
function test(problem, expected) {
  console.log('Trying to solve: ' + problem)
  var result = solve_string(problem, problem.length);
  console.log('Got: ' + result);
  console.log('Expected: ' + expected);
}

// Tiny testcases.
test('p cnf 3 2\n1 -3 0\n2 3 -1 0', 'SAT 1 2 -3');
test('hi', 'UNK');
test('p cnf 1 2\n1 0\n-1 0', 'UNSAT');
