defmodule Alloy.Projects.ApiToken do
  @moduledoc """
  A per-project API token authenticating CLI/HTTP access to the JSON API.

  Tokens are bearer secrets: the plaintext (`alloy_<random>`) is generated once,
  returned to the operator to paste into `.alloy_env`, and never stored. Only a
  SHA-256 hash of the secret is persisted, so the database never holds a usable
  credential. Authentication hashes the presented bearer token and looks up the
  matching row.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Alloy.Projects.Project

  # The plaintext secret is `@prefix` followed by this many URL-safe random
  # bytes (base64, unpadded). 32 bytes ≈ 256 bits of entropy.
  @prefix "alloy_"
  @secret_bytes 32

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "api_tokens" do
    field :name, :string
    field :token_hash, :string
    field :last_used_at, :utc_datetime_usec

    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Builds a changeset for an API token. `name` is required; `token_hash` is set
  by the context from a freshly generated secret, not cast from user input.
  """
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
  end

  @doc """
  Generates a fresh plaintext bearer secret (`alloy_<random>`).

  This is the only time the secret exists in usable form — the caller must
  return it to the operator and store only its `hash/1`.
  """
  def generate_secret do
    @prefix <> Base.url_encode64(:crypto.strong_rand_bytes(@secret_bytes), padding: false)
  end

  @doc """
  Hashes a plaintext secret to the value stored in `token_hash` (lowercase hex
  SHA-256). Deterministic, so authentication can look a token up by its hash.
  """
  def hash(secret) when is_binary(secret) do
    :crypto.hash(:sha256, secret) |> Base.encode16(case: :lower)
  end
end
