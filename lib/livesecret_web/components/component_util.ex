defmodule LiveSecretWeb.ComponentUtil do
  def render_live_action(:admin) do
    "Admin"
  end

  def render_live_action(:receiver) do
    "Recipient"
  end
end
