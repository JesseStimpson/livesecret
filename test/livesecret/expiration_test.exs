defmodule LiveSecret.ExpirationTest do
  use LiveSecret.DataCase

  alias LiveSecret.{Do, Expiration}

  test "everything *can be* expired" do
    0 = Do.count_secrets()
    Do.insert!(@valid_presecret_attrs)
    1 = Do.count_secrets()
    Expiration.expire_all()
    0 = Do.count_secrets()
  end

  test "not everything *is* expired" do
    0 = Do.count_secrets()
    Do.insert!(@preexpired_presecret_attrs)
    Do.insert!(@valid_presecret_attrs)
    2 = Do.count_secrets()
    Expiration.expire()
    1 = Do.count_secrets()
  end
end
