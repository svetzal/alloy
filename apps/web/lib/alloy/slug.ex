defmodule Alloy.Slug do
  @moduledoc """
  Derivation and validation of URL- and key-safe slugs.

  A slug is a lowercase identifier matching `~r/^[a-z0-9_-]+$/`, used as the
  human-readable key for projects and the local key for intent records. Slugs
  are stable and immutable once assigned; this module only handles *derivation*
  of a candidate slug from free text (e.g. a title) and *format validation*.
  Uniqueness and immutability live with the schemas that own the slug.
  """

  @format ~r/^[a-z0-9_-]+$/

  @doc """
  The regex every slug must match: lowercase alphanumerics, underscore, hyphen.
  """
  def format, do: @format

  @doc """
  Derives a slug from arbitrary text.

  Downcases, collapses any run of disallowed characters into a single
  underscore, and trims leading/trailing underscores. Returns `""` when `text`
  contains no slug-able characters.

      iex> Alloy.Slug.slugify("Stable Failure Semantics")
      "stable_failure_semantics"

      iex> Alloy.Slug.slugify("  Multiple   Spaces  ")
      "multiple_spaces"

      iex> Alloy.Slug.slugify("already-a-slug")
      "already-a-slug"
  """
  def slugify(text) when is_binary(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9_-]+/, "_")
    |> String.replace(~r/_+/, "_")
    |> String.trim("_")
  end

  def slugify(_), do: ""

  @doc """
  Returns `true` when `value` is a non-empty valid slug.
  """
  def valid?(value) when is_binary(value), do: Regex.match?(@format, value)
  def valid?(_), do: false
end
