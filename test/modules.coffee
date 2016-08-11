# Modules, a.k.a. ES2015 import/export
# ------------------------------------
#
# Remember, we’re not *resolving* modules, just outputting valid ES2015 syntax.


# This is the CoffeeScript import and export syntax, closely modeled after the ES2015 syntax
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export

# import "module-name"
# import defaultMember from "module-name"
# import * as name from "module-name"
# import { member } from "module-name"
# import { member as alias } from "module-name"
# import { member1 , member2 } from "module-name"
# import { member1 , member2 as alias2 , [...] } from "module-name"
# import defaultMember, { member [ , [...] ] } from "module-name"
# import defaultMember, * as name from "module-name"

# export { name1, name2, …, nameN }
# export { variable1 as name1, variable2 as name2, …, nameN }
# export default expression
# export default ->
# export { name1 as default, … }

# export * from …
# export { name1, name2, …, nameN } from …
# export { import1 as name1, import2 as name2, …, nameN } from …

# Syntaxes from the MDN documentation that are *not* supported, because of ambiguous grammar and similarity to unsupported `var foo, bar = 'baz'`:
# export name1, name2, …, nameN
# export name1 = …, name2 = …, …, nameN


# Helper function
toJS = (str) ->
  CoffeeScript.compile str, bare: yes
  .replace /^\s+|\s+$/g, '' # Trim leading/trailing whitespace


# Import statements

test "backticked import statement", ->
  input = "`import { foo, bar as baz } from 'lib'`"
  output = "import { foo, bar as baz } from 'lib';"
  eq toJS(input), output

test "import an entire module for side effects only, without importing any bindings", ->
  input = "import 'lib'"
  output = "import 'lib';"
  eq toJS(input), output

test "import default member from module, adding the member to the current scope", ->
  input = "import foo from 'lib'\nfoo.fooMethod()"
  output = "import foo from 'lib';\n\nfoo.fooMethod();"
  eq toJS(input), output

test "import an entire module's contents as an alias, adding the alias to the current scope", ->
  input = "import * as foo from 'lib'\nfoo.fooMethod()"
  output = "import * as foo from 'lib';\n\nfoo.fooMethod();"
  eq toJS(input), output

test "import a single member of a module, adding the member to the current scope", ->
  input = "import { foo } from 'lib'\nfoo.fooMethod()"
  output = "import { foo } from 'lib';\n\nfoo.fooMethod();"
  eq toJS(input), output

test "import a single member of a module as an alias, adding the alias to the current scope", ->
  input = "import { foo as bar } from 'lib'\nbar.barMethod()"
  output = "import { foo as bar } from 'lib';\n\nbar.barMethod();"
  eq toJS(input), output

test "import a multiple members of a module, adding the members to the current scope", ->
  input = "import { foo, bar } from 'lib'\nfoo.fooMethod()\nbar.barMethod()"
  output = "import { foo, bar } from 'lib';\n\nfoo.fooMethod();\n\nbar.barMethod();"
  eq toJS(input), output

test "import a multiple members of a module where some are aliased, adding the members or aliases to the current scope", ->
  input = "import { foo, bar as baz } from 'lib'\nfoo.fooMethod()\nbaz.bazMethod()"
  output = "import { foo, bar as baz } from 'lib';\n\nfoo.fooMethod();\n\nbaz.bazMethod();"
  eq toJS(input), output

test "import default member and other members of a module, adding the members to the current scope", ->
  input = "import foo, { bar, baz as qux } from 'lib'\nfoo.fooMethod()\nbar.barMethod()\nqux.quxMethod()"
  output = "import foo, { bar, baz as qux } from 'lib';\n\nfoo.fooMethod();\n\nbar.barMethod();\n\nqux.quxMethod();"
  eq toJS(input), output

test "import default member from a module as well as the entire module's contents as an alias, adding the member and alias to the current scope", ->
  input = "import foo, * as bar from 'lib'\nfoo.fooMethod()\nbar.barMethod()"
  output = "import foo, * as bar from 'lib';\n\nfoo.fooMethod();\n\nbar.barMethod();"
  eq toJS(input), output

test "multiline simple import", ->
  input = """import {
    foo,
    bar as baz
  } from 'lib'"""
  output = "import { foo, bar as baz } from 'lib';"

  eq toJS(input), output

test "multiline complex import", ->
  input = """import foo, {
      bar,
      baz as qux
    } from 'lib'"""
  output = "import foo, { bar, baz as qux } from 'lib';"

  eq toJS(input), output

# test "multiline simple import", ->
#   input = """import {
#       foo,
#       bar as baz
#     } from 'lib'"""
#   output = """import {
#       foo,
#       bar as baz
#     } from 'lib';"""
#   eq toJS(input), output

# test "multiline complex import", ->
#   input = """import foo, {
#       bar,
#       baz as qux
#     } from 'lib'"""
#   output = """import foo, {
#       bar,
#       baz as qux
#     } from 'lib';"""
#   eq toJS(input), output


# Export statements

test "export named members within an object", ->
  input = "export { foo, bar }"
  output = "export { foo, bar };"
  eq toJS(input), output

test "export named members as aliases, within an object", ->
  input = "export { foo as bar, baz as qux }"
  output = "export { foo as bar, baz as qux };"
  eq toJS(input), output

test "export default expression", ->
  input = "export default foo = 'bar'"
  output = "export default foo = 'bar';"
  eq toJS(input), output

test "export default function", ->
  input = "export default ->"
  output = "export default function() {};"
  eq toJS(input), output

test "export default multiline function", ->
  input = """
    export default (foo) ->
      console.log foo"""
  output = """
    export default function(foo) {
      return console.log(foo);
    };"""
  eq toJS(input), output

test "export default named member, within an object", ->
  input = "export { foo as default, bar }"
  output = "export { foo as default, bar };"
  eq toJS(input), output


# Import and export in the same statement

test "export an entire module's contents", ->
  input = "export * from 'lib'"
  output = "export * from 'lib';"
  eq toJS(input), output

test "export members imported from another module", ->
  input = "export { foo, bar } from 'lib'"
  output = "export { foo, bar } from 'lib';"
  eq toJS(input), output

test "export as aliases members imported from another module", ->
  input = "export { foo as bar, baz as qux } from 'lib'"
  output = "export { foo as bar, baz as qux } from 'lib';"
  eq toJS(input), output
