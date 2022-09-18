defmodule LiveSecret.DoTest do
  use LiveSecret.DataCase
  alias LiveSecret.{Secret, Do}

  test "create secret" do
    attrs = @valid_presecret_attrs
    changeset = Do.validate_presecret(attrs)
    assert changeset.valid?
    %Secret{id: id} = Do.insert!(attrs)
    %Secret{} = Do.get_secret!(id)
  end

  test "reject invalid secret" do
    attrs = @invalid_presecret_attrs
    changeset = Do.validate_presecret(attrs)
    refute changeset.valid?

    assert_raise(
      FunctionClauseError,
      fn -> Do.insert!(attrs) end
    )
  end

  test "burn secret" do
    secret = Do.insert!(@valid_presecret_attrs)
    %Secret{iv: nil, content: nil} = Do.burn!(secret)
  end

  test "change live state" do
    %Secret{id: id} = Do.insert!(@valid_presecret_attrs)
    %Secret{live?: true} = Do.go_live!(id)
    %Secret{live?: false} = Do.go_async!(id)
  end
end
