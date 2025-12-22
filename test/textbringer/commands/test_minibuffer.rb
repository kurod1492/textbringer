require_relative "../../test_helper"

class TestMinibuffer < Textbringer::TestCase
  def setup
    super
    MINIBUFFER_HISTORY.clear
  end

  def test_read_from_minibuffer_with_symbol_history
    push_keys("value1\n")
    read_from_minibuffer("Input: ", history: :test)
    assert_equal(["value1"], MinibufferHistory.get(:test))

    push_keys("value2\n")
    read_from_minibuffer("Input: ", history: :test)
    assert_equal(["value2", "value1"], MinibufferHistory.get(:test))
  end

  def test_read_from_minibuffer_with_array_history
    history = ["item1", "item2", "item3"]
    push_keys("\ep\n")
    result = read_from_minibuffer("Input: ", history: history)
    assert_equal("item1", result)
  end

  def test_previous_history_element
    history = ["item1", "item2", "item3"]
    push_keys("\ep\ep\n")
    result = read_from_minibuffer("Input: ", history: history)
    assert_equal("item2", result)
  end

  def test_next_history_element
    history = ["item1", "item2", "item3"]
    push_keys("\ep\ep\en\n")
    result = read_from_minibuffer("Input: ", history: history)
    assert_equal("item1", result)
  end

  def test_history_preserves_input
    history = ["item1", "item2"]
    push_keys("typed\ep\en\n")
    result = read_from_minibuffer("Input: ", history: history)
    assert_equal("typed", result)
  end

  def test_previous_history_at_beginning
    history = ["item1"]
    # M-p twice but only one item, second M-p shows error but stays at item1
    push_keys("\ep\ep\n")
    result = read_from_minibuffer("Input: ", history: history)
    assert_equal("item1", result)
  end

  def test_read_file_name_uses_file_history
    push_keys("test.rb\n")
    read_file_name("File: ")
    # History stores the input as typed, not expanded
    assert_equal(["test.rb"], MinibufferHistory.get(:file))
  end

  def test_read_buffer_uses_buffer_history
    push_keys("*scratch*\n")
    read_buffer("Buffer: ")
    assert_equal(["*scratch*"], MinibufferHistory.get(:buffer))
  end

  def test_read_command_name_uses_command_history
    push_keys("forward_char\n")
    read_command_name("M-x ")
    assert_equal(["forward_char"], MinibufferHistory.get(:command))
  end
end
