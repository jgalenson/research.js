var Module = require('./build/z3.js')

var solve_string = Module.cwrap('solve_string', 'string', ['string'])
function test(str) {
    console.log('Testing:\n' + str)
    solve_string(str)
}

str1 = "(benchmark test\n :logic QF_UF\n :extrafuns ((x Int) (y Int))\n :formula (= x y)\n )"
str2 = "(benchmark test\n :logic QF_AUFLIA\n :extrafuns ((x Int) (y Int))\n :formula (and (and (= x 42) (= y 137) (= x y)))\n )"
str3 = "(benchmark test\n :logic QF_AUFLIA\n :extrafuns ((x Int) (y Int))\n :formula (and (> x y) (= x 42))\n )"
test(str1)
test(str2)
test(str3)
