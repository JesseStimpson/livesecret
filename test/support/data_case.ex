defmodule LiveSecret.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use LiveSecret.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias LiveSecret.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import LiveSecret.DataCase

      @valid_presecret_attrs %{
        "burn_key" => "exunit-burnkey",
        "content" => :base64.encode("encrypted-content-here"),
        "iv" => :base64.encode(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1>>),
        "duration" => "1h",
        "mode" => "live"
      }

      @preexpired_presecret_attrs %{
        "burn_key" => "exunit-burnkey",
        "content" => :base64.encode("encrypted-content-here"),
        "iv" => :base64.encode(<<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1>>),
        "duration" => "-1h",
        "mode" => "live"
      }

      @invalid_presecret_attrs %{
        "burn_key" => nil,
        "content" => nil,
        "iv" => nil,
        "duration" => nil,
        "mode" => nil
      }
    end
  end

  setup tags do
    LiveSecret.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(LiveSecret.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
