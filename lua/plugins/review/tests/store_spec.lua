-- Тесты парсера/сериализатора хранилища замечаний.
-- Запуск: см. tests/run.sh
local store = require('plugins.review.store')

describe('store.encode_name', function()
  it('кодирует путь через __', function()
    assert.are.equal('src__app__main.py.md', store.encode_name('src/app/main.py'))
    assert.are.equal('main.py.md', store.encode_name('main.py'))
  end)
end)

describe('store.serialize + parse (round-trip)', function()
  local rf = {
    file = 'src/app/main.py',
    base = 'a1b2c3d',
    head = 'e4f5a6b',
    comments = {
      {
        line_start = 42,
        line_end = 42,
        quote = { 'if user.is_admin and not user.is_active:' },
        text = 'Условие дублирует проверку из check_access — вынести в одну функцию.',
      },
      {
        line_start = 57,
        line_end = 60,
        quote = { 'for item in items:', '    process(item)' },
        text = 'Нужен батчинг: process дёргает БД на каждой итерации.\n\nВторой абзац замечания.',
      },
    },
  }

  it('восстанавливает всё без потерь', function()
    local parsed, err = store.parse(store.serialize(rf))
    assert.is_nil(err)
    assert.are.equal(rf.file, parsed.file)
    assert.are.equal(rf.base, parsed.base)
    assert.are.equal(rf.head, parsed.head)
    assert.are.equal(2, #parsed.comments)
    for i, c in ipairs(rf.comments) do
      assert.are.equal(c.line_start, parsed.comments[i].line_start)
      assert.are.equal(c.line_end, parsed.comments[i].line_end)
      assert.are.same(c.quote, parsed.comments[i].quote)
      assert.are.equal(c.text, parsed.comments[i].text)
    end
  end)

  it('текст с > после первой строки текста не считается цитатой', function()
    local parsed = store.parse({
      '---',
      'file: a.py',
      'base: x',
      'head: y',
      '---',
      '',
      '## L1',
      '> code',
      'текст',
      '> это часть текста',
    })
    assert.are.same({ 'code' }, parsed.comments[1].quote)
    assert.are.equal('текст\n> это часть текста', parsed.comments[1].text)
  end)

  it('ошибка без frontmatter', function()
    local parsed, err = store.parse({ '## L1', 'текст' })
    assert.is_nil(parsed)
    assert.is_not_nil(err)
  end)
end)

describe('store.save/load', function()
  local tmp = vim.fn.tempname()

  it('создаёт, читает и удаляет файл замечаний', function()
    vim.fn.mkdir(tmp, 'p')
    local rf = {
      file = 'src/main.py',
      base = 'aaa',
      head = 'bbb',
      comments = { { line_start = 1, line_end = 1, quote = { 'x = 1' }, text = 'замечание' } },
    }
    store.save(tmp, rf)
    assert.are.equal(1, vim.fn.filereadable(tmp .. '/.review/src__main.py.md'))

    local loaded = store.load(tmp, 'src/main.py')
    assert.are.equal('замечание', loaded.comments[1].text)

    local all = store.load_all(tmp)
    assert.is_not_nil(all['src/main.py'])

    rf.comments = {}
    store.save(tmp, rf)
    assert.are.equal(0, vim.fn.filereadable(tmp .. '/.review/src__main.py.md'))
    assert.are.equal(0, vim.fn.isdirectory(tmp .. '/.review'))
  end)
end)
