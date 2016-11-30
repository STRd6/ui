parse = require "../lib/indent-parse"

module.exports = parse """
  [M]odal
    [A]lert
    [C]onfirm
    [P]rompt
    [F]orm
    P[r]ogress
  [T]est
    Test[1]
      Hello
      Wat
    Test[2]
      [N]ested
      [R]ad
        So Rad
        Hella
          Hecka
            Super Hecka
"""
