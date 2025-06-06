require "minitest/autorun"

class DottedKeysMergeTest < Minitest::Test
  def test_dotted_keys_merge
    toml = <<~TOML
      [tool.ruff]
      target-version = "py310"
      line-length = 88
      exclude = [ ".git", ".mypy_cache", ".pytest_cache", ".venv", "__pycache__" ]
      lint.select = ["B", "C4", "E", "F", "FAST", "I", "N", "RUF", "T20", "UP", "W"]
      lint.ignore = ["B008", "C901", "RUF012", "RUF029", "UP007"]
      lint.exclude = ["*.ipynb"]
      lint.per-file-ignores = { "__init__.py" = ["F401"], "migrations/versions/*.py" = ["E501", "W291"] }
      lint.preview = true
    TOML
    parsed = TomlRB.parse(toml)
    assert_equal "py310", parsed["tool"]["ruff"]["target-version"]
    assert_equal 88, parsed["tool"]["ruff"]["line-length"]
    assert_equal [".git", ".mypy_cache", ".pytest_cache", ".venv", "__pycache__"], parsed["tool"]["ruff"]["exclude"]
    assert_equal ["B", "C4", "E", "F", "FAST", "I", "N", "RUF", "T20", "UP", "W"], parsed["tool"]["ruff"]["lint"]["select"]
    assert_equal ["B008", "C901", "RUF012", "RUF029", "UP007"], parsed["tool"]["ruff"]["lint"]["ignore"]
    assert_equal ["*.ipynb"], parsed["tool"]["ruff"]["lint"]["exclude"]
    assert_equal({"__init__.py" => ["F401"], "migrations/versions/*.py" => ["E501", "W291"]}, parsed["tool"]["ruff"]["lint"]["per-file-ignores"])
    assert_equal true, parsed["tool"]["ruff"]["lint"]["preview"]
  end

  def test_duplicate_key_error
    toml = "a.b = 1\na.b = 2"
    assert_raises(TomlRB::ValueOverwriteError) { TomlRB.parse(toml) }
  end
end
