defmodule Alloy.MixProject do
  use Mix.Project

  def project do
    [
      app: :alloy,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      dialyzer: dialyzer(),
      docs: docs(),
      test_coverage: test_coverage()
    ]
  end

  # Test coverage configuration.
  #
  # The scaffold is mostly generated framework boilerplate with no domain
  # behaviour yet, so the bootstrap threshold is intentionally low. RAISE
  # THIS as real Alloy domain code (intent records, briefs, feedback)
  # lands — the functional core should sit comfortably above 90%.
  #
  # Generated, behaviour-free modules are excluded so the number reflects
  # code we actually own and test.
  defp test_coverage do
    [
      summary: [threshold: 30],
      ignore_modules: [
        Alloy.Application,
        Alloy.Mailer,
        Alloy.Repo,
        AlloyWeb,
        AlloyWeb.Endpoint,
        AlloyWeb.Gettext,
        AlloyWeb.Layouts,
        AlloyWeb.Telemetry,
        AlloyWeb.CoreComponents,
        AlloyWeb.ErrorHTML,
        AlloyWeb.ErrorJSON,
        ~r/AlloyWeb\.Layouts\..*/
      ]
    ]
  end

  # Dialyzer configuration. The PLT is cached under priv/plts so CI can
  # restore it between runs (priv/plts is git-ignored).
  defp dialyzer do
    [
      plt_local_path: "priv/plts",
      plt_core_path: "priv/plts",
      plt_add_apps: [:ex_unit, :mix],
      flags: [:error_handling, :extra_return, :missing_return, :unmatched_returns]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_url: "https://github.com/mojility/alloy"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Alloy.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test, quality: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.0"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},

      # Quality tooling
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind alloy", "esbuild alloy"],
      "assets.deploy": [
        "tailwind alloy --minify",
        "esbuild alloy --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"],
      # Full quality gate. Run before pushing / merging to main.
      # `mix dialyzer` and `mix deps.audit` are run separately so a slow
      # PLT build or a network-dependent audit does not block fast feedback.
      quality: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict",
        "sobelow --config",
        "test"
      ]
    ]
  end
end
