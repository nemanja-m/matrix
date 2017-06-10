# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :matrix, Matrix.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RNRHpszwzV702jRsKlnZbqME0hfnEPtzMBXpT0Y85IecXkJq2+tVFcUx18mUPdP4",
  render_errors: [view: Matrix.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Matrix.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :matrix, :master_node, System.get_env["MASTER"] || "true"
config :matrix, :master_node_url, System.get_env["MASTER_URL"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
