import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :my_ash_blog, MyAshBlog.Repo,
  username: "postgres",
  password: "badcoffe",
  database: "my_ash_blog_test",
  hostname: "localhost",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :my_ash_blog, MyAshBlogWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "guV7SLv2WGFYi07wZBCMZMDv6JbGp7GaOZE3ta49YRhjXI7nYdpi2WMudWwhda8x",
  server: false

# In test we don't send emails
config :my_ash_blog, MyAshBlog.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :bcrypt_elixir, log_rounds: 4
