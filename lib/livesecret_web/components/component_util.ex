defmodule LiveSecretWeb.ComponentUtil do
  def render_live_action(:admin, nil) do
    "Admin"
  end

  def render_live_action(:admin, true) do
    "Admin (Live)"
  end

  def render_live_action(:admin, false) do
    "Admin (Async)"
  end

  def render_live_action(:receiver, _) do
    "Recipient"
  end
end
