defmodule Alloy.SlugTest do
  use ExUnit.Case, async: true

  doctest Alloy.Slug

  alias Alloy.Slug

  describe "slugify/1" do
    test "downcases and underscores whitespace" do
      assert Slug.slugify("Stable Failure Semantics") == "stable_failure_semantics"
    end

    test "drops punctuation" do
      assert Slug.slugify("Stable, Failure! Semantics?") == "stable_failure_semantics"
    end

    test "collapses repeated separators" do
      assert Slug.slugify("  Multiple   Spaces  ") == "multiple_spaces"
    end

    test "preserves existing slugs" do
      assert Slug.slugify("already-a-slug") == "already-a-slug"
      assert Slug.slugify("already_a_slug") == "already_a_slug"
    end

    test "returns empty string for text with no slug-able characters" do
      assert Slug.slugify("!!!") == ""
      assert Slug.slugify("") == ""
    end

    test "returns empty string for non-binaries" do
      assert Slug.slugify(nil) == ""
      assert Slug.slugify(123) == ""
    end
  end

  describe "valid?/1" do
    test "accepts valid slugs" do
      assert Slug.valid?("alloy")
      assert Slug.valid?("epilogue_tracker")
      assert Slug.valid?("a-b-c")
      assert Slug.valid?("v1")
    end

    test "rejects invalid slugs" do
      refute Slug.valid?("Has Caps")
      refute Slug.valid?("with space")
      refute Slug.valid?("punct!")
      refute Slug.valid?("")
      refute Slug.valid?(nil)
    end
  end
end
