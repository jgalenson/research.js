// Include the minisat.js file.
// http://stackoverflow.com/a/5809968
var minisat = require('fs');
eval(minisat.readFileSync('minisat.js').toString())

// Testing function.
var solve_string = s.cwrap('solve_string', 'string', ['string', 'int']);
function test(problem, expected) {
  console.log('Trying to solve: ' + problem)
  var result = solve_string(problem, problem.length);
  console.log('Got: ' + result);
  console.log('Expected: ' + expected);
}

// Tiny testcase.
test('p cnf 3 2\n1 -3 0\n2 3 -1 0', 'SAT 1 2 -3');
