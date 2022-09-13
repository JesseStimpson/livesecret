defmodule LiveSecret.OperationalKey do
  use Puid, chars: :safe32, total: 1.0e5, risk: 1.0e12
end
