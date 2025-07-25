require_relative "../../test_helper"

class TestBuffers < Textbringer::TestCase
  def test_forward_char
    insert("hello world")
    beginning_of_buffer
    forward_char(3)
    assert_equal(3, Buffer.current.point)
  end

  def test_backward_char
    insert("hello world")
    backward_char(6)
    assert_equal(5, Buffer.current.point)
  end

  def test_forward_word
    insert("hello world")
    beginning_of_buffer
    forward_word
    assert_equal(5, Buffer.current.point)
  end

  def test_backward_word
    insert("hello world")
    backward_word
    assert_equal(6, Buffer.current.point)
  end

  def test_next_line
    insert("foo\nbar\nbaz\n")
    beginning_of_buffer
    next_line
    assert_equal(2, Buffer.current.current_line)
    assert_equal(1, Buffer.current.current_column)
  end

  def test_previous_line
    insert("foo\nbar\nbaz\n")
    previous_line
    assert_equal(3, Buffer.current.current_line)
    assert_equal(1, Buffer.current.current_column)
  end

  def test_delete_char
    insert("foo")
    beginning_of_buffer
    delete_char
    assert_equal("oo", Buffer.current.to_s)
  end

  def test_backward_delete_char
    insert("foo")
    backward_delete_char
    assert_equal("fo", Buffer.current.to_s)
  end

  def test_push_mark
    insert("foo")
    push_mark
    insert("bar")
    assert_equal(3, Buffer.current.mark)
  end

  def test_pop_mark
    insert("foo")
    push_mark
    insert("bar")
    push_mark
    insert("baz")
    pop_mark
    assert_equal(3, Buffer.current.mark)
    assert_equal(9, Buffer.current.point)
  end

  def test_pop_to_mark
    insert("foo")
    push_mark
    insert("bar")
    push_mark
    insert("baz")
    pop_to_mark
    assert_equal(3, Buffer.current.mark)
    assert_equal(6, Buffer.current.point)
  end

  def test_exchange_point_and_mark
    insert("foo")
    push_mark
    insert("bar")
    exchange_point_and_mark
    assert_equal(6, Buffer.current.mark)
    assert_equal(3, Buffer.current.point)
  end

  def test_kill_region
    insert("foo")
    set_mark_command
    insert("bar")
    kill_region
    assert_equal("foo", Buffer.current.to_s)
  end

  def test_self_insert
    Controller.current.last_key = "a"
    self_insert
    assert_equal("a", Buffer.current.to_s)
    Controller.current.last_key = "x"
    self_insert(10)
    assert_equal("axxxxxxxxxx", Buffer.current.to_s)
    undo
    assert_equal("a", Buffer.current.to_s)
  end

  def test_quoted_insert
    push_keys("\C-v")
    quoted_insert
    assert_equal("\C-v", Buffer.current.to_s)

    push_keys("\C-l")
    quoted_insert(3)
    assert_equal("\C-v\C-l\C-l\C-l", Buffer.current.to_s)

    push_keys([Curses::KEY_LEFT])
    assert_raise(EditorError) do
      quoted_insert
    end
  end

  def test_yank_pop
    assert_raise(EditorError) do
      yank_pop
    end
    insert("foo\n")
    insert("bar\n")
    insert("baz\n")
    beginning_of_buffer
    kill_line
    next_line
    kill_line
    next_line
    kill_line
    yank
    assert_equal("\n\nbaz\n", Buffer.current.to_s)
    Controller.current.last_command = :yank
    yank_pop
    assert_equal("\n\nbar\n", Buffer.current.to_s)
    yank_pop
    assert_equal("\n\nfoo\n", Buffer.current.to_s)
    yank_pop
    assert_equal("\n\nbaz\n", Buffer.current.to_s)
  end

  def test_undo
    insert("foo\n")
    beginning_of_buffer
    insert("bar\n")
    assert_equal("bar\nfoo\n", Buffer.current.to_s)
    undo
    assert_equal("foo\n", Buffer.current.to_s)
    undo
    assert_equal("", Buffer.current.to_s)
    redo_command
    assert_equal("foo\n", Buffer.current.to_s)
    redo_command
    assert_equal("bar\nfoo\n", Buffer.current.to_s)
  end

  def test_back_to_indentation
    buffer = Buffer.current
    insert(<<EOF)
int
main()
{
    if (1) {
	if (0) {
\t    return 0;
EOF
    buffer.backward_line
    assert_equal(6, buffer.current_line)
    assert_equal(1, buffer.current_column)
    back_to_indentation
    assert_equal(6, buffer.current_line)
    assert_equal(6, buffer.current_column)
    backward_char(3)
    back_to_indentation
    assert_equal(6, buffer.current_line)
    assert_equal(6, buffer.current_column)
    end_of_line
    back_to_indentation
    assert_equal(6, buffer.current_line)
    assert_equal(6, buffer.current_column)
    forward_char(3)
    back_to_indentation
    assert_equal(6, buffer.current_line)
    assert_equal(6, buffer.current_column)
    end_of_buffer
    back_to_indentation
    assert_equal(7, buffer.current_line)
    assert_equal(1, buffer.current_column)
  end

  def test_delete_indentation
    buffer = Buffer.current
    insert(<<EOF)
foo(bar,
    baz)
EOF
    buffer.backward_line
    delete_indentation
    assert_equal(<<EOF, buffer.to_s)
foo(bar, baz)
EOF
    assert_equal(8, buffer.point)
    delete_indentation
    assert_equal(<<EOF, buffer.to_s)
foo(bar, baz)
EOF
    assert_equal(true, buffer.beginning_of_buffer?)
  end

  def test_open_line
    insert("foo")
    open_line
    insert("bar")
    assert_equal("foobar\n", Buffer.current.to_s)
    assert_equal(6, Buffer.current.point)
  end

  def test_delete_region
    insert("foo")
    set_mark_command
    insert("barbaz")
    backward_char(3)
    delete_region
    assert_equal("foobaz", Buffer.current.to_s)
  end

  def test_transpose_chars
    insert("retrun")
    backward_char(2)
    transpose_chars
    assert_equal("return", Buffer.current.to_s)
  end

  def test_set_mark_command
    set_mark_command
    insert("foo\n")
    set_mark_command
    insert("bar\n")
    set_mark_command(true)
    assert_equal(4, Buffer.current.point)
    set_mark_command(true)
    assert_equal(0, Buffer.current.point)
  end

  def test_mark_whole_buffer
    insert("foo\nbar\n")
    Buffer.current.backward_line
    mark_whole_buffer
    assert_equal(Buffer.current.point_min, Buffer.current.point)
    assert_equal(Buffer.current.point_max, Buffer.current.mark)
  end

  def test_zap_to_char
    insert("foo:bar:baz")
    beginning_of_buffer
    zap_to_char(?:, count: 2)
    assert_equal("baz", Buffer.current.to_s)
    end_of_buffer
    insert(":quux:quuux:quuuux")
    zap_to_char(?:, count: -2)
    assert_equal("baz:quux", Buffer.current.to_s)
  end


  def test_downcase_word
    insert(" AAA")
    beginning_of_buffer
    downcase_word
    assert_equal(" aaa", Buffer.current.to_s)
    assert_equal(4, Buffer.current.point)
  end

  def test_upcase_word
    insert(" aaa")
    beginning_of_buffer
    upcase_word
    assert_equal(" AAA", Buffer.current.to_s)
    assert_equal(4, Buffer.current.point)
  end

  def test_capitalize_word
    insert(" ccc")
    beginning_of_buffer
    capitalize_word
    assert_equal(" Ccc", Buffer.current.to_s)
    assert_equal(4, Buffer.current.point)
  end

  def test_insert_char
    insert_char("feff")
    assert_equal("\u{feff}", Buffer.current.to_s)
    assert_equal(3, Buffer.current.point)
    insert_char("200b", 3)
    assert_equal("\u{feff}\u{200b}\u{200b}\u{200b}", Buffer.current.to_s)
    assert_equal(12, Buffer.current.point)
  end

  def test_read_only_mode
    assert_equal(false, Buffer.current.read_only?)
    read_only_mode
    assert_equal(true, Buffer.current.read_only?)
    assert_raise(ReadOnlyError) do
      insert("hello")
    end
    read_only_mode
    assert_equal(false, Buffer.current.read_only?)
    insert("hello")
    assert_equal("hello", Buffer.current.to_s)
    assert_equal(true, Buffer.current.modified?)
    read_only_mode
    assert_equal(true, Buffer.current.read_only?)
    assert_equal(true, Buffer.current.modified?)
  end
end
