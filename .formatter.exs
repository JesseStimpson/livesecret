[
  plugins: [Phoenix.LiveView.HTMLFormatter],
  import_deps: [:ecto, :phoenix],

  # The Phoenix.LiveView.HTMLFormatter imposes a change to the live_flash button compontents
  # in live.html.heex that renders as a material difference on the page. The newlines inserted
  # by the formatter cause an empty flash to be rendered as a visible in by the browser. To avoid
  # this, we've modified our formatter to ignore this specific file.
  inputs:
    Enum.flat_map(
      ["*.{heex,ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{heex,ex,exs}"],
      &Path.wildcard(&1, match_dot: true)
    ) -- ["lib/livesecret_web/templates/layout/live.html.heex"],
  subdirectories: ["priv/*/migrations"]
]
