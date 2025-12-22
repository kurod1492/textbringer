require_relative "../test_helper"

class TestMinibufferHistory < Textbringer::TestCase
  def setup
    super
    MINIBUFFER_HISTORY.clear
  end

  def test_get_returns_empty_array_for_new_key
    assert_equal([], MinibufferHistory.get(:test))
  end

  def test_add_stores_value
    MinibufferHistory.add(:test, "value1")
    assert_equal(["value1"], MinibufferHistory.get(:test))
  end

  def test_add_prepends_to_list
    MinibufferHistory.add(:test, "value1")
    MinibufferHistory.add(:test, "value2")
    assert_equal(["value2", "value1"], MinibufferHistory.get(:test))
  end

  def test_add_ignores_nil
    MinibufferHistory.add(:test, nil)
    assert_equal([], MinibufferHistory.get(:test))
  end

  def test_add_ignores_empty_string
    MinibufferHistory.add(:test, "")
    assert_equal([], MinibufferHistory.get(:test))
  end

  def test_add_deletes_duplicates
    MinibufferHistory.add(:test, "value1")
    MinibufferHistory.add(:test, "value2")
    MinibufferHistory.add(:test, "value1")
    assert_equal(["value1", "value2"], MinibufferHistory.get(:test))
  end

  def test_add_respects_history_length
    original_length = CONFIG[:history_length]
    CONFIG[:history_length] = 3
    begin
      MinibufferHistory.add(:test, "value1")
      MinibufferHistory.add(:test, "value2")
      MinibufferHistory.add(:test, "value3")
      MinibufferHistory.add(:test, "value4")
      assert_equal(["value4", "value3", "value2"], MinibufferHistory.get(:test))
    ensure
      CONFIG[:history_length] = original_length
    end
  end

  def test_add_without_delete_duplicates
    original_setting = CONFIG[:history_delete_duplicates]
    CONFIG[:history_delete_duplicates] = false
    begin
      MinibufferHistory.add(:test, "value1")
      MinibufferHistory.add(:test, "value1")
      assert_equal(["value1", "value1"], MinibufferHistory.get(:test))
    ensure
      CONFIG[:history_delete_duplicates] = original_setting
    end
  end

  def test_separate_histories
    MinibufferHistory.add(:file, "file1")
    MinibufferHistory.add(:command, "cmd1")
    assert_equal(["file1"], MinibufferHistory.get(:file))
    assert_equal(["cmd1"], MinibufferHistory.get(:command))
  end
end
