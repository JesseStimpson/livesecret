defmodule LiveSecret.Do do
  alias LiveSecret.{Repo, Secret, Presecret}
  import Ecto.Query, only: [from: 2]

  def count_secrets() do
    Repo.aggregate(from(_s in Secret, []), :count, :id)
  end

  @doc """
  Reads secret with id or throws
  """
  def get_secret!(id) do
    Repo.get!(Secret, id)
  end

  @doc """
  Reads secret with id or returns error
  """
  def get_secret(id) do
    Repo.get(Secret, id)
  end

  @doc """
  Inserts secret or throws

  `presecret_attrs` is a map of attrs from the Presecret struct. We
  transform this into fields on the Secret. Easier to send base64 to
  to the browser with Presecret and store raw binary in the Secret.
  """
  def insert!(presecret_attrs) do
    attrs = Presecret.make_secret_attrs(presecret_attrs)

    Secret.new()
    |> Secret.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Returns a changeset with validated fields (or not) from Presecret attrs
  """
  def validate_presecret(presecret_attrs) do
    %Presecret{}
    |> Presecret.changeset(presecret_attrs)
    |> Map.put(:action, :validate)
  end

  @doc """
  Burns a secret or throws

  Burned secrets have no iv and no ciphertext
  """
  def burn!(secret) do
    burned_at = NaiveDateTime.utc_now()

    secret
    |> Secret.changeset(%{
      iv: nil,
      burned_at: burned_at,
      content: nil
    })
    |> Repo.update!()
  end

  @doc """
  Updates a secret to be in live mode
  """
  def go_live!(id) do
    Repo.get!(Secret, id)
    |> Secret.changeset(%{
      live?: true
    })
    |> Repo.update!()
  end

  @doc """
  Updates a secret to be in async mode
  """
  def go_async!(id) do
    Repo.get!(Secret, id)
    |> Secret.changeset(%{
      live?: false
    })
    |> Repo.update!()
  end
end
