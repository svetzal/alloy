defmodule Alloy.Projects do
  @moduledoc """
  The Projects context: the top-level containers that scope engineering intent.

  This context owns all persistence for `Alloy.Projects.Project`. The web layer
  delegates here; it never builds Ecto queries directly.
  """

  import Ecto.Query, warn: false

  alias Alloy.Projects.ApiToken
  alias Alloy.Projects.Project
  alias Alloy.Repo

  @doc """
  Returns all projects, alphabetically by name.
  """
  def list_projects do
    Repo.all(from p in Project, order_by: [asc: p.name, asc: p.id])
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the project does not exist.
  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Gets a single project by its key, or `nil` if none matches.
  """
  def get_project_by_key(key), do: Repo.get_by(Project, key: key)

  @doc """
  Gets a single project by its key.

  Raises `Ecto.NoResultsError` if no project has that key.
  """
  def get_project_by_key!(key), do: Repo.get_by!(Project, key: key)

  @doc """
  Creates a project.
  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project's mutable fields. The `key` is immutable.
  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.
  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  ## API tokens

  @doc """
  Lists a project's API tokens, most recently created first.

  Only metadata is returned — the plaintext secret is never stored, so it cannot
  be listed.
  """
  def list_api_tokens(%Project{} = project) do
    Repo.all(
      from t in ApiToken,
        where: t.project_id == ^project.id,
        order_by: [desc: t.inserted_at, desc: t.id]
    )
  end

  @doc """
  Mints a new API token for a project.

  Returns `{:ok, token, secret}` where `secret` is the one-time plaintext bearer
  string to hand to the operator; only its hash is persisted. Returns
  `{:error, changeset}` if the token metadata is invalid.
  """
  def create_api_token(%Project{} = project, attrs \\ %{}) do
    secret = ApiToken.generate_secret()

    result =
      project
      |> Ecto.build_assoc(:api_tokens, token_hash: ApiToken.hash(secret))
      |> ApiToken.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, token} -> {:ok, token, secret}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deletes (revokes) an API token.
  """
  def delete_api_token(%ApiToken{} = token), do: Repo.delete(token)

  @doc """
  Returns a changeset for an API token (e.g. to drive the mint-token form).
  """
  def change_api_token(token \\ %ApiToken{}, attrs \\ %{}) do
    ApiToken.changeset(token, attrs)
  end

  @doc """
  Authenticates a plaintext bearer `secret`, returning the owning project (with
  the matching token) or `nil`.

  On a match, the token's `last_used_at` is touched. Lookup is by hash, so the
  plaintext is never compared against stored data directly.
  """
  def authenticate_token(secret) when is_binary(secret) do
    hash = ApiToken.hash(secret)

    case Repo.one(from t in ApiToken, where: t.token_hash == ^hash, preload: [:project]) do
      nil ->
        nil

      %ApiToken{} = token ->
        touch_api_token(token)
        token.project
    end
  end

  def authenticate_token(_), do: nil

  defp touch_api_token(%ApiToken{} = token) do
    token
    |> Ecto.Changeset.change(last_used_at: DateTime.utc_now())
    |> Repo.update()
  end

  @doc """
  Returns a changeset for tracking project changes (e.g. to drive a form).

  Picks the create or update changeset based on whether the project is already
  persisted, so the `key` field is editable only for new projects.
  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    if Ecto.get_meta(project, :state) == :loaded do
      Project.update_changeset(project, attrs)
    else
      Project.create_changeset(project, attrs)
    end
  end
end
