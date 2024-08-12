local ls = require("luasnip")
ls.snippets = {
  python = {
    ls.snippet("func", {
      ls.text_node("def "),
      ls.insert_node(1, "method_name"),
      ls.text_node("(self, "),
      ls.insert_node(2, "args"),
      ls.text_node("):"),
      ls.insert_node(0, "pass"),
    }),
  },
}

print('Loaded python snippets')
