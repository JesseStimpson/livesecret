import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :livesecret, LiveSecret.Repo,
  database: Path.expand("../livesecret_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :livesecret, LiveSecretWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "RDekpi/uUZ0ZuKQ84ARGndoiHw9OBfrLb+yz6JycX2kN3yeZWc9NkI7f055Pepuo",
  server: false

config :livesecret, LiveSecret.Expiration, interval: :timer.seconds(20)

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
